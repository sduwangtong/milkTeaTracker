//
//  AdManager.swift
//  milkTeaTracker
//
//  Manages Google AdMob ads and in-app purchase for ad removal.
//

import Foundation
import SwiftUI
import AppTrackingTransparency
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

/// Manager for handling ads and ad-free purchases
@Observable
@MainActor
final class AdManager {
    
    // MARK: - Singleton
    
    static let shared = AdManager()
    
    // MARK: - Properties
    
    /// Whether ads should be shown (false if user purchased ad removal)
    private(set) var isAdsEnabled: Bool = true
    
    /// Whether the SDK has been initialized
    private(set) var isInitialized: Bool = false
    
    /// Whether ad removal has been purchased
    private(set) var hasRemovedAds: Bool = false
    
    /// Current tracking authorization status
    private(set) var trackingAuthorizationStatus: ATTrackingManager.AuthorizationStatus = .notDetermined
    
    // MARK: - Private Properties
    
    private let adRemovalKey = "com.milkTeaTracker.adRemovalPurchased"
    
    // MARK: - Initialization
    
    private init() {
        loadPurchaseStatus()
        trackingAuthorizationStatus = ATTrackingManager.trackingAuthorizationStatus
    }
    
    // MARK: - Public Methods
    
    /// Request App Tracking Transparency authorization
    /// Should be called before initializing ads
    func requestTrackingAuthorization() async -> ATTrackingManager.AuthorizationStatus {
        // Check current status first
        let currentStatus = ATTrackingManager.trackingAuthorizationStatus
        
        // Only request if not determined yet
        if currentStatus == .notDetermined {
            let status = await ATTrackingManager.requestTrackingAuthorization()
            trackingAuthorizationStatus = status
            #if DEBUG
            print("[AdManager] ATT authorization status: \(status.rawValue)")
            #endif
            return status
        }
        
        trackingAuthorizationStatus = currentStatus
        #if DEBUG
        print("[AdManager] ATT already determined: \(currentStatus.rawValue)")
        #endif
        return currentStatus
    }
    
    /// Initialize the Google Mobile Ads SDK
    /// This should be called after ATT authorization is handled
    func initializeSDK() {
        guard !isInitialized else { return }
        
        #if canImport(GoogleMobileAds)
        Task {
            do {
                try await MobileAds.shared.start()
                await MainActor.run {
                    self.isInitialized = true
                    #if DEBUG
                    print("[AdManager] Google Mobile Ads SDK initialized")
                    #endif
                }
            } catch {
                #if DEBUG
                print("[AdManager] Failed to initialize SDK: \(error)")
                #endif
            }
        }
        #else
        #if DEBUG
        print("[AdManager] GoogleMobileAds SDK not available")
        #endif
        isInitialized = true
        #endif
    }
    
    /// Request ATT authorization and then initialize the SDK
    func requestTrackingAndInitialize() async {
        // Request tracking authorization first
        _ = await requestTrackingAuthorization()
        
        // Then initialize the SDK (works regardless of ATT status)
        initializeSDK()
    }
    
    /// Record that the user purchased ad removal
    func purchaseAdRemoval() {
        hasRemovedAds = true
        isAdsEnabled = false
        UserDefaults.standard.set(true, forKey: adRemovalKey)
        #if DEBUG
        print("[AdManager] Ad removal purchased - ads disabled")
        #endif
    }
    
    /// Restore ad removal purchase (for app reinstall)
    func restorePurchase() {
        // In a real implementation, this would verify with StoreKit
        // For now, just check UserDefaults
        loadPurchaseStatus()
    }
    
    /// Check if ads should be shown for the current user
    func shouldShowAds() -> Bool {
        return isAdsEnabled && !hasRemovedAds && FeatureFlags.showAds
    }
    
    // MARK: - Private Methods
    
    private func loadPurchaseStatus() {
        hasRemovedAds = UserDefaults.standard.bool(forKey: adRemovalKey)
        isAdsEnabled = !hasRemovedAds
    }
}

// MARK: - Ad Unit IDs

extension AdManager {
    /// Get the banner ad unit ID (test in debug, production in release)
    var bannerAdUnitID: String {
        return AuthConfig.currentBannerAdUnitID
    }
}

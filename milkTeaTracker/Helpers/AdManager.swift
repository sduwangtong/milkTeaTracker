//
//  AdManager.swift
//  milkTeaTracker
//
//  Manages Google AdMob ads and in-app purchase for ad removal.
//

import Foundation
import SwiftUI
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
    
    // MARK: - Private Properties
    
    private let adRemovalKey = "com.milkTeaTracker.adRemovalPurchased"
    
    // MARK: - Initialization
    
    private init() {
        loadPurchaseStatus()
    }
    
    // MARK: - Public Methods
    
    /// Initialize the Google Mobile Ads SDK
    func initializeSDK() {
        guard !isInitialized else { return }
        
        #if canImport(GoogleMobileAds)
        Task {
            do {
                try await MobileAds.shared.start()
                await MainActor.run {
                    self.isInitialized = true
                    print("[AdManager] Google Mobile Ads SDK initialized")
                }
            } catch {
                print("[AdManager] Failed to initialize SDK: \(error)")
            }
        }
        #else
        print("[AdManager] GoogleMobileAds SDK not available")
        isInitialized = true
        #endif
    }
    
    /// Record that the user purchased ad removal
    func purchaseAdRemoval() {
        hasRemovedAds = true
        isAdsEnabled = false
        UserDefaults.standard.set(true, forKey: adRemovalKey)
        print("[AdManager] Ad removal purchased - ads disabled")
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

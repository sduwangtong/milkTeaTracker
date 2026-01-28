//
//  ConsentManager.swift
//  milkTeaTracker
//
//  Manages GDPR consent using Google's User Messaging Platform (UMP) SDK.
//  Required for apps that show personalized ads to users in the EU/EEA.
//

import Foundation
import SwiftUI
#if canImport(UserMessagingPlatform)
import UserMessagingPlatform
#endif

/// Manager for handling GDPR consent using Google UMP SDK
@Observable
@MainActor
final class ConsentManager {
    
    // MARK: - Singleton
    
    static let shared = ConsentManager()
    
    // MARK: - Properties
    
    /// Whether consent has been gathered
    private(set) var hasConsent: Bool = false
    
    /// Whether the user can see personalized ads
    private(set) var canShowPersonalizedAds: Bool = false
    
    /// Whether consent is required (user is in EU/EEA)
    private(set) var isConsentRequired: Bool = false
    
    /// Whether consent form is available to show
    private(set) var isFormAvailable: Bool = false
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Request consent information and load form if available
    /// Should be called early in the app lifecycle
    func requestConsentInfoUpdate() async {
        #if canImport(UserMessagingPlatform)
        // Create request parameters
        let parameters = RequestParameters()
        
        // For testing, you can force a geography for debugging:
        // let debugSettings = DebugSettings()
        // debugSettings.testDeviceIdentifiers = ["YOUR_TEST_DEVICE_ID"]
        // debugSettings.geography = .EEA
        // parameters.debugSettings = debugSettings
        
        // Request consent info update
        do {
            try await ConsentInformation.shared.requestConsentInfoUpdate(with: parameters)
            
            // Check if a form is available
            isFormAvailable = ConsentInformation.shared.formStatus == .available
            isConsentRequired = ConsentInformation.shared.consentStatus != .notRequired
            hasConsent = ConsentInformation.shared.consentStatus == .obtained
            
            // Check for personalized ads capability
            updatePersonalizedAdsStatus()
            
            debugLog("[ConsentManager] Consent info updated - formAvailable: \(isFormAvailable), required: \(isConsentRequired), hasConsent: \(hasConsent)")
        } catch {
            debugLog("[ConsentManager] Failed to request consent info: \(error.localizedDescription)")
        }
        #else
        debugLog("[ConsentManager] UMP SDK not available")
        hasConsent = true // Assume consent if SDK not available
        canShowPersonalizedAds = true
        #endif
    }
    
    /// Load and present consent form if required and available
    /// - Parameter viewController: The view controller to present from
    func loadAndPresentConsentFormIfRequired(from viewController: UIViewController) async {
        #if canImport(UserMessagingPlatform)
        guard isFormAvailable else {
            debugLog("[ConsentManager] Form not available, skipping")
            return
        }
        
        guard ConsentInformation.shared.consentStatus == .required else {
            debugLog("[ConsentManager] Consent not required, skipping form")
            return
        }
        
        do {
            try await ConsentForm.loadAndPresentIfRequired(from: viewController)
            
            // Update status after form is dismissed
            hasConsent = ConsentInformation.shared.consentStatus == .obtained
            updatePersonalizedAdsStatus()
            
            debugLog("[ConsentManager] Form presented and dismissed - hasConsent: \(hasConsent)")
        } catch {
            debugLog("[ConsentManager] Failed to load/present consent form: \(error.localizedDescription)")
        }
        #endif
    }
    
    /// Check if we can request ads (consent obtained or not required)
    func canRequestAds() -> Bool {
        #if canImport(UserMessagingPlatform)
        return ConsentInformation.shared.canRequestAds
        #else
        return true
        #endif
    }
    
    /// Reset consent for testing purposes
    func resetConsent() {
        #if canImport(UserMessagingPlatform)
        ConsentInformation.shared.reset()
        hasConsent = false
        canShowPersonalizedAds = false
        isConsentRequired = false
        isFormAvailable = false
        debugLog("[ConsentManager] Consent reset")
        #endif
    }
    
    // MARK: - Private Methods
    
    private func updatePersonalizedAdsStatus() {
        #if canImport(UserMessagingPlatform)
        // Check the TCF string for personalized ads consent
        // This is a simplified check - in production you might want more detailed parsing
        canShowPersonalizedAds = ConsentInformation.shared.canRequestAds
        #endif
    }
}

//
//  LegalConsentManager.swift
//  milkTeaTracker
//
//  Manages user consent for Terms of Service and Privacy Policy.
//  Tracks acceptance status with UserDefaults persistence.
//

import Foundation

/// Manager for tracking user consent to Terms of Service and Privacy Policy
@Observable
@MainActor
final class LegalConsentManager {
    
    // MARK: - Singleton
    
    static let shared = LegalConsentManager()
    
    // MARK: - UserDefaults Keys
    
    private enum Keys {
        static let hasAcceptedTerms = "legal.hasAcceptedTerms"
        static let termsAcceptedDate = "legal.termsAcceptedDate"
        static let acceptedTermsVersion = "legal.acceptedTermsVersion"
    }
    
    // MARK: - Current Terms Version
    
    /// Increment this when terms are updated to require re-acceptance
    static let currentTermsVersion = "1.0"
    
    // MARK: - Properties
    
    /// Whether the user has accepted the current version of terms
    var hasAcceptedTerms: Bool {
        get {
            let accepted = UserDefaults.standard.bool(forKey: Keys.hasAcceptedTerms)
            let acceptedVersion = UserDefaults.standard.string(forKey: Keys.acceptedTermsVersion)
            // Must have accepted AND be on current version
            return accepted && acceptedVersion == Self.currentTermsVersion
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.hasAcceptedTerms)
            if newValue {
                UserDefaults.standard.set(Self.currentTermsVersion, forKey: Keys.acceptedTermsVersion)
            }
        }
    }
    
    /// Date when terms were accepted
    var termsAcceptedDate: Date? {
        get {
            UserDefaults.standard.object(forKey: Keys.termsAcceptedDate) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.termsAcceptedDate)
        }
    }
    
    /// The version of terms the user accepted
    var acceptedTermsVersion: String? {
        UserDefaults.standard.string(forKey: Keys.acceptedTermsVersion)
    }
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Record that the user has accepted the terms
    func acceptTerms() {
        hasAcceptedTerms = true
        termsAcceptedDate = Date()
        debugLog("[LegalConsent] User accepted terms version \(Self.currentTermsVersion)")
    }
    
    /// Reset consent (for testing or when terms are updated)
    func resetConsent() {
        UserDefaults.standard.removeObject(forKey: Keys.hasAcceptedTerms)
        UserDefaults.standard.removeObject(forKey: Keys.termsAcceptedDate)
        UserDefaults.standard.removeObject(forKey: Keys.acceptedTermsVersion)
        debugLog("[LegalConsent] Consent reset")
    }
    
    /// Check if user needs to re-accept terms (version changed)
    var needsReacceptance: Bool {
        guard UserDefaults.standard.bool(forKey: Keys.hasAcceptedTerms) else {
            return true // Never accepted
        }
        let acceptedVersion = UserDefaults.standard.string(forKey: Keys.acceptedTermsVersion)
        return acceptedVersion != Self.currentTermsVersion
    }
}

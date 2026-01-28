//
//  AuthConfig.swift
//  milkTeaTracker
//
//  Configuration for authentication providers and backend services.
//  Update these values with your actual credentials before building.
//

import Foundation

/// Configuration for authentication and backend services
enum AuthConfig {
    // MARK: - Legal URLs
    /// Privacy Policy URL - REQUIRED for App Store submission
    /// Replace with your actual privacy policy URL before submitting to App Store
    static let privacyPolicyURL = "https://bobadiary.app/privacy"
    
    /// Terms of Service URL - REQUIRED for App Store submission
    /// Replace with your actual terms of service URL before submitting to App Store
    static let termsOfServiceURL = "https://bobadiary.app/terms"
    
    // MARK: - Google Sign-In
    /// Your Google OAuth 2.0 Client ID from Google Cloud Console
    /// Format: "xxxx.apps.googleusercontent.com"
    static let googleClientID = "684734745499-j7u63h0v934ie44unvcun912phcuo8nj.apps.googleusercontent.com"
    
    // MARK: - Facebook Login
    /// Your Facebook App ID from Meta Developers Console
    static let facebookAppID = "YOUR_FACEBOOK_APP_ID"
    
    // MARK: - Google Apps Script Backend (Complex Sync)
    /// The deployed Google Apps Script Web App URL for full sync operations
    /// Get this after deploying AppsScript.js from the Backend folder
    static let appsScriptURL = "YOUR_APPS_SCRIPT_DEPLOYMENT_URL"
    
    // MARK: - Simple Drink Logger (Google Sheets)
    /// The deployed Google Apps Script Web App URL for simple drink logging
    /// This endpoint just appends drink data to a sheet with API key verification
    /// Set via SIMPLE_SHEETS_URL in your xcconfig file
    static var simpleSheetsURL: String {
        SecureConfig.simpleSheetsURL
    }
    
    /// API key for authenticating with the Simple Drink Logger
    /// Must match the API_KEY in SimpleDrinkLogger.js
    /// Set via SHEETS_API_KEY in your xcconfig file
    static var sheetsAPIKey: String {
        SecureConfig.sheetsAPIKey
    }
    
    // MARK: - AdMob Configuration
    /// Your AdMob App ID
    /// Get this from your AdMob dashboard
    static let adMobAppID = "ca-app-pub-6942834770897120~2562851982"
    
    /// Your AdMob Banner Ad Unit ID
    static let bannerAdUnitID = "ca-app-pub-6942834770897120/7175474243"
    
    /// Test Ad Unit ID for development (use this during development)
    static let testBannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
    
    // MARK: - Validation
    /// Check if the configuration has been set up
    static var isConfigured: Bool {
        return !googleClientID.contains("YOUR_") &&
               !facebookAppID.contains("YOUR_") &&
               !appsScriptURL.contains("YOUR_")
    }
    
    /// Check if only the backend URL is configured (for testing without social login)
    static var isBackendConfigured: Bool {
        return !appsScriptURL.contains("YOUR_")
    }
    
    /// Check if simple sheets logging is configured
    static var isSimpleSheetsConfigured: Bool {
        return SecureConfig.isSheetsConfigured
    }
    
    /// Check if AdMob is configured
    static var isAdMobConfigured: Bool {
        return !adMobAppID.contains("YOUR_")
    }
    
    /// Get the appropriate banner ad unit ID (test or production)
    static var currentBannerAdUnitID: String {
        #if DEBUG
        return testBannerAdUnitID
        #else
        return isAdMobConfigured ? bannerAdUnitID : testBannerAdUnitID
        #endif
    }
}

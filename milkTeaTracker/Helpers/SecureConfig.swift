//
//  SecureConfig.swift
//  milkTeaTracker
//
//  Secure configuration manager that reads API keys from Info.plist.
//  API keys should be set via xcconfig files that are NOT committed to git.
//
//  Setup for Release builds:
//  1. Create a Secrets.xcconfig file (gitignored) with your actual API keys
//  2. Reference the keys in your build settings
//  3. Add the keys to Info.plist using $(VARIABLE_NAME) syntax
//
//  For DEBUG builds, fallback keys are used if xcconfig is not set up.
//

import Foundation

/// Secure configuration manager for API keys and sensitive values
enum SecureConfig {
    
    // MARK: - Info.plist Key Names
    
    private enum InfoPlistKey {
        static let geminiAPIKey = "GEMINI_API_KEY"
        static let sheetsAPIKey = "SHEETS_API_KEY"
        static let simpleSheetsURL = "SIMPLE_SHEETS_URL"
    }
    
    // MARK: - DEBUG Fallback Keys
    // These are used only in DEBUG builds when xcconfig is not configured
    // IMPORTANT: For App Store submission, set up proper xcconfig files
    // Do NOT commit actual API keys to version control
    
    #if DEBUG
    private enum DebugFallback {
        // Set these in Secrets.xcconfig or environment variables
        // These empty strings will cause features to be disabled in DEBUG if not configured
        static let geminiAPIKey = ""
        static let sheetsAPIKey = ""
        static let simpleSheetsURL = ""
    }
    #endif
    
    // MARK: - API Keys
    
    /// Gemini API key for receipt scanning
    /// Set via GEMINI_API_KEY in your xcconfig file
    static var geminiAPIKey: String {
        #if DEBUG
        // Debug: Log what Info.plist returns
        let rawValue = Bundle.main.object(forInfoDictionaryKey: InfoPlistKey.geminiAPIKey)
        debugLog("[SecureConfig] GEMINI_API_KEY from Info.plist: \(String(describing: rawValue))")
        #endif
        
        // First try Info.plist (populated from xcconfig via build settings)
        if let key = Bundle.main.object(forInfoDictionaryKey: InfoPlistKey.geminiAPIKey) as? String,
           !key.isEmpty,
           !key.hasPrefix("$(") { // Not an unresolved variable
            #if DEBUG
            debugLog("[SecureConfig] Using GEMINI_API_KEY from Info.plist: \(key.prefix(20))...")
            #endif
            return key
        }
        
        // Fallback to environment variable (for CI/CD or scheme settings)
        if let key = ProcessInfo.processInfo.environment["GEMINI_API_KEY"],
           !key.isEmpty {
            #if DEBUG
            debugLog("[SecureConfig] Using GEMINI_API_KEY from environment: \(key.prefix(20))...")
            #endif
            return key
        }
        
        // DEBUG fallback - remove for production
        #if DEBUG
        debugLog("[SecureConfig] Using DEBUG fallback for GEMINI_API_KEY (empty)")
        return DebugFallback.geminiAPIKey
        #else
        debugLog("[SecureConfig] Warning: GEMINI_API_KEY not configured")
        return ""
        #endif
    }
    
    /// Google Sheets API key for drink logging
    /// Set via SHEETS_API_KEY in your xcconfig file
    static var sheetsAPIKey: String {
        if let key = Bundle.main.object(forInfoDictionaryKey: InfoPlistKey.sheetsAPIKey) as? String,
           !key.isEmpty,
           !key.hasPrefix("$(") {
            return key
        }
        
        if let key = ProcessInfo.processInfo.environment["SHEETS_API_KEY"],
           !key.isEmpty {
            return key
        }
        
        #if DEBUG
        debugLog("[SecureConfig] Using DEBUG fallback for SHEETS_API_KEY")
        return DebugFallback.sheetsAPIKey
        #else
        debugLog("[SecureConfig] Warning: SHEETS_API_KEY not configured")
        return ""
        #endif
    }
    
    /// Simple Sheets deployment URL
    /// Set via SIMPLE_SHEETS_URL in your xcconfig file
    static var simpleSheetsURL: String {
        if let url = Bundle.main.object(forInfoDictionaryKey: InfoPlistKey.simpleSheetsURL) as? String,
           !url.isEmpty,
           !url.hasPrefix("$(") {
            return url
        }
        
        if let url = ProcessInfo.processInfo.environment["SIMPLE_SHEETS_URL"],
           !url.isEmpty {
            return url
        }
        
        #if DEBUG
        debugLog("[SecureConfig] Using DEBUG fallback for SIMPLE_SHEETS_URL")
        return DebugFallback.simpleSheetsURL
        #else
        debugLog("[SecureConfig] Warning: SIMPLE_SHEETS_URL not configured")
        return ""
        #endif
    }
    
    // MARK: - Validation
    
    /// Check if Gemini API is configured
    static var isGeminiConfigured: Bool {
        !geminiAPIKey.isEmpty
    }
    
    /// Check if Sheets logging is configured
    static var isSheetsConfigured: Bool {
        !sheetsAPIKey.isEmpty && !simpleSheetsURL.isEmpty
    }
}

//
//  GeminiConfig.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/18/26.
//

import Foundation

/// Configuration for Gemini API access via Vertex AI
enum GeminiConfig {
    /// The Vertex AI access token
    /// Retrieved securely from Info.plist (set via xcconfig files)
    static var apiKey: String {
        SecureConfig.geminiAPIKey
    }
    
    /// Check if API key is configured
    static var isConfigured: Bool {
        SecureConfig.isGeminiConfigured
    }
    
    /// Vertex AI endpoint for Gemini content generation
    static let endpoint = "https://aiplatform.googleapis.com/v1/publishers/google/models/gemini-2.5-flash-lite:generateContent"
}

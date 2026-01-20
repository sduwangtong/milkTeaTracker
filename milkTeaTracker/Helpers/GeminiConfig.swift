//
//  GeminiConfig.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/18/26.
//

import Foundation

/// Configuration for Gemini API access via Vertex AI
enum GeminiConfig {
    /// The Vertex AI API key
    /// For production apps, consider using a more secure approach (backend proxy, etc.)
    static let apiKey = "AQ.Ab8RN6LvqSCFdeqmwbZ5hKZ3YMpOc1SSCxC-NgGZ2MuGADXesw"
    
    /// Check if API key is configured
    static var isConfigured: Bool {
        !apiKey.isEmpty
    }
    
    /// Vertex AI endpoint for Gemini content generation
    static let endpoint = "https://aiplatform.googleapis.com/v1/publishers/google/models/gemini-2.5-flash-lite:generateContent"
}

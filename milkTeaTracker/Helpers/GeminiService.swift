//
//  GeminiService.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/18/26.
//

import Foundation
import UIKit

/// Errors that can occur during Gemini API operations
enum GeminiError: Error, LocalizedError {
    case apiKeyNotConfigured
    case invalidImage
    case networkError(Error)
    case invalidResponse
    case apiError(String)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .apiKeyNotConfigured:
            return "Gemini API key is not configured"
        case .invalidImage:
            return "Could not process the image"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from Gemini API"
        case .apiError(let message):
            return "API error: \(message)"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        }
    }
}

/// Response structure from Gemini API for receipt parsing
struct GeminiReceiptResponse: Codable {
    var brandName: String?
    var items: [GeminiReceiptItem]?
    var totalPrice: Double?
    
    struct GeminiReceiptItem: Codable {
        var drinkName: String
        var price: Double?
        var size: String?
        var sugarLevel: String?
        var iceLevel: String?
        var bubbleLevel: String?
    }
}

/// Service for processing receipt images using Google's Gemini API
class GeminiService {
    
    /// Maximum dimension for image compression (768px balances quality and token cost)
    private static let maxImageDimension: CGFloat = 768
    
    /// JPEG compression quality (0.7 maintains text clarity)
    private static let jpegQuality: CGFloat = 0.7
    
    /// Compress and resize image for optimal API usage
    /// - Parameters:
    ///   - image: Original image to compress
    ///   - maxDimension: Maximum dimension for the longest side
    /// - Returns: Compressed image
    private static func compressImage(_ image: UIImage, maxDimension: CGFloat = 768) -> UIImage {
        let size = image.size
        
        // Check if resizing is needed
        guard size.width > maxDimension || size.height > maxDimension else {
            debugLog("[Gemini] Image already within size limits, no resize needed")
            return image
        }
        
        // Calculate new size maintaining aspect ratio
        let aspectRatio = size.width / size.height
        var newSize: CGSize
        
        if size.width > size.height {
            // Landscape: constrain width
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            // Portrait: constrain height
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
        
        // Resize using UIGraphicsImageRenderer for better performance
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resizedImage
    }
    
    /// The prompt for extracting receipt information (optimized for ~30% token savings)
    private static let extractionPrompt = """
    Extract milk tea receipt data. Brand name is at TOP.

    IMPORTANT: Only extract DRINKS (beverages), NOT add-ons/toppings. Add-ons like mochi, pudding, jelly, boba, coconut, aloe, grass jelly, red bean, etc. are NOT separate drinks - ignore them or include as part of the drink they modify.

    Return JSON only:
    {"brandName":"store","items":[{"drinkName":"name","price":5.50,"size":"medium","sugarLevel":"less","iceLevel":"less","bubbleLevel":"none"}],"totalPrice":5.50}

    Value mappings:
    - size: S/小杯→small, M/中杯→medium, L/大杯→large (default:medium)
    - sugarLevel: 0%/无糖→none, 25%/微糖→light, 50%/半糖→less, 70%/正常糖→regular, 100%/全糖→extra (default:less)
    - iceLevel: 去冰/hot→none, 少冰→less, 正常冰→regular, 多冰→extra (default:less)
    - bubbleLevel: 无珍珠→none, 珍珠/波霸→regular, 多珍珠→extra (default:none)

    Extract only DRINK items (tea, milk tea, latte, smoothie, juice, etc.). Skip standalone toppings/add-ons. Return ONLY valid JSON.
    """
    
    /// Process a receipt image and extract drink information using Gemini API
    /// - Parameter image: The receipt image to process
    /// - Returns: A ParsedReceipt with extracted information
    /// - Throws: GeminiError if processing fails
    static func processReceiptImage(_ image: UIImage) async throws -> ParsedReceipt {
        debugLog("[Gemini] ========== Starting Receipt Processing ==========")
        
        // Check if API key is configured
        guard GeminiConfig.isConfigured else {
            debugLog("[Gemini] ERROR: API key not configured")
            throw GeminiError.apiKeyNotConfigured
        }
        
        // Log original image info
        let originalSize = image.size
        let originalPixels = Int(originalSize.width * originalSize.height)
        debugLog("[Gemini] ORIGINAL IMAGE:")
        debugLog("[Gemini]   Dimensions: \(Int(originalSize.width))x\(Int(originalSize.height)) pixels")
        debugLog("[Gemini]   Total pixels: \(originalPixels) (\(String(format: "%.1f", Double(originalPixels) / 1_000_000)) MP)")
        
        // Compress and resize image
        debugLog("[Gemini] COMPRESSING IMAGE (max dimension: \(Int(maxImageDimension))px)...")
        let compressedImage = compressImage(image, maxDimension: maxImageDimension)
        let compressedSize = compressedImage.size
        let compressedPixels = Int(compressedSize.width * compressedSize.height)
        
        debugLog("[Gemini] COMPRESSED IMAGE:")
        debugLog("[Gemini]   Dimensions: \(Int(compressedSize.width))x\(Int(compressedSize.height)) pixels")
        debugLog("[Gemini]   Total pixels: \(compressedPixels) (\(String(format: "%.1f", Double(compressedPixels) / 1_000_000)) MP)")
        debugLog("[Gemini]   Pixel reduction: \(String(format: "%.1f", (1 - Double(compressedPixels) / Double(originalPixels)) * 100))%")
        
        // Convert compressed image to JPEG
        guard let imageData = compressedImage.jpegData(compressionQuality: jpegQuality) else {
            debugLog("[Gemini] ERROR: Failed to convert image to JPEG")
            throw GeminiError.invalidImage
        }
        let base64Image = imageData.base64EncodedString()
        
        // Log final data sizes
        let dataSizeKB = imageData.count / 1024
        let base64SizeKB = base64Image.count / 1024
        debugLog("[Gemini] FINAL DATA:")
        debugLog("[Gemini]   JPEG size: \(dataSizeKB) KB (\(String(format: "%.2f", Double(imageData.count) / 1_000_000)) MB)")
        debugLog("[Gemini]   Base64 size: \(base64SizeKB) KB (\(base64Image.count) characters)")
        debugLog("[Gemini]   Prompt size: \(extractionPrompt.count) characters")
        
        // Build the request
        let requestBody = buildRequestBody(base64Image: base64Image)
        
        // Make the API call
        debugLog("[Gemini] Sending request to Gemini API...")
        let response = try await makeAPICall(requestBody: requestBody)
        
        // Log raw response
        debugLog("[Gemini] OUTPUT (raw response):")
        debugLog("[Gemini] \(response)")
        
        // Parse the response into ParsedReceipt
        let parsedReceipt = try parseResponse(response)
        
        // Log parsed result
        debugLog("[Gemini] OUTPUT (parsed):")
        debugLog("[Gemini]   Brand: \(parsedReceipt.brandName ?? "nil")")
        debugLog("[Gemini]   Items count: \(parsedReceipt.items.count)")
        for (index, item) in parsedReceipt.items.enumerated() {
            debugLog("[Gemini]   Item \(index + 1): \(item.drinkName)")
            debugLog("[Gemini]     - Price: \(item.price.map { String(format: "$%.2f", $0) } ?? "nil")")
            debugLog("[Gemini]     - Size: \(item.size?.rawValue ?? "nil")")
            debugLog("[Gemini]     - Sugar: \(item.sugarLevel?.rawValue ?? "nil")")
            debugLog("[Gemini]     - Ice: \(item.iceLevel?.rawValue ?? "nil")")
            debugLog("[Gemini]     - Bubble: \(item.bubbleLevel?.rawValue ?? "nil")")
        }
        debugLog("[Gemini]   Total price: \(parsedReceipt.totalPrice.map { String(format: "$%.2f", $0) } ?? "nil")")
        debugLog("[Gemini] ========== Processing Complete ==========")
        
        return parsedReceipt
    }
    
    /// Build the Gemini API request body
    private static func buildRequestBody(base64Image: String) -> [String: Any] {
        return [
            "model": "gemini-2.5-flash-lite",
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        [
                            "text": extractionPrompt
                        ],
                        [
                            "inline_data": [
                                "mime_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.1,
                "topK": 1,
                "topP": 1,
                "maxOutputTokens": 1024
            ]
        ]
    }
    
    /// Make the API call to Gemini
    private static func makeAPICall(requestBody: [String: Any]) async throws -> String {
        // Build URL with API key
        guard var urlComponents = URLComponents(string: GeminiConfig.endpoint) else {
            debugLog("[Gemini] ERROR: Invalid endpoint URL")
            throw GeminiError.invalidResponse
        }
        urlComponents.queryItems = [URLQueryItem(name: "key", value: GeminiConfig.apiKey)]
        
        guard let url = urlComponents.url else {
            debugLog("[Gemini] ERROR: Failed to build URL with API key")
            throw GeminiError.invalidResponse
        }
        
        debugLog("[Gemini] API Endpoint: \(GeminiConfig.endpoint)")
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        debugLog("[Gemini] Request body size: \((request.httpBody?.count ?? 0) / 1024) KB")
        
        // Make the request
        let startTime = Date()
        let (data, response) = try await URLSession.shared.data(for: request)
        let elapsed = Date().timeIntervalSince(startTime)
        
        debugLog("[Gemini] Response received in \(String(format: "%.2f", elapsed)) seconds")
        debugLog("[Gemini] Response data size: \(data.count) bytes")
        
        // Check response status
        guard let httpResponse = response as? HTTPURLResponse else {
            debugLog("[Gemini] ERROR: Invalid HTTP response")
            throw GeminiError.invalidResponse
        }
        
        debugLog("[Gemini] HTTP Status: \(httpResponse.statusCode)")
        
        if httpResponse.statusCode != 200 {
            // Try to extract error message
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                debugLog("[Gemini] ERROR: API error - \(message)")
                throw GeminiError.apiError(message)
            }
            debugLog("[Gemini] ERROR: HTTP \(httpResponse.statusCode)")
            // Log raw error response for debugging
            if let errorString = String(data: data, encoding: .utf8) {
                debugLog("[Gemini] Error response body: \(errorString)")
            }
            throw GeminiError.apiError("HTTP \(httpResponse.statusCode)")
        }
        
        // Parse the response to extract the text content
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            debugLog("[Gemini] ERROR: Failed to parse response structure")
            // Log raw response for debugging
            if let rawString = String(data: data, encoding: .utf8) {
                debugLog("[Gemini] Raw response: \(rawString.prefix(500))...")
            }
            throw GeminiError.invalidResponse
        }
        
        return text
    }
    
    /// Parse the Gemini response text into a ParsedReceipt
    private static func parseResponse(_ responseText: String) throws -> ParsedReceipt {
        debugLog("[Gemini] Parsing response...")
        
        // Clean up the response - remove markdown code blocks if present
        var cleanedText = responseText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove ```json and ``` markers if present
        if cleanedText.hasPrefix("```json") {
            debugLog("[Gemini] Removing ```json markdown wrapper")
            cleanedText = String(cleanedText.dropFirst(7))
        } else if cleanedText.hasPrefix("```") {
            debugLog("[Gemini] Removing ``` markdown wrapper")
            cleanedText = String(cleanedText.dropFirst(3))
        }
        if cleanedText.hasSuffix("```") {
            cleanedText = String(cleanedText.dropLast(3))
        }
        cleanedText = cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        debugLog("[Gemini] Cleaned JSON to parse:")
        debugLog("[Gemini] \(cleanedText)")
        
        // Parse JSON
        guard let jsonData = cleanedText.data(using: .utf8) else {
            debugLog("[Gemini] ERROR: Failed to convert cleaned text to UTF-8 data")
            throw GeminiError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let geminiResponse: GeminiReceiptResponse
        
        do {
            geminiResponse = try decoder.decode(GeminiReceiptResponse.self, from: jsonData)
            debugLog("[Gemini] JSON decoded successfully")
        } catch {
            debugLog("[Gemini] ERROR: JSON decoding failed - \(error)")
            throw GeminiError.decodingError(error)
        }
        
        // Convert to ParsedReceipt with defaults applied
        let items = (geminiResponse.items ?? []).map { item in
            ParsedReceiptItem(
                drinkName: item.drinkName,
                price: item.price,
                size: parseSize(item.size) ?? .medium,           // Default: medium
                sugarLevel: parseSugarLevel(item.sugarLevel) ?? .less,  // Default: half sugar (50%)
                iceLevel: parseIceLevel(item.iceLevel) ?? .less,       // Default: less ice
                bubbleLevel: parseBubbleLevel(item.bubbleLevel) ?? .none  // Default: no bubble
            )
        }
        
        return ParsedReceipt(
            brandName: geminiResponse.brandName,
            matchedBrandName: nil, // Will be matched later in the UI
            items: items,
            totalPrice: geminiResponse.totalPrice,
            rawText: responseText
        )
    }
    
    /// Convert size string to DrinkSize enum
    private static func parseSize(_ size: String?) -> DrinkSize? {
        guard let size = size?.lowercased() else { return nil }
        
        switch size {
        case "small", "s": return .small
        case "medium", "m", "regular": return .medium
        case "large", "l": return .large
        default: return nil
        }
    }
    
    /// Convert bubble level string to BubbleLevel enum
    private static func parseBubbleLevel(_ level: String?) -> BubbleLevel? {
        guard let level = level?.lowercased() else { return nil }
        
        switch level {
        case "none": return .none
        case "regular": return .regular
        case "extra": return .extra
        default: return nil
        }
    }
    
    /// Convert sugar level string to SugarLevel enum
    private static func parseSugarLevel(_ level: String?) -> SugarLevel? {
        guard let level = level?.lowercased() else { return nil }
        
        switch level {
        case "none": return .none
        case "light": return .light
        case "less": return .less
        case "regular": return .regular
        case "extra": return .extra
        default: return nil
        }
    }
    
    /// Convert ice level string to IceLevel enum
    private static func parseIceLevel(_ level: String?) -> IceLevel? {
        guard let level = level?.lowercased() else { return nil }
        
        switch level {
        case "none": return .none
        case "less": return .less
        case "regular": return .regular
        case "extra": return .extra
        default: return nil
        }
    }
}

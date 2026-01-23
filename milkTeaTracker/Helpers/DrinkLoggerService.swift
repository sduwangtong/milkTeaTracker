//
//  DrinkLoggerService.swift
//  milkTeaTracker
//
//  Simple service for logging drinks to Google Sheets.
//  Fire-and-forget approach - doesn't block the UI on failure.
//

import Foundation

/// Service for logging drinks to Google Sheets via Apps Script
actor DrinkLoggerService {
    
    // MARK: - Singleton
    
    static let shared = DrinkLoggerService()
    
    private init() {}
    
    // MARK: - Properties
    
    private let session = URLSession.shared
    private let encoder = JSONEncoder()
    
    // MARK: - Public Methods
    
    /// Log a drink to Google Sheets (fire-and-forget)
    /// - Parameters:
    ///   - email: User's email address
    ///   - name: User's display name
    ///   - drink: The drink log to record
    ///   - location: Optional location data
    func logDrink(email: String, name: String, drink: DrinkLog, location: LogLocation? = nil) async {
        guard AuthConfig.isSimpleSheetsConfigured else {
            print("[DrinkLogger] Simple Sheets URL not configured, skipping log")
            return
        }
        
        guard let url = URL(string: AuthConfig.simpleSheetsURL) else {
            print("[DrinkLogger] Invalid URL")
            return
        }
        
        let payload = DrinkLogPayload(
            apiKey: AuthConfig.sheetsAPIKey,
            email: email,
            name: name,
            brandName: drink.brandName,
            brandNameZH: drink.brandNameZH,
            drinkName: drink.drinkName,
            drinkNameZH: drink.drinkNameZH,
            size: drink.size.rawValue,
            sugarLevel: drink.sugarLevel.rawValue,
            iceLevel: drink.iceLevel.rawValue,
            bubbleLevel: drink.bubbleLevel.rawValue,
            calories: drink.calories,
            sugarGrams: drink.sugarGrams,
            price: drink.price,
            timestamp: ISO8601DateFormatter().string(from: drink.timestamp),
            isCustomDrink: drink.isCustomDrink,
            latitude: location?.latitude,
            longitude: location?.longitude
        )
        
        await sendRequest(url: url, payload: payload)
    }
    
    /// Log a drink with raw values (for when DrinkLog object isn't available)
    func logDrink(
        email: String,
        name: String,
        brandName: String,
        brandNameZH: String,
        drinkName: String,
        drinkNameZH: String,
        size: String,
        sugarLevel: String,
        iceLevel: String,
        bubbleLevel: String,
        calories: Double,
        sugarGrams: Double,
        price: Double?,
        timestamp: Date,
        isCustomDrink: Bool,
        location: LogLocation? = nil
    ) async {
        guard AuthConfig.isSimpleSheetsConfigured else {
            print("[DrinkLogger] Simple Sheets URL not configured, skipping log")
            return
        }
        
        guard let url = URL(string: AuthConfig.simpleSheetsURL) else {
            print("[DrinkLogger] Invalid URL")
            return
        }
        
        let payload = DrinkLogPayload(
            apiKey: AuthConfig.sheetsAPIKey,
            email: email,
            name: name,
            brandName: brandName,
            brandNameZH: brandNameZH,
            drinkName: drinkName,
            drinkNameZH: drinkNameZH,
            size: size,
            sugarLevel: sugarLevel,
            iceLevel: iceLevel,
            bubbleLevel: bubbleLevel,
            calories: calories,
            sugarGrams: sugarGrams,
            price: price,
            timestamp: ISO8601DateFormatter().string(from: timestamp),
            isCustomDrink: isCustomDrink,
            latitude: location?.latitude,
            longitude: location?.longitude
        )
        
        await sendRequest(url: url, payload: payload)
    }
    
    /// Ping the API to check if it's running
    func ping() async -> Bool {
        guard AuthConfig.isSimpleSheetsConfigured else {
            return false
        }
        
        guard let url = URL(string: AuthConfig.simpleSheetsURL + "?action=ping") else {
            return false
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return false
            }
            
            struct PingResponse: Decodable {
                let success: Bool
            }
            
            let pingResponse = try JSONDecoder().decode(PingResponse.self, from: data)
            return pingResponse.success
        } catch {
            print("[DrinkLogger] Ping failed: \(error)")
            return false
        }
    }
    
    // MARK: - Private Methods
    
    private func sendRequest(url: URL, payload: DrinkLogPayload) async {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15
        
        do {
            request.httpBody = try encoder.encode(payload)
            
            let (data, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("[DrinkLogger] Successfully logged drink: \(payload.drinkName)")
                } else {
                    print("[DrinkLogger] HTTP error: \(httpResponse.statusCode)")
                }
            }
            
            // Log response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("[DrinkLogger] Response: \(responseString)")
            }
            
        } catch {
            // Fire-and-forget: just log the error, don't propagate
            print("[DrinkLogger] Failed to log drink: \(error.localizedDescription)")
        }
    }
}

// MARK: - Payload Model

private struct DrinkLogPayload: Encodable {
    let apiKey: String
    let email: String
    let name: String
    let brandName: String
    let brandNameZH: String
    let drinkName: String
    let drinkNameZH: String
    let size: String
    let sugarLevel: String
    let iceLevel: String
    let bubbleLevel: String
    let calories: Double
    let sugarGrams: Double
    let price: Double?
    let timestamp: String
    let isCustomDrink: Bool
    let latitude: Double?
    let longitude: Double?
}

//
//  LocationManager.swift
//  milkTeaTracker
//
//  Manages location services for drink logging.
//

import Foundation
import CoreLocation

/// Simple location manager for getting user's current location
@Observable
@MainActor
final class LocationManager: NSObject {
    
    // MARK: - Singleton
    
    static let shared = LocationManager()
    
    // MARK: - Properties
    
    private let locationManager = CLLocationManager()
    
    /// Current user location (if available)
    private(set) var currentLocation: CLLocation?
    
    /// Whether location services are authorized
    var isAuthorized: Bool {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        default:
            return false
        }
    }
    
    /// Whether location services are denied
    var isDenied: Bool {
        locationManager.authorizationStatus == .denied
    }
    
    // MARK: - Private Properties
    
    private var locationContinuation: CheckedContinuation<CLLocation?, Never>?
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    // MARK: - Public Methods
    
    /// Request location permission
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Get current location (one-time request)
    /// Returns nil if location is unavailable or denied
    func getCurrentLocation() async -> CLLocation? {
        // Check authorization - if not authorized, try to request permission
        if !isAuthorized {
            if locationManager.authorizationStatus == .notDetermined {
                requestPermission()
                // Wait a moment for user response
                try? await Task.sleep(nanoseconds: 500_000_000)
                // If still not authorized after waiting, return nil
                if !isAuthorized {
                    return nil
                }
            } else {
                // Permission denied or restricted
                return nil
            }
        }
        
        // If we have a recent location (within last 5 minutes), use it
        if let location = currentLocation,
           Date().timeIntervalSince(location.timestamp) < 300 {
            return location
        }
        
        // Request new location
        return await withCheckedContinuation { continuation in
            self.locationContinuation = continuation
            self.locationManager.requestLocation()
            
            // Timeout after 10 seconds
            Task {
                try? await Task.sleep(nanoseconds: 10_000_000_000)
                if self.locationContinuation != nil {
                    self.locationContinuation?.resume(returning: self.currentLocation)
                    self.locationContinuation = nil
                }
            }
        }
    }
    
    /// Get location as a simple struct for logging
    func getLocationForLogging() async -> LogLocation? {
        guard let location = await getCurrentLocation() else {
            return nil
        }
        
        return LogLocation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            self.currentLocation = location
            self.locationContinuation?.resume(returning: location)
            self.locationContinuation = nil
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugLog("[LocationManager] Error: \(error.localizedDescription)")
        
        Task { @MainActor in
            self.locationContinuation?.resume(returning: nil)
            self.locationContinuation = nil
        }
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        debugLog("[LocationManager] Authorization changed: \(manager.authorizationStatus.rawValue)")
    }
}

// MARK: - Location Model

/// Simple location struct for logging purposes
struct LogLocation: Codable {
    let latitude: Double
    let longitude: Double
}

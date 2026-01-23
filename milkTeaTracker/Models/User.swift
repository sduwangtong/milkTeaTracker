//
//  User.swift
//  milkTeaTracker
//
//  User model for authentication with support for multiple providers.
//

import Foundation
import SwiftData

/// Authentication provider types
enum AuthProvider: String, Codable, CaseIterable {
    case apple = "apple"
    case google = "google"
    case facebook = "facebook"
    case guest = "guest"
    
    var displayName: String {
        switch self {
        case .apple: return "Apple"
        case .google: return "Google"
        case .facebook: return "Facebook"
        case .guest: return "Guest"
        }
    }
    
    var iconName: String {
        switch self {
        case .apple: return "apple.logo"
        case .google: return "g.circle.fill"
        case .facebook: return "f.circle.fill"
        case .guest: return "person.fill"
        }
    }
    
    /// Whether this provider requires external authentication
    var requiresExternalAuth: Bool {
        switch self {
        case .apple, .google, .facebook: return true
        case .guest: return false
        }
    }
}

/// Represents an authenticated user
@Model
final class User {
    /// Unique identifier from the auth provider (e.g., Apple's user ID)
    @Attribute(.unique) var id: String
    
    /// The authentication provider used
    var providerRawValue: String
    
    /// User's email address (may be nil for Apple if user chose to hide it)
    var email: String?
    
    /// User's display name
    var displayName: String?
    
    /// URL to user's profile photo (from Google/Facebook)
    var photoURL: String?
    
    /// When the user first signed in
    var createdAt: Date
    
    /// When the user last signed in
    var lastSignInAt: Date
    
    /// Last successful sync timestamp
    var lastSyncAt: Date?
    
    /// Computed property for the auth provider enum
    var provider: AuthProvider {
        get { AuthProvider(rawValue: providerRawValue) ?? .apple }
        set { providerRawValue = newValue.rawValue }
    }
    
    /// Unique identifier for API calls (provider_userId format for uniqueness across providers)
    var apiUserId: String {
        return "\(providerRawValue)_\(id)"
    }
    
    init(
        id: String,
        provider: AuthProvider,
        email: String? = nil,
        displayName: String? = nil,
        photoURL: String? = nil
    ) {
        self.id = id
        self.providerRawValue = provider.rawValue
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.createdAt = Date()
        self.lastSignInAt = Date()
        self.lastSyncAt = nil
    }
    
    /// Update the last sign-in timestamp
    func updateLastSignIn() {
        lastSignInAt = Date()
    }
    
    /// Update the last sync timestamp
    func updateLastSync() {
        lastSyncAt = Date()
    }
}

/// Lightweight user info for passing around without SwiftData dependency
struct UserInfo: Codable, Sendable {
    let id: String
    let provider: AuthProvider
    let email: String?
    let displayName: String?
    let photoURL: String?
    
    /// Unique identifier for API calls
    var apiUserId: String {
        return "\(provider.rawValue)_\(id)"
    }
    
    init(from user: User) {
        self.id = user.id
        self.provider = user.provider
        self.email = user.email
        self.displayName = user.displayName
        self.photoURL = user.photoURL
    }
    
    init(
        id: String,
        provider: AuthProvider,
        email: String? = nil,
        displayName: String? = nil,
        photoURL: String? = nil
    ) {
        self.id = id
        self.provider = provider
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
    }
}

/// Token info for API authentication
struct AuthToken: Codable, Sendable {
    let idToken: String
    let provider: AuthProvider
    let expiresAt: Date?
    
    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() >= expiresAt
    }
}

//
//  AuthManager.swift
//  milkTeaTracker
//
//  Central authentication manager handling Apple, Google, Facebook, and Guest sign-in.
//

import Foundation
import SwiftUI
import AuthenticationServices
#if canImport(GoogleSignIn)
import GoogleSignIn
#endif
#if canImport(FacebookLogin)
import FacebookLogin
#endif

/// Errors that can occur during authentication
enum AuthError: Error, LocalizedError {
    case notConfigured
    case sdkNotInstalled(String)
    case cancelled
    case failed(String)
    case noToken
    case invalidCredential
    case unknownProvider
    case invalidEmail
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Authentication is not configured. Please check AuthConfig.swift"
        case .sdkNotInstalled(let provider):
            return "\(provider) Sign-In SDK is not installed. Please use Guest login or another provider."
        case .cancelled:
            return "Sign in was cancelled"
        case .failed(let message):
            return "Sign in failed: \(message)"
        case .noToken:
            return "No authentication token available"
        case .invalidCredential:
            return "Invalid credentials"
        case .unknownProvider:
            return "Unknown authentication provider"
        case .invalidEmail:
            return "Please enter a valid email address"
        }
    }
}

/// Central manager for all authentication operations
@Observable
@MainActor
final class AuthManager: NSObject {
    // MARK: - Published Properties
    
    /// The currently authenticated user info
    private(set) var currentUser: UserInfo?
    
    /// Current authentication token
    private(set) var currentToken: AuthToken?
    
    /// Whether authentication is in progress
    private(set) var isLoading = false
    
    /// Whether session restoration is in progress
    private(set) var isRestoringSession = true
    
    /// Last authentication error
    private(set) var error: AuthError?
    
    // MARK: - Computed Properties
    
    /// Whether a user is currently authenticated
    var isAuthenticated: Bool {
        return currentUser != nil && currentToken != nil
    }
    
    /// Whether the current user is a guest
    var isGuest: Bool {
        return currentUser?.provider == .guest
    }
    
    // MARK: - Private Properties
    
    /// Continuation for Apple Sign In async wrapper
    private var appleSignInContinuation: CheckedContinuation<ASAuthorization, Error>?
    
    // MARK: - Keychain Keys
    
    private enum KeychainKey {
        static let userInfo = "com.milkTeaTracker.userInfo"
        static let authToken = "com.milkTeaTracker.authToken"
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
    }
    
    // MARK: - Session Management
    
    /// Attempt to restore a previous session
    func restoreSession() async -> Bool {
        defer { isRestoringSession = false }
        
        // Try to load saved user info and token from keychain
        guard let userData = KeychainHelper.load(key: KeychainKey.userInfo),
              let userInfo = try? JSONDecoder().decode(UserInfo.self, from: userData),
              let tokenData = KeychainHelper.load(key: KeychainKey.authToken),
              let token = try? JSONDecoder().decode(AuthToken.self, from: tokenData) else {
            return false
        }
        
        // Guest tokens never expire
        if userInfo.provider == .guest {
            self.currentUser = userInfo
            self.currentToken = token
            return true
        }
        
        // Check if token is expired
        if token.isExpired {
            // Try to refresh based on provider
            do {
                _ = try await refreshToken(for: userInfo.provider)
                return true
            } catch {
                // Clear invalid session
                signOut()
                return false
            }
        }
        
        self.currentUser = userInfo
        self.currentToken = token
        return true
    }
    
    /// Sign out and clear all auth data
    func signOut() {
        // Clear Google sign-in state
        #if canImport(GoogleSignIn)
        GIDSignIn.sharedInstance.signOut()
        #endif
        
        // Clear Facebook login state
        #if canImport(FacebookLogin)
        LoginManager().logOut()
        #endif
        
        // Clear stored data
        KeychainHelper.delete(key: KeychainKey.userInfo)
        KeychainHelper.delete(key: KeychainKey.authToken)
        
        // Clear state
        currentUser = nil
        currentToken = nil
        error = nil
    }
    
    /// Get current ID token for API calls, refreshing if needed
    func getCurrentIdToken() async throws -> String {
        guard let token = currentToken else {
            throw AuthError.noToken
        }
        
        // Guest tokens don't need refresh
        if currentUser?.provider == .guest {
            return token.idToken
        }
        
        if token.isExpired {
            guard let user = currentUser else {
                throw AuthError.noToken
            }
            return try await refreshToken(for: user.provider)
        }
        
        return token.idToken
    }
    
    // MARK: - Sign In Methods
    
    /// Sign in as a guest with email and name
    func signInAsGuest(email: String, name: String) throws -> UserInfo {
        // Validate email format
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        guard email.range(of: emailRegex, options: .regularExpression) != nil else {
            throw AuthError.invalidEmail
        }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName = trimmedName.isEmpty ? "Guest" : trimmedName
        
        // Generate a unique guest ID
        let guestId = "guest_\(UUID().uuidString)"
        
        let userInfo = UserInfo(
            id: guestId,
            provider: .guest,
            email: email.lowercased().trimmingCharacters(in: .whitespaces),
            displayName: displayName,
            photoURL: nil
        )
        
        // Guest tokens don't expire
        let token = AuthToken(
            idToken: guestId,
            provider: .guest,
            expiresAt: nil
        )
        
        saveSession(userInfo: userInfo, token: token)
        return userInfo
    }
    
    /// Sign in with Apple
    func signInWithApple() async throws -> UserInfo {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            let authorization = try await performAppleSignIn()
            
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                throw AuthError.invalidCredential
            }
            
            guard let identityTokenData = appleIDCredential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8) else {
                throw AuthError.noToken
            }
            
            let userId = appleIDCredential.user
            let email = appleIDCredential.email
            let fullName = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            
            let userInfo = UserInfo(
                id: userId,
                provider: .apple,
                email: email,
                displayName: fullName.isEmpty ? nil : fullName
            )
            
            let token = AuthToken(
                idToken: identityToken,
                provider: .apple,
                expiresAt: nil // Apple tokens are validated server-side
            )
            
            saveSession(userInfo: userInfo, token: token)
            return userInfo
            
        } catch let authError as AuthError {
            self.error = authError
            throw authError
        } catch {
            let authError = AuthError.failed(error.localizedDescription)
            self.error = authError
            throw authError
        }
    }
    
    /// Sign in with Google
    func signInWithGoogle(presenting viewController: UIViewController) async throws -> UserInfo {
        #if canImport(GoogleSignIn)
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
            
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.noToken
            }
            
            let userId = result.user.userID ?? UUID().uuidString
            let email = result.user.profile?.email
            let displayName = result.user.profile?.name
            let photoURL = result.user.profile?.imageURL(withDimension: 200)?.absoluteString
            
            let userInfo = UserInfo(
                id: userId,
                provider: .google,
                email: email,
                displayName: displayName,
                photoURL: photoURL
            )
            
            // Don't expire Google tokens locally - let server handle validation
            // The GIDSignIn SDK doesn't persist currentUser after app restart,
            // so local expiration causes unnecessary logouts
            let token = AuthToken(
                idToken: idToken,
                provider: .google,
                expiresAt: nil
            )
            
            saveSession(userInfo: userInfo, token: token)
            return userInfo
            
        } catch let gidError as GIDSignInError {
            if gidError.code == .canceled {
                let authError = AuthError.cancelled
                self.error = authError
                throw authError
            }
            let authError = AuthError.failed(gidError.localizedDescription)
            self.error = authError
            throw authError
        } catch {
            let authError = AuthError.failed(error.localizedDescription)
            self.error = authError
            throw authError
        }
        #else
        let authError = AuthError.sdkNotInstalled("Google")
        self.error = authError
        throw authError
        #endif
    }
    
    /// Sign in with Facebook
    func signInWithFacebook(presenting viewController: UIViewController) async throws -> UserInfo {
        #if canImport(FacebookLogin)
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        return try await withCheckedThrowingContinuation { continuation in
            let loginManager = LoginManager()
            loginManager.logIn(permissions: ["public_profile", "email"], from: viewController) { result, error in
                if let error = error {
                    let authError = AuthError.failed(error.localizedDescription)
                    self.error = authError
                    continuation.resume(throwing: authError)
                    return
                }
                
                guard let result = result else {
                    let authError = AuthError.failed("No result from Facebook login")
                    self.error = authError
                    continuation.resume(throwing: authError)
                    return
                }
                
                if result.isCancelled {
                    let authError = AuthError.cancelled
                    self.error = authError
                    continuation.resume(throwing: authError)
                    return
                }
                
                guard let accessToken = AccessToken.current else {
                    let authError = AuthError.noToken
                    self.error = authError
                    continuation.resume(throwing: authError)
                    return
                }
                
                // Fetch user profile
                self.fetchFacebookProfile(accessToken: accessToken) { userInfo in
                    if let userInfo = userInfo {
                        let token = AuthToken(
                            idToken: accessToken.tokenString,
                            provider: .facebook,
                            expiresAt: accessToken.expirationDate
                        )
                        self.saveSession(userInfo: userInfo, token: token)
                        continuation.resume(returning: userInfo)
                    } else {
                        let authError = AuthError.failed("Failed to fetch Facebook profile")
                        self.error = authError
                        continuation.resume(throwing: authError)
                    }
                }
            }
        }
        #else
        let authError = AuthError.sdkNotInstalled("Facebook")
        self.error = authError
        throw authError
        #endif
    }

    // MARK: - Private Methods
    
    /// Perform Apple Sign In using async/await
    private func performAppleSignIn() async throws -> ASAuthorization {
        return try await withCheckedThrowingContinuation { continuation in
            self.appleSignInContinuation = continuation
            
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.performRequests()
        }
    }
    
    /// Fetch Facebook user profile
    #if canImport(FacebookLogin)
    private func fetchFacebookProfile(accessToken: AccessToken, completion: @escaping (UserInfo?) -> Void) {
        let request = GraphRequest(
            graphPath: "me",
            parameters: ["fields": "id,name,email,picture.type(large)"]
        )
        
        request.start { _, result, error in
            guard error == nil,
                  let result = result as? [String: Any],
                  let userId = result["id"] as? String else {
                completion(nil)
                return
            }
            
            let email = result["email"] as? String
            let name = result["name"] as? String
            var photoURL: String?
            
            if let picture = result["picture"] as? [String: Any],
               let pictureData = picture["data"] as? [String: Any],
               let url = pictureData["url"] as? String {
                photoURL = url
            }
            
            let userInfo = UserInfo(
                id: userId,
                provider: .facebook,
                email: email,
                displayName: name,
                photoURL: photoURL
            )
            
            completion(userInfo)
        }
    }
    #endif
    
    /// Save session to keychain
    private func saveSession(userInfo: UserInfo, token: AuthToken) {
        self.currentUser = userInfo
        self.currentToken = token
        
        if let userData = try? JSONEncoder().encode(userInfo) {
            KeychainHelper.save(key: KeychainKey.userInfo, data: userData)
        }
        
        if let tokenData = try? JSONEncoder().encode(token) {
            KeychainHelper.save(key: KeychainKey.authToken, data: tokenData)
        }
    }
    
    /// Refresh token for a specific provider
    private func refreshToken(for provider: AuthProvider) async throws -> String {
        switch provider {
        case .google:
            #if canImport(GoogleSignIn)
            guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
                throw AuthError.noToken
            }
            try await currentUser.refreshTokensIfNeeded()
            guard let idToken = currentUser.idToken?.tokenString else {
                throw AuthError.noToken
            }
            
            let token = AuthToken(
                idToken: idToken,
                provider: .google,
                expiresAt: nil
            )
            
            if let tokenData = try? JSONEncoder().encode(token) {
                KeychainHelper.save(key: KeychainKey.authToken, data: tokenData)
            }
            self.currentToken = token
            
            return idToken
            #else
            throw AuthError.notConfigured
            #endif
            
        case .apple:
            // Apple tokens don't refresh the same way - re-auth might be needed
            // For now, return existing token and let server validate
            guard let token = currentToken else {
                throw AuthError.noToken
            }
            return token.idToken
            
        case .facebook:
            #if canImport(FacebookLogin)
            guard let accessToken = AccessToken.current else {
                throw AuthError.noToken
            }
            
            if accessToken.isExpired {
                // Facebook tokens need to be refreshed through re-login
                throw AuthError.noToken
            }
            
            return accessToken.tokenString
            #else
            throw AuthError.notConfigured
            #endif
            
        case .guest:
            // Guest tokens never expire
            guard let token = currentToken else {
                throw AuthError.noToken
            }
            return token.idToken
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthManager: ASAuthorizationControllerDelegate {
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            appleSignInContinuation?.resume(returning: authorization)
            appleSignInContinuation = nil
        }
    }
    
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Task { @MainActor in
            if let authError = error as? ASAuthorizationError {
                switch authError.code {
                case .canceled:
                    appleSignInContinuation?.resume(throwing: AuthError.cancelled)
                default:
                    appleSignInContinuation?.resume(throwing: AuthError.failed(authError.localizedDescription))
                }
            } else {
                appleSignInContinuation?.resume(throwing: AuthError.failed(error.localizedDescription))
            }
            appleSignInContinuation = nil
        }
    }
}

// MARK: - Keychain Helper

/// Simple keychain helper for storing auth data securely
enum KeychainHelper {
    static func save(key: String, data: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        }
        return nil
    }
    
    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

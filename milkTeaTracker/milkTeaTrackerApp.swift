//
//  milkTeaTrackerApp.swift
//  milkTeaTracker
//
//  Created by Tong Wang on 1/12/26.
//

import SwiftUI
import SwiftData
#if canImport(GoogleSignIn)
import GoogleSignIn
#endif
#if canImport(FacebookCore)
import FacebookCore
#endif

@main
struct milkTeaTrackerApp: App {
    @State private var languageManager = LanguageManager.shared
    @State private var authManager = AuthManager()
    
    /// Whether to require authentication (set to true to show login screen first)
    private let requireAuthentication = true
    
    init() {
        // Configure Google Sign-In
        #if canImport(GoogleSignIn)
        if !AuthConfig.googleClientID.contains("YOUR_") {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: AuthConfig.googleClientID)
        }
        #endif
        
        // Initialize Google Mobile Ads SDK
        if FeatureFlags.showAds {
            Task { @MainActor in
                AdManager.shared.initializeSDK()
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentWrapperView(
                authManager: authManager,
                languageManager: languageManager,
                requireAuthentication: requireAuthentication
            )
            .task {
                // Try to restore previous session
                _ = await authManager.restoreSession()
            }
            .onOpenURL { url in
                handleOpenURL(url)
            }
        }
        .modelContainer(for: [Brand.self, DrinkTemplate.self, DrinkLog.self, CustomDrinkTemplate.self, UserGoals.self, User.self])
    }
    
    /// Handle URL schemes for OAuth callbacks
    private func handleOpenURL(_ url: URL) {
        #if canImport(GoogleSignIn)
        GIDSignIn.sharedInstance.handle(url)
        #endif
        
        #if canImport(FacebookCore)
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
        #endif
    }
}

/// Wrapper view that decides whether to show login or main content
struct ContentWrapperView: View {
    let authManager: AuthManager
    let languageManager: LanguageManager
    let requireAuthentication: Bool
    
    var body: some View {
        Group {
            if requireAuthentication && !authManager.isAuthenticated {
                LoginView()
            } else {
                MainTabView()
            }
        }
        .environment(authManager)
        .environment(languageManager)
    }
}

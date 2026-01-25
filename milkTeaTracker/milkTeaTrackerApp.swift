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
    @State private var freeUsageManager = FreeUsageManager.shared
    
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
                freeUsageManager: freeUsageManager,
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
    let freeUsageManager: FreeUsageManager
    let requireAuthentication: Bool
    
    var body: some View {
        Group {
            if authManager.isRestoringSession {
                // Show splash screen while restoring session
                SplashView()
            } else if requireAuthentication && !authManager.isAuthenticated {
                LoginView()
            } else {
                MainTabView()
            }
        }
        .environment(authManager)
        .environment(languageManager)
        .environment(freeUsageManager)
        .environment(\.locale, languageManager.locale)
        // Force view recreation when language changes to update all localized strings
        .id(languageManager.currentLanguage)
    }
}

/// Splash screen shown while restoring session
struct SplashView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.93, green: 0.26, blue: 0.55), Color(red: 0.8, green: 0.2, blue: 0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(String(localized: "app_name"))
                    .font(.title)
                    .fontWeight(.bold)
                
                ProgressView()
                    .padding(.top, 10)
            }
        }
    }
}

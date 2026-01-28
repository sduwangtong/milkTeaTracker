//
//  LoginView.swift
//  milkTeaTracker
//
//  Login screen with Google Sign-In and Guest options.
//

import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(LegalConsentManager.self) private var legalConsentManager
    
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showGuestLogin = false
    @State private var showTermsSheet = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: geometry.size.height * 0.15)
                    
                    // App Logo and Title
                    VStack(spacing: 16) {
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
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(String(localized: "app_subtitle"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 48)
                    
                    // Login Buttons
                    VStack(spacing: 16) {
                        // Sign in with Google
                        SocialLoginButton(
                            title: String(localized: "continue_google"),
                            icon: "g.circle.fill",
                            backgroundColor: .white,
                            foregroundColor: .black,
                            borderColor: Color(.systemGray4)
                        ) {
                            Task {
                                await handleGoogleSignIn()
                            }
                        }
                        
                        // Guest login button (styled similarly)
                        SocialLoginButton(
                            title: String(localized: "continue_guest"),
                            icon: "person.fill",
                            backgroundColor: Color(.systemGray6),
                            foregroundColor: .primary,
                            borderColor: Color(.systemGray4)
                        ) {
                            showGuestLogin = true
                        }
                    }
                    .padding(.horizontal, 32)
                    .disabled(authManager.isLoading)
                    
                    // Loading indicator
                    if authManager.isLoading {
                        ProgressView()
                            .padding(.top, 16)
                    }
                    
                    Spacer()
                    
                    // Terms and Privacy - clickable to show popup
                    VStack(spacing: 4) {
                        Text(String(localized: "login_terms_agreement"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            showTermsSheet = true
                        } label: {
                            Text(String(localized: "terms_and_privacy"))
                                .font(.caption)
                                .foregroundStyle(Color(red: 0.93, green: 0.26, blue: 0.55))
                                .underline()
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 16)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .background(Color(.systemGroupedBackground))
        .alert(String(localized: "sign_in_error"), isPresented: $showError) {
            Button(String(localized: "ok"), role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showGuestLogin) {
            GuestLoginSheet()
                .environment(authManager)
        }
        .sheet(isPresented: $showTermsSheet) {
            TermsOfServiceView(isViewOnly: true)
                .environment(legalConsentManager)
        }
    }
    
    // MARK: - Sign In Handlers
    
    private func handleGoogleSignIn() async {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            errorMessage = "Unable to present sign in"
            showError = true
            return
        }
        
        do {
            _ = try await authManager.signInWithGoogle(presenting: rootViewController)
        } catch AuthError.cancelled {
            // User cancelled, do nothing
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - Social Login Button

struct SocialLoginButton: View {
    let title: String
    let icon: String
    let backgroundColor: Color
    let foregroundColor: Color
    var borderColor: Color? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .accessibilityHidden(true)
                
                Text(title)
                    .fontWeight(.medium)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(height: 50)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor ?? .clear, lineWidth: 1)
            )
        }
        .accessibilityLabel(title)
    }
}

#Preview {
    LoginView()
        .environment(AuthManager())
        .environment(LegalConsentManager.shared)
}

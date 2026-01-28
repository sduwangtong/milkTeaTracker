//
//  ProfileView.swift
//  milkTeaTracker
//
//  User profile screen with account info and sign out option.
//

import SwiftUI

struct ProfileView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(LanguageManager.self) private var languageManager
    @Environment(LegalConsentManager.self) private var legalConsentManager
    @Environment(\.modelContext) private var modelContext
    
    @State private var showTermsSheet = false
    @State private var showDeleteAccountAlert = false
    @State private var isDeletingAccount = false
    
    var body: some View {
        NavigationStack {
            List {
                // User Info Section
                if let user = authManager.currentUser {
                    Section {
                        HStack(spacing: 16) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.93, green: 0.26, blue: 0.55).opacity(0.2))
                                    .frame(width: 60, height: 60)
                                
                                if let photoURL = user.photoURL,
                                   let url = URL(string: photoURL) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Image(systemName: "person.fill")
                                            .font(.title)
                                            .foregroundStyle(Color(red: 0.93, green: 0.26, blue: 0.55))
                                    }
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.title)
                                        .foregroundStyle(Color(red: 0.93, green: 0.26, blue: 0.55))
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.displayName ?? "User")
                                    .font(.headline)
                                
                                if let email = user.email {
                                    Text(email)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                
                                HStack(spacing: 4) {
                                    Image(systemName: user.provider.iconName)
                                        .font(.caption)
                                    Text(user.provider.displayName)
                                        .font(.caption)
                                }
                                .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Account Section
                Section {
                    Button(role: .destructive) {
                        authManager.signOut()
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text(languageManager.localizedString("sign_out"))
                        }
                    }
                } footer: {
                    Text(languageManager.localizedString("sign_out_footer"))
                }
                
                // Danger Zone - Delete Account
                Section {
                    Button(role: .destructive) {
                        showDeleteAccountAlert = true
                    } label: {
                        HStack {
                            if isDeletingAccount {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "trash")
                            }
                            Text(String(localized: "delete_account"))
                        }
                    }
                    .disabled(isDeletingAccount)
                } header: {
                    Text(String(localized: "danger_zone"))
                } footer: {
                    Text(String(localized: "delete_account_footer"))
                }
                
                // Legal Section
                Section {
                    Button {
                        showTermsSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                            Text(String(localized: "terms_and_privacy"))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .foregroundStyle(.primary)
                    }
                } header: {
                    Text(String(localized: "legal_section"))
                } footer: {
                    if let acceptedDate = legalConsentManager.termsAcceptedDate {
                        Text(String(localized: "terms_accepted_on") + " " + acceptedDate.formatted(date: .abbreviated, time: .omitted))
                    }
                }
                
                // App Info Section
                Section(languageManager.localizedString("about")) {
                    HStack {
                        Text(languageManager.localizedString("version"))
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(languageManager.localizedString("profile"))
            .sheet(isPresented: $showTermsSheet) {
                TermsOfServiceView(isViewOnly: true)
                    .environment(legalConsentManager)
            }
            .alert(String(localized: "delete_account_title"), isPresented: $showDeleteAccountAlert) {
                Button(String(localized: "cancel"), role: .cancel) { }
                Button(String(localized: "delete"), role: .destructive) {
                    Task {
                        await deleteAccount()
                    }
                }
            } message: {
                Text(String(localized: "delete_account_message"))
            }
        }
    }
    
    private func deleteAccount() async {
        isDeletingAccount = true
        defer { isDeletingAccount = false }
        
        do {
            try await authManager.deleteAccount(modelContext: modelContext)
        } catch {
            // Error handling - the user will be signed out regardless
            debugLog("[ProfileView] Error deleting account: \(error)")
        }
    }
}

#Preview {
    ProfileView()
        .environment(AuthManager())
        .environment(LanguageManager.shared)
        .environment(LegalConsentManager.shared)
}

//
//  ProfileView.swift
//  milkTeaTracker
//
//  User profile screen with account info and sign out option.
//

import SwiftUI

struct ProfileView: View {
    @Environment(AuthManager.self) private var authManager
    
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
                            Text("Sign Out")
                        }
                    }
                } footer: {
                    Text("Signing out will return you to the login screen.")
                }
                
                // App Info Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
        .environment(AuthManager())
}

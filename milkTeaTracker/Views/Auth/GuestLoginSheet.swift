//
//  GuestLoginSheet.swift
//  milkTeaTracker
//
//  Sheet for guest login with email and name collection.
//

import SwiftUI

struct GuestLoginSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    
    @State private var email = ""
    @State private var name = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, name
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.93, green: 0.26, blue: 0.55), Color(red: 0.8, green: 0.2, blue: 0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Continue as Guest")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Enter your details to track your drinks")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 16) {
                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        
                        TextField("your@email.com", text: $email)
                            .textFieldStyle(.plain)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: .email)
                            .padding(14)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(focusedField == .email ? Color(red: 0.93, green: 0.26, blue: 0.55) : Color.clear, lineWidth: 2)
                            )
                    }
                    
                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name or Nickname")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        
                        TextField("What should we call you?", text: $name)
                            .textFieldStyle(.plain)
                            .textContentType(.name)
                            .focused($focusedField, equals: .name)
                            .padding(14)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(focusedField == .name ? Color(red: 0.93, green: 0.26, blue: 0.55) : Color.clear, lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Continue button
                VStack(spacing: 12) {
                    Button {
                        continueAsGuest()
                    } label: {
                        HStack {
                            Text("Continue as Guest")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.93, green: 0.26, blue: 0.55), Color(red: 0.8, green: 0.2, blue: 0.4)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(email.isEmpty)
                    .opacity(email.isEmpty ? 0.6 : 1.0)
                    
                    Text("Your data will be synced to track your habits")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                focusedField = .email
            }
        }
    }
    
    private func continueAsGuest() {
        do {
            _ = try authManager.signInAsGuest(email: email, name: name)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    GuestLoginSheet()
        .environment(AuthManager())
}

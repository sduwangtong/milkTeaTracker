//
//  TermsOfServiceView.swift
//  milkTeaTracker
//
//  Terms of Service and Privacy Policy popup with full legal text.
//  Requires explicit user consent before using the app.
//

import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LegalConsentManager.self) private var legalManager
    
    @State private var hasScrolledToBottom = false
    @State private var agreedToTerms = false
    
    let onAccept: () -> Void
    let onDecline: (() -> Void)?
    let isViewOnly: Bool
    
    init(onAccept: @escaping () -> Void = {}, onDecline: (() -> Void)? = nil, isViewOnly: Bool = false) {
        self.onAccept = onAccept
        self.onDecline = onDecline
        self.isViewOnly = isViewOnly
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Scrollable Terms Content
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            termsContent
                            
                            // Bottom marker for scroll detection
                            Color.clear
                                .frame(height: 1)
                                .id("bottom")
                                .onAppear {
                                    hasScrolledToBottom = true
                                }
                        }
                        .padding()
                    }
                }
                
                // Action Buttons (only if not view-only)
                if !isViewOnly {
                    VStack(spacing: 16) {
                        Divider()
                        
                        // Agreement Checkbox
                        Button {
                            agreedToTerms.toggle()
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                    .font(.title3)
                                    .foregroundStyle(agreedToTerms ? Color(red: 0.93, green: 0.26, blue: 0.55) : .secondary)
                                
                                Text(String(localized: "terms_agreement_checkbox"))
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                        
                        // Action Buttons
                        HStack(spacing: 12) {
                            Button {
                                onDecline?()
                                dismiss()
                            } label: {
                                Text(String(localized: "decline"))
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color(.systemGray5))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            Button {
                                legalManager.acceptTerms()
                                onAccept()
                                dismiss()
                            } label: {
                                Text(String(localized: "accept_and_continue"))
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        agreedToTerms
                                            ? Color(red: 0.93, green: 0.26, blue: 0.55)
                                            : Color.gray
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(!agreedToTerms)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle(String(localized: "terms_and_privacy"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isViewOnly {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(String(localized: "done")) {
                            dismiss()
                        }
                    }
                }
            }
            .interactiveDismissDisabled(!isViewOnly)
        }
    }
    
    // MARK: - Terms Content (Legal text in English for consistency)
    
    @ViewBuilder
    private var termsContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Terms of Service & Privacy Policy")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Last Updated: January 2026")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Section 1: Acceptance
            termSection(
                title: "1. Acceptance of Terms",
                content: "By downloading, accessing, or using Boba Diary (\"the App\"), you agree to be bound by these Terms of Service and Privacy Policy. If you do not agree to these terms, please do not use the App."
            )
            
            // Section 2: Information We Collect
            termSection(
                title: "2. Information We Collect",
                content: """
We collect the following categories of information:

• Account Information: Email address and display name you provide during registration.

• Usage Data: Beverage preferences, consumption logs, timestamps, and customization choices you enter into the App.

• Device Information: Device type, operating system version, and app version for compatibility and troubleshooting purposes.

• Location Data: With your explicit permission, approximate location data to enhance your experience. You may disable location access at any time in your device settings.

• Visual Data: Photos you voluntarily upload for receipt scanning features. These images are processed to extract text and are not stored permanently.
"""
            )
            
            // Section 3: How We Use Your Information
            termSection(
                title: "3. How We Use Your Information",
                content: """
We use the information we collect for the following purposes:

• Providing and maintaining App functionality and features.

• Personalizing your experience and remembering your preferences.

• Analytics and usage pattern analysis to understand how the App is used.

• Service improvement and product development, including enhancing existing features and developing new capabilities to better serve our users.

• Communicating important updates, security alerts, and support messages.

• Ensuring compliance with applicable legal obligations.
"""
            )
            
            // Section 4: Data Sharing
            termSection(
                title: "4. Data Sharing and Disclosure",
                content: """
We may share your information with:

• Service Providers: Third-party vendors who assist us in operating the App, performing analytics, processing data, and providing infrastructure services. These providers are contractually obligated to protect your information and use it only for the purposes we specify.

• Analytics Partners: To help us understand App usage patterns and improve our services.

• Legal Requirements: When required by law, court order, or governmental authority, or when we believe disclosure is necessary to protect our rights or the safety of others.

• Business Transfers: In connection with a merger, acquisition, reorganization, or sale of assets, your information may be transferred as part of that transaction.

We do NOT sell your personal information to third parties for their marketing purposes.
"""
            )
            
            // Section 5: Location Data
            termSection(
                title: "5. Location Data",
                content: """
When you grant location permission, we use this data solely to:

• Associate your beverage logs with general purchase areas for your personal reference.

• Provide location-based features within the App.

You may revoke location permissions at any time through your device's Settings app. The App will continue to function without location access, though some features may be limited. Location data is processed in accordance with applicable privacy laws and is not shared with third parties for their independent use.
"""
            )
            
            // Section 6: Data Retention
            termSection(
                title: "6. Data Retention",
                content: "We retain your information for as long as your account is active or as needed to provide you with our services. You may request deletion of your personal data at any time by using the in-app account deletion feature or by contacting us. Upon account deletion, we will remove your personal information from our active systems, though some information may be retained in backups for a limited period or as required by law."
            )
            
            // Section 7: Your Rights
            termSection(
                title: "7. Your Rights (US Residents)",
                content: """
Depending on your state of residence, you may have the following rights regarding your personal information:

• Access: Request a copy of the personal information we hold about you.

• Correction: Request correction of inaccurate personal information.

• Deletion: Request deletion of your personal information, subject to certain exceptions.

• Opt-Out: Opt out of certain data processing activities.

• Non-Discrimination: Exercise your privacy rights without facing discriminatory treatment.

California Residents: Under the California Consumer Privacy Act (CCPA), you have additional rights including the right to know what personal information is collected, sold, or disclosed. Contact us for a detailed disclosure of your CCPA rights.
"""
            )
            
            // Section 8: Data Security
            termSection(
                title: "8. Data Security",
                content: "We implement industry-standard technical and organizational security measures designed to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the Internet or electronic storage is completely secure, and we cannot guarantee absolute security."
            )
            
            // Section 9: Children's Privacy
            termSection(
                title: "9. Children's Privacy",
                content: "The App is not intended for use by children under the age of 13. We do not knowingly collect personal information from children under 13. If we become aware that we have inadvertently collected personal information from a child under 13, we will take steps to delete such information promptly. If you believe we may have collected information from a child under 13, please contact us."
            )
            
            // Section 10: Changes
            termSection(
                title: "10. Changes to This Policy",
                content: "We may update these Terms of Service and Privacy Policy from time to time to reflect changes in our practices or for legal, operational, or regulatory reasons. If we make material changes, we will notify you through the App or by other means. Your continued use of the App after any changes indicates your acceptance of the updated terms."
            )
            
            // Section 11: Contact
            termSection(
                title: "11. Contact Us",
                content: "If you have questions about these terms, wish to exercise your privacy rights, or have concerns about our data practices, please contact us at: support@bobadiary.app"
            )
        }
    }
    
    @ViewBuilder
    private func termSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            Text(content)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview("Consent Required") {
    TermsOfServiceView(
        onAccept: { print("Accepted") },
        onDecline: { print("Declined") }
    )
    .environment(LegalConsentManager.shared)
}

#Preview("View Only") {
    TermsOfServiceView(isViewOnly: true)
        .environment(LegalConsentManager.shared)
}

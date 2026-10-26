import SwiftUI
import SwiftData
import AuthenticationServices

struct AppleSignInButtonView: UIViewRepresentable {
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(type: .signIn, style: .white)
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
}

struct AccountSection: View {
    @Environment(\.modelContext) private var modelContext
    @State private var authService = AuthService.shared
    @State private var showEmailAuth = false
    @State private var showDeleteExplanation = false
    @State private var showDeleteConfirmation = false
    @State private var showDeletionResult = false
    @State private var isDeleting = false
    @State private var deletionResultTitle = ""
    @State private var deletionResultMessage = ""

    var body: some View {
        if authService.isSignedIn {
            HStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(AppTheme.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text(authService.displayName ?? "Bible Student")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    Text(authService.email ?? "Signed in")
                        .font(.caption)
                        .foregroundColor(AppTheme.textMuted)
                }

                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppTheme.success)
            }

            Button("Sign Out", role: .destructive) {
                authService.signOut()
            }
            .font(.subheadline)

            Button(role: .destructive) {
                showDeleteExplanation = true
            } label: {
                HStack {
                    if isDeleting {
                        ProgressView()
                    }
                    Text(isDeleting ? "Deleting Account…" : "Delete Account")
                }
            }
            .disabled(isDeleting)
            .font(.subheadline)
            .confirmationDialog(
                "Delete your Bible Copilot account?",
                isPresented: $showDeleteExplanation,
                titleVisibility: .visible
            ) {
                Button("Continue", role: .destructive) {
                    showDeleteConfirmation = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently deletes your synced passages, journal entries, reading-plan progress, profile, and Bible Copilot membership. It does not cancel an App Store subscription, which you manage separately in Apple Subscriptions.")
            }
            .alert("Permanently delete everything?", isPresented: $showDeleteConfirmation) {
                Button("Delete My Account", role: .destructive) {
                    Task { await deleteAccount() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This cannot be undone. Bible Copilot will remove its cloud and on-device account data and sign you out after the server confirms deletion.")
            }
            .alert(deletionResultTitle, isPresented: $showDeletionResult) {
                Button("OK", role: .cancel) {}
                if deletionResultTitle == "Account Deleted" {
                    Link("Manage Apple Subscription", destination: URL(string: "https://apps.apple.com/account/subscriptions")!)
                }
            } message: {
                Text(deletionResultMessage)
            }
        } else {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 28))
                        .foregroundColor(AppTheme.accent)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        Text("Sync your data across devices")
                            .font(.caption)
                            .foregroundColor(AppTheme.textMuted)
                    }

                    Spacer()
                }

                // Sign in with Apple
                SignInWithAppleCoordinator()
                    .frame(height: 50)

                // Email sign in
                Button {
                    showEmailAuth = true
                } label: {
                    HStack {
                        Image(systemName: "envelope.fill")
                        Text("Sign in with Email")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppTheme.surfaceLight)
                    .foregroundColor(AppTheme.textPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.surfaceBorder, lineWidth: 1)
                    )
                }
            }
            .sheet(isPresented: $showEmailAuth) {
                EmailAuthView()
            }

            if let error = authService.error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(AppTheme.error)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
            }
        }
    }

    @MainActor
    private func deleteAccount() async {
        guard !isDeleting else { return }
        isDeleting = true
        defer { isDeleting = false }

        do {
            let result = try await authService.deleteBibleCopilotAccount()
            let localDataCleared: Bool
            do {
                try clearLocalAccountData()
                localDataCleared = true
            } catch {
                localDataCleared = false
            }
            authService.signOut()

            deletionResultTitle = "Account Deleted"
            if !localDataCleared {
                deletionResultMessage = "Your Bible Copilot cloud account was deleted and you were signed out, but the app could not confirm removal of all saved data on this device. Delete Bible Copilot from this device to remove its remaining local data. Any App Store subscription continues until you cancel it in Apple Subscriptions."
            } else if result.appleManualRevocationRequired {
                deletionResultMessage = "Your Bible Copilot account and data were deleted. To finish disconnecting Sign in with Apple, open Settings, tap your name, choose Sign in with Apple, select Bible Copilot, and tap Delete. Any App Store subscription continues until you cancel it in Apple Subscriptions."
            } else if result.scope == "app_data_only", result.remainingMemberships > 0 {
                deletionResultMessage = "Your Bible Copilot account and data were deleted. Your shared sign-in remains available for your other Copilot apps. Any App Store subscription continues until you cancel it in Apple Subscriptions."
            } else {
                deletionResultMessage = "Your Bible Copilot account and data were deleted, and you have been signed out. Any App Store subscription continues until you cancel it in Apple Subscriptions."
            }
            HapticService.success()
        } catch {
            deletionResultTitle = "Deletion Not Confirmed"
            deletionResultMessage = (error as? LocalizedError)?.errorDescription
                ?? "Bible Copilot could not confirm account deletion. Your local data was kept."
        }
        showDeletionResult = true
    }

    @MainActor
    private func clearLocalAccountData() throws {
        for passage in try modelContext.fetch(FetchDescriptor<SavedPassage>()) {
            modelContext.delete(passage)
        }
        for entry in try modelContext.fetch(FetchDescriptor<JournalEntry>()) {
            modelContext.delete(entry)
        }
        for progress in try modelContext.fetch(FetchDescriptor<ReadingPlanProgress>()) {
            modelContext.delete(progress)
        }
        try modelContext.save()

        StreakService.shared.resetLocalProgress()
        AnalyticsService.shared.setEnabled(false, context: "account_deleted")
        let defaults = UserDefaults.standard
        [
            "onboarding_goals",
            "onboarding_experience",
            "onboarding_denomination",
            "onboarding_heard_about",
            "onboarding_translation",
            "onboarding_struggles"
        ].forEach { defaults.removeObject(forKey: $0) }
    }
}

// MARK: - Email Auth View

struct EmailAuthView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var authService = AuthService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "envelope.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(AppTheme.accent)

                    Text(isSignUp ? "Create Account" : "Sign In")
                        .font(.title2.bold())
                        .foregroundColor(AppTheme.textPrimary)

                    Text(isSignUp ? "Sign up with your email" : "Welcome back")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textMuted)
                }
                .padding(.top, 20)

                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onChange(of: email) { _, _ in authService.error = nil }
                        .padding()
                        .background(AppTheme.surfaceLight)
                        .foregroundColor(AppTheme.textPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.surfaceBorder, lineWidth: 1)
                        )

                    SecureField("Password", text: $password)
                        .textContentType(isSignUp ? .newPassword : .password)
                        .padding()
                        .background(AppTheme.surfaceLight)
                        .foregroundColor(AppTheme.textPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.surfaceBorder, lineWidth: 1)
                        )
                }
                .padding(.horizontal)

                if let error = authService.error {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(AppTheme.error)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button {
                    Task {
                        if isSignUp {
                            await authService.signUpWithEmail(email, password: password)
                        } else {
                            await authService.signInWithEmail(email, password: password)
                        }
                        if authService.isSignedIn {
                            HapticService.success()
                            dismiss()
                        }
                    }
                } label: {
                    HStack {
                        if authService.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(isSignUp ? "Create Account" : "Sign In")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(canSubmit ? AppTheme.accent : AppTheme.accent.opacity(0.4))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!canSubmit || authService.isLoading)
                .padding(.horizontal)

                // Or sign in with Apple
                VStack(spacing: 8) {
                    Text("or")
                        .font(.caption)
                        .foregroundColor(AppTheme.textMuted)

                    SignInWithAppleCoordinator()
                        .frame(height: 50)
                        .padding(.horizontal)
                }

                Button {
                    isSignUp.toggle()
                    authService.error = nil
                } label: {
                    Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.accent)
                }

                Spacer()
            }
            .background(AppTheme.background)
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: authService.isSignedIn) { _, signedIn in
                if signedIn {
                    HapticService.success()
                    dismiss()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.textMuted)
                    }
                }
            }
        }
    }

    private var canSubmit: Bool {
        !email.isEmpty && password.count >= 6
    }
}

// MARK: - Apple Sign In Coordinator
// Uses UIViewRepresentable + ASAuthorizationController with an explicit presentationAnchor
// so the sheet reliably appears when the button is inside a List/Section.

struct SignInWithAppleCoordinator: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
        button.cornerRadius = 12
        button.addTarget(context.coordinator, action: #selector(Coordinator.handleTap), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}

    class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        private let authService = AuthService.shared

        @objc func handleTap() {
            let hashedNonce = authService.prepareNonce()

            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = hashedNonce

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }

        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow }) ?? UIWindow()
        }

        func authorizationController(controller: ASAuthorizationController,
                                     didCompleteWithAuthorization authorization: ASAuthorization) {
            Task { await authService.handleAppleSignIn(result: .success(authorization)) }
        }

        func authorizationController(controller: ASAuthorizationController,
                                     didCompleteWithError error: Error) {
            Task { await authService.handleAppleSignIn(result: .failure(error)) }
        }
    }
}

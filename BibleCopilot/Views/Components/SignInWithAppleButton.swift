import SwiftUI
import AuthenticationServices

struct AppleSignInButtonView: UIViewRepresentable {
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(type: .signIn, style: .white)
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
}

struct AccountSection: View {
    @State private var authService = AuthService.shared
    @State private var showEmailAuth = false

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
                Task { await authService.signOut() }
            }
            .font(.subheadline)
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
        }
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

struct SignInWithAppleCoordinator: View {
    @State private var authService = AuthService.shared

    var body: some View {
        AuthenticationServices.SignInWithAppleButton(
            .signIn,
            onRequest: { request in
                let appleRequest = authService.signInWithApple()
                request.requestedScopes = appleRequest.requestedScopes
                request.nonce = appleRequest.nonce
            },
            onCompletion: { result in
                Task {
                    await authService.handleAppleSignIn(result: result)
                }
            }
        )
        .signInWithAppleButtonStyle(.white)
        .frame(height: 50)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

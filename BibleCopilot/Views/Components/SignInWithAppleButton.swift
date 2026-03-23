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

    var body: some View {
        if authService.isSignedIn {
            // Signed in state
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
            // Not signed in
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

                SignInWithAppleCoordinator()
            }
        }
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

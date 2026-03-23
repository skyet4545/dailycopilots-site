import Foundation
import AuthenticationServices
import CryptoKit

@Observable
final class AuthService: NSObject {
    static let shared = AuthService()

    var isSignedIn = false
    var userId: String?
    var displayName: String?
    var email: String?
    var isLoading = false
    var error: String?

    private let supabaseURL = "https://fseqgcebvxiqmzngxhre.supabase.co"
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZzZXFnY2VidnhpcW16bmd4aHJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyODQ2MDMsImV4cCI6MjA4OTg2MDYwM30.J_rkoAP-qFfaankfjSyWInk5pSQtrymfhvNhvzh7joA"

    @ObservationIgnored
    private var currentNonce: String?

    @ObservationIgnored
    private var accessToken: String? {
        get { UserDefaults.standard.string(forKey: "supabase_access_token") }
        set { UserDefaults.standard.set(newValue, forKey: "supabase_access_token") }
    }

    @ObservationIgnored
    private var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: "supabase_refresh_token") }
        set { UserDefaults.standard.set(newValue, forKey: "supabase_refresh_token") }
    }

    override init() {
        super.init()
        // Check if we have a saved session
        if let token = accessToken, !token.isEmpty {
            isSignedIn = true
            userId = UserDefaults.standard.string(forKey: "supabase_user_id")
            displayName = UserDefaults.standard.string(forKey: "supabase_display_name")
            email = UserDefaults.standard.string(forKey: "supabase_email")
            // Try to refresh the session
            Task { await refreshSession() }
        }
    }

    // MARK: - Sign in with Apple

    func signInWithApple() -> ASAuthorizationAppleIDRequest {
        let nonce = randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        return request
    }

    @MainActor
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        switch result {
        case .success(let authorization):
            guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityToken = appleCredential.identityToken,
                  let tokenString = String(data: identityToken, encoding: .utf8),
                  let nonce = currentNonce else {
                error = "Failed to get Apple credentials"
                return
            }

            // Send to Supabase
            do {
                let session = try await signInWithIdToken(
                    provider: "apple",
                    idToken: tokenString,
                    nonce: nonce
                )
                handleSession(session)

                // Save Apple name if provided (only comes on first sign-in)
                if let fullName = appleCredential.fullName {
                    let name = [fullName.givenName, fullName.familyName]
                        .compactMap { $0 }
                        .joined(separator: " ")
                    if !name.isEmpty {
                        displayName = name
                        UserDefaults.standard.set(name, forKey: "supabase_display_name")
                        await updateProfile(displayName: name)
                    }
                }
            } catch {
                self.error = "Sign in failed: \(error.localizedDescription)"
            }

        case .failure(let err):
            if (err as NSError).code != ASAuthorizationError.canceled.rawValue {
                error = "Apple Sign In failed: \(err.localizedDescription)"
            }
        }
    }

    // MARK: - Supabase Auth API

    private func signInWithIdToken(provider: String, idToken: String, nonce: String) async throws -> [String: Any] {
        let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=id_token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")

        let body: [String: Any] = [
            "provider": provider,
            "id_token": idToken,
            "nonce": nonce
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AuthError.serverError(errorBody)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw AuthError.invalidResponse
        }

        return json
    }

    private func handleSession(_ session: [String: Any]) {
        accessToken = session["access_token"] as? String
        refreshToken = session["refresh_token"] as? String

        if let user = session["user"] as? [String: Any] {
            userId = user["id"] as? String
            email = user["email"] as? String

            if let metadata = user["user_metadata"] as? [String: Any] {
                displayName = metadata["full_name"] as? String ?? metadata["name"] as? String
            }
        }

        UserDefaults.standard.set(userId, forKey: "supabase_user_id")
        UserDefaults.standard.set(displayName, forKey: "supabase_display_name")
        UserDefaults.standard.set(email, forKey: "supabase_email")

        isSignedIn = true
        print("✅ Signed in as \(displayName ?? email ?? userId ?? "unknown")")
    }

    @MainActor
    func refreshSession() async {
        guard let refresh = refreshToken else { return }

        let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=refresh_token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")

        let body: [String: String] = ["refresh_token": refresh]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                // Token expired — sign out
                signOut()
                return
            }
            handleSession(json)
        } catch {
            print("⚠️ Session refresh failed: \(error)")
        }
    }

    // MARK: - Sign Out

    @MainActor
    func signOut() {
        accessToken = nil
        refreshToken = nil
        userId = nil
        displayName = nil
        email = nil
        isSignedIn = false

        UserDefaults.standard.removeObject(forKey: "supabase_user_id")
        UserDefaults.standard.removeObject(forKey: "supabase_display_name")
        UserDefaults.standard.removeObject(forKey: "supabase_email")

        print("👋 Signed out")
    }

    // MARK: - Profile Sync

    func updateProfile(displayName: String? = nil, isPro: Bool? = nil, streakCurrent: Int? = nil, streakLongest: Int? = nil, totalStudies: Int? = nil) async {
        guard let token = accessToken, let uid = userId else { return }

        let url = URL(string: "\(supabaseURL)/rest/v1/profiles?id=eq.\(uid)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        var body: [String: Any] = ["updated_at": ISO8601DateFormatter().string(from: .now)]
        if let displayName { body["display_name"] = displayName }
        if let isPro { body["is_pro"] = isPro }
        if let streakCurrent { body["streak_current"] = streakCurrent }
        if let streakLongest { body["streak_longest"] = streakLongest }
        if let totalStudies { body["total_studies"] = totalStudies }

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        _ = try? await URLSession.shared.data(for: request)
    }

    // MARK: - Authenticated Headers (for sync)

    var authHeaders: [String: String] {
        var headers: [String: String] = [
            "apikey": supabaseKey,
            "Content-Type": "application/json"
        ]
        if let token = accessToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }

    // MARK: - Apple Nonce Helpers

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce: \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Errors

enum AuthError: LocalizedError {
    case serverError(String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .serverError(let msg): return msg
        case .invalidResponse: return "Invalid response from server"
        }
    }
}

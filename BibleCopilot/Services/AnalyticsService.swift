import Foundation
import SwiftUI

/// Fire-and-forget funnel analytics. Inserts are best-effort: failures are
/// swallowed so analytics can never block or break the user experience.
final class AnalyticsService {
    static let shared = AnalyticsService()

    // Dedicated analytics project — separate from the shared auth project so
    // event volume can never impact auth/journal quotas.
    private let endpoint = URL(string: "https://fseqgcebvxiqmzngxhre.supabase.co/rest/v1/analytics_events")!
    private let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZzZXFnY2VidnhpcW16bmd4aHJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyODQ2MDMsImV4cCI6MjA4OTg2MDYwM30.J_rkoAP-qFfaankfjSyWInk5pSQtrymfhvNhvzh7joA"
    private let appIdentifier = "bible_copilot"

    private let sessionId = UUID().uuidString

    private var deviceId: String {
        if let existing = UserDefaults.standard.string(forKey: "analyticsDeviceId") {
            return existing
        }
        let new = UUID().uuidString
        UserDefaults.standard.set(new, forKey: "analyticsDeviceId")
        return new
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }

    func track(_ event: String, _ properties: [String: String] = [:]) {
        let payload: [String: Any] = [
            "app_identifier": appIdentifier,
            "event": event,
            "properties": properties,
            "device_id": deviceId,
            "session_id": sessionId,
            "app_version": appVersion,
        ]
        guard let body = try? JSONSerialization.data(withJSONObject: payload) else { return }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        request.timeoutInterval = 10

        URLSession.shared.dataTask(with: request).resume()
    }
}

// MARK: - Event names

enum AnalyticsEvent {
    static let appOpen = "app_open"
    static let onboardingStep = "onboarding_step"
    static let quizAnswer = "quiz_answer"
    static let onboardingComplete = "onboarding_complete"
    static let paywallView = "paywall_view"
    static let trialStartTap = "trial_start_tap"
    static let purchaseSuccess = "purchase_success"
    static let purchaseFailed = "purchase_failed"
    static let questionAsked = "question_asked"
    static let limitHit = "limit_hit"
    static let planOpened = "plan_opened"
    static let verseShared = "verse_shared"
}

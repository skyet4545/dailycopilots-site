import Foundation
import SwiftUI

/// Fire-and-forget funnel analytics. Inserts are best-effort: failures are
/// swallowed so analytics can never block or break the user experience.
final class AnalyticsService {
    static let shared = AnalyticsService()

    static let consentKey = "analyticsConsentGranted"

    // Dedicated analytics project — separate from the shared auth project so
    // event volume can never impact auth/journal quotas.
    private let endpoint = URL(string: "https://fseqgcebvxiqmzngxhre.supabase.co/rest/v1/analytics_events")!
    private let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZzZXFnY2VidnhpcW16bmd4aHJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyODQ2MDMsImV4cCI6MjA4OTg2MDYwM30.J_rkoAP-qFfaankfjSyWInk5pSQtrymfhvNhvzh7joA"
    private let appIdentifier = "bible_copilot"

    private let sessionId = UUID().uuidString

    var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: Self.consentKey)
    }

    func setEnabled(_ enabled: Bool, context: String? = nil) {
        let wasEnabled = isEnabled
        UserDefaults.standard.set(enabled, forKey: Self.consentKey)
        if !enabled {
            UserDefaults.standard.removeObject(forKey: "analyticsDeviceId")
        } else if !wasEnabled, let context {
            // App launch happened before consent, so establish the consenting device's
            // cohort entry now. Without this backfill, new consenting users would never
            // enter the activation, paywall, and retention funnel.
            track(AnalyticsEvent.appOpen, ["context": "analytics_enabled", "consent_context": context])
            track(AnalyticsEvent.analyticsConsent, ["context": context])
        }
    }

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
        guard isEnabled else { return }

        var enrichedProperties = properties
        if let acquisitionSource = UserDefaults.standard.string(forKey: "onboarding_heard_about") {
            enrichedProperties["acquisition_source"] = acquisitionSource
        }

        let payload: [String: Any] = [
            "app_identifier": appIdentifier,
            "event": event,
            "properties": enrichedProperties,
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
    static let analyticsConsent = "analytics_consent_granted"
    static let appOpen = "app_open"
    static let onboardingStep = "onboarding_step"
    static let quizAnswer = "quiz_answer"
    static let onboardingComplete = "onboarding_complete"
    static let paywallView = "paywall_view"
    static let trialStartTap = "trial_start_tap"
    static let purchaseSuccess = "purchase_success"
    static let purchaseCancelled = "purchase_cancelled"
    static let purchasePending = "purchase_pending"
    static let purchaseUnknown = "purchase_unknown"
    static let purchaseFailed = "purchase_failed"
    static let paywallDismissed = "paywall_dismissed"
    static let paywallPlansLoadFailed = "paywall_plans_load_failed"
    static let restoreSucceeded = "restore_succeeded"
    static let restoreNoEntitlement = "restore_no_entitlement"
    static let restoreFailed = "restore_failed"
    static let entitlementStateObserved = "entitlement_state_observed"
    static let questionAsked = "question_asked"
    static let firstQuestionCompleted = "first_question_completed"
    static let followUpSuggestionTapped = "follow_up_suggestion_tapped"
    static let notificationPermission = "notif_permission"
    static let reminderPromptShown = "reminder_prompt_shown"
    static let reminderPromptDismissed = "reminder_prompt_dismissed"
    static let dailyReminderEnabled = "daily_reminder_enabled"
    static let studyReminderOpened = "study_reminder_opened"
    static let limitHit = "limit_hit"
    static let planSelected = "plan_selected"
    static let planOpened = "plan_opened"
    static let verseShared = "verse_shared"
    static let shareComposerOpened = "share_composer_opened"
    static let reviewPromptRequested = "review_prompt_requested"
    static let tiktokShareStarted = "tiktok_share_started"
    static let tiktokShareSucceeded = "tiktok_share_succeeded"
    static let tiktokShareFailed = "tiktok_share_failed"
}

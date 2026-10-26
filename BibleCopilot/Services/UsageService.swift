import Foundation
import SwiftUI

@Observable
final class UsageService {
    static let shared = UsageService()
    static let freeQuestionsPerDay = 3

    @ObservationIgnored
    @AppStorage("usageDate") private var usageDate: String = ""

    @ObservationIgnored
    @AppStorage("usageCount") private var usageCount: Int = 0

    @ObservationIgnored
    @AppStorage("hasCompletedFirstQuestion") private var hasCompletedFirstQuestion = false

    /// Observable copy of today's count so Home and Study refresh after an answer.
    private(set) var questionsUsedToday: Int = 0

    init() {
        resetIfNewDay()
    }

    var usedToday: Int {
        usageCount
    }

    /// Free questions still available today. Pro callers should use `remainingQuestions(isPro:)`.
    var freeQuestionsRemaining: Int {
        max(0, Self.freeQuestionsPerDay - questionsUsedToday)
    }

    static func remainingQuestionsLabel(remaining: Int) -> String {
        "\(remaining) of \(freeQuestionsPerDay) free questions left today"
    }

    /// Re-reads the calendar day. Call when the app becomes active, not during view body.
    func refreshForDisplay() {
        resetIfNewDay()
    }

    /// Passage and prompt from the latest successful answer, so the paywall can
    /// speak to the study the person just finished.
    var lastStudyReference: String {
        UserDefaults.standard.string(forKey: Self.lastStudyReferenceKey) ?? ""
    }

    var lastStudyPrompt: String {
        UserDefaults.standard.string(forKey: Self.lastStudyPromptKey) ?? ""
    }

    func recordStudyContext(reference: String, prompt: String) {
        let reference = reference.trimmingCharacters(in: .whitespacesAndNewlines)
        let prompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !reference.isEmpty else { return }
        UserDefaults.standard.set(reference, forKey: Self.lastStudyReferenceKey)
        UserDefaults.standard.set(prompt, forKey: Self.lastStudyPromptKey)
    }

    func canAsk(isPro: Bool) -> Bool {
        if isPro { return true }
        resetIfNewDay()
        let allowed = usageCount < Self.freeQuestionsPerDay
        if !allowed {
            AnalyticsService.shared.track(AnalyticsEvent.limitHit, ["used": "\(usageCount)"])
        }
        return allowed
    }

    func remainingQuestions(isPro: Bool) -> Int {
        if isPro { return .max }
        resetIfNewDay()
        return max(0, Self.freeQuestionsPerDay - usageCount)
    }

    /// Records a successfully completed answer and returns true only for the
    /// first successful question on this install.
    @discardableResult
    func recordQuestion() -> Bool {
        resetIfNewDay()
        usageCount += 1
        questionsUsedToday = usageCount
        AnalyticsService.shared.track(AnalyticsEvent.questionAsked, ["count_today": "\(usageCount)"])
        if !hasCompletedFirstQuestion {
            hasCompletedFirstQuestion = true
            AnalyticsService.shared.track(AnalyticsEvent.firstQuestionCompleted)
            return true
        }
        return false
    }

    private static let lastStudyReferenceKey = "lastStudyReference"
    private static let lastStudyPromptKey = "lastStudyPrompt"

    private func resetIfNewDay() {
        let today = Date().dayString
        if usageDate != today {
            usageDate = today
            usageCount = 0
        }
        if questionsUsedToday != usageCount {
            questionsUsedToday = usageCount
        }
    }
}

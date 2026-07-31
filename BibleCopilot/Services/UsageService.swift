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

    init() {
        resetIfNewDay()
    }

    var usedToday: Int {
        usageCount
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

    @discardableResult
    func recordQuestion() -> Bool {
        resetIfNewDay()
        usageCount += 1
        AnalyticsService.shared.track(AnalyticsEvent.questionAsked, ["count_today": "\(usageCount)"])
        let isFirstQuestion = !UserDefaults.standard.bool(forKey: "has_completed_first_question")
        if isFirstQuestion {
            UserDefaults.standard.set(true, forKey: "has_completed_first_question")
            AnalyticsService.shared.track(AnalyticsEvent.firstQuestionCompleted)
        }
        return isFirstQuestion
    }

    private func resetIfNewDay() {
        let today = Date().dayString
        if usageDate != today {
            usageDate = today
            usageCount = 0
        }
    }
}

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
        return usageCount < Self.freeQuestionsPerDay
    }

    func remainingQuestions(isPro: Bool) -> Int {
        if isPro { return .max }
        resetIfNewDay()
        return max(0, Self.freeQuestionsPerDay - usageCount)
    }

    func recordQuestion() {
        resetIfNewDay()
        usageCount += 1
    }

    private func resetIfNewDay() {
        let today = Date().dayString
        if usageDate != today {
            usageDate = today
            usageCount = 0
        }
    }
}

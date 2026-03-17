import Foundation

/// Tracks daily question usage with date-aware reset at midnight.
@MainActor
class UsageTracker: ObservableObject {
    static let shared = UsageTracker()

    private let storageKey = "dailyUsageData"
    let freeQuestionLimit = 10

    @Published private(set) var questionCount: Int = 0
    @Published private(set) var lastQuestionDate: String = ""

    init() {
        loadUsage()
    }

    /// Returns true if the user can still ask a free question today.
    var canAskQuestion: Bool {
        questionCount < freeQuestionLimit
    }

    /// Number of remaining free questions today.
    var remainingQuestions: Int {
        max(0, freeQuestionLimit - questionCount)
    }

    /// Check if a free question is allowed and increment the count if so.
    /// Returns `true` if the limit has been reached (should show paywall).
    /// Returns `false` if the question was counted (proceed with AI).
    func checkAndIncrement() -> Bool {
        resetIfNewDay()
        if questionCount >= freeQuestionLimit {
            return true
        }
        questionCount += 1
        saveUsage()
        return false
    }

    /// Force reset (e.g., for testing).
    func reset() {
        questionCount = 0
        lastQuestionDate = todayString()
        saveUsage()
    }

    // MARK: - Private

    private func loadUsage() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let usage = try? JSONDecoder().decode(UsageData.self, from: data) else {
            questionCount = 0
            lastQuestionDate = todayString()
            return
        }

        if usage.date == todayString() {
            questionCount = usage.count
            lastQuestionDate = usage.date
        } else {
            // New day — reset
            questionCount = 0
            lastQuestionDate = todayString()
            saveUsage()
        }
    }

    private func resetIfNewDay() {
        if lastQuestionDate != todayString() {
            questionCount = 0
            lastQuestionDate = todayString()
            saveUsage()
        }
    }

    private func saveUsage() {
        let usage = UsageData(date: lastQuestionDate, count: questionCount)
        if let data = try? JSONEncoder().encode(usage) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter.string(from: Date())
    }
}

private struct UsageData: Codable {
    let date: String
    let count: Int
}

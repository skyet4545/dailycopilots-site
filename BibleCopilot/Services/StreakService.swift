import Foundation
import SwiftUI

@Observable
final class StreakService {
    static let shared = StreakService()

    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var studiedToday: Bool = false
    var totalStudies: Int = 0

    @ObservationIgnored
    private let defaults = UserDefaults.standard

    init() {
        load()
        checkMidnightReset()
    }

    // MARK: - Record a Study Session

    func recordStudy() {
        let today = dateString(for: .now)
        let lastDate = defaults.string(forKey: "streak_lastDate") ?? ""

        if today == lastDate {
            // Already studied today — just increment total
            totalStudies += 1
            defaults.set(totalStudies, forKey: "streak_total")
            return
        }

        let yesterday = dateString(for: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now)

        if lastDate == yesterday {
            // Consecutive day — extend streak
            currentStreak += 1
        } else if lastDate.isEmpty {
            // First ever study
            currentStreak = 1
        } else {
            // Streak broken — restart
            currentStreak = 1
        }

        studiedToday = true
        totalStudies += 1
        longestStreak = max(longestStreak, currentStreak)

        defaults.set(today, forKey: "streak_lastDate")
        defaults.set(currentStreak, forKey: "streak_current")
        defaults.set(longestStreak, forKey: "streak_longest")
        defaults.set(totalStudies, forKey: "streak_total")
    }

    // MARK: - Load & Reset

    private func load() {
        currentStreak = defaults.integer(forKey: "streak_current")
        longestStreak = defaults.integer(forKey: "streak_longest")
        totalStudies = defaults.integer(forKey: "streak_total")

        let today = dateString(for: .now)
        let lastDate = defaults.string(forKey: "streak_lastDate") ?? ""
        studiedToday = (today == lastDate)
    }

    private func checkMidnightReset() {
        let lastDate = defaults.string(forKey: "streak_lastDate") ?? ""
        let today = dateString(for: .now)
        let yesterday = dateString(for: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now)

        if lastDate != today && lastDate != yesterday && !lastDate.isEmpty {
            // More than 1 day gap — streak is broken
            currentStreak = 0
            defaults.set(0, forKey: "streak_current")
        }
    }

    private func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    // MARK: - Display Helpers

    var streakEmoji: String {
        if currentStreak >= 30 { return "👑" }
        if currentStreak >= 14 { return "⭐" }
        if currentStreak >= 7 { return "🔥" }
        if currentStreak >= 3 { return "✨" }
        return "📖"
    }

    var streakMessage: String {
        if currentStreak == 0 { return "Start your study streak today!" }
        if currentStreak == 1 { return "1 day — great start!" }
        if currentStreak < 7 { return "\(currentStreak) days — keep going!" }
        if currentStreak < 30 { return "\(currentStreak) days — on fire!" }
        return "\(currentStreak) days — incredible dedication!"
    }
}

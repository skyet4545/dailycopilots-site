import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    // MARK: - Request Permission

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            #if DEBUG
            print("Notification permission error: \(error)")
            #endif
            return false
        }
    }

    /// Returns true exactly once after a person's first useful study. The UI
    /// presents a dismissible, user-timed soft ask before invoking iOS's
    /// permission dialog; Settings remains available for a later opt-in.
    func shouldOfferDailyReminderAfterFirstStudy() -> Bool {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: "dailyReminderEnabled"),
              !defaults.bool(forKey: "firstStudyReminderPromptAttempted") else {
            return false
        }

        defaults.set(true, forKey: "firstStudyReminderPromptAttempted")
        return true
    }

    func enableDailyReminder(hour: Int, minute: Int) async -> Bool {
        let defaults = UserDefaults.standard
        let granted = await requestPermission()
        AnalyticsService.shared.track(
            AnalyticsEvent.notificationPermission,
            ["granted": granted ? "true" : "false", "context": "post_first_successful_question"]
        )
        guard granted else { return false }

        scheduleDailyReminder(hour: hour, minute: minute)
        defaults.set(true, forKey: "dailyReminderEnabled")
        defaults.set(hour, forKey: "reminderHour")
        defaults.set(minute, forKey: "reminderMinute")
        AnalyticsService.shared.track(
            AnalyticsEvent.dailyReminderEnabled,
            ["context": "post_first_successful_question"]
        )
        return true
    }

    // MARK: - Schedule Daily Reminder

    func scheduleDailyReminder(hour: Int = 8, minute: Int = 0) {
        let center = UNUserNotificationCenter.current()

        // Remove existing reminders
        center.removePendingNotificationRequests(withIdentifiers: ["daily_reminder"])

        let content = UNMutableNotificationContent()
        content.title = "Time to Study"
        content.body = dailyReminderBody()
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)

        center.add(request)
    }

    // MARK: - Schedule Streak Reminder (if they miss a day)

    func scheduleStreakReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["streak_reminder"])

        // Only schedule if user hasn't studied today
        guard !StreakService.shared.studiedToday else { return }

        let content = UNMutableNotificationContent()
        content.title = "Don't Break Your Streak!"
        content.body = "Open Bible Copilot to keep your study streak alive."
        content.sound = .default

        // Fire at 7pm
        var dateComponents = DateComponents()
        dateComponents.hour = 19
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "streak_reminder", content: content, trigger: trigger)

        center.add(request)
    }

    // MARK: - Cancel All

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Helpers

    private func dailyReminderBody() -> String {
        let messages = [
            "Your daily verse is waiting. Open to study.",
            "A new verse is ready for you today.",
            "Take a few minutes to study Scripture today.",
            "Grow in understanding — your daily study awaits.",
            "Scripture speaks today. Open to listen."
        ]
        return messages.randomElement() ?? messages[0]
    }
}

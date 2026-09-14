import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    static let studyReminderOpenedNotification = Notification.Name("BibleCopilotStudyReminderOpened")
    private static let referenceKey = "study_reference"
    private static let modeKey = "study_mode"
    private static let pendingReferenceKey = "pending_study_reference"
    private static let pendingModeKey = "pending_study_mode"

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

    func enableDailyReminder(hour: Int, minute: Int, reference: String? = nil, mode: StudyMode? = nil) async -> Bool {
        let defaults = UserDefaults.standard
        let granted = await requestPermission()
        AnalyticsService.shared.track(
            AnalyticsEvent.notificationPermission,
            ["granted": granted ? "true" : "false", "context": "post_first_successful_question"]
        )
        guard granted else { return false }

        if let reference { defaults.set(reference, forKey: Self.referenceKey) }
        if let mode { defaults.set(mode.rawValue, forKey: Self.modeKey) }
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

        let defaults = UserDefaults.standard
        let reference = defaults.string(forKey: Self.referenceKey)
        let mode = defaults.string(forKey: Self.modeKey).flatMap(StudyMode.init(rawValue:))
        let content = makeDailyReminderContent(reference: reference, mode: mode)

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)

        center.add(request)
    }

    func updateDailyReminderContext(reference: String, mode: StudyMode) {
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: "dailyReminderEnabled") else { return }
        defaults.set(reference, forKey: Self.referenceKey)
        defaults.set(mode.rawValue, forKey: Self.modeKey)
        scheduleDailyReminder(
            hour: defaults.integer(forKey: "reminderHour"),
            minute: defaults.integer(forKey: "reminderMinute")
        )
    }

    func makeDailyReminderContent(reference: String?, mode: StudyMode?) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        if let reference, !reference.isEmpty {
            content.title = "Continue \(reference)"
            content.body = mode.map { "Return to your \($0.label.lowercased()) study and follow the next question." }
                ?? "Return to the passage and follow the next question."
            content.userInfo[Self.referenceKey] = reference
            if let mode { content.userInfo[Self.modeKey] = mode.rawValue }
        } else {
            content.title = "Time to Study"
            content.body = dailyReminderBody()
        }
        content.sound = .default
        return content
    }

    func recordPendingStudyResume(userInfo: [AnyHashable: Any]) {
        guard let request = StudyResumeRequest(userInfo: userInfo) else { return }
        let defaults = UserDefaults.standard
        defaults.set(request.reference, forKey: Self.pendingReferenceKey)
        if let mode = request.mode { defaults.set(mode.rawValue, forKey: Self.pendingModeKey) }
        NotificationCenter.default.post(name: Self.studyReminderOpenedNotification, object: nil)
    }

    func consumePendingStudyResume() -> StudyResumeRequest? {
        let defaults = UserDefaults.standard
        guard let reference = defaults.string(forKey: Self.pendingReferenceKey) else { return nil }
        let mode = defaults.string(forKey: Self.pendingModeKey).flatMap(StudyMode.init(rawValue:))
        defaults.removeObject(forKey: Self.pendingReferenceKey)
        defaults.removeObject(forKey: Self.pendingModeKey)
        return StudyResumeRequest(reference: reference, mode: mode)
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

struct StudyResumeRequest: Equatable {
    let reference: String
    let mode: StudyMode?

    init?(userInfo: [AnyHashable: Any]) {
        guard let reference = userInfo["study_reference"] as? String,
              CrossReferenceParser.extractReferences(from: reference, limit: 1).first?.caseInsensitiveCompare(reference) == .orderedSame else {
            return nil
        }
        self.reference = reference
        self.mode = (userInfo["study_mode"] as? String).flatMap(StudyMode.init(rawValue:))
    }

    init(reference: String, mode: StudyMode?) {
        self.reference = reference
        self.mode = mode
    }
}

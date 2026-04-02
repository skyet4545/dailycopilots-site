import SwiftUI
import SwiftData

@main
struct BibleCopilotApp: App {
    @State private var subscriptionService = SubscriptionService.shared
    @State private var usageService = UsageService.shared
    @State private var authService = AuthService.shared
    @State private var themeManager = ThemeManager.shared
    @AppStorage("dailyReminderEnabled") private var reminderEnabled: Bool = false
    @AppStorage("reminderHour") private var reminderHour: Int = 8
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(subscriptionService)
                .environment(usageService)
                .environment(authService)
                .preferredColorScheme(themeManager.colorScheme)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    guard reminderEnabled else { return }
                    NotificationService.shared.scheduleStreakReminder()
                }
        }
        .modelContainer(for: [
            SavedPassage.self,
            JournalEntry.self,
            ReadingPlanProgress.self
        ])
    }
}

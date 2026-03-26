import SwiftUI
import SwiftData

@main
struct BibleCopilotApp: App {
    @State private var subscriptionService = SubscriptionService.shared
    @State private var usageService = UsageService.shared
    @State private var authService = AuthService.shared
    @State private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(subscriptionService)
                .environment(usageService)
                .environment(authService)
                .preferredColorScheme(themeManager.colorScheme)
        }
        .modelContainer(for: [
            SavedPassage.self,
            JournalEntry.self,
            ReadingPlanProgress.self
        ])
    }
}

import SwiftUI
import SwiftData

@main
struct BibleCopilotApp: App {
    @State private var subscriptionService = SubscriptionService.shared
    @State private var usageService = UsageService.shared
    @State private var authService = AuthService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(subscriptionService)
                .environment(usageService)
                .environment(authService)
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [
            SavedPassage.self,
            JournalEntry.self,
            ReadingPlanProgress.self
        ])
    }
}

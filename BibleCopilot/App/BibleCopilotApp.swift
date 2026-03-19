import SwiftUI
import SwiftData

@main
struct BibleCopilotApp: App {
    @State private var subscriptionService = SubscriptionService.shared
    @State private var usageService = UsageService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(subscriptionService)
                .environment(usageService)
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [
            SavedPassage.self,
            JournalEntry.self,
            ReadingPlanProgress.self
        ])
    }
}

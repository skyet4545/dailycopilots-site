import SwiftUI
import SwiftData

@main
struct BibleCopilotApp: App {
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(subscriptionManager)
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [
            ChatMessage.self,
            JournalEntry.self,
            SavedItem.self,
            ReadingPlanProgress.self,
        ])
    }
}

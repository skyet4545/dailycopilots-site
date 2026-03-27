import SwiftUI
import SwiftData

@main
struct BibleCopilotApp: App {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(subscriptionManager)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
        }
        .modelContainer(for: [
            ChatMessage.self,
            JournalEntry.self,
            SavedItem.self,
            ReadingPlanProgress.self,
        ])
    }
}

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            mainTabView
        } else {
            OnboardingView {
                withAnimation {
                    hasCompletedOnboarding = true
                }
            }
        }
    }

    private var mainTabView: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            BibleReaderView()
                .tabItem {
                    Label("Bible", systemImage: "book.fill")
                }

            JournalListView()
                .tabItem {
                    Label("Journal", systemImage: "note.text")
                }

            BookmarksView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(AppTheme.accent)
    }
}

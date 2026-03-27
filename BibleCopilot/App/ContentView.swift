import SwiftUI

struct ContentView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var themeManager: ThemeManager
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

            PlansListView()
                .tabItem {
                    Label("Plans", systemImage: "calendar")
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
        .onChange(of: themeManager.themeMode) { _, _ in updateTabBarAppearance() }
        .onAppear { updateTabBarAppearance() }
    }

    private func updateTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppTheme.tabBarBackground)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppTheme.textMuted)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(AppTheme.textMuted)]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

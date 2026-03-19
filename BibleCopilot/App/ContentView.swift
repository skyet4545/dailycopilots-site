import SwiftUI

struct ContentView: View {
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @State private var selectedTab = 0
    @State private var studyVerse: String?
    @State private var studyMode: StudyMode?
    @State private var showPaywall = false

    var body: some View {
        Group {
            if !onboardingComplete {
                OnboardingView {
                    onboardingComplete = true
                }
            } else {
                mainTabView
            }
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                HomeView(
                    onStudy: { verse, mode in
                        studyVerse = verse
                        studyMode = mode
                    },
                    onShowPaywall: { showPaywall = true }
                )
            }

            Tab("Plans", systemImage: "calendar", value: 1) {
                PlansListView(
                    onStudyVerse: { verse in
                        studyVerse = verse
                        studyMode = nil
                    },
                    onShowPaywall: { showPaywall = true }
                )
            }

            Tab("Journal", systemImage: "book.fill", value: 2) {
                JournalView(onShowPaywall: { showPaywall = true })
            }

            Tab("Saved", systemImage: "bookmark.fill", value: 3) {
                SavedView(onStudyVerse: { verse in
                    studyVerse = verse
                    studyMode = nil
                })
            }

            Tab("Settings", systemImage: "gearshape.fill", value: 4) {
                SettingsView(onShowPaywall: { showPaywall = true })
            }
        }
        .tint(AppTheme.accent)
        .fullScreenCover(item: $studyVerse) { verse in
            StudyView(
                verse: verse,
                initialMode: studyMode,
                onShowPaywall: { showPaywall = true }
            )
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .onAppear {
            configureTabBarAppearance()
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppTheme.tabBar)

        let normalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(AppTheme.textMuted)
        ]
        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(AppTheme.accent)
        ]

        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppTheme.textMuted)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppTheme.accent)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// Make String identifiable for fullScreenCover
extension String: @retroactive Identifiable {
    public var id: String { self }
}

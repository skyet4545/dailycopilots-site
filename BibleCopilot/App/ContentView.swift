import SwiftUI

struct ContentView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @State private var selectedTab = 0
    @State private var studyRequest: StudyRequest?
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
                        studyRequest = StudyRequest(verse: verse)
                        studyMode = mode
                    },
                    onShowPaywall: { showPaywall = true }
                )
            }

            Tab("Plans", systemImage: "calendar", value: 1) {
                PlansListView(
                    onStudyVerse: { verse in
                        studyRequest = StudyRequest(verse: verse)
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
                    studyRequest = StudyRequest(verse: verse)
                    studyMode = nil
                })
            }

            Tab("Settings", systemImage: "gearshape.fill", value: 4) {
                SettingsView(onShowPaywall: { showPaywall = true })
            }
        }
        .tint(AppTheme.accent)
        .fullScreenCover(item: $studyRequest) { request in
            StudyView(
                verse: request.verse,
                initialMode: studyMode,
                onShowPaywall: { showPaywall = true }
            )
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .onAppear {
            configureTabBarAppearance()
            openPendingStudyReminder()
        }
        .onReceive(NotificationCenter.default.publisher(for: NotificationService.studyReminderOpenedNotification)) { _ in
            openPendingStudyReminder()
        }
        .onChange(of: ThemeManager.shared.themeMode) {
            configureTabBarAppearance()
        }
    }

    private func openPendingStudyReminder() {
        guard let resume = NotificationService.shared.consumePendingStudyResume() else { return }
        Task { @MainActor in
            // Resolve current StoreKit entitlement before deciding whether the
            // reminder can auto-run a study mode. Free users still return to
            // the passage without consuming a question.
            await subscriptionService.checkSubscriptionStatus()
            studyRequest = StudyRequest(verse: resume.reference)
            studyMode = subscriptionService.isPro ? resume.mode : nil
            AnalyticsService.shared.track(AnalyticsEvent.studyReminderOpened, [
                "has_context": "true",
                "is_pro": subscriptionService.isPro ? "true" : "false",
                "mode": resume.mode?.rawValue ?? "none"
            ])
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

// Wrapper for fullScreenCover to avoid String: Identifiable and allow re-study of same verse
struct StudyRequest: Identifiable {
    let id = UUID()
    let verse: String
}

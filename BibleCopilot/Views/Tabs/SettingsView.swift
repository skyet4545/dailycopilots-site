import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @AppStorage("translation") private var translation: String = "asv"
    @AppStorage("hapticFeedbackEnabled") private var hapticEnabled: Bool = true
    @AppStorage("fontSizePreference") private var fontSizePref: String = "medium"
    @AppStorage("dailyReminderEnabled") private var reminderEnabled: Bool = false
    @AppStorage("reminderHour") private var reminderHour: Int = 8
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0
    @AppStorage(AnalyticsService.consentKey) private var analyticsConsentGranted = false
    @State private var restoreAlertMessage = ""
    @State private var showingRestoreAlert = false

    let onShowPaywall: () -> Void

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: reminderHour, minute: reminderMinute, second: 0, of: Date()) ?? Date()
            },
            set: { date in
                let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                reminderHour = components.hour ?? 8
                reminderMinute = components.minute ?? 0
                if reminderEnabled {
                    NotificationService.shared.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                }
            }
        )
    }

    private let translations = [
        ("asv", "American Standard Version"),
        ("kjv", "King James Version"),
        ("web", "World English Bible"),
        ("bbe", "Bible in Basic English")
    ]

    var body: some View {
        NavigationStack {
            List {
                // Account
                Section {
                    AccountSection()
                } header: {
                    Text("Account")
                }

                // Subscription
                Section {
                    if subscriptionService.isPro {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(AppTheme.gold)
                            Text("Bible Copilot Pro")
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Text("Active")
                                .font(.caption)
                                .foregroundColor(AppTheme.success)
                        }
                    } else {
                        Button(action: onShowPaywall) {
                            HStack {
                                Image(systemName: "crown")
                                    .foregroundColor(AppTheme.gold)
                                Text("Upgrade to Pro")
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(AppTheme.textMuted)
                            }
                        }
                    }
                } header: {
                    Text("Subscription")
                }

                // Bible Translation
                Section {
                    ForEach(translations, id: \.0) { code, name in
                        Button {
                            translation = code
                            HapticService.selection()
                        } label: {
                            HStack {
                                Text(name)
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                                if translation == code {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppTheme.accent)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Bible Translation")
                }

                // Preferences
                Section {
                    Toggle(isOn: $reminderEnabled) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(AppTheme.accent)
                            Text("Daily Study Reminder")
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                    .tint(AppTheme.accent)
                    .onChange(of: reminderEnabled) { _, enabled in
                        if enabled {
                            Task {
                                let granted = await NotificationService.shared.requestPermission()
                                if granted {
                                    NotificationService.shared.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
                                    NotificationService.shared.scheduleStreakReminder()
                                } else {
                                    reminderEnabled = false
                                }
                            }
                        } else {
                            NotificationService.shared.cancelAll()
                        }
                    }

                    if reminderEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .foregroundColor(AppTheme.textPrimary)
                        .tint(AppTheme.accent)
                    }

                    Toggle(isOn: $hapticEnabled) {
                        HStack {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .foregroundColor(AppTheme.accent)
                            Text("Haptic Feedback")
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                    .tint(AppTheme.accent)

                    HStack {
                        Image(systemName: "textformat.size")
                            .foregroundColor(AppTheme.accent)
                        Text("Font Size")
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Picker("", selection: $fontSizePref) {
                            ForEach(FontSizePreference.allCases, id: \.rawValue) { size in
                                Text(size.label).tag(size.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 180)
                    }

                    // Appearance
                    HStack {
                        Image(systemName: "moon.circle.fill")
                            .foregroundColor(AppTheme.accent)
                        Text("Appearance")
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Picker("", selection: Binding(
                            get: { ThemeManager.shared.themeMode },
                            set: { ThemeManager.shared.themeMode = $0 }
                        )) {
                            ForEach(AppThemeMode.allCases, id: \.rawValue) { mode in
                                Text(mode.label).tag(mode.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 180)
                    }
                } header: {
                    Text("Preferences")
                }

                Section {
                    Toggle(isOn: $analyticsConsentGranted) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Share Usage Analytics")
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Share app interactions and purchase events to help improve Bible Copilot. Bible text, study questions, journal entries, your name, and your email are excluded.")
                                .font(.caption)
                                .foregroundColor(AppTheme.textMuted)
                        }
                    }
                    .tint(AppTheme.accent)
                    .onChange(of: analyticsConsentGranted) { _, enabled in
                        AnalyticsService.shared.setEnabled(enabled, context: "settings")
                    }
                } header: {
                    Text("Privacy")
                }

                // Legal (required by App Store 3.1.2)
                Section {
                    Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(AppTheme.accent)
                            Text("Terms of Use (EULA)")
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(AppTheme.textMuted)
                        }
                    }

                    Link(destination: URL(string: "https://mybiblecopilot.com/privacy")!) {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(AppTheme.accent)
                            Text("Privacy Policy")
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(AppTheme.textMuted)
                        }
                    }
                } header: {
                    Text("Legal")
                }

                // Stats
                Section {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(AppTheme.gold)
                        Text("Current Streak")
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Text("\(StreakService.shared.currentStreak) days")
                            .foregroundColor(AppTheme.textMuted)
                    }
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(AppTheme.gold)
                        Text("Longest Streak")
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Text("\(StreakService.shared.longestStreak) days")
                            .foregroundColor(AppTheme.textMuted)
                    }
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundColor(AppTheme.accent)
                        Text("Total Studies")
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Text("\(StreakService.shared.totalStudies)")
                            .foregroundColor(AppTheme.textMuted)
                    }
                } header: {
                    Text("Your Progress")
                }

                if !SiblingApps.promotable.isEmpty {
                    Section {
                        ForEach(SiblingApps.promotable) { app in
                            Button {
                                SiblingApps.present(app)
                            } label: {
                                HStack {
                                    Image(systemName: "square.and.arrow.up.on.square")
                                        .foregroundColor(AppTheme.accent)
                                    Text(app.name)
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textMuted)
                                }
                            }
                        }
                    } header: {
                        Text("More from Bible Copilot's makers")
                    } footer: {
                        Text("Other apps from the same maker. Opens in the App Store.")
                    }
                }

                // About
                Section {
                    HStack {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Bible Copilot")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.0.0")")
                                .font(.caption)
                                .foregroundColor(AppTheme.textMuted)
                        }
                        Spacer()
                    }

                    Button {
                        Task {
                            let restoreProperties = ["source": "settings", "restore_attempt_id": UUID().uuidString]
                            AnalyticsService.shared.track(AnalyticsEvent.restoreStarted, restoreProperties)
                            do {
                                if try await subscriptionService.restore() {
                                    AnalyticsService.shared.track(AnalyticsEvent.restoreSucceeded, restoreProperties)
                                    restoreAlertMessage = "Bible Copilot Pro has been restored."
                                } else {
                                    AnalyticsService.shared.track(AnalyticsEvent.restoreNoEntitlement, restoreProperties)
                                    restoreAlertMessage = "No active Bible Copilot Pro purchase was found for this Apple ID."
                                }
                            } catch {
                                AnalyticsService.shared.track(AnalyticsEvent.restoreFailed, restoreProperties.merging(["error": String(describing: error).prefix(120).description]) { current, _ in current })
                                restoreAlertMessage = "Apple could not restore purchases. Check your connection and try again."
                            }
                            showingRestoreAlert = true
                        }
                    } label: {
                        Text("Restore Purchases")
                            .foregroundColor(AppTheme.accent)
                    }
                } header: {
                    Text("About")
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Restore Purchases", isPresented: $showingRestoreAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(restoreAlertMessage)
            }
        }
    }
}

/// Cross-promo catalog. Ids checked against the iTunes Lookup API on 2026-10-26.
/// A row is omitted if its id is ever cleared or non-numeric.
enum SiblingApps {
    /// Campaign token on every Settings cross-promo link (`ct`).
    static let campaignToken = "bc_crosspromo_settings"

    struct AppPromo: Identifiable, Equatable {
        let id: String
        let name: String
        /// Numeric App Store id.
        let appStoreID: String
    }

    static let catalog: [AppPromo] = [
        AppPromo(id: "prayer_copilot", name: "Prayer Copilot", appStoreID: "6761485209"),
        AppPromo(id: "stoic_copilot", name: "Stoic Copilot", appStoreID: "6761389396"),
        AppPromo(id: "gita_copilot", name: "Gita Copilot", appStoreID: "6761395731"),
        AppPromo(id: "wisdom_copilot", name: "Wisdom Copilot", appStoreID: "6761395984"),
        AppPromo(id: "torah_copilot", name: "Torah Copilot", appStoreID: "6761395920"),
        AppPromo(id: "constitution_copilot", name: "Constitution Copilot", appStoreID: "6761391729"),
    ]

    static var promotable: [AppPromo] {
        catalog.filter { app in
            !app.appStoreID.isEmpty && app.appStoreID.allSatisfy(\.isNumber)
        }
    }

    static func appStoreURL(for app: AppPromo) -> URL? {
        guard promotable.contains(app) else { return nil }
        return URL(string: "https://apps.apple.com/app/id\(app.appStoreID)?ct=\(campaignToken)")
    }

    /// Opens the App Store campaign link. `SKOverlay` cannot carry a `ct` token,
    /// so the row uses the URL and the token is actually recorded.
    static func present(_ app: AppPromo) {
        guard let url = appStoreURL(for: app) else { return }
        AnalyticsService.shared.track(AnalyticsEvent.crossPromoTapped, ["app": app.id, "campaign": campaignToken])
        UIApplication.shared.open(url)
    }
}

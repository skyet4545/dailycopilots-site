import SwiftUI

struct SettingsView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @AppStorage("translation") private var translation: String = "asv"
    @AppStorage("hapticFeedbackEnabled") private var hapticEnabled: Bool = true
    @AppStorage("fontSizePreference") private var fontSizePref: String = "medium"
    @AppStorage("dailyReminderEnabled") private var reminderEnabled: Bool = false

    let onShowPaywall: () -> Void

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
                                    NotificationService.shared.scheduleDailyReminder()
                                    NotificationService.shared.scheduleStreakReminder()
                                } else {
                                    reminderEnabled = false
                                }
                            }
                        } else {
                            NotificationService.shared.cancelAll()
                        }
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
                } header: {
                    Text("Preferences")
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

                    Link(destination: URL(string: "https://scripturecopilot.netlify.app/privacy")!) {
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
                        Task { await subscriptionService.restore() }
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
        }
    }
}

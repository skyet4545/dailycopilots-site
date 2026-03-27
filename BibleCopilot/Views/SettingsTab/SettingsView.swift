import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            List {
                // Subscription
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(subscriptionManager.isPro ? "Pro Member" : "Free Plan")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)

                            Text(subscriptionManager.isPro
                                ? "Unlimited questions"
                                : "\(subscriptionManager.remainingQuestions)/\(subscriptionManager.freeQuestionLimit) questions today")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.textMuted)
                        }
                        Spacer()
                        if !subscriptionManager.isPro {
                            Button("Upgrade") {
                                showPaywall = true
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, AppTheme.spacingMD)
                            .padding(.vertical, AppTheme.spacingSM)
                            .background(AppTheme.accent)
                            .cornerRadius(AppTheme.cornerRadiusSM)
                        } else {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(AppTheme.gold)
                        }
                    }
                } header: {
                    Text("Subscription")
                        .foregroundColor(AppTheme.textMuted)
                }
                .listRowBackground(AppTheme.surface)

                // Bible
                Section {
                    Picker("Translation", selection: $viewModel.selectedTranslation) {
                        ForEach(BibleTranslation.allCases) { translation in
                            Text("\(translation.displayName) — \(translation.fullName)")
                                .tag(translation.rawValue)
                        }
                    }
                    .foregroundColor(AppTheme.textPrimary)
                } header: {
                    Text("Bible")
                        .foregroundColor(AppTheme.textMuted)
                }
                .listRowBackground(AppTheme.surface)

                // Appearance
                Section {
                    Picker("Appearance", selection: $themeManager.themeMode) {
                        ForEach(AppThemeMode.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .foregroundColor(AppTheme.textPrimary)
                } header: {
                    Text("Appearance")
                        .foregroundColor(AppTheme.textMuted)
                }
                .listRowBackground(AppTheme.surface)

                // Preferences
                Section {
                    Toggle("Haptic Feedback", isOn: Binding(
                        get: { UserDefaults.standard.object(forKey: "hapticFeedbackEnabled") as? Bool ?? true },
                        set: { UserDefaults.standard.set($0, forKey: "hapticFeedbackEnabled") }
                    ))
                    .foregroundColor(AppTheme.textPrimary)
                    .tint(AppTheme.accent)

                    Picker("Font Size", selection: $viewModel.fontSize) {
                        Text("Small").tag("small")
                        Text("Medium").tag("medium")
                        Text("Large").tag("large")
                    }
                    .foregroundColor(AppTheme.textPrimary)
                } header: {
                    Text("Preferences")
                        .foregroundColor(AppTheme.textMuted)
                }
                .listRowBackground(AppTheme.surface)

                // About
                Section {
                    HStack {
                        Text("Version")
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundColor(AppTheme.textMuted)
                    }

                    Link(destination: URL(string: "https://bible-copilot-app.netlify.app/privacy.html")!) {
                        HStack {
                            Text("Privacy Policy")
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textMuted)
                        }
                    }

                    Link(destination: URL(string: "https://bible-copilot-app.netlify.app/terms.html")!) {
                        HStack {
                            Text("Terms of Use")
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textMuted)
                        }
                    }

                    Link(destination: URL(string: "https://bible-copilot-app.netlify.app/")!) {
                        HStack {
                            Text("Support")
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.textMuted)
                        }
                    }
                } header: {
                    Text("About")
                        .foregroundColor(AppTheme.textMuted)
                }
                .listRowBackground(AppTheme.surface)

                // Restore Purchases
                Section {
                    Button {
                        Task {
                            try? await subscriptionManager.restorePurchases()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Restore Purchases")
                                .foregroundColor(AppTheme.accent)
                            Spacer()
                        }
                    }
                }
                .listRowBackground(AppTheme.surface)
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

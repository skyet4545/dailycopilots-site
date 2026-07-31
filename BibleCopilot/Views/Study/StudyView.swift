import SwiftUI
import SwiftData

struct StudyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionService.self) private var subscriptionService
    @State private var viewModel: StudyViewModel
    @State private var showShareSheet = false
    @State private var showReminderPrompt = false

    let onShowPaywall: () -> Void

    init(verse: String, initialMode: StudyMode?, onShowPaywall: @escaping () -> Void) {
        _viewModel = State(initialValue: StudyViewModel(verse: verse, initialMode: initialMode))
        self.onShowPaywall = onShowPaywall
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Verse Card
                    VerseCardView(
                        reference: viewModel.verse,
                        text: viewModel.verseText,
                        isLoading: viewModel.verseLoading,
                        isBookmarked: viewModel.isBookmarked,
                        onBookmark: { viewModel.savePassage(context: modelContext) },
                        onShare: {
                            showShareSheet = true
                        }
                    )

                    // Study Mode Pills
                    StudyModePillsView(
                        selectedMode: viewModel.selectedMode,
                        onSelect: { mode in
                            Task {
                                await viewModel.selectMode(mode, isPro: subscriptionService.isPro, onShowPaywall: onShowPaywall)
                            }
                        }
                    )

                    // AI Response
                    if viewModel.aiLoading || !viewModel.aiResponse.isEmpty {
                        AIResponseView(
                            response: viewModel.aiResponse,
                            isLoading: viewModel.aiLoading,
                            error: viewModel.aiError,
                            onSaveToJournal: { viewModel.saveToJournal(context: modelContext) }
                        )
                    }

                    // Follow-up question
                    if viewModel.showFollowUp && !viewModel.aiLoading {
                        VStack(spacing: 8) {
                            if let suggestion = viewModel.suggestedFollowUpQuestion {
                                Button {
                                    Task { await viewModel.askSuggestedFollowUp(isPro: subscriptionService.isPro, onShowPaywall: onShowPaywall) }
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "sparkles")
                                        Text(suggestion).multilineTextAlignment(.leading)
                                        Spacer(minLength: 0)
                                        Image(systemName: "arrow.right")
                                    }
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(AppTheme.accent)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(AppTheme.accent.opacity(0.10))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .accessibilityLabel("Explore next: \(suggestion)")
                            }
                            HStack(spacing: 10) {
                                TextField("Ask a follow-up question...", text: $viewModel.followUpText)
                                    .foregroundColor(AppTheme.textPrimary)
                                    .submitLabel(.send)
                                    .onSubmit {
                                        Task {
                                            await viewModel.askFollowUp(
                                                isPro: subscriptionService.isPro,
                                                onShowPaywall: onShowPaywall
                                            )
                                        }
                                    }

                                if !viewModel.followUpText.isEmpty {
                                    Button {
                                        Task {
                                            await viewModel.askFollowUp(
                                                isPro: subscriptionService.isPro,
                                                onShowPaywall: onShowPaywall
                                            )
                                        }
                                    } label: {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .font(.title3)
                                            .foregroundColor(AppTheme.accent)
                                    }
                                }
                            }
                            .padding()
                            .background(AppTheme.surfaceLight)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppTheme.surfaceBorder, lineWidth: 1)
                            )
                        }
                    }

                    // Cross References
                    if !viewModel.crossReferences.isEmpty {
                        CrossReferencesView(references: viewModel.crossReferences) { ref in
                            // Navigate to new study for this reference & auto-trigger AI
                            let currentMode = viewModel.selectedMode ?? .observe
                            viewModel.verse = ref
                            viewModel.aiResponse = ""
                            viewModel.crossReferences = []
                            Task {
                                await viewModel.fetchVerse()
                                await viewModel.selectMode(
                                    currentMode,
                                    isPro: subscriptionService.isPro,
                                    onShowPaywall: onShowPaywall
                                )
                            }
                        }
                    }

                    // Error state
                    if let error = viewModel.verseError {
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.error)
                            .padding()
                    }

                    Spacer(minLength: 40)
                }
                .padding()
            }
            .background(AppTheme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.down")
                            .foregroundColor(AppTheme.textMuted)
                    }
                }
            }
        }
        .task { await viewModel.fetchVerse() }
        .onDisappear { viewModel.cancelStream() }
        .onChange(of: viewModel.shouldOfferDailyReminder) { _, shouldOffer in
            guard shouldOffer else { return }
            AnalyticsService.shared.track(AnalyticsEvent.reminderPromptShown, ["context": "post_first_successful_question"])
            showReminderPrompt = true
            viewModel.shouldOfferDailyReminder = false
        }
        .sheet(isPresented: $showShareSheet) {
            let text = "\(viewModel.verse)\n\n\(viewModel.verseText)\n\n— Studied with Bible Copilot"
            ActivityView(activityItems: [text])
        }
        .sheet(isPresented: $showReminderPrompt) {
            PostStudyReminderView()
        }
    }
}

private struct PostStudyReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "bell.badge.fill").font(.system(size: 42)).foregroundColor(AppTheme.gold)
                Text("Continue this study tomorrow").font(.title2.bold()).foregroundColor(AppTheme.textPrimary).multilineTextAlignment(.center)
                Text("Choose a time for a gentle daily reminder. You can change it anytime in Settings.")
                    .font(.body).foregroundColor(AppTheme.textMuted).multilineTextAlignment(.center)
                DatePicker("Reminder time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel).labelsHidden().frame(maxHeight: 160)
                Button { Task { await saveReminder() } } label: {
                    if isSaving { ProgressView().tint(.white) } else { Text("Remind me") }
                }
                .buttonStyle(.borderedProminent).tint(AppTheme.accent).disabled(isSaving)
                Button("Not now") {
                    AnalyticsService.shared.track(AnalyticsEvent.reminderPromptDismissed, ["context": "post_first_successful_question"])
                    dismiss()
                }.foregroundColor(AppTheme.textMuted)
            }.padding(28).navigationBarTitleDisplayMode(.inline)
        }
    }

    private func saveReminder() async {
        isSaving = true
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        _ = await NotificationService.shared.enableDailyReminder(hour: components.hour ?? 8, minute: components.minute ?? 0)
        isSaving = false
        dismiss()
    }
}

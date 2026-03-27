import SwiftUI
import SwiftData

struct StudyView: View {
    let initialReference: String
    let initialMode: StudyMode?

    @State private var viewModel = StudyViewModel()
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.modelContext) private var modelContext
    @State private var showPaywall = false
    @State private var showSaveConfirmation = false
    @State private var showCopied = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingLG) {
                // Usage Counter
                if !subscriptionManager.isPro {
                    UsageCounterView()
                        .padding(.horizontal, AppTheme.spacingLG)
                }

                // Verse Display
                if viewModel.isLoadingVerse {
                    ProgressView("Loading verse...")
                        .tint(AppTheme.accent)
                        .padding(AppTheme.spacing2XL)
                } else if let verse = viewModel.verse {
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        Text(verse.reference)
                            .font(AppTheme.sectionFont)
                            .foregroundColor(AppTheme.gold)

                        // Translation picker
                        HStack {
                            Spacer()
                            Menu {
                                ForEach(BibleTranslation.allCases) { translation in
                                    Button(translation.displayName) {
                                        viewModel.selectedTranslation = translation
                                        Task { await viewModel.loadVerse(initialReference) }
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(viewModel.selectedTranslation.displayName)
                                        .font(AppTheme.labelFont)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 10))
                                }
                                .foregroundColor(AppTheme.accent)
                                .padding(.horizontal, AppTheme.spacingSM)
                                .padding(.vertical, AppTheme.spacingXS)
                                .background(AppTheme.accent.opacity(0.15))
                                .cornerRadius(AppTheme.cornerRadiusSM)
                            }
                        }

                        Text(verse.text)
                            .font(AppTheme.scriptureFont)
                            .foregroundColor(AppTheme.textPrimary)
                            .lineSpacing(8)
                    }
                    .padding(AppTheme.spacingLG)
                    .background(AppTheme.surface)
                    .cornerRadius(AppTheme.cornerRadiusMD)
                    .padding(.horizontal, AppTheme.spacingLG)
                }

                // Study Mode Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.spacingSM) {
                        ForEach(StudyMode.allCases) { mode in
                            Button {
                                HapticManager.mediumImpact()
                                let limitReached = subscriptionManager.checkAndIncrementQuestion()
                                if limitReached {
                                    showPaywall = true
                                    return
                                }
                                viewModel.selectMode(mode)
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: mode.icon)
                                        .font(.system(size: 12))
                                    Text(mode.title)
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(viewModel.selectedMode == mode ? .white : mode.color)
                                .padding(.horizontal, AppTheme.spacingMD)
                                .padding(.vertical, AppTheme.spacingSM)
                                .background(
                                    viewModel.selectedMode == mode
                                        ? mode.color
                                        : mode.color.opacity(0.15)
                                )
                                .cornerRadius(AppTheme.cornerRadiusLG)
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.spacingLG)
                }

                // AI Response
                if viewModel.isLoadingAI && viewModel.aiResponse.isEmpty {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(AppTheme.accent)
                        Text("Studying...")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.textMuted)
                    }
                    .padding(AppTheme.spacingXL)
                }

                if !viewModel.aiResponse.isEmpty {
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        if let mode = viewModel.selectedMode {
                            HStack(spacing: 6) {
                                Image(systemName: mode.icon)
                                    .foregroundColor(mode.color)
                                Text(mode.title)
                                    .font(AppTheme.labelFont)
                                    .foregroundColor(mode.color)
                            }
                        }

                        Text(viewModel.aiResponse)
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.textSecondary)
                            .lineSpacing(4)

                        // Cross References
                        let crossRefs = CrossReferenceParser.extractReferences(from: viewModel.aiResponse)
                        if !crossRefs.isEmpty && !viewModel.isLoadingAI {
                            VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
                                Text("Cross References")
                                    .font(AppTheme.labelFont)
                                    .foregroundColor(AppTheme.textMuted)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: AppTheme.spacingSM) {
                                        ForEach(crossRefs, id: \.self) { ref in
                                            NavigationLink {
                                                StudyView(initialReference: ref, initialMode: nil)
                                            } label: {
                                                Text(ref)
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(AppTheme.accent)
                                                    .padding(.horizontal, AppTheme.spacingSM)
                                                    .padding(.vertical, AppTheme.spacingXS)
                                                    .background(AppTheme.accent.opacity(0.15))
                                                    .cornerRadius(AppTheme.cornerRadiusSM)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.top, AppTheme.spacingSM)
                        }

                        // Action Buttons
                        HStack(spacing: AppTheme.spacingMD) {
                            Button {
                                saveResponse()
                                HapticManager.success()
                            } label: {
                                Label("Save", systemImage: "bookmark")
                                    .font(AppTheme.captionFont)
                                    .foregroundColor(AppTheme.accent)
                            }

                            Button {
                                UIPasteboard.general.string = viewModel.aiResponse
                                showCopied = true
                                HapticManager.success()
                                Task {
                                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                                    showCopied = false
                                }
                            } label: {
                                Label(showCopied ? "Copied!" : "Copy", systemImage: showCopied ? "checkmark" : "doc.on.doc")
                                    .font(AppTheme.captionFont)
                                    .foregroundColor(showCopied ? AppTheme.success : AppTheme.textMuted)
                            }

                            Spacer()

                            ShareLink(item: viewModel.aiResponse) {
                                Label("Share", systemImage: "square.and.arrow.up")
                                    .font(AppTheme.captionFont)
                                    .foregroundColor(AppTheme.textMuted)
                            }
                        }
                        .padding(.top, AppTheme.spacingSM)

                        // AI disclaimer
                        Text("AI-generated study aid. Verify with trusted commentaries and pastoral guidance.")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.textMuted)
                            .padding(.top, AppTheme.spacingXS)
                    }
                    .padding(AppTheme.spacingLG)
                    .background(AppTheme.surface)
                    .cornerRadius(AppTheme.cornerRadiusMD)
                    .padding(.horizontal, AppTheme.spacingLG)
                }

                Spacer(minLength: AppTheme.spacing3XL)
            }
            .padding(.top, AppTheme.spacingMD)
        }
        .background(AppTheme.background)
        .navigationTitle(initialReference)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .overlay {
            if showSaveConfirmation {
                savedConfirmationOverlay
            }
        }
        .task {
            await viewModel.loadVerse(initialReference)
            if let mode = initialMode {
                let limitReached = subscriptionManager.checkAndIncrementQuestion()
                if limitReached {
                    showPaywall = true
                } else {
                    viewModel.selectMode(mode)
                }
            }
        }
    }

    private func saveResponse() {
        let item = SavedItem(
            type: .response,
            verseReference: viewModel.verseReference,
            content: viewModel.aiResponse,
            studyMode: viewModel.selectedMode
        )
        modelContext.insert(item)
        showSaveConfirmation = true
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            showSaveConfirmation = false
        }
    }

    private var savedConfirmationOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Saved!")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.textPrimary)
            }
            .padding(.horizontal, AppTheme.spacingLG)
            .padding(.vertical, AppTheme.spacingMD)
            .background(AppTheme.surfaceLight)
            .cornerRadius(AppTheme.cornerRadiusSM)
            .padding(.bottom, AppTheme.spacing2XL)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeInOut, value: showSaveConfirmation)
    }
}

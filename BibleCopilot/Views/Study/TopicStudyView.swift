import SwiftUI

struct TopicStudyView: View {
    let topic: String
    @Environment(\.dismiss) private var dismiss
    @State private var response = ""
    @State private var isLoading = true
    @State private var error: String?
    @State private var crossReferences: [String] = []
    @State private var showCopied = false
    var onStudyVerse: (String) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Topic header
                    Text(topic)
                        .font(.title2.bold())
                        .foregroundColor(AppTheme.textPrimary)
                        .padding(.horizontal)

                    // AI Response
                    if isLoading {
                        VStack(spacing: 12) {
                            LoadingDotsView()
                            Text("Searching Scripture...")
                                .font(.caption)
                                .foregroundColor(AppTheme.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else if let error {
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title2)
                                .foregroundColor(AppTheme.error)
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textMuted)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    } else {
                        Text(response)
                            .font(.body)
                            .foregroundColor(AppTheme.textPrimary)
                            .lineSpacing(6)
                            .padding(.horizontal)

                        // Copy button
                        HStack {
                            Button {
                                UIPasteboard.general.string = response
                                showCopied = true
                                HapticService.success()
                                Task {
                                    try? await Task.sleep(for: .seconds(1.5))
                                    showCopied = false
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                                    Text(showCopied ? "Copied!" : "Copy")
                                }
                                .font(.caption.weight(.medium))
                                .foregroundColor(showCopied ? AppTheme.success : AppTheme.textMuted)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)

                        // AI disclaimer
                        Text("AI-generated study aid. Verify with trusted commentaries and pastoral guidance.")
                            .font(.caption2)
                            .foregroundColor(AppTheme.textMuted)
                            .padding(.horizontal)

                        // Tappable cross-references
                        if !crossReferences.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("STUDY THESE PASSAGES")
                                    .font(.caption.bold())
                                    .foregroundColor(AppTheme.textMuted)
                                    .tracking(1.2)

                                FlowLayout(spacing: 8) {
                                    ForEach(crossReferences, id: \.self) { ref in
                                        Button {
                                            dismiss()
                                            onStudyVerse(ref)
                                        } label: {
                                            Text(ref)
                                                .font(.caption.bold())
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(AppTheme.accent.opacity(0.15))
                                                .foregroundColor(AppTheme.accent)
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .background(AppTheme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.textMuted)
                    }
                }
            }
        }
        .task { await fetchTopicStudy() }
    }

    private func fetchTopicStudy() async {
        let usageService = UsageService.shared
        let isPro = SubscriptionService.shared.isPro
        guard usageService.canAsk(isPro: isPro) else {
            self.error = "You've used all 3 free questions today. Upgrade to Pro for unlimited access."
            isLoading = false
            return
        }

        isLoading = true
        do {
            let stream = await AIService.shared.streamTopicResponse(topic: topic)
            for try await chunk in stream {
                response += chunk
            }
            crossReferences = CrossReferenceParser.extractReferences(from: response, limit: 8)
            usageService.recordQuestion()
            HapticService.success()
        } catch {
            self.error = "Unable to search Scripture for this topic. Check your internet connection."
        }
        isLoading = false
    }
}

// FlowLayout is defined in CrossReferencesView.swift

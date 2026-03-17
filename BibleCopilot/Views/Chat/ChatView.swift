import SwiftUI

/// A simple in-memory chat message (not persisted via SwiftData).
struct ChatBubbleMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp = Date()
}

struct ChatView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var messages: [ChatBubbleMessage] = [
        ChatBubbleMessage(
            text: "Hello! I'm Bible Copilot, your AI-powered Bible study companion. Ask me anything about Scripture, theology, or faith.",
            isUser: false
        )
    ]
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false
    @State private var showPaywall: Bool = false
    @State private var streamingText: String = ""

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }

                        // Streaming response
                        if !streamingText.isEmpty {
                            HStack(alignment: .bottom, spacing: 8) {
                                Image(systemName: "book.fill")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.accent)
                                    .frame(width: 28, height: 28)
                                    .background(AppTheme.accent.opacity(0.1))
                                    .clipShape(Circle())

                                Text(streamingText)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(AppTheme.surface)
                                    .foregroundColor(AppTheme.textPrimary)
                                    .cornerRadius(18)

                                Spacer(minLength: 60)
                            }
                            .padding(.horizontal, 12)
                            .id("streaming")
                        }

                        if isLoading && streamingText.isEmpty {
                            HStack {
                                HStack(spacing: 6) {
                                    ForEach(0..<3, id: \.self) { i in
                                        Circle()
                                            .fill(AppTheme.textMuted)
                                            .frame(width: 7, height: 7)
                                            .scaleEffect(isLoading ? 1 : 0.5)
                                            .animation(
                                                .easeInOut(duration: 0.6).repeatForever().delay(Double(i) * 0.2),
                                                value: isLoading
                                            )
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(AppTheme.surface)
                                .cornerRadius(18)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .id("loading")
                        }
                    }
                    .padding(.vertical, 12)
                }
                .onChange(of: messages.count) {
                    if let last = messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: streamingText) {
                    withAnimation {
                        proxy.scrollTo("streaming", anchor: .bottom)
                    }
                }
                .onChange(of: isLoading) {
                    if isLoading {
                        withAnimation {
                            proxy.scrollTo("loading", anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Usage counter
            if !subscriptionManager.isPro {
                UsageCounterView()
            }

            // Input area
            HStack(alignment: .bottom, spacing: 10) {
                TextField("Ask a Bible question...", text: $inputText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...5)
                    .frame(minHeight: 36)
                    .onSubmit {
                        if canSend { sendMessage() }
                    }

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(canSend ? AppTheme.accent : AppTheme.textMuted)
                }
                .disabled(!canSend)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(AppTheme.background)
        .navigationTitle("Bible Copilot")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .onChange(of: subscriptionManager.showPaywall) {
            if subscriptionManager.showPaywall {
                showPaywall = true
                subscriptionManager.showPaywall = false
            }
        }
    }

    var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        // CRITICAL: Check question limit BEFORE responding
        // If limit reached -> show paywall. Do NOT show an error.
        let limitReached = subscriptionManager.checkAndIncrementQuestion()
        if limitReached {
            showPaywall = true
            return
        }

        inputText = ""
        messages.append(ChatBubbleMessage(text: text, isUser: true))
        isLoading = true
        streamingText = ""

        Task {
            do {
                for try await chunk in AIService.shared.streamResponse(question: text) {
                    await MainActor.run {
                        streamingText += chunk
                    }
                }
            } catch {
                // Handled by AIService fallback
            }

            await MainActor.run {
                let finalText = streamingText.isEmpty
                    ? "I couldn't process that request. Please try again."
                    : streamingText
                messages.append(ChatBubbleMessage(text: finalText, isUser: false))
                streamingText = ""
                isLoading = false
            }
        }
    }
}

struct MessageBubble: View {
    let message: ChatBubbleMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 60)
            } else {
                Image(systemName: "book.fill")
                    .font(.caption)
                    .foregroundColor(AppTheme.accent)
                    .frame(width: 28, height: 28)
                    .background(AppTheme.accent.opacity(0.1))
                    .clipShape(Circle())
            }

            Text(message.text)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(message.isUser ? AppTheme.accent : AppTheme.surface)
                .foregroundColor(message.isUser ? .white : AppTheme.textPrimary)
                .cornerRadius(18)
                .cornerRadius(
                    message.isUser ? 4 : 18,
                    corners: message.isUser ? .bottomRight : .bottomLeft
                )

            if !message.isUser {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 12)
    }
}

// Extension for individual corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

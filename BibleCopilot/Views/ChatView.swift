import SwiftUI

struct ChatView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var messages: [ChatMessage] = [
        ChatMessage(
            text: "Hello! I'm Bible Copilot, your AI-powered Bible study companion. Ask me anything about Scripture, theology, or faith.",
            isUser: false
        )
    ]
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false
    @State private var showPaywall: Bool = false

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
                        if isLoading {
                            HStack {
                                HStack(spacing: 6) {
                                    ForEach(0..<3) { i in
                                        Circle()
                                            .fill(Color.secondary)
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
                                .background(Color(.systemGray6))
                                .cornerRadius(18)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .id("loading")
                        }
                    }
                    .padding(.vertical, 12)
                }
                .onChange(of: messages.count) { _ in
                    if let last = messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: isLoading) { loading in
                    if loading {
                        withAnimation {
                            proxy.scrollTo("loading", anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Question count indicator
            if !subscriptionManager.isPro {
                let used = subscriptionManager.questionCount
                let limit = subscriptionManager.freeQuestionLimit
                let remaining = max(0, limit - used)

                HStack {
                    Image(systemName: remaining > 0 ? "questionmark.circle" : "lock.fill")
                        .foregroundColor(remaining > 0 ? .secondary : .orange)
                        .font(.caption)
                    Text(remaining > 0
                        ? "\(remaining) free question\(remaining == 1 ? "" : "s") remaining"
                        : "Free questions used - upgrade to continue")
                        .font(.caption)
                        .foregroundColor(remaining > 0 ? .secondary : .orange)
                    Spacer()
                    if remaining == 0 {
                        Button("Upgrade") {
                            showPaywall = true
                        }
                        .font(.caption.bold())
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
            }

            // Input area
            HStack(alignment: .bottom, spacing: 10) {
                if #available(iOS 16.0, *) {
                    TextField("Ask a Bible question...", text: $inputText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...5)
                        .frame(minHeight: 36)
                        .onSubmit {
                            if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                sendMessage()
                            }
                        }
                } else {
                    TextField("Ask a Bible question...", text: $inputText)
                        .textFieldStyle(.roundedBorder)
                        .frame(minHeight: 36)
                        .onSubmit {
                            if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                sendMessage()
                            }
                        }
                }

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(canSend ? .blue : Color(.systemGray4))
                }
                .disabled(!canSend)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .navigationTitle("Bible Copilot")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .onChange(of: subscriptionManager.showPaywall) { newValue in
            if newValue {
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
        messages.append(ChatMessage(text: text, isUser: true))
        isLoading = true

        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            let response = await AIService.shared.askQuestion(text)
            await MainActor.run {
                messages.append(ChatMessage(text: response, isUser: false))
                isLoading = false
            }
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp = Date()
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 60)
            } else {
                Image(systemName: "book.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .frame(width: 28, height: 28)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }

            Text(message.text)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(message.isUser ? Color.blue : Color(.systemGray6))
                .foregroundColor(message.isUser ? .white : .primary)
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

// Extension to allow individual corner radius
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

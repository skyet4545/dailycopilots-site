import StoreKit

final class ReviewService {
    static let shared = ReviewService()

    private let studyCountKey = "review_studyCount"
    private let hasRequestedKey = "review_hasRequested"

    /// Call after each completed study. Prompts for review after 5 studies.
    func recordStudyAndPromptIfReady() {
        let count = UserDefaults.standard.integer(forKey: studyCountKey) + 1
        UserDefaults.standard.set(count, forKey: studyCountKey)

        let hasRequested = UserDefaults.standard.bool(forKey: hasRequestedKey)

        // Prompt at 5, 15, and 50 studies
        let milestones = [5, 15, 50]
        if milestones.contains(count) && !hasRequested {
            requestReview()
            if count >= 5 {
                UserDefaults.standard.set(true, forKey: hasRequestedKey)
            }
        }
    }

    private func requestReview() {
        Task { @MainActor in
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                AppStore.requestReview(in: scene)
            }
        }
    }
}

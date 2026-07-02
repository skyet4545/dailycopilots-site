import StoreKit

final class ReviewService {
    static let shared = ReviewService()

    private let studyCountKey = "review_studyCount"
    private let lastPromptMilestoneKey = "review_lastPromptMilestone"

    func recordStudyAndPromptIfReady() {
        let count = UserDefaults.standard.integer(forKey: studyCountKey) + 1
        UserDefaults.standard.set(count, forKey: studyCountKey)

        let lastMilestone = UserDefaults.standard.integer(forKey: lastPromptMilestoneKey)

        // Prompt at 3, 10, and 30 studies (each only once).
        // 3 is reachable on day one within the free tier's 3 questions/day —
        // right after the third successful answer, the strongest aha moment.
        let milestones = [3, 10, 30]
        if milestones.contains(count) && count > lastMilestone {
            requestReview()
            UserDefaults.standard.set(count, forKey: lastPromptMilestoneKey)
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

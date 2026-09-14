import StoreKit

final class ReviewService {
    static let shared = ReviewService()

    private let studyCountKey = "review_studyCount"
    private let lastPromptMilestoneKey = "review_lastPromptMilestone"
    private let defaults: UserDefaults
    private let requestReviewAction: () -> Void
    private let trackPromptRequest: (Int) -> Void

    init(
        defaults: UserDefaults = .standard,
        requestReviewAction: (() -> Void)? = nil,
        trackPromptRequest: ((Int) -> Void)? = nil
    ) {
        self.defaults = defaults
        self.requestReviewAction = requestReviewAction ?? Self.requestReviewInActiveScene
        self.trackPromptRequest = trackPromptRequest ?? { milestone in
            AnalyticsService.shared.track(
                AnalyticsEvent.reviewPromptRequested,
                ["study_milestone": "\(milestone)"]
            )
        }
    }

    @discardableResult
    func recordStudyAndPromptIfReady() -> Int? {
        let count = defaults.integer(forKey: studyCountKey) + 1
        defaults.set(count, forKey: studyCountKey)

        let lastMilestone = defaults.integer(forKey: lastPromptMilestoneKey)

        // Prompt at 3, 10, and 30 studies (each only once).
        // 3 is reachable on day one within the free tier's 3 questions/day —
        // right after the third successful answer, the strongest aha moment.
        let milestones = [3, 10, 30]
        if milestones.contains(count) && count > lastMilestone {
            trackPromptRequest(count)
            requestReviewAction()
            defaults.set(count, forKey: lastPromptMilestoneKey)
            return count
        }
        return nil
    }

    private static func requestReviewInActiveScene() {
        Task { @MainActor in
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                AppStore.requestReview(in: scene)
            }
        }
    }
}

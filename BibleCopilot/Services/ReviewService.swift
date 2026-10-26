import StoreKit

final class ReviewService {
    static let shared = ReviewService()

    private let studyCountKey = "review_studyCount"
    private let lastPromptMilestoneKey = "review_lastPromptMilestone"
    private let savePromptKey = "review_promptedForSave"
    private let defaults: UserDefaults
    private let requestReviewAction: () -> Void
    private let trackPromptRequest: (Int) -> Void
    private let trackSavePromptRequest: () -> Void
    /// Stops a save-triggered request from stacking on a milestone request in this process.
    private var requestedThisProcess = false

    init(
        defaults: UserDefaults = .standard,
        requestReviewAction: (() -> Void)? = nil,
        trackPromptRequest: ((Int) -> Void)? = nil,
        trackSavePromptRequest: (() -> Void)? = nil
    ) {
        self.defaults = defaults
        self.requestReviewAction = requestReviewAction ?? Self.requestReviewInActiveScene
        self.trackPromptRequest = trackPromptRequest ?? { milestone in
            AnalyticsService.shared.track(
                AnalyticsEvent.reviewPromptRequested,
                ["study_milestone": "\(milestone)"]
            )
        }
        self.trackSavePromptRequest = trackSavePromptRequest ?? {
            AnalyticsService.shared.track(
                AnalyticsEvent.reviewPromptRequested,
                ["source": "saved_study"]
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
            requestedThisProcess = true
            requestReviewAction()
            defaults.set(count, forKey: lastPromptMilestoneKey)
            return count
        }
        return nil
    }

    /// A saved passage or journal entry is a positive moment. Ask once ever, and
    /// skip it when this process already requested a review for a study milestone.
    @discardableResult
    func recordSavedStudyAndPromptIfReady() -> Bool {
        guard !requestedThisProcess else { return false }
        guard !defaults.bool(forKey: savePromptKey) else { return false }
        defaults.set(true, forKey: savePromptKey)
        requestedThisProcess = true
        trackSavePromptRequest()
        requestReviewAction()
        return true
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

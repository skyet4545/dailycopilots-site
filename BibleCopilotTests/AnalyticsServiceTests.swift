import XCTest
@testable import BibleCopilot

final class AnalyticsServiceTests: XCTestCase {
    private let defaults = UserDefaults.standard
    private var priorConsent: Any?
    private var priorDeviceID: Any?

    override func setUp() {
        super.setUp()
        priorConsent = defaults.object(forKey: AnalyticsService.consentKey)
        priorDeviceID = defaults.object(forKey: "analyticsDeviceId")
    }

    override func tearDown() {
        restore(priorConsent, key: AnalyticsService.consentKey)
        restore(priorDeviceID, key: "analyticsDeviceId")
        super.tearDown()
    }

    func testAnalyticsRequiresExplicitConsent() {
        defaults.removeObject(forKey: AnalyticsService.consentKey)
        XCTAssertFalse(AnalyticsService.shared.isEnabled)

        AnalyticsService.shared.setEnabled(true)
        XCTAssertTrue(AnalyticsService.shared.isEnabled)
    }

    func testWithdrawingConsentRemovesPersistentDeviceIdentifier() {
        defaults.set("test-device-id", forKey: "analyticsDeviceId")

        AnalyticsService.shared.setEnabled(false)

        XCTAssertNil(defaults.object(forKey: "analyticsDeviceId"))
    }

    private func restore(_ value: Any?, key: String) {
        if let value {
            defaults.set(value, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }
}

final class ReviewServiceTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "ReviewServiceTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testRequestsOnlyAtConfiguredSuccessfulStudyMilestones() {
        var requested = 0
        var tracked: [Int] = []
        let service = ReviewService(
            defaults: defaults,
            requestReviewAction: { requested += 1 },
            trackPromptRequest: { tracked.append($0) }
        )

        var returned: [Int] = []
        for _ in 1...30 {
            if let milestone = service.recordStudyAndPromptIfReady() {
                returned.append(milestone)
            }
        }

        XCTAssertEqual(returned, [3, 10, 30])
        XCTAssertEqual(tracked, [3, 10, 30])
        XCTAssertEqual(requested, 3)
    }

    func testExistingMilestoneCannotRequestTwice() {
        defaults.set(2, forKey: "review_studyCount")
        defaults.set(3, forKey: "review_lastPromptMilestone")
        var requested = 0
        let service = ReviewService(
            defaults: defaults,
            requestReviewAction: { requested += 1 },
            trackPromptRequest: { _ in XCTFail("A completed milestone must not be tracked twice") }
        )

        XCTAssertNil(service.recordStudyAndPromptIfReady())
        XCTAssertEqual(requested, 0)
    }
}

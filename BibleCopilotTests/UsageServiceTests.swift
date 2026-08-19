import XCTest
@testable import BibleCopilot

final class UsageServiceTests: XCTestCase {

    var service: UsageService!

    override func setUp() {
        super.setUp()
        service = UsageService()
        // Reset stored values
        UserDefaults.standard.removeObject(forKey: "usageDate")
        UserDefaults.standard.removeObject(forKey: "usageCount")
        UserDefaults.standard.removeObject(forKey: "hasCompletedFirstQuestion")
    }

    // MARK: - Free Tier Limits

    func testFreeUserCanAskWhenUnderLimit() {
        XCTAssertTrue(service.canAsk(isPro: false))
    }

    func testFreeUserBlockedAtLimit() {
        for _ in 0..<3 {
            service.recordQuestion()
        }
        XCTAssertFalse(service.canAsk(isPro: false))
    }

    func testFreeUserAllowed2Questions() {
        for _ in 0..<2 {
            service.recordQuestion()
        }
        XCTAssertTrue(service.canAsk(isPro: false))
    }

    func testFreeUserBlockedAt3Questions() {
        for _ in 0..<3 {
            service.recordQuestion()
        }
        XCTAssertFalse(service.canAsk(isPro: false))
        XCTAssertEqual(service.remainingQuestions(isPro: false), 0)
    }

    // MARK: - Pro Tier

    func testProUserAlwaysAllowed() {
        for _ in 0..<50 {
            service.recordQuestion()
        }
        XCTAssertTrue(service.canAsk(isPro: true))
    }

    func testProUserUnlimitedRemaining() {
        XCTAssertEqual(service.remainingQuestions(isPro: true), .max)
    }

    // MARK: - Question Counting

    func testRecordIncrementsCount() {
        XCTAssertEqual(service.usedToday, 0)
        service.recordQuestion()
        XCTAssertEqual(service.usedToday, 1)
        service.recordQuestion()
        XCTAssertEqual(service.usedToday, 2)
    }

    func testRemainingDecrements() {
        XCTAssertEqual(service.remainingQuestions(isPro: false), 3)
        service.recordQuestion()
        XCTAssertEqual(service.remainingQuestions(isPro: false), 2)
    }

    // MARK: - Midnight Reset

    func testResetOnNewDay() {
        // Simulate questions from yesterday
        UserDefaults.standard.set("2020-01-01", forKey: "usageDate")
        UserDefaults.standard.set(3, forKey: "usageCount")

        // Should reset because today != 2020-01-01
        XCTAssertTrue(service.canAsk(isPro: false))
        XCTAssertEqual(service.usedToday, 0)
    }

    // MARK: - Constants

    func testFreeQuestionLimitMatchesProductTruth() {
        XCTAssertEqual(UsageService.freeQuestionsPerDay, 3)
    }

    func testOnlyFirstSuccessfulQuestionReturnsTrue() {
        XCTAssertTrue(service.recordQuestion())
        XCTAssertFalse(service.recordQuestion())
    }
}

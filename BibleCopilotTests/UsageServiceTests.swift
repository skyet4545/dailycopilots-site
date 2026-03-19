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
    }

    // MARK: - Free Tier Limits

    func testFreeUserCanAskWhenUnderLimit() {
        XCTAssertTrue(service.canAsk(isPro: false))
    }

    func testFreeUserBlockedAtLimit() {
        for _ in 0..<10 {
            service.recordQuestion()
        }
        XCTAssertFalse(service.canAsk(isPro: false))
    }

    func testFreeUserAllowed9Questions() {
        for _ in 0..<9 {
            service.recordQuestion()
        }
        XCTAssertTrue(service.canAsk(isPro: false))
    }

    func testFreeUserBlockedAt10Questions() {
        for _ in 0..<10 {
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
        XCTAssertEqual(service.remainingQuestions(isPro: false), 10)
        service.recordQuestion()
        XCTAssertEqual(service.remainingQuestions(isPro: false), 9)
    }

    // MARK: - Midnight Reset

    func testResetOnNewDay() {
        // Simulate questions from yesterday
        UserDefaults.standard.set("2020-01-01", forKey: "usageDate")
        UserDefaults.standard.set(10, forKey: "usageCount")

        // Should reset because today != 2020-01-01
        XCTAssertTrue(service.canAsk(isPro: false))
        XCTAssertEqual(service.usedToday, 0)
    }

    // MARK: - Constants

    func testFreeQuestionLimitIs10() {
        XCTAssertEqual(UsageService.freeQuestionsPerDay, 10)
    }
}

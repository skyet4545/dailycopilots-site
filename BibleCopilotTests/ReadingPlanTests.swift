import XCTest
@testable import BibleCopilot

final class ReadingPlanTests: XCTestCase {

    // MARK: - Plan Definitions

    func testAllFivePlansExist() {
        XCTAssertEqual(ReadingPlan.allPlans.count, 5)
    }

    func testPlanIDs() {
        let ids = ReadingPlan.allPlans.map(\.id)
        XCTAssertTrue(ids.contains("gospel-of-john"))
        XCTAssertTrue(ids.contains("30-days-of-psalms"))
        XCTAssertTrue(ids.contains("romans-deep-dive"))
        XCTAssertTrue(ids.contains("proverbs-31"))
        XCTAssertTrue(ids.contains("sermon-on-the-mount"))
    }

    func testPlanDayCounts() {
        let plans = ReadingPlan.allPlans
        let byID = Dictionary(uniqueKeysWithValues: plans.map { ($0.id, $0) })

        XCTAssertEqual(byID["gospel-of-john"]?.dayCount, 21)
        XCTAssertEqual(byID["30-days-of-psalms"]?.dayCount, 30)
        XCTAssertEqual(byID["romans-deep-dive"]?.dayCount, 16)
        XCTAssertEqual(byID["proverbs-31"]?.dayCount, 31)
        XCTAssertEqual(byID["sermon-on-the-mount"]?.dayCount, 7)
    }

    func testVersesMatchDayCount() {
        for plan in ReadingPlan.allPlans {
            XCTAssertEqual(
                plan.verses.count, plan.dayCount,
                "\(plan.title) has \(plan.verses.count) verses but claims \(plan.dayCount) days"
            )
        }
    }

    func testAllPlansHaveTitle() {
        for plan in ReadingPlan.allPlans {
            XCTAssertFalse(plan.title.isEmpty, "Plan \(plan.id) needs a title")
        }
    }

    func testAllPlansHaveDescription() {
        for plan in ReadingPlan.allPlans {
            XCTAssertFalse(plan.description.isEmpty, "Plan \(plan.id) needs a description")
        }
    }

    func testAllPlansHaveIcon() {
        for plan in ReadingPlan.allPlans {
            XCTAssertFalse(plan.icon.isEmpty, "Plan \(plan.id) needs an icon")
        }
    }

    func testAllVersesAreNonEmpty() {
        for plan in ReadingPlan.allPlans {
            for (index, verse) in plan.verses.enumerated() {
                XCTAssertFalse(verse.isEmpty, "\(plan.title) day \(index + 1) has empty verse")
            }
        }
    }

    // MARK: - Proverbs 31 Plan

    func testProverbs31HasAllChapters() {
        let plan = ReadingPlan.allPlans.first { $0.id == "proverbs-31" }!
        for i in 1...31 {
            XCTAssertTrue(
                plan.verses.contains("Proverbs \(i)"),
                "Missing Proverbs \(i)"
            )
        }
    }

    // MARK: - Sermon on the Mount

    func testSermonOnTheMountIsMatthew5to7() {
        let plan = ReadingPlan.allPlans.first { $0.id == "sermon-on-the-mount" }!
        for verse in plan.verses {
            XCTAssertTrue(
                verse.starts(with: "Matthew"),
                "Sermon on the Mount should only contain Matthew verses, got: \(verse)"
            )
        }
    }

    // MARK: - Progress Model

    func testProgressInitialState() {
        let progress = ReadingPlanProgress(planId: "gospel-of-john")
        XCTAssertEqual(progress.completedDays.count, 0)
        XCTAssertEqual(progress.completedCount, 0)
        XCTAssertNil(progress.lastReadAt)
    }

    func testProgressDayCompletion() {
        let progress = ReadingPlanProgress(planId: "gospel-of-john")
        progress.completedDays.append(0)
        progress.completedDays.append(1)

        XCTAssertTrue(progress.isCompleted(day: 0))
        XCTAssertTrue(progress.isCompleted(day: 1))
        XCTAssertFalse(progress.isCompleted(day: 2))
        XCTAssertEqual(progress.completedCount, 2)
    }
}

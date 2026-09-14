import XCTest
@testable import BibleCopilot

final class StudyResumeReminderTests: XCTestCase {
    override func tearDown() {
        let defaults = UserDefaults.standard
        for key in ["study_reference", "study_mode", "pending_study_reference", "pending_study_mode"] {
            defaults.removeObject(forKey: key)
        }
        super.tearDown()
    }

    func testContextualContentCarriesPassageAndMode() {
        let content = NotificationService.shared.makeDailyReminderContent(
            reference: "Romans 8:28",
            mode: .interpret
        )

        XCTAssertEqual(content.title, "Continue Romans 8:28")
        XCTAssertTrue(content.body.contains("interpret"))
        XCTAssertEqual(content.userInfo["study_reference"] as? String, "Romans 8:28")
        XCTAssertEqual(content.userInfo["study_mode"] as? String, "interpret")
    }

    func testGenericContentHasNoNavigationPayload() {
        let content = NotificationService.shared.makeDailyReminderContent(reference: nil, mode: nil)

        XCTAssertEqual(content.title, "Time to Study")
        XCTAssertNil(content.userInfo["study_reference"])
    }

    func testResumeRequestRejectsMalformedReference() {
        XCTAssertNil(StudyResumeRequest(userInfo: ["study_reference": "Hezekiah 3:17", "study_mode": "summary"]))
    }

    func testResumeRequestAcceptsCanonicalReferenceAndKnownMode() {
        let request = StudyResumeRequest(userInfo: ["study_reference": "John 3:16", "study_mode": "observe"])

        XCTAssertEqual(request, StudyResumeRequest(reference: "John 3:16", mode: .observe))
    }

    func testPendingResumeIsConsumedExactlyOnce() {
        NotificationService.shared.recordPendingStudyResume(userInfo: [
            "study_reference": "Psalm 23:1",
            "study_mode": "apply"
        ])

        XCTAssertEqual(
            NotificationService.shared.consumePendingStudyResume(),
            StudyResumeRequest(reference: "Psalm 23:1", mode: .apply)
        )
        XCTAssertNil(NotificationService.shared.consumePendingStudyResume())
    }
}

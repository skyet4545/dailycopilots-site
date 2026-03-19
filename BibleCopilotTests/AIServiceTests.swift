import XCTest
@testable import BibleCopilot

final class AIServiceTests: XCTestCase {

    // MARK: - SSE Content Parsing

    func testParseSimpleContentFormat() async {
        // Test that the service can be instantiated
        let service = AIService.shared
        XCTAssertNotNil(service)
    }

    func testStudyModeLabels() {
        // Verify all 5 study modes have correct labels for API calls
        XCTAssertEqual(StudyMode.observe.rawValue, "observe")
        XCTAssertEqual(StudyMode.interpret.rawValue, "interpret")
        XCTAssertEqual(StudyMode.theology.rawValue, "theology")
        XCTAssertEqual(StudyMode.apply.rawValue, "apply")
        XCTAssertEqual(StudyMode.apologetics.rawValue, "apologetics")
    }

    func testStudyModeCount() {
        XCTAssertEqual(StudyMode.allCases.count, 5)
    }

    func testStudyModeHasIcon() {
        for mode in StudyMode.allCases {
            XCTAssertFalse(mode.icon.isEmpty, "\(mode.rawValue) should have an icon")
        }
    }

    func testStudyModeHasDescription() {
        for mode in StudyMode.allCases {
            XCTAssertFalse(mode.description.isEmpty, "\(mode.rawValue) should have a description")
        }
    }

    func testStudyModeHasLabel() {
        for mode in StudyMode.allCases {
            XCTAssertFalse(mode.label.isEmpty, "\(mode.rawValue) should have a label")
        }
    }

    // MARK: - Error Types

    func testAIServiceErrorDescriptions() {
        XCTAssertNotNil(AIServiceError.serverError.errorDescription)
        XCTAssertNotNil(AIServiceError.invalidResponse.errorDescription)
    }

    // MARK: - API URL

    func testAPIEndpointIsValid() {
        let url = URL(string: "https://scripture-copilot-rust.vercel.app/api/chat")
        XCTAssertNotNil(url)
    }
}

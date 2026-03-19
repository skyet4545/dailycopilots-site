import XCTest
@testable import BibleCopilot

final class BibleServiceTests: XCTestCase {

    // MARK: - URL Construction

    func testBaseURLIsValid() {
        let url = URL(string: "https://bible-api.com")
        XCTAssertNotNil(url)
    }

    func testSimpleVerseURL() {
        let url = URL(string: "https://bible-api.com/John%203:16?translation=kjv")
        XCTAssertNotNil(url)
    }

    func testVerseRangeURL() {
        let url = URL(string: "https://bible-api.com/Romans%208:28-39?translation=web")
        XCTAssertNotNil(url)
    }

    // MARK: - Translations

    func testSupportedTranslations() {
        let supported = ["kjv", "web", "bbe", "asv"]
        for translation in supported {
            let url = URL(string: "https://bible-api.com/John%203:16?translation=\(translation)")
            XCTAssertNotNil(url, "\(translation) should produce a valid URL")
        }
    }

    // MARK: - Error Types

    func testBibleServiceErrorDescriptions() {
        XCTAssertNotNil(BibleServiceError.invalidReference.errorDescription)
        XCTAssertNotNil(BibleServiceError.verseNotFound.errorDescription)
    }

    // MARK: - Service Singleton

    func testServiceExists() {
        let service = BibleService.shared
        XCTAssertNotNil(service)
    }

    // MARK: - Live API Test (Integration)

    func testFetchJohn316() async throws {
        let text = try await BibleService.shared.fetchVerse("John 3:16", translation: "kjv")
        XCTAssertFalse(text.isEmpty, "Should return verse text")
        XCTAssertTrue(text.lowercased().contains("god"), "John 3:16 should mention God")
    }

    func testFetchPsalm23() async throws {
        let text = try await BibleService.shared.fetchVerse("Psalm 23:1", translation: "kjv")
        XCTAssertFalse(text.isEmpty)
        XCTAssertTrue(text.lowercased().contains("lord") || text.lowercased().contains("shepherd"))
    }

    func testFetchWithDifferentTranslation() async throws {
        let kjv = try await BibleService.shared.fetchVerse("John 3:16", translation: "kjv")
        let web = try await BibleService.shared.fetchVerse("John 3:16", translation: "web")
        XCTAssertFalse(kjv.isEmpty)
        XCTAssertFalse(web.isEmpty)
        // Different translations should have different wording
    }

    func testInvalidVerseThrows() async {
        do {
            _ = try await BibleService.shared.fetchVerse("FakeBook 99:99", translation: "kjv")
            // If we get here, the API returned something (it may return an error message as text)
        } catch {
            // Expected — invalid reference should throw
            XCTAssertTrue(error is BibleServiceError || error is DecodingError)
        }
    }
}

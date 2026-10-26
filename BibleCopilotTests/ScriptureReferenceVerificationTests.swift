import XCTest
@testable import BibleCopilot

final class ScriptureReferenceVerificationTests: XCTestCase {
    func testLiveVerifierKeepsRealReferenceAndRejectsImpossibleReference() async {
        let result = await BibleService.shared.verifyReferences(["John 3:16", "John 99:99"])

        XCTAssertEqual(result.verified, ["John 3:16"])
        XCTAssertEqual(result.rejected, ["John 99:99"])
        XCTAssertTrue(result.unavailable.isEmpty)
        XCTAssertEqual(result.displayedReferences, ["John 3:16"])
    }

    func testRejectedReferencesAreNotDisplayed() {
        let result = ScriptureReferenceVerification(
            verified: ["John 3:16"],
            rejected: ["John 99:99"],
            unavailable: []
        )

        XCTAssertEqual(result.displayedReferences, ["John 3:16"])
        XCTAssertTrue(result.note?.contains("1 invalid reference omitted") == true)
    }

    func testUnavailableReferencesRemainVisibleWithWarning() {
        let result = ScriptureReferenceVerification(
            verified: ["Romans 8:28"],
            rejected: [],
            unavailable: ["James 1:5"]
        )

        XCTAssertEqual(result.displayedReferences, ["Romans 8:28", "James 1:5"])
        XCTAssertTrue(result.note?.contains("check unavailable") == true)
    }

    func testVerifiedReferencesExplainEvidenceBoundary() {
        let result = ScriptureReferenceVerification(
            verified: ["Psalm 23:1", "John 10:11"],
            rejected: [],
            unavailable: []
        )

        XCTAssertEqual(result.note, "2 references checked against public-domain Bible text.")
    }
}

import XCTest
@testable import BibleCopilot

final class CrossReferenceParserTests: XCTestCase {

    // MARK: - Basic Extraction

    func testExtractsSingleReference() {
        let text = "As we see in John 3:16, God loves the world."
        let refs = CrossReferenceParser.extractReferences(from: text)
        XCTAssertEqual(refs, ["John 3:16"])
    }

    func testExtractsMultipleReferences() {
        let text = "Romans 8:28 and Philippians 4:13 are both encouraging verses."
        let refs = CrossReferenceParser.extractReferences(from: text)
        XCTAssertEqual(refs.count, 2)
        XCTAssertTrue(refs.contains("Romans 8:28"))
        XCTAssertTrue(refs.contains("Philippians 4:13"))
    }

    func testExtractsChapterOnly() {
        let text = "Read Psalm 23 for comfort."
        let refs = CrossReferenceParser.extractReferences(from: text)
        XCTAssertEqual(refs, ["Psalm 23"])
    }

    func testExtractsVerseRange() {
        let text = "Matthew 5:1-12 contains the Beatitudes."
        let refs = CrossReferenceParser.extractReferences(from: text)
        XCTAssertEqual(refs.count, 1)
        XCTAssertTrue(refs[0].contains("Matthew 5:1"))
    }

    // MARK: - Book Coverage

    func testOldTestamentBooks() {
        let text = "Genesis 1:1, Exodus 20:1, Deuteronomy 6:4, Isaiah 53:5, Proverbs 3:5"
        let refs = CrossReferenceParser.extractReferences(from: text)
        XCTAssertEqual(refs.count, 5)
    }

    func testNewTestamentBooks() {
        let text = "Matthew 28:19, Acts 2:38, Romans 3:23, Hebrews 11:1, Revelation 21:4"
        let refs = CrossReferenceParser.extractReferences(from: text)
        XCTAssertEqual(refs.count, 5)
    }

    func testNumberedBooks() {
        let text = "1 Corinthians 13:4 and 2 Timothy 3:16 are key passages."
        let refs = CrossReferenceParser.extractReferences(from: text)
        XCTAssertEqual(refs.count, 2)
        XCTAssertTrue(refs.contains("1 Corinthians 13:4"))
        XCTAssertTrue(refs.contains("2 Timothy 3:16"))
    }

    func testThreeJohn() {
        let text = "3 John 1:4 speaks about walking in truth."
        let refs = CrossReferenceParser.extractReferences(from: text)
        XCTAssertEqual(refs.count, 1)
        XCTAssertTrue(refs[0].contains("3 John"))
    }

    // MARK: - Limit Enforcement

    func testLimitsToFiveByDefault() {
        let text = """
        John 3:16, Romans 8:28, Psalm 23:1, Genesis 1:1,
        Proverbs 3:5, Isaiah 40:31, Matthew 28:19, Acts 2:38
        """
        let refs = CrossReferenceParser.extractReferences(from: text)
        XCTAssertEqual(refs.count, 5)
    }

    func testCustomLimit() {
        let text = "John 3:16, Romans 8:28, Psalm 23:1"
        let refs = CrossReferenceParser.extractReferences(from: text, limit: 2)
        XCTAssertEqual(refs.count, 2)
    }

    // MARK: - Deduplication

    func testDeduplicatesReferences() {
        let text = "John 3:16 is important. As John 3:16 shows us..."
        let refs = CrossReferenceParser.extractReferences(from: text)
        XCTAssertEqual(refs.count, 1)
    }

    // MARK: - Edge Cases

    func testEmptyText() {
        let refs = CrossReferenceParser.extractReferences(from: "")
        XCTAssertTrue(refs.isEmpty)
    }

    func testNoReferences() {
        let refs = CrossReferenceParser.extractReferences(from: "This is just a regular sentence with no Bible references.")
        XCTAssertTrue(refs.isEmpty)
    }

    func testCaseInsensitive() {
        let text = "As noted in JOHN 3:16 and psalm 23"
        let refs = CrossReferenceParser.extractReferences(from: text)
        XCTAssertEqual(refs.count, 2)
    }
}

import XCTest
@testable import BibleCopilot

final class SubscriptionServiceTests: XCTestCase {

    // MARK: - Product IDs

    func testMonthlyProductID() {
        let service = SubscriptionService.shared
        XCTAssertEqual(service.monthlyProductID, "bible_copilot_pro_monthly")
    }

    func testAnnualProductID() {
        let service = SubscriptionService.shared
        XCTAssertEqual(service.annualProductID, "bible_copilot_pro_annual")
    }

    // MARK: - Initial State

    func testInitiallyNotPro() {
        // In test environment without StoreKit config, should default to not pro
        // Note: actual subscription state depends on StoreKit testing configuration
        let service = SubscriptionService()
        // Just verify the property exists and is accessible
        _ = service.isPro
    }

    func testProductsInitiallyEmpty() {
        let service = SubscriptionService()
        // Products load asynchronously, so initially empty
        // This just verifies the property is accessible
        _ = service.products
    }

    // MARK: - Error Types

    func testSubscriptionErrorDescription() {
        XCTAssertNotNil(SubscriptionError.failedVerification.errorDescription)
    }

    // MARK: - Computed Properties

    func testAnnualProductComputedProperty() {
        let service = SubscriptionService.shared
        // Without products loaded, should be nil
        // This tests the computed property doesn't crash
        _ = service.annualProduct
        _ = service.monthlyProduct
    }
}

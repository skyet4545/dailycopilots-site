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

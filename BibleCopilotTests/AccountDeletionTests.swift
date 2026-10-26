import XCTest
@testable import BibleCopilot

final class AccountDeletionTests: XCTestCase {
    func testConfirmedDeletionResponseDecodesSharedIdentityScope() throws {
        let data = Data(#"""
        {
          "deleted": true,
          "scope": "app_data_only",
          "appId": "bible_copilot",
          "remainingMemberships": 2,
          "authUserDeleted": false,
          "appleManualRevocationRequired": false
        }
        """#.utf8)

        let result = try JSONDecoder().decode(AccountDeletionResult.self, from: data)

        XCTAssertTrue(result.deleted)
        XCTAssertEqual(result.scope, "app_data_only")
        XCTAssertEqual(result.remainingMemberships, 2)
        XCTAssertFalse(result.authUserDeleted)
    }

    func testConfirmedDeletionResponsePreservesAppleManualRevocationRequirement() throws {
        let data = Data(#"""
        {
          "deleted": true,
          "scope": "shared_identity_and_app_data",
          "appId": "bible_copilot",
          "remainingMemberships": 0,
          "authUserDeleted": true,
          "appleManualRevocationRequired": true
        }
        """#.utf8)

        let result = try JSONDecoder().decode(AccountDeletionResult.self, from: data)

        XCTAssertTrue(result.authUserDeleted)
        XCTAssertTrue(result.appleManualRevocationRequired)
    }

    func testRecoverablePartialFailureExplainsWhatWasDeleted() {
        let error = AccountDeletionError.server(
            code: "auth_user_deletion_pending",
            appDataDeleted: true,
            retrySafe: true
        )

        XCTAssertTrue(error.localizedDescription.contains("cloud data was deleted"))
        XCTAssertTrue(error.localizedDescription.contains("Retry"))
    }

    func testUnknownOutcomeDoesNotTellUserToBlindlyRetry() {
        let message = AccountDeletionError.outcomeUnknown.localizedDescription

        XCTAssertTrue(message.contains("Do not retry"))
        XCTAssertTrue(message.contains("local data was kept"))
    }
}

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
        UserDefaults.standard.removeObject(forKey: "hasCompletedFirstQuestion")
        UserDefaults.standard.removeObject(forKey: "lastStudyReference")
        UserDefaults.standard.removeObject(forKey: "lastStudyPrompt")
    }

    // MARK: - Free Tier Limits

    func testFreeUserCanAskWhenUnderLimit() {
        XCTAssertTrue(service.canAsk(isPro: false))
    }

    func testFreeUserBlockedAtLimit() {
        for _ in 0..<3 {
            service.recordQuestion()
        }
        XCTAssertFalse(service.canAsk(isPro: false))
    }

    func testFreeUserAllowed2Questions() {
        for _ in 0..<2 {
            service.recordQuestion()
        }
        XCTAssertTrue(service.canAsk(isPro: false))
    }

    func testFreeUserBlockedAt3Questions() {
        for _ in 0..<3 {
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
        XCTAssertEqual(service.remainingQuestions(isPro: false), 3)
        service.recordQuestion()
        XCTAssertEqual(service.remainingQuestions(isPro: false), 2)
        XCTAssertEqual(service.freeQuestionsRemaining, 2)
        XCTAssertEqual(
            UsageService.remainingQuestionsLabel(remaining: service.freeQuestionsRemaining),
            "2 of 3 free questions left today"
        )
    }

    func testStudyContextStoresTheLatestQuestion() {
        service.recordStudyContext(reference: "John 3:16", prompt: "Summary")
        XCTAssertEqual(service.lastStudyReference, "John 3:16")
        XCTAssertEqual(service.lastStudyPrompt, "Summary")
        service.recordStudyContext(reference: "  ", prompt: "ignored")
        XCTAssertEqual(service.lastStudyReference, "John 3:16")
    }

    func testRefreshForDisplayRollsTheCounterToTheNewDay() {
        UserDefaults.standard.set("2020-01-01", forKey: "usageDate")
        UserDefaults.standard.set(3, forKey: "usageCount")
        service.refreshForDisplay()
        XCTAssertEqual(service.freeQuestionsRemaining, 3)
        XCTAssertEqual(
            UsageService.remainingQuestionsLabel(remaining: service.freeQuestionsRemaining),
            "3 of 3 free questions left today"
        )
    }

    func testFirstAnswerFollowUpDefersTheReminderUntilTheSoftPaywallCloses() {
        let free = FirstAnswerFollowUp.decide(isPro: false, wantsReminder: true)
        XCTAssertTrue(free.showSoftPaywall)
        XCTAssertFalse(free.showReminder)
        XCTAssertTrue(free.deferReminder)

        let freeWithoutReminder = FirstAnswerFollowUp.decide(isPro: false, wantsReminder: false)
        XCTAssertTrue(freeWithoutReminder.showSoftPaywall)
        XCTAssertFalse(freeWithoutReminder.deferReminder)

        let pro = FirstAnswerFollowUp.decide(isPro: true, wantsReminder: true)
        XCTAssertFalse(pro.showSoftPaywall)
        XCTAssertTrue(pro.showReminder)
        XCTAssertFalse(pro.deferReminder)
    }

    func testAnnualTrialLineUsesTheLiveOfferLength() {
        XCTAssertEqual(
            PaywallView.trialThenPrice(lengthLabel: "7-Day", displayPrice: "$49.99", periodWord: "year"),
            "7 days free, then $49.99/year"
        )
        XCTAssertEqual(
            PaywallView.trialThenPrice(lengthLabel: nil, displayPrice: "$49.99", periodWord: "year"),
            "$49.99/year"
        )
        XCTAssertEqual(
            PaywallView.reassurance(lengthLabel: "7-Day", displayPrice: "$49.99", periodWord: "year"),
            "7 days free, then $49.99/year. Auto-renews each year unless you cancel at least 24 hours before the period ends."
        )
    }

    func testAnnualSavingsVersusMonthlyCatalogPrices() {
        let saved = PaywallPricing.percentSaved(annual: Decimal(string: "49.99")!, monthly: Decimal(string: "9.99")!)
        XCTAssertEqual(saved, 58)
        let detail = PaywallView.annualPriceDetail(
            trialLine: "7 days free, then $49.99/year",
            perWeek: "$0.96",
            perMonth: "$4.17",
            percentSaved: saved
        )
        XCTAssertEqual(
            detail,
            "7 days free, then $49.99/year\nabout $0.96/week · $4.17/month · save 58% vs monthly"
        )
    }

    func testExplanationShareIncludesVerseExcerptAndCampaign() {
        let message = ExplanationShare.message(
            reference: "Romans 8:28",
            answer: "God works through this verse. " + String(repeating: "context ", count: 80)
        )
        XCTAssertTrue(message.contains("Romans 8:28"))
        XCTAssertTrue(message.contains("God works through this verse."))
        XCTAssertTrue(message.contains(ExplanationShare.appStoreURLString))
        XCTAssertEqual(
            ExplanationShare.appStoreURLString,
            "https://apps.apple.com/app/apple-store/id6758913373?pt=128532000&ct=app_share&mt=8"
        )
        XCTAssertTrue(message.contains("…"))
        XCTAssertLessThan(message.count, 560)
    }

    func testSiblingCrossPromoLinksUseCampaignToken() {
        let expected = [
            "Prayer Copilot": "6761485209",
            "Stoic Copilot": "6761389396",
            "Gita Copilot": "6761395731",
            "Wisdom Copilot": "6761395984",
            "Torah Copilot": "6761395920",
            "Constitution Copilot": "6761391729",
        ]
        XCTAssertEqual(SiblingApps.promotable.count, expected.count)
        for app in SiblingApps.promotable {
            XCTAssertEqual(app.appStoreID, expected[app.name])
            let url = SiblingApps.appStoreURL(for: app)?.absoluteString
            XCTAssertEqual(url, "https://apps.apple.com/app/id\(app.appStoreID)?ct=bc_crosspromo_settings")
        }
    }

    // MARK: - Midnight Reset

    func testResetOnNewDay() {
        // Simulate questions from yesterday
        UserDefaults.standard.set("2020-01-01", forKey: "usageDate")
        UserDefaults.standard.set(3, forKey: "usageCount")

        // Should reset because today != 2020-01-01
        XCTAssertTrue(service.canAsk(isPro: false))
        XCTAssertEqual(service.usedToday, 0)
    }

    // MARK: - Constants

    func testFreeQuestionLimitMatchesProductTruth() {
        XCTAssertEqual(UsageService.freeQuestionsPerDay, 3)
    }

    func testOnlyFirstSuccessfulQuestionReturnsTrue() {
        XCTAssertTrue(service.recordQuestion())
        XCTAssertFalse(service.recordQuestion())
    }

    func testOnboardingStudyIntentPreservesSelectedReferenceAndMode() {
        let intent = OnboardingCompletionIntent.startStudy(reference: "Romans 8:28", mode: .summary)
        XCTAssertEqual(intent, .startStudy(reference: "Romans 8:28", mode: .summary))
        XCTAssertEqual(intent.analyticsValue, "start_selected_study")
    }

    func testOnboardingSkipIntentEntersHome() {
        XCTAssertEqual(OnboardingCompletionIntent.enterHome.analyticsValue, "enter_home")
    }
}

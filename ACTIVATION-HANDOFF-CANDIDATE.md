# Bible Copilot 2.4.6/132 activation handoff candidate

## Outcome

Increase the share of new readers who complete a first useful Bible Copilot question within 24 hours by fulfilling the onboarding action they explicitly selected.

## Evidence behind the change

The privacy-safe current-public-version cohort contained 70 devices. Sixty-five completed onboarding, a 92.9% completion rate, in a median 15.2 seconds. Forty-four of those 65 completers asked a question within 24 hours, leaving 21 completers who reached the app but did not experience the measured first-use outcome.

The existing button says `Start studying — it's free`, but after the optional attribution step it opens the general Home screen. The reader must choose a passage or action again. This candidate carries the verse selected in the onboarding demonstration into Summary study immediately. Readers who choose `Skip`, `Maybe later`, or a legacy completion path still enter Home.

The live transition data is diagnostic. It does not prove that the extra choice caused the missing first questions or that this candidate will improve retention or subscriptions.

## Implementation

- Adds an explicit `OnboardingCompletionIntent` with `enterHome` and `startStudy` states.
- Preserves the selected onboarding verse and Summary mode through the optional attribution screen.
- Sets the study mode before presenting the study so the selected action runs immediately.
- Adds `next_action` to the existing consent-gated `onboarding_complete` event. It records only `enter_home` or `start_selected_study`; it does not transmit the selected verse.
- Preserves Home as the destination for every skip and legacy completion path.
- Advances the candidate version to 2.4.6 build 132.

## Verification

- Product-claim boundary guard: passed.
- Full iPhone 17 Pro simulator suite: 82 passed, 0 failed, 0 skipped.
- Focused intent tests verify that the study path retains Summary mode and the selected reference, while the skip path enters Home.

## Measurement after an approved release

Primary mechanism metric: consenting new-device `onboarding_complete` events with `next_action=start_selected_study` that produce `question_asked` within 24 hours.

Business guardrails: overall first-question-within-24-hours rate, D1 and D7 retention, free-limit paywall reach, purchase taps, StoreKit success, Apple active paid subscriptions, trial-to-paid movement, churn, refunds, and currency-specific proceeds.

Do not compare the consented continuation subset with non-consenting users as if assignment were random. Do not call an automatic question a retention or subscription win.

## Sequence and authority

This candidate is based on the exact integrated 2.4.5/131 growth head `59d5ae319a2c4298ce2c0f378ab88a71000dc215`. Keep it held until the 2.4.3/129 paywall treatment has a readable decision window and the binding constraint is reassessed. Merge, device verification, provider changes, submission, and release require their existing owner gates.

No production, App Store, provider, customer, price, subscription, or revenue state changed.

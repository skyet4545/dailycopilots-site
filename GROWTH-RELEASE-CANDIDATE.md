# Bible Copilot 2.4.5/131 integrated growth candidate

## Purpose

Preserve every verified trust repair while staging the next retention and monetization improvements behind the current paywall experiment.

## Included foundation

- Generated Scripture reference verification before navigation.
- App privacy manifest and analytics-consent work.
- In-app account-deletion client with fail-closed destructive-network handling.
- Bounded onboarding and paywall product claims with the correct six-mode count.

## Included growth treatments

- A contextual study-resume reminder that returns readers to their validated passage and study mode.
- Aggregate reminder-open to useful-question measurement.
- Per-customer StoreKit introductory-offer eligibility resolution.
- Trial language shown only for a confirmed eligible plan; unknown and ineligible states use direct-subscription language.
- Eligibility and offer-type properties on purchase-intent analytics.

## Experiment sequence

This candidate must remain staged until the submitted 2.4.3/129 `Continue Your Bible Study` headline treatment has a readable decision window. Shipping the reminder or eligibility presentation during that window would change the customer experience and weaken interpretation of the paywall result.

## Verification

- The complete iPhone 17 Pro simulator suite passed 80 tests with zero failures.
- The suite includes account deletion, generated-reference verification, contextual reminder, StoreKit eligibility, subscription, analytics, reading-plan, and study-service coverage.
- The product-claim guard checked three customer-facing Swift files against seven forbidden or stale patterns and passed.
- The integrated candidate retains version 2.4.5 and build 131.

## Release gates

- Reconcile and integration-test the account-deletion backend against current provider schema.
- Verify destructive cleanup and Apple revocation fallback with an authorized synthetic identity.
- Verify the full candidate on a physical device.
- Obtain separate approval for archive, upload, submission, and manual release.

No provider, App Store, production, customer, subscription, price, or revenue state is changed by this candidate.

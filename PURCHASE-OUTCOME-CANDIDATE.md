# Bible Copilot 2.4.8/134 purchase-outcome candidate

## Business purpose

Explain what happens after a reader taps the Pro purchase button. The current flow records the tap and a verified purchase, but Apple cancellation and pending approval are silent. That prevents the Friday review from distinguishing customer hesitation, Ask to Buy or other pending approval, technical failure, and successful StoreKit completion.

## Customer behavior

- A verified purchase still unlocks Pro and closes the paywall.
- A cancellation leaves the paywall open without pressure or an error.
- A pending Apple transaction leaves the paywall open and explains that Pro will unlock automatically when Apple completes it.
- An unknown StoreKit outcome leaves the paywall open with a retry message.
- Onboarding shows trial headlines, timeline, CTA, and no-charge copy only after StoreKit confirms that the selected Apple ID is eligible.
- Entitlement verification remains unchanged.
- Restore Purchases now reports restored, no active entitlement, and App Store synchronization failure states instead of silently doing nothing. A successful restore is not counted as a paywall dismissal.

## Consented measurement contract

The existing analytics-consent gate applies to all new events:

- `purchase_cancelled`
- `purchase_pending`
- `purchase_unknown`
- `paywall_dismissed`
- `paywall_plans_load_failed`
- `restore_succeeded`
- `restore_no_entitlement`
- `restore_failed`

The purchase events retain product, source, paywall trigger, copy version, trial eligibility, and offer type where the paywall already knows them. No transaction identifier, receipt, Apple account, price, exact time-to-renewal, or customer content is added.

## Decision boundary

These events diagnose the paywall and Apple purchase flow. They do not establish an active paid subscription, renewal, proceeds, or causal revenue lift. Apple active-paid state and currency-specific proceeds remain the commercial authority.

## Release boundary

This exact candidate descends from clean 2.4.7/133 commit `9bf3b9acf492175d65e4045fd94d0bed1ea63a63`. Keep it behind the submitted 2.4.3/129 paywall experiment and the existing trust, activation, retention, entitlement, provider, device, submission, Apple-review, manual-release, and owner-approval gates.

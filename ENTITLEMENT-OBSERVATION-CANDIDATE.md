# Bible Copilot 2.4.7/133 entitlement observation candidate

## Business purpose

Measure whether consented Bible Copilot devices still have verified Pro access in later app sessions. This closes the gap between an initial StoreKit purchase-success event and retained Pro use, which Apple aggregate reports cannot currently expose below its privacy threshold.

## Event contract

After `Transaction.currentEntitlements` is verified, the app emits at most one `entitlement_state_observed` event for each distinct state in an app session. Properties are limited to:

- `state`: `active` or `inactive`
- `plan`: `annual`, `monthly`, or `none`
- `source`: `storekit_current_entitlements`

The event uses the existing explicit analytics-consent gate. It contains no transaction identifier, receipt, original purchase identifier, exact purchase or renewal date, expiration date, price, currency, Apple account, email address, or synced study content.

## Decision boundary

An observation proves only that StoreKit reported a current entitlement to a consenting device during that app session. It does not prove paid billing, trial conversion, renewal, proceeds, causal retention, or incremental revenue. Friday reporting must join it to app-open sessions and keep Apple active-paid and currency-specific proceeds as the commercial outcome.

## Release boundary

This candidate descends from exact clean 2.4.6/132 commit `062ab8690701f5c0f3aef83e32ac99336b21b4dd`. It remains held behind the 2.4.3/129 paywall treatment and the existing trust, provider, device, submission, Apple-review, manual-release, and owner-approval gates.

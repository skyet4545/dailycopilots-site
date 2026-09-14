# Bible Copilot App Store claim-boundary candidate

## Outcome

Increase qualified product-page conversion into Bible Copilot Pro while keeping every public claim within current product and StoreKit evidence.

## Live finding

The United States App Store product page was inspected in a browser on September 14, 2026. It showed four iPhone screenshots. Screenshot three said `Every answer cites Scripture`, and screenshot four said `Try Pro free for 7 days` without an eligibility qualifier.

Current product evidence supports a reference-bearing study design and a real seven-day introductory offer for StoreKit-confirmed eligible customers. It does not prove that every generated answer contains only correct references or that every App Store visitor is eligible for the introductory offer.

## Prepared treatment

The existing six-frame Product Page Optimization treatment now uses:

- `Study with Scripture references` / `Open cited passages and check the context`
- `Unlock unlimited Bible study` / `Eligible new subscribers may receive a 7-day trial`

The treatment keeps the real product captures, six-mode sequence, follow-up study, reading-plan habit, and monthly/annual Pro journey. No UI state was fabricated.

## Validation

- All six source hashes match and all six composites are exactly 1290 by 2796 pixels.
- The prior build 129 Pro capture was disqualified and replaced by a real simulator capture from product-copy commit `79bfba4f21338a73ed4946cb4bf93a45e139b988`.
- StoreKit loaded both plans, confirmed the eligible annual trial state, and the corrected paywall visibly showed `Unlimited AI study questions`.
- The normal validator and strict upload gate both pass at six of six.
- Four unsupported absolute Scripture-claim patterns are rejected by the validator.
- Trial language is rejected unless the customer-facing copy includes an eligibility boundary.
- Each generated asset has an immutable SHA-256 in the asset manifest.

## Measurement

Use this only as one Apple Product Page Optimization treatment against the live four-frame gallery. The primary mechanism is Apple's product-page conversion estimate. Preserve first useful question, paywall reach, purchase tap, StoreKit success, active paid subscriptions, churn, refunds, and currency-specific proceeds as separate downstream evidence.

Do not attribute any result to one individual frame because the six-frame package changes copy, order, and coverage together.

## Owner gate

No App Store Connect asset, test, metadata, app version, subscription, or price was changed. Creating or starting a Product Page Optimization test and applying a winner each require a separate owner decision.

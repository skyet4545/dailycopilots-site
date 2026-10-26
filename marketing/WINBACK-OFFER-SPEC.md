# Win-Back Offer Spec — lapsed trialists → 50% off annual (2026-07-04)

Why: only ~9.3% of apps run ANY promotional offer; win-backs are the lowest-risk offer type
(user already churned). Redownloads outpace new downloads 2:1 in 2026 — returning users are
a real segment. StoreKit 2 supports win-back offers natively (iOS 18+); they can even
surface in App Store editorial placements automatically.

## CONFIGURED IN ASC 2026-07-04 ✅
- **Product:** biblecopilot_pro_annual — NOTE: live US price is **$49.99/yr** (the $29.99 in older docs was stale)
- **Offer:** winback-annual-50 / `winback_annual_50` / Apple ID **6787463228**
- **Price:** **$24.99 first year** (50% off $49.99), pay-up-front, auto-renews at full price
- **Dates:** starts **Jul 6, 2026**, no end date · 175 countries (3 low-price storefronts auto-excluded)
- **Eligibility (Apple-managed):** paid ≥1 month, subscription ended 1–24 months ago · High priority · no wait between offers
- **Redemption URL (works without app code once live):** https://apps.apple.com/win-back/6787463228

## ASC setup (~15 min, Carlos or agent-with-browser)
1. ASC → Bible Copilot → Subscriptions → biblecopilot_pro_annual → **Win-Back Offers → +**
2. Name: `winback-annual-50`; Price: $14.99 (US, let Apple auto-convert other storefronts)
3. Duration: 1 year, pay-up-front, one-time
4. Priority: high; Availability: all territories
5. Submit with next app version (win-back offers ride app review)

## App code (Views/Paywall — keep minimal)
```swift
// StoreKit 2: eligible win-back offers arrive on the product's subscription info.
let product = try await Product.products(for: ["biblecopilot_pro_annual"]).first
if let offer = product?.subscription?.winBackOffers.first {
    // Show dedicated "Welcome back — 50% off your first year" paywall variant
    let result = try await product?.purchase(options: [.winBackOffer(offer)])
}
```
Trigger: on app open, if `Transaction.currentEntitlements` is empty AND a past transaction
exists → route to the win-back paywall variant instead of the standard one.

## Guardrails
- **Real-device test required** before ship (paywall regression rule — CLAUDE.md).
- Never show win-back pricing to active subscribers or never-subscribed users (Apple gates
  eligibility server-side, but the UI routing must match).
- Measure: ASC → Subscription reports → offer redemptions, monthly.

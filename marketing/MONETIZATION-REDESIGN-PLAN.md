# Bible Copilot monetization redesign

## Objective

Increase total value per organic session by monetizing informational visitors with AdSense while protecting the higher-value path into Bible Copilot and Bible Copilot Pro.

## Page-intent rules

| Experience | Routes | Primary action | Ads |
|---|---|---|---|
| Product | `/`, `/pro/` | Free tool or App Store install | Never |
| Tool | `/tools/**` | Complete tool, then continue in app | Never |
| Commercial article | comparison and best-app articles | App Store install / Pro consideration | Never |
| Editorial article | most `/blog/**` pages | Satisfy query, then study/app CTA | Eligible |
| Bible hub | `/bible/**` | Navigate to related studies | Eligible |
| Utility | privacy, terms, about, thanks | Complete utility task | Never |

## Editorial conversion sequence

1. Give the direct answer without interruption.
2. Offer a soft free-study CTA before the first deep section.
3. Keep a desktop table of contents and app prompt in the sidebar.
4. Show one final Pro-oriented CTA after the article.
5. Hide legacy duplicate promotions and fixed download bars.

## AdSense rollout

AdSense remains disabled until an approved `ca-pub-...` identifier is added. When enabled, the loader runs only on ad-eligible routes. Start with Auto Ads at low ad load, with vignette ads off and product/tool sections excluded in AdSense as a second control layer.

## Measurement

Primary events: `appstore_click`, `pro_cta_click`, `study_tool_click`, `pricing_viewed`, and existing `verse_tool_started` / `verse_tool_completed`.

Guardrails: organic CTR, engaged sessions, 75% content depth, LCP, INP, CLS, and indexed-page count.

North-star calculation: AdSense revenue + estimated Pro contribution, divided by sessions. Do not optimize ad RPM in isolation.

## 30-day rollout

- Days 1–7: establish event baseline and verify no duplicate events.
- Days 8–14: add approved AdSense ID, low ad load, no vignette ads.
- Days 15–21: compare eligible editorial RPM, App Store click rate, and engagement by page intent.
- Days 22–30: test the homepage primary CTA (`Study a verse free` versus `Try Bible Copilot free`) only after baseline volume is sufficient.

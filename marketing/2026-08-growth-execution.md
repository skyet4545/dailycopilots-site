# Bible Copilot Growth Execution — August 2026

## Decision

Scale only the channels that can be measured from landing view through app activation. Do not begin paid search or paid social while the source baseline remains incomplete.

## Verified starting point

- The 2026-08-12 through 2026-08-18 product events recorded 10 named-source onboarding completions: 6 `other`, 2 `app_store_search`, and 2 `social_media`.
- The same week recorded one `other` purchase and no recorded purchases from the named App Store-search or social rows. These rows are too small to establish a winning channel.
- The current production release is 2.4.1. Build 2.4.2 (128), which adds `organic_search`, `youtube`, `website_article`, and `email_newsletter` to onboarding source collection, has been uploaded and is awaiting the normal App Store release workflow.
- The 2026-08-17 weekly scorecard found YouTube views rose from 5,277 to 7,545 while Gospel Briefing reach and app-side podcast attribution fell. This is a hypothesis for a measured YouTube pilot, not proof that YouTube caused installs.

## Execution now

### 1. App source measurement

Release build 2.4.2 (128) before interpreting the new source values. For the first four weeks after release, retain `other` as a valid unknown; do not recode old answers or infer Google traffic.

Run the acquisition-funnel report weekly. Record its date range beside the App Store first-time-download total; do not construct a purchase rate from mismatched aggregate windows.

### 2. YouTube pilot

Every Short in the pilot uses one destination and one CTA:

> Study the verse yourself — use the link in the description to open Bible Copilot free.

The description and pinned comment must use the dedicated landing-page URL with the `youtube / organic_video / shorts_2026_08 / {video_id}` fields defined in the acquisition contract. The landing page, not YouTube or the App Store URL, is responsible for recording the visit and outbound App Store tap.

Deployment status on 2026-08-19: `https://mybiblecopilot.com/youtube/` is live, returns the expected noindex campaign page, and has the correct App Store campaign token. Its event receiver is not yet usable from the browser: the existing `marketing-attribution` endpoint returned `401 UNAUTHORIZED_NO_AUTH_HEADER` to a controlled production receipt, while its current CORS contract permits only `content-type`. Do not treat YouTube landing views or handoffs as measured until the endpoint's authentication and CORS contract are reconciled in its owning, source-controlled project.

Pilot window: 14 consecutive days after both the landing page and 2.4.2 are live. Do not change the CTA, destination, or content cadence during the window.

Success readout:

| Metric | Source of truth | Interpretation |
| --- | --- | --- |
| Landing views and App Store taps | Owned landing-page analytics | A viewer reached the handoff; not an install |
| `youtube` onboarding completions and first questions | App product events | Directional activation signal |
| `youtube` trial taps and purchases | App product events | Directional paid-intent signal; low-volume results remain hypotheses |
| First-time downloads and subscription events | App Store Connect | Aggregate business outcome; not cohort-attributed to YouTube |

### 3. Organic-search content

Do not generate new verse pages merely to create pages. The current site already contains a substantial article library and has an in-page CTA system that reports its CTA locations. Prioritize only existing articles that meet all three requirements:

1. Search demand is verified in Search Console or an equivalent query-evidence source.
2. The article gives a complete, Scripture-cited answer before its app CTA.
3. Its CTA links to the owned, measured handoff with `utm_medium=article` and its article slug in `utm_content`.

The immediate dependency is authenticated Search Console access. Until it exists, publishing a new page is not an evidence-led growth action.

### 4. App Store conversion experiment

Draft created in App Store Connect: **2026-08 Search Result Hero**.

| Field | Value |
| --- | --- |
| Hypothesis | Because app-search impressions have historically exceeded downloads, showing the six study modes in screenshot 1 will increase product-page conversion for App Store searchers. |
| Control | Current product page |
| Treatment A | Replace only screenshot 1 with `marketing/screenshots/store-02-study.png` (1290 × 2796), whose headline is “Study Scripture six ways.” |
| Allocation | 50% treatment / 50% original page |
| Primary metric | App Store product-page conversion rate |
| Secondary metrics | Downloads and downstream first-question completion |
| Guardrail | No material decline in product-page conversion or first-question completion |
| Decision rule | Keep running until App Store Connect reports a conclusive result or the volume is clearly insufficient after a full, stable traffic period. Do not stop early for a favorable fluctuation. |

The draft has not been started. It still needs the Treatment A upload in App Store Connect and an explicit action-time approval to start the live test.

## Next decision gate

When 2.4.2 is released and the YouTube landing page is deployed, start the 14-day pilot and the App Store experiment. At the end of the window, allocate effort only to the source that produces attributable activations and meaningful paid intent; do not treat views, clicks, or self-reported answers alone as proof of causal revenue.

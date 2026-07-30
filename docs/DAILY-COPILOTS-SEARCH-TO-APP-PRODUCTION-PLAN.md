# Daily Copilots Search-to-App Production Plan

Date: 2026-07-30
Owner: Jarvis / Daily Copilots
Status: Approved for production by Carlos Reyes

## Objective

Turn app-specific search demand into a measurable, trustworthy journey:

`search query → matching app answer → useful follow-up bridge → matching App Store page → activation → Pro`

The site must answer the visitor's question substantially before promotion. Every page has exactly
one primary app and must preserve that app's sources, doctrine, product identity, App Store ID, Pro
route, and analytics stream.

## Production architecture

Each shared-site app owns one product hub and one answer hub:

- Constitution Copilot: `/constitution/` and `/constitution/answers/`
- Gita Copilot: `/gita/` and `/gita/answers/`
- Stoic Copilot: `/stoic/` and `/stoic/answers/`
- Torah Copilot: `/torah/` and `/torah/answers/`
- Wisdom Copilot: `/wisdom/` and `/wisdom/answers/`

Every answer page must:

1. Match one distinct search question and one primary app.
2. Give a direct, source-backed answer before any promotion.
3. Link upward to its app hub and answer hub.
4. Show an app-specific follow-up module explaining what the visitor can ask next.
5. Route only to the matching App Store ID and Pro page.
6. Carry a valid Apple provider token and app/placement-specific campaign token.
7. Emit app, page type, content ID, CTA location, campaign, provider, and destination parameters.
8. Preserve educational-not-legal-advice framing for Constitution content.

Bible Copilot and Prayer Copilot remain on their separate canonical sites. Daily Copilots may route
to them from the family catalog but must not duplicate their search corpus.

## Measurement contract

### Web events

| Event | Trigger | Required parameters |
| --- | --- | --- |
| `copilot_catalog_click` | A visitor selects any app on the family homepage | `app_id`, `cta_location`, `destination_type`, `link_url`, `page_type` |
| `answer_landing_viewed` | An app-specific answer page loads | `app_id`, `content_id`, `language`, `page_type` |
| `app_bridge_viewed` | The contextual app bridge first enters the viewport | `app_id`, `content_id`, `cta_location`, `page_type` |
| `appstore_click` | A visitor selects a matching App Store link | `app_id`, `content_id`, `cta_location`, `campaign_token`, `provider_token`, `page_type`, `link_url` |
| `pro_cta_click` | A visitor selects a matching Pro page | `app_id`, `cta_location`, `page_type`, `link_url` |
| `pricing_viewed` | A matching Pro page loads | `app_id`, `annual_price`, `monthly_price`, `currency`, `page_type` |

Apple campaign links use verified provider token `128532000` and one campaign token per app and
placement:

- `dc_{app}_answer`
- `dc_{app}_landing`
- `dc_{app}_pro`

Apple campaign reporting is aggregate and privacy-thresholded. It must never be described as
person-level web-to-purchase identity. Missing or thresholded results remain missing, never zero.

### Decision funnel

Report separately by app:

`answer landing → bridge view → App Store click → first-time download → first study → paywall → purchase → renewal`

The website can prove the first three steps immediately. App Store Connect supplies aggregate
campaign downloads, sales, and subscriptions after Apple's reporting delay and privacy threshold.
Native app activation and purchase events remain a separate stream until a verified campaign/source
join is available.

## Automation contract

The Monday-through-Thursday Daily Copilots automations must:

- read this plan and the commanding-presence authority before acting;
- use `Website/` as the automation-safe production source;
- preserve `/Users/carlosreyes/Documents/GitHub/dailycopilots-site` as untouched work in progress;
- prefer refreshing an adequate app-specific URL over creating a competing page;
- require one primary app, one answer hub, one App Store ID, one Pro route, and one campaign token;
- run `node scripts/build-search-to-app-journey.mjs` from `Website/` after eligible answer changes;
- run `node scripts/validate-search-to-app-journey.mjs` from `Website/` before deployment;
- fail closed on wrong-app routing, missing provider/campaign tokens, missing tracking parameters,
  unsupported sources, duplicate intent, or legal/product drift;
- record 7-, 14-, and 28-day evaluation dates.

## Release gates

Production deployment requires:

- clean source aligned with `origin/main` before changes;
- all answer pages assigned to the correct app;
- all App Store links contain `pt`, `ct`, and `mt`;
- all answer pages contain a contextual bridge and answer-hub breadcrumb;
- every answer hub is canonical, crawlable, linked from its app page, and present in the sitemap;
- HTML, canonical, schema, link, sitemap, analytics, accessibility, app identity, and product-truth
  validators pass;
- live changed URLs and events are verified after deployment;
- the deployment, evidence, remaining gaps, and next safe action are reconciled into Jarvis.

## Evaluation and reversal

- Day 7: confirm indexing eligibility, landing sessions, bridge visibility, and event arrival.
- Day 14: compare query/page impressions, clicks, CTR, engaged sessions, and App Store clicks.
- Day 28: compare app-specific answer-to-App-Store rate and available Apple campaign outcomes.

Keep the system when app-specific handoffs become measurable without harming answer quality,
engagement, or search visibility. Revise or roll back the promotional module if it materially
reduces engagement, creates wrong-app routing, harms indexing, or produces misleading product or
legal claims.

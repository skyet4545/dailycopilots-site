# Bible Copilot Acquisition Measurement Contract

## Decision this supports

Decide which content, owned channels, and future paid campaigns produce activated Bible Copilot users and paid Pro starts. Do not use a click or a self-reported source as proof of an App Store install or paid subscription.

## Attribution layers

| Layer | Evidence | What it can prove | What it cannot prove |
| --- | --- | --- | --- |
| Website or social handoff | Tagged landing event and App Store CTA event | A visitor reached the handoff and clicked it | An install, trial, purchase, or renewal |
| Onboarding source | `quiz_answer` with `question=heard_about`, retained as `acquisition_source` | What the user says first introduced Bible Copilot | The exact campaign click or first App Store impression |
| Product activation | `question_asked`, `paywall_view`, `limit_hit` | Product engagement after installation | The originating campaign unless a user supplied a source |
| Purchase intent | `plan_selected`, `trial_start_tap` | The product and paywall trigger selected in the app | A completed transaction or paid renewal |
| Purchase outcome | `purchase_success` plus App Store subscription reports | A completed in-app entitlement and aggregate subscription state | A cohort-safe campaign-to-paid join |

## Source vocabulary

Use stable snake-case source IDs. Existing values remain valid; do not silently rename historical data.

| ID | Meaning |
| --- | --- |
| `app_store_search` | The user reports finding the app in App Store search |
| `organic_search` | The user reports using Google or another search engine to find a verse, Bible question, or Bible Copilot website/article; this is self-reported organic discovery, not a verified search-click record |
| `youtube` | The user reports YouTube as the source; this is self-reported discovery unless it is corroborated by a tagged YouTube landing-view and App Store handoff |
| `website_article` | The user reports a Bible Copilot website article as the source; this is self-reported discovery unless it is corroborated by a tagged article handoff |
| `email_newsletter` | The user reports an email newsletter as the source; this is self-reported discovery unless it is corroborated by a tagged email handoff |
| `podcast_gospel_briefing` | The user reports The Gospel Briefing as the source |
| `social_media` | Social source is known but platform or creative is unavailable |
| `friend_church` | Word of mouth, church, or small group |
| `other` | Unclassified self-report; do not treat as direct traffic |

When an external asset is published, add its own web campaign fields: `utm_source`, `utm_medium`, `utm_campaign`, and `utm_content`. Use the existing App Store campaign token only as a handoff identifier unless App Store Connect returns the appropriate attributed install report.

### Active acquisition campaign registry

| Channel | Reader-facing destination | Website campaign fields | Apple handoff identifier | App-side source expected after 2.4.2 is live |
| --- | --- | --- | --- | --- |
| YouTube Shorts | Dedicated YouTube landing page, not a raw App Store URL | `utm_source=youtube&utm_medium=organic_video&utm_campaign=shorts_2026_08&utm_content={video_id}` | `ct=youtube_shorts_2026_08` | `youtube` |
| Bible Copilot article | The article's existing measured in-page handoff | `utm_source=organic&utm_medium=article&utm_campaign=article_journey_v1&utm_content={article_slug}` | Existing `bc_{cta_location}` token | `website_article` or `organic_search` |
| Gospel Briefing | `/gospel` | `utm_source=gospel_briefing&utm_medium=podcast&utm_campaign=weekly_sponsor&utm_content={episode_date}` | `ct=gospelbriefing_podcast` | `podcast_gospel_briefing` |

Do not add UTMs directly to an App Store URL. UTMs belong on the owned landing page; the owned page records the handoff and appends the Apple campaign identifier to the outbound App Store link.

## Weekly readout

Run:

```sh
BIBLE_COPILOT_ANALYTICS_PROJECT_DIR="/Users/carlosreyes/Desktop/Projects/The Gospel Briefing" \
  node scripts/report-acquisition-funnel.mjs 2026-08-01 2026-08-31
```

Report these separately:

1. tagged landing views and App Store handoffs;
2. first-time downloads from App Store Connect;
3. activated devices, paywall views, trial taps, and purchase successes by self-reported source;
4. active subscriptions, introductory offers, renewals, cancellations, billing retry, and grace-period counts from App Store Connect.

No stage may be substituted for another. In particular, an App Store handoff is not an install, and an aggregate subscription count is not campaign-attributed conversion.

## Data-quality gates

- `first_question_completed` must be plausible relative to `question_asked`; investigate release/deployment or event delivery if it materially diverges.
- Never infer a paid conversion rate by dividing App Store purchase units by an unmatched download window.
- Do not sum platform-reported conversions with product events. Reconcile them as separate evidence classes.
- Treat low-volume source rows as directional. A single observed purchase is a hypothesis for a future controlled test, not proof to scale a channel.

# Bible Copilot content-system rollout plan

## Purpose

Keep existing search entry points useful while giving every qualified article a consistent path back to the passage, the free Verse Study Builder, and—when appropriate—the iPhone app. This plan does not authorize bulk rewrites, deletions, redirects, or indexability changes.

## The article operating system

Every eligible article uses the shared presentation layer in `site-deploy/assets/revenue.js` and `site-deploy/assets/monetization.css`:

1. A concise, passage-first answer remains at the beginning of the article.
2. An inline study module offers the canonical free worksheet at `/tools/verse-study/`.
3. The desktop rail provides a table of contents, verification resources, and an App Store continuation.
4. The final module offers the paid continuation only after the reader has received value.
5. App Store handoffs carry a `data-cta-location`, campaign parameters, and the existing `article_app_store_handoff` measurement where an approved article mapping exists.

## Canonical-content decision gate

Each URL must be classified before any direct edit:

| Decision | Evidence required | Action |
| --- | --- | --- |
| Keep and enhance | Query-plus-page evidence, meaningful unique intent, or demonstrated engagement | Preserve canonical; use the shared article system. |
| Consolidate | Two or more pages answer the same search intent and a clear destination page exists | Map the source to the destination with a tested 301; update internally linked high-traffic sources. |
| Rewrite | Query-plus-page evidence shows demand but the answer is materially weak or stale | Editorial rewrite with source and claim review; retain the canonical only if intent remains unique. |
| Review only | Query-only evidence, no URL evidence, unclear intent, or insufficient content quality evidence | No indexability, redirect, or copy change until reviewed. |

## Batches and release gates

Start with a controlled batch of 20 canonicals in the Isaiah, Genesis, Ephesians, Proverbs, and application clusters. A batch may publish only when:

- the canonical, title, description, structured data, and internal targets validate;
- the direct answer is accurate to the cited passage and does not overstate interpretive certainty;
- all free-tool and App Store handoffs use the approved tracking hooks;
- no duplicate destination is introduced;
- the previous batch has at least 14 days of Search Console and GA4 observation, unless a correction requires faster release.

Do not use query-only exports to choose canonical survivors. Do not mass noindex, delete, or redirect the corpus.

## Measurement

For each batch, compare against the previous 28 days and retain URL-level evidence for:

- Search impressions, clicks, and click-through rate;
- GA4 engaged sessions and the `study_tool_click` event;
- `appstore_click` and `article_app_store_handoff` by article and CTA location;
- App Store Connect acquisition and conversion trends, treated as separate from website handoff events unless direct attribution joins them.

The primary decision is whether a passage-first page both serves the search question and increases verified next-step behavior. A handoff is not a purchase attribution claim.

## Ownership and next action

The initial homepage and shared article system can be deployed with the current static release. The next content action after live verification is a URL-level opportunity table for the first 20 canonical candidates, with a reviewer assignment for every consolidation or rewrite recommendation.

# Bible Copilot Premium Redesign Prototype

This is an isolated, nonproduction homepage prototype. It is not a deployment candidate and does not modify the existing static-site corpus.

## The operating system

The site should work as a single reader journey rather than a set of disconnected pages:

1. **Discover** — searchers land on an answer, article, or the free Verse Study Builder.
2. **Begin** — the canonical `/tools/verse-study/` tool gives immediate value with three free daily questions and no account requirement.
3. **Continue** — the site contextualizes the next question as an ongoing study, not a generic software upsell.
4. **Convert** — a precise, App Store-bound Bible Copilot Pro invitation appears at the natural continuation point.

The prototype establishes this system on the homepage. The canonical tools, article URLs, canonicals, sitemap, and internal-link topology remain untouched until a separately approved production rollout.

## Proposed page roles

| Existing surface | Single job | Primary next action |
| --- | --- | --- |
| `/` | Establish the study method and orient visitors | Start a free verse study |
| `/tools/verse-study/` | Deliver immediate, query-led Bible-study value | Continue in Bible Copilot |
| Article and answer pages | Answer the searched question in context | Study the passage free |
| Existing Pro surface | Explain the continuation value precisely | Open the app / begin Pro |

## Conversion rules

- Keep the free tool as the principal acquisition route; do not replace it with a gate.
- Never make an unapproved claim about the app, subscriptions, scholarship, or saved history.
- Preserve `data-cta-location` tracking and `ct=bc_<location>` App Store attribution on production links.
- Treat Pro as the continuity offer after a useful free study action, not as the hero’s only purpose.
- Retain three free questions daily, no account required, and approved pricing/trial language exactly as governed by `product-truth.json`.

## Nonproduction validation required before a production build

1. Map this design language into the current templates without changing URL paths or canonicals.
2. Attach every App Store CTA to the existing revenue instrumentation and audit first-touch source persistence.
3. Validate mobile and desktop layouts, keyboard navigation, contrast, image loading, structured data, sitemap, and all internal links.
4. Verify the free question limit, purchase, entitlement, restore-purchases, and App Store journey if the app surface is changed.
5. Obtain explicit production approval before publishing.

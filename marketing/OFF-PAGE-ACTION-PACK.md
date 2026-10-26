# Off-Page Action Pack — ready to execute (needs a login)

These are the entity + third-party-consensus moves research ranked highest (~80% of AI citation is off-page). Everything is drafted; each needs an account/login I can't create. When you're ready, log me in and I'll do the entry.

---

## ✅ EXECUTION STATUS — updated 2026-07-03

**DONE (durable):**
- **Wikidata entity CREATED + FULLY POPULATED → `Q140422402` "Bible Copilot"** (label + description "AI-powered Bible study app for iPhone and iPad" + alias). Live: https://www.wikidata.org/wiki/Q140422402 — **all 6 verified statements published 2026-07-03 by hand** (manual editing is NOT autoconfirmed-gated; earlier "blocked" claim was wrong):
  1. instance of → mobile app (Q620615) — referenced with App Store URL (P854)
  2. operating system → iOS (Q48493)
  3. official website → https://mybiblecopilot.com — **closes the reciprocal loop** (site sameAs→Q AND Q P856→site)
  4. App Store app ID (P3861) → 6758913373 — the external-ID that reconciles the item to Apple's catalog (top KG-pickup signal)
  5. publication date (P577) → 2026 (year precision)
  6. country of origin (P495) → United States (Q30)
  Item is no longer "blank" → deletion risk cleared (Notability C2 satisfied). Optional cheap follow-up: es/pt multilingual labels (low/speculative value per research — skipped).
- **Site schema linked to it** — added the Q-number to the Organization `sameAs` in `site-deploy/index.html` and DEPLOYED. Ties the site ⇄ Wikidata entity for KG consensus.
- **Grokipedia article SUBMITTED** via "Suggest Article". Right-sized as nice-to-have (reputational-risk caveat — see AI-SEARCH-STRATEGY.md).

**CORRECTION (was wrong earlier):** I previously said statements were blocked by an "anti-spam gate." That's **not accurate** — per Wikidata's own [Autoconfirmed policy](https://www.wikidata.org/wiki/Wikidata:Autoconfirmed_users), *manual* item editing is **NOT gated**. Only **QuickStatements** (the batch tool) needs autoconfirmed (50 edits + 4 days). The earlier failures were a JS-render glitch + an email-confirm bounce in the automated browser — not a permission wall. **The item can and should be completed by hand now**, and doing so also builds toward the 50-edit autoconfirmed threshold.

### ✅ Verified statement spec (every P/Q first-source confirmed on Wikidata)

**MVP set — add first (clears Notability C2 "clearly identifiable entity + references"; de-risks the blank-item deletion flag):**
| # | Statement | Value | Reference to attach |
|---|---|---|---|
| 1 | `instance of` (P31) | **mobile app** (Q620615) — the precise value; do NOT also add Q166142/Q7397 | P854 reference URL = `https://apps.apple.com/us/app/bible-copilot-ai-bible-study/id6758913373` |
| 2 | `operating system` (P306) | **iOS** (Q48493) | P854 = App Store URL |
| 3 | `official website` (P856) | `https://mybiblecopilot.com` | P854 = App Store URL |
| 4 | `App Store app ID` (P3861) | **6758913373** (numeric only, no "id" prefix) | self-referencing — no ref needed |

**Full set — add after MVP:**
| # | Statement | Value | Notes |
|---|---|---|---|
| 5 | `platform` (P400) | iOS (Q48493) | |
| 6 | `publication date` (P577) | 2026 release date | **use P577, not P571 inception** — P577 is the correct property for a product's release |
| 7 | `country of origin` (P495) | **United States** (Q30) | |

**DO NOT GUESS (verified as unsafe to auto-add):**
- `genre` (P136) / `main subject` (P921) — no verified Q-item for "Bible study app"; would need to confirm a real Q first. Omit rather than invent.
- `developer` (P178) / `publisher` (P123) — require an **item** value (a Wikidata item for the dev/company), which doesn't exist yet. Leave off, don't point at a string.
- `Google Play app ID` (P3418) — **Android-only**, N/A for an iOS app. Skip.

**Reciprocal loop (important — this is the actual leverage):** the site's Organization `sameAs` already points to Q140422402 (deployed). Statement #3 above (P856 → mybiblecopilot.com) closes the **other half** of the loop so the site↔entity link is independently verifiable, not self-asserted — this is the Kalicube "self-confirming loop" that Google's KG confidence score actually rewards.

**Multilingual labels (cheap entity hygiene — NOT a measured reach lever):** add label + description + one alias in **es, pt** (highest-value for a Bible app), then **fr, de, it, zh**. Caveat from research: multilingual *labels alone* have no measured AI-reach lift (SPECULATIVE) — they aid entity disambiguation. The measured multilingual lever is translated *content* on authoritative pages (Weglot 1.3M-citation study: up to **+327% AI-Overview visibility** for translated sites). So do the labels because they're cheap, but the real non-English reach play is translated content, not label fields. Keep descriptions short/lowercase/non-promotional, e.g. es: `"aplicación de estudio bíblico con IA para iOS"`.

**QuickStatements fallback** (only once account is autoconfirmed — 50 edits + 4 days; not needed for one item):
```
Q140422402|P31|Q620615|S854|"https://apps.apple.com/us/app/bible-copilot-ai-bible-study/id6758913373"
Q140422402|P306|Q48493|S854|"https://apps.apple.com/us/app/bible-copilot-ai-bible-study/id6758913373"
Q140422402|P856|"https://mybiblecopilot.com"|S854|"https://apps.apple.com/us/app/bible-copilot-ai-bible-study/id6758913373"
Q140422402|P3861|"6758913373"
Q140422402|P400|Q48493
Q140422402|P577|+2026-01-01T00:00:00Z/9
Q140422402|P495|Q30
```

### ⚠️ Right-sizing note (from the 2026-07-03 research)
Wikidata is **eligibility/disambiguation infrastructure, not a growth lever** — Wikidata's own [FAQ](https://www.wikidata.org/wiki/Help:FAQ/Freebase) says an item is NOT a "free ticket" into Google's KG, and it's ~invisible as an AI *citation* source. Finish it because it's cheap and clears deletion risk, then **stop investing here.** The real levers are §4 (brand mentions on Reddit/YouTube), earned independent press (which unlocks Wikipedia — see WIKIPEDIA-VERDICT below — and better Grokipedia odds), and corroborating cross-linked profiles (§2). See `marketing/AI-SEARCH-STRATEGY.md` for the full evidence-graded reprioritization.

**Still needs a login / your click (unchanged from below):** AlternativeTo (free account), RankmyAI, Product Hunt, ChatGPT App (OpenAI acct), Reddit/YouTube.

---

## WIKIPEDIA-VERDICT — NO-GO right now (2026-07-03 research, well-sourced)
A brand-new 2026 indie app with no independent press **cannot** meet [WP:NCORP](https://en.wikipedia.org/wiki/Wikipedia:Notability_(organizations_and_companies))/[WP:GNG](https://en.wikipedia.org/wiki/Wikipedia:Notability). App Store presence, own blog, press releases, and **podcast sponsorship all explicitly do NOT count**. A founder-written draft would likely be **G11 speedy-deleted as promotional** or declined at AfC — leaving a permanent public record tied to the brand. Paid/COI disclosure is a **Wikimedia Terms-of-Use requirement** ([WP:PAID](https://en.wikipedia.org/wiki/Wikipedia:Paid-contribution_disclosure)), not optional. **Honest path:** earn **≥3 substantive, genuinely independent in-depth reviews** (≥1 regional/national), THEN file a neutral disclosed AfC draft. Wikipedia is a *lagging* indicator of press — not a lever you pull. It's worth pursuing *eventually* (ChatGPT: ~7.8% of all citations, ~48% of top-10 sources) — but only after the sourcing exists.

## 1. Wikidata entity — CREATED ✅ (see verified completion spec above)
Item **Q140422402** "Bible Copilot" is live (label + description + alias). Complete the statements per the verified spec above. This is disambiguation infrastructure, right-sized — not the growth engine.

## 2. Directories — DOWNGRADED by 2026-07-03 research (near-zero AI-citation value)
**Correction:** SE Ranking's review-platform analysis found **AlternativeTo, SaaSHub, FinancesOnline cited 0%** and **Product Hunt <1%** and **Crunchbase rarely** as *cited answer sources* in AI answers. They carry minor entity-graph/corroboration value only — NOT a citation lever. So spend at most a few minutes each; don't treat directory submissions as reach.
- faith.tools — already submitted + paid (pending); fine as a niche corroboration mention.
- **AlternativeTo / Product Hunt / RankmyAI** — low priority; do only if trivially fast. Value is a consistent cross-linked profile (corroboration), not citations.
- The directories that ACTUALLY get retrieved for a consumer app: **Reddit discussion, YouTube coverage, App Store presence, and genuine review/editorial coverage** — see §4, which is where the real reach is.

Reusable copy is in `marketing/directory-submissions.md` (already fact-checked: 3/day free, $9.99/$49.99, 7-day trial).

## 3. ChatGPT App (Apps SDK) — distribution inside ChatGPT
The MCP backend is already live (mybiblecopilot.com/mcp, in the registry). Wrapping it as a ChatGPT App needs your OpenAI account to submit via the Apps SDK dashboard. This puts "Bible Copilot" callable inside ChatGPT for 800M users — a channel no competitor has yet.

## 4. Reddit / YouTube presence (the ~3× citation lever)
Reddit + YouTube are the strongest citation predictors (mentions r≈0.66–0.74 vs backlinks 0.22). Reddit API app retry is set for Jul 4 (see [[bible-copilot-reddit-reach-staging]]). Post drafted answers from an ESTABLISHED account, not a fresh one.

## 5. Digital PR / unlinked brand mentions
Unlinked mentions outweigh backlinks ~3×. Cheapest solo path: HARO-style reactive replies + 2–3 podcast guest spots on faith/tech shows, optimizing for the name-drop. Needs you (founder voice).

## 6. Grokipedia article (Grok/xAI encyclopedia — feeds Grok + X search)
Grokipedia has a "Suggest Article" tool (grokipedia.com, top-right). Requires sign-in (via X). Blue Letter Bible already has a Grokipedia page — the AI Bible category is represented. Grok's AI reviews the request and decides. The Wikidata entity (#1) strengthens this request since Grok pulls from web+X entity signals.

**Ready-to-submit content (Suggest Article form):**
- **Title:** Bible Copilot
- **Notability rationale:** Bible Copilot is a distinct, verifiable AI-powered Bible study application for iOS, published on the Apple App Store (id6758913373) with an official website (mybiblecopilot.com) and an ongoing sponsorship presence on the daily podcast The Gospel Briefing. It is part of the emerging "AI Bible study app" category alongside YouVersion, Logos, Bible Chat, and Blue Letter Bible (the last of which already has a Grokipedia article).
- **Key facts / outline:**
  - What: AI Bible study app for iPhone & iPad; launched 2026; independent developer.
  - Core: ask any question about any Bible verse → clear, Scripture-cited answer across six purpose-built study modes (Summary, Observe, Interpret, Theology, Apply, Apologetics); inductive method ("Scripture interprets Scripture"); denominationally humble.
  - Model: free tier (3 questions/day, no account required); Pro $9.99/mo or $49.99/yr with a 7-day free trial. No ads, no data selling.
  - Tech: gpt-4o-mini backend; also exposes a public MCP server (mybiblecopilot.com/mcp) making it agent-callable.
  - Relationship: the featured study companion of the daily Scripture-news podcast The Gospel Briefing.
- **Sources:** https://apps.apple.com/us/app/bible-copilot-ai-bible-study/id6758913373 · https://mybiblecopilot.com · https://mybiblecopilot.com/about/ · https://thegospelbriefing.com

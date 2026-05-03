# The GEO Playbook (2026)

**Author:** Carlos Reyes
**Last validated against a real product:** Bible Copilot, 2026-05-02 (baseline 0/50, citation footprint 0)
**Status:** Sellable methodology. Repeatable across the 7 Copilot constellation apps and across non-religion verticals (AI FrontDesk, TurnoutOS, future products).

---

## 1. What is GEO and why it matters in 2026

Generative Engine Optimization (GEO) is the discipline of getting your product cited by AI answer engines — ChatGPT, Gemini, Perplexity, Meta AI, Bing Copilot, You.com, and Google's AI Overviews — when a buyer asks them a question your product answers. Classic SEO competes for ten blue links; GEO competes for the *one* sentence the model reads aloud, plus the 1-3 citation chips it surfaces. In 2026 the share of high-intent searches that resolve inside an AI surface (rather than ending at a SERP) has crossed the threshold where invisibility there is a structural growth ceiling. If your product is invisible to the models, you are invisible to a fast-growing slice of the funnel — and that slice over-indexes on the comparison-shopping moment ("best X for Y", "alternative to Z"). GEO is not "SEO 2"; it overlaps with SEO but adds three new surfaces (schema for AI parsers, llms.txt corpus files, and citation outreach optimized for LLM training data and retrieval indices rather than backlink juice).

---

## 2. The 7-phase playbook

### Phase 1 — AI visibility baseline (the 10 × N grid)

**Goal:** quantify how often your product is named or linked when an AI engine answers your top buyer queries. Output: a CSV of `(query × engine)` cells and a markdown read-out.

**Steps:**
1. Pick 10 queries that mirror real buyer intent (see Section 3).
2. Pick the engines that matter for your category. Default set: WebSearch (Google proxy), Perplexity, Bing/Copilot, You.com, ChatGPT, Gemini, Meta AI = 7 engines, 70 cells. Bible Copilot used 5 engines × 10 = 50 cells.
3. For each `(query, engine)` cell, record: cited Y/N, the URL if cited, every named competitor, every cited URL, freeform notes.
4. **Be honest about what you can't fetch.** As of 2026-05-02, only Google-proxy WebSearch returned parseable HTML for me. Perplexity, Bing, and You.com return JS shells; ChatGPT/Gemini/Meta AI have no public HTTP endpoint. Mark the cells `NOT_TESTED` and run them manually with the script in Section 4.
5. Write the read-out: top-line citation count, per-engine breakdown, top competitors by citation frequency, per-query findings, what the baseline does NOT measure (App Store search, Reddit, YouTube transcripts, branded queries).

**Deliverables on disk** (mirrors Bible Copilot today):
- `marketing/geo/baseline-YYYY-MM-DD.csv` — row-level data
- `marketing/geo/baseline-YYYY-MM-DD.md` — human read-out

**Time to run:** 2-4 hours for the automated portion + ~90 minutes for the manual ChatGPT/Gemini/Meta AI/Perplexity pass.

### Phase 2 — Schema + technical audit

**Goal:** make the marketing site machine-legible to LLM crawlers. AI engines disproportionately cite content that ships well-formed JSON-LD because schema is how they disambiguate "is this an app, an article, or a person?"

**JSON-LD checklist** (target the marketing site's `index.html` and key landing pages):
- `MobileApplication` or `SoftwareApplication` — name, operating system, app store URL, aggregate rating, offers (price/currency/billing period), features list
- `Organization` — legal entity, founding date, founders, social links, logo, sameAs to App Store + LinkedIn + X
- `Person` — founder/CEO with bio, expertise, sameAs links (this is what powers the "made by" attribution AI engines now surface)
- `Review` and `AggregateRating` — pull from real App Store reviews; never fabricate
- `Product` + `Offer` — price, billing period, free trial, currency
- `FAQPage` — your top 8-15 buyer questions answered in 40-80 words each. **This is the single highest-leverage block** — Perplexity and Google AI Overviews quote FAQ schema verbatim.
- `BreadcrumbList` — site navigation hierarchy

Validate every block in Google's Rich Results Test (`https://search.google.com/test/rich-results`) and Schema.org's validator. Bible Copilot ships 7 JSON-LD blocks in `/marketing-site-v2/index.html` — use that as the reference implementation.

**Technical files (must all exist, served at root):**
- `/robots.txt` — explicitly Allow every AI crawler user-agent (see Section 6)
- `/sitemap.xml` — every public URL, with `lastmod` honest
- `/llms.txt` — short index of what's on the site
- `/llms-full.txt` — long-form, AI-readable corpus (see Section 6)
- HTTPS, fast TTFB, server-rendered HTML for the home + comparison + pricing pages (JS-only renders are a death sentence for AI crawlers)

### Phase 3 — Citation footprint audit

**Goal:** map every place your product is mentioned today (likely zero) and every place it *should* be mentioned (likely 30+).

**The 12 search queries to run** (substitute your brand for `BRAND`):
1. `"BRAND" review`
2. `"BRAND" iOS` / `"BRAND" Android`
3. `"BRAND" alternative`
4. `"BRAND" vs [top competitor]`
5. `"BRAND" CATEGORY` (e.g., `"Bible Copilot" christian app`)
6. `site:reddit.com "BRAND"`
7. `site:youtube.com "BRAND"`
8. `site:x.com "BRAND"` and `site:twitter.com "BRAND"`
9. `"LEGAL ENTITY" CATEGORY` (e.g., `"Republic Publishing LLC" Bible app`)
10. `"BRAND" podcast`
11. `"BRAND" newsletter` / `"BRAND" substack`
12. Brand-collision check: search the bare name without quotes, look for namesakes

**Where to look for prospect venues** (not where you're cited, but where competitors are):
- Category review blogs (12 verified for Bible Copilot — ChurchTech Today, Tim Challies, Redeeming Productivity, The Sweet Setup, REACHRIGHT, The Lead Pastor, faith.tools, Doxa, Lumenology, Superprompt, Christian Post Deals, K-LOVE)
- Topical subreddits (10+ for Bible Copilot)
- Podcasts in the niche (5+)
- Substack/newsletter writers (5+)
- YouTube channels (long-tail; rarely organic, usually paid)
- Aggregator directories (faith.tools, AlternativeTo, Product Hunt)

**Output:** `marketing/geo/citation-audit-YYYY-MM-DD.md` listing every found mention (or "none"), every prospect venue with URL, and a top-3 highest-value targets section. See `/Users/carlosreyes/Desktop/Projects/Apps/biblecopilot/marketing/geo/citation-audit-2026-05-02.md` for the template.

### Phase 4 — Apply fixes

This is where the meat is. Three workstreams in parallel:

**4a. Schema patches** — ship the JSON-LD checklist from Phase 2. Validate in Rich Results Test. Reference: `/Users/carlosreyes/Desktop/Projects/Apps/biblecopilot/marketing-site-v2/index.html` (7 blocks shipped).

**4b. llms-full.txt** — write a 5,000-15,000 word AI-readable corpus that answers every buyer question, includes pricing, founder story, feature list, comparison-to-competitor sections, FAQ, and a glossary. **This is the underrated weapon.** AI engines retrieving via RAG against your domain pull from this file disproportionately because it's pre-chunked, plain-prose, no boilerplate. Bible Copilot's lives at `/marketing-site-v2/llms-full.txt`.

**4c. robots.txt + sitemap.xml** — explicitly Allow every AI crawler. Bible Copilot's robots.txt names 22 AI bot user-agents (GPTBot, ChatGPT-User, OAI-SearchBot, PerplexityBot, Perplexity-User, ClaudeBot, Claude-Web, anthropic-ai, Google-Extended, GoogleOther, CCBot, FacebookExternalHit, Meta-ExternalAgent, Bytespider, Applebot, Applebot-Extended, Amazonbot, cohere-ai, DuckAssistBot, YouBot, MistralAI-User, Diffbot). Copy that list verbatim — it's complete as of 2026-05-02.

### Phase 5 — Citation outreach

The schema work moves the needle by ~20%. Citations move it 80%. AI engines' retrieval ranks domains they trust; they trust domains by counting third-party endorsements.

**Three tiers of outreach** (in this order):
1. **Directories** — submit to faith.tools, AlternativeTo, Product Hunt, niche directories. Free, takes a week, every one is a backlink + a citation in the engines that scrape directories.
2. **Review blogs** — pitch the top 5-12 category review sites to be included in their next "best of" refresh. Email template: 2-paragraph pitch, demo link, free Pro code, one-line credibility marker.
3. **Reddit + podcasts + newsletters** — slowest, highest-trust. A single Tim Challies "A La Carte" link is worth 10 directory listings. Don't astroturf.

**Wikipedia eligibility:** only after 3+ independent third-party reviews exist. Don't try to write your own page first — it'll get flagged COI and tank your reputation.

**Response-rate expectation:** ~10-15% on cold pitch to review blogs, ~5% on cold pitch to podcasts, ~30% on directories (it's free + good for them too). Plan for 50 outreach touches to net 5-7 citations in the first 90 days.

### Phase 6 — Content gaps

Your Phase 1 baseline named the gaps. Build pages for each:
- **Comparison pages**: `BRAND vs YouVersion`, `BRAND vs Logos`, `BRAND alternative cheap iOS`. One page per top-5 competitor.
- **Topic pages**: a flagship landing page for each unique mode/feature. For Bible Copilot: an "Inductive Bible Study" page (the exact-match competitor owns this), an "AI Bible Apologetics" page, a "Greek and Hebrew without Logos pricing" page.
- **Long-form guides**: 2,000-4,000 word, schema-marked, FAQ-blocked, glossary-included — the kind of page Perplexity loves to summarize.

Each page ships its own `FAQPage` and `Article` schema and is added to llms-full.txt.

### Phase 7 — Re-test cadence

GEO is slow. Citations propagate to LLM training and retrieval indices over weeks-to-months. Re-test on a fixed cadence so you measure the curve, not the noise:
- **30 days** post-launch: re-run the 10 × N grid. Realistic goal: 3-5/50 cells cite you.
- **90 days**: 8-12/50.
- **6 months**: 15+/50.
- **Quarterly thereafter**: track the GEO Score (% of cells citing you) as a north-star.

The GEO Score is the headline KPI. Bible Copilot's today is **0/50 = 0%**. That's the ground truth and the floor.

---

## 3. The 10-query baseline grid template

Pick 10 queries with this distribution:
- **1-2 head terms** — `best CATEGORY app`, `best CATEGORY 2026` (high volume, listicle territory, hardest to win)
- **3-4 long-tail problem queries** — phrases real users type when they have the pain. Bible Copilot example: "Bible app for inductive Bible study", "AI Bible study for apologetics", "AI Bible study app with Greek and Hebrew"
- **2-3 competitor-alternative queries** — `BIG_COMPETITOR alternative`, `cheap CATEGORY app instead of BIG_COMPETITOR`. Watch for namespace collisions (Bible Copilot's "Logos alternative" returned 8/10 logo-design results).
- **1-2 listicle/recency queries** — `best CATEGORY 2026`, `top CATEGORY apps this year`
- **1 wildcard** — a niche but high-conversion query specific to your differentiator

Adapt for siblings:
- Quran Copilot: `best AI Quran study app`, `Quran tafsir app`, `IslamicFinder alternative`, `AI Quran with tajweed`
- Stoic Copilot: `daily Stoicism app`, `Meditations companion app`, `best Marcus Aurelius app`
- AI FrontDesk: `AI receptionist for small business`, `phone AI for HVAC`, `Ruby Receptionist alternative`
- TurnoutOS: `volunteer canvassing app`, `voter turnout software`, `NGP VAN alternative for small campaigns`

---

## 4. Engine grid + manual test script

**Fetchable (with caveats):**
- WebSearch / Google — tool-level fetchable, parseable. Use as Google AI Overviews proxy.
- Perplexity — `perplexity.ai/search?q=…` returns JS shell only. Use the manual script.
- Bing / Copilot — `bing.com/search` returns JS shell. Manual.
- You.com — JS shell. Manual.

**Not fetchable, manual only:**
- ChatGPT (chat.openai.com, web search ON)
- Gemini (gemini.google.com)
- Meta AI (meta.ai)

**Manual test script** (copy verbatim into each engine, fresh chat each time):

> What are the best apps that do X for me? Please list 5-10 specific apps by name, give a short reason for each, and cite any sources you used. I'm on iOS.

For each `(query, engine)` cell, screenshot the answer and record: `cited Y/N`, the cited URL (or `name-only` if mentioned without link), all named competitors, the model used (GPT-5 vs GPT-4o, Gemini 2.x version, Sonar vs Claude in Perplexity, Balanced vs Precise in Copilot), notes. Save screenshots to `marketing/geo/screenshots/YYYY-MM-DD/`.

Estimated time: 90 minutes for 10 queries × 6 engines.

---

## 5. Schema checklist (ship every one)

| Schema type | Why it matters for AI citation | Required fields |
|---|---|---|
| `MobileApplication` / `SoftwareApplication` | Identifies the product as an app | name, applicationCategory, operatingSystem, offers, aggregateRating, downloadUrl |
| `Organization` | Disambiguates the company behind the app | name, legalName, founder, foundingDate, sameAs[] |
| `Person` (founder) | Powers "made by X" attribution | name, jobTitle, sameAs[], description, knowsAbout[] |
| `Review` + `AggregateRating` | Social proof in the citation card | reviewRating, author, reviewBody, datePublished |
| `Product` + `Offer` | Pricing answers in AI responses | price, priceCurrency, billingDuration, availability |
| `FAQPage` | **Highest-leverage** — quoted verbatim | mainEntity[].{Question, acceptedAnswer.{Answer.text}} |
| `BreadcrumbList` | Helps AI parsers map site structure | itemListElement[] |

Reference shipped: `/Users/carlosreyes/Desktop/Projects/Apps/biblecopilot/marketing-site-v2/index.html` ships all 7 blocks. Validate every change in Rich Results Test before committing.

---

## 6. llms.txt + llms-full.txt + robots.txt + sitemap.xml

| File | Purpose | Mandatory content | Hosted at |
|---|---|---|---|
| `llms.txt` | Short index of the AI-readable corpus | H1 product name, 2-3 sentence pitch, links to each major page with one-line description | `/llms.txt` |
| `llms-full.txt` | Long-form corpus AI engines retrieve from | Founder story, full feature description, pricing, comparison sections per top competitor, FAQ, glossary, change log. 5K-15K words. | `/llms-full.txt` |
| `robots.txt` | Crawler permissions | Allow `*` + explicit Allow for 22 AI bot user-agents (full list in Bible Copilot's `marketing-site-v2/robots.txt`); Sitemap directive | `/robots.txt` |
| `sitemap.xml` | Canonical URL list | Every public URL, accurate `lastmod`, `<priority>` set | `/sitemap.xml` |

The underrated weapon is **llms-full.txt**. AI engines doing RAG against your domain (which is increasingly how Perplexity, ChatGPT search, and Google AI Overviews work) prefer pre-chunked plain-prose corpora. A good llms-full.txt is the one file that single-handedly raises citation rate, because it removes every barrier between the model and your facts (no JS, no nav chrome, no images, no tracking pixels).

---

## 7. Citation outreach playbook

**Venues that work** (highest hit-rate first):
1. Niche directories (faith.tools `/platform-ios`, AlternativeTo, Product Hunt) — submission, ~30% acceptance
2. Category roundup blogs (ChurchTech Today, Tim Challies A La Carte, The Lead Pastor) — cold pitch, ~10-15% reply rate
3. Reddit (r/Christianity, r/Reformed, r/iosapps) — founder post in good faith, ~50% positive engagement if not promotional
4. Substack writers in the niche (faith.tools / Cam Pak, Scot McKnight, Tyler Prieb) — pitch a guest post, ~15% reply rate
5. Podcasts — pitch a founder-interview slot, ~5% reply rate, but huge upside if it lands
6. YouTube — sponsored review or founder interview; rarely organic. Treat as paid.

**Email template (cold pitch to roundup blog):**

> Subject: BRAND for your "best of CATEGORY" list?
>
> Hi NAME — saw your [Year] roundup of [category] apps. Noticed you covered [competitor 1] and [competitor 2] but not BRAND, which I built. Quick differentiator: [one sharp sentence]. Happy to send a free Pro code, demo video, or hop on a 15-min call. No pressure either way.
>
> [Founder name + one credibility marker]

**Response-rate expectation:** plan for 50 outreach touches to net 5-7 placements in 90 days. The slow tail extends 6-12 months.

**Wikipedia:** wait until you have 3+ independent third-party reviews from non-aggregator domains. Self-creation is a flag.

---

## 8. Re-test cadence and the GEO Score

**GEO Score = % of `(query × engine)` cells in your baseline grid where your product is cited.**

| Milestone | Realistic GEO Score | Bible Copilot today |
|---|---|---|
| Launch / baseline | 0% | 0/50 = 0% |
| 30 days post-Phase 4 | 6-10% | target 3-5/50 |
| 90 days | 16-24% | target 8-12/50 |
| 6 months | 30%+ | target 15+/50 |
| 12 months | 40-50% in healthy categories | — |

Be honest with clients: this is a slow-moving game. Schema and llms-full.txt move the needle in weeks; citations propagate over months. If a client wants 30-day blue-link rankings, sell them SEO, not GEO.

---

## 9. Cost model

**Solo operator (Carlos):**
- Phase 1 baseline: 4-6 hours
- Phase 2 schema + technical audit: 2-3 hours
- Phase 3 citation audit: 3-4 hours
- Phase 4 implementation: 8-16 hours (depends on site complexity)
- Phase 5 outreach setup: 4-6 hours, then ~2 hours/week ongoing
- Phase 6 content pages: 4-8 hours per page
- Phase 7 quarterly re-test: 3-4 hours

**Tooling:**
- Anthropic API (running the automated baseline, drafting llms-full.txt): ~$30-80 per engagement
- Optional: Ahrefs ($129/mo) or SEMrush ($139/mo) for competitor backlink mapping
- Google Rich Results Test: free
- Schema.org validator: free

**Engagement size estimate:**
- **Initial setup (Phases 1-4):** $3,500-$8,000 per app
- **Content + outreach (Phases 5-6):** $2,500-$6,000
- **Quarterly retainer (Phase 7 + ongoing outreach):** $1,500/quarter

Bundle as: $5,000 setup + $1,500/quarter retainer for solo founders, $10,000 setup + $3,000/quarter for funded startups.

---

## 10. What to sell vs what to give away

| Phase | Sell or give away? | Why |
|---|---|---|
| Phase 1 baseline | **Give away** as a free audit | Best lead-gen asset in the playbook. Hand a prospect their 0/50 score and they buy the rest. |
| Phase 2 schema audit | Bundle into the diagnostic | Fast, looks technical, low effort once templated |
| Phase 3 citation audit | Bundle into the diagnostic | Same |
| Phase 4 implementation | **Core paid work** | This is the meat. Schema patches + llms-full.txt + robots/sitemap. |
| Phase 5 outreach | **Highest-margin retainer** | Slow tail = recurring revenue. Sell as quarterly. |
| Phase 6 content pages | Per-page or bundled | Comparison pages stand alone; sell each. |
| Phase 7 re-test | **Retainer hook** | Quarterly score updates keep clients engaged. |

**Recommended tiered offer:**
- **Diagnostic ($500-$1,500):** Phases 1-3 only. Deliverable: baseline + audit + 3-page recommendations memo.
- **Implementation ($5,000-$10,000):** Phases 4 + 6 (3 comparison pages). Deliverable: shipped schema, llms-full.txt, 3 new pages.
- **Retainer ($1,500-$3,000/quarter):** Phases 5 + 7 ongoing. Deliverable: 10 outreach touches/month + quarterly score report.

---

## 11. Sibling-app rollout plan

| App | Same as Bible Copilot | What changes |
|---|---|---|
| **Prayer Copilot** | Identical playbook, same Supabase schema, same StoreKit 2 stack | Competitors = Hallow, Glorify, Pray.com, Echo Prayer. Companion programmatic-SEO site already exists — leverage its schema for cross-link authority. Inductive angle replaced with "structured prayer practice" angle. |
| **Constitution Copilot** | Same | Competitors = Annenberg, iCivics, Constitution Center app. Audience = students, teachers, civic-minded adults. "Founders' intent" angle replaces inductive angle. Wikipedia path is realistic given educational adjacency. |
| **Quran Copilot** | Same playbook, same shared Supabase | Competitors = Quran.com, Muslim Pro, iQuran, Tarteel. Inductive-method angle won't work; replace with "tafsir-method" angle (multiple classical commentaries surfaced). Outreach venues = AboutIslam, IslamicFinder community, r/islam. |
| **Torah Copilot** | Same | Competitors = Sefaria (massive), Aleph Beta, Tanach Bible. Sefaria is the YouVersion-equivalent giant. Replace inductive angle with "PaRDeS-method" (Pshat/Remez/Drash/Sod). Outreach venues = Aish, Chabad.org adjacency, r/Judaism. |
| **Gita Copilot** | Same | Competitors = Bhagavad Gita As It Is (ISKCON), Gita Press, Gita Daily. Replace inductive angle with multi-commentator angle (Shankara, Ramanuja, Madhva, Aurobindo). Outreach venues = ISKCON publications, r/hinduism, r/bhagavadgita. |
| **Wisdom Copilot** | Same | Competitors = Blinkist (adjacency), Shortform (adjacency), Mindset App. Broader category — needs sharper positioning. Pick one wisdom tradition first (Tao Te Ching? Proverbs?) before expanding. |
| **Stoic Copilot** | Same | Competitors = Stoic (the journaling app), Daily Stoic, Hallow's Stoic content, Wisdom App. "Daily reading + journaling" angle. r/Stoicism is huge and well-moderated; founder-Q&A there is the highest-leverage citation. |

**Cross-cutting note for the constellation:** all 7 apps share the Supabase project `hfxaltbdagvwtrkfipqi`. Any GEO content that exposes user numbers, retention stats, or aggregate usage **must filter by `app_identifier`** before publishing — leaking sibling-app data into a Bible Copilot landing page is a privacy regression and a positioning regression simultaneously.

**Non-Copilot products:**
- **AI FrontDesk:** different category (B2B SaaS, not consumer iOS). Phase 1 grid stays the same. Phase 2 schema = `Service` + `Product` instead of `MobileApplication`. Citation venues = G2, Capterra, SaaS roundup blogs (not app review sites). Comparison pages mandatory ("AI FrontDesk vs Ruby Receptionist", "AI FrontDesk vs Smith.ai").
- **TurnoutOS:** specialized B2B-to-political. Phase 1 queries are narrower. Citation venues = political-tech newsletters (Campaigns & Elections, The Cycle), state-party tech committees. Lower volume but higher per-citation impact. Wikipedia eligibility low (commercial political vendor).

---

**End of methodology. Last updated 2026-05-02 against Bible Copilot's real artifacts.**

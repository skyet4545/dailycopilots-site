# Bible Copilot — 12-Month Organic Growth Engine → $5–20K/mo (no paid spend)

**Locked 2026-07-04.** Mandate: get Bible Copilot to **~$5–20K/mo within ~12 months**, **organic only (no paid acquisition)**, **all firepower on Bible Copilot** (not the constellation). This doc is the operating plan.

## Baseline reality (be honest)
- **5.0★ but only 9 ratings** (App Store, US, 2026-07-04). The app is very early — the flywheel is stalled at the bottom; revenue is near-zero.
- v2.3.0 is live (new trial-forward paywall; $9.99/mo or $49.99/yr, 7-day trial).
- **The bottleneck is top-of-funnel organic installs**, not conversion polish. With ~9 ratings there's almost no volume flowing through the funnel. Conversion multiplies installs — but first we need installs.

## The equation (what we're engineering)
`Revenue = organic installs × (install→trial) × (trial→paid) × LTV`

With **no paid spend**, organic installs come from exactly four sources, ranked by how much we control them:
1. **OWNED — The Gospel Briefing podcast.** A captive, Bible-interested daily audience where Bible Copilot is the sponsor, in multiple languages. The single biggest lever we fully control. Every listener is a perfect-fit potential install.
2. **OWNED — the AI-search / Google moat.** 2,648 citable pages + the Wikidata/Grokipedia entity. Compounds at zero marginal cost; drives discovery → mybiblecopilot.com → App Store.
3. **App Store organic search (ASO).** Keywords + ratings + conversion + install velocity. Chicken-and-egg with ratings (few ratings → low rank → few installs → few ratings). Breaking this cycle is job #1.
4. **EARNED — Reddit / YouTube / faith-press.** The strongest AI-citation + install lever, but needs founder voice / established accounts (you're now available).

## Honest odds
$5–20K/mo organic-only in 12 months **from 9 ratings is a stretch.** It works only if the podcast + moat genuinely scale installs into the hundreds/day and conversion holds (roughly: ~$10K/mo ≈ ~2,000 paying subs ≈ ~50–70k engaged users). I'll flag the trajectory monthly against the target; if the owned channels aren't pacing by ~month 4, the honest move is to reconsider a small paid test — but per the mandate we go organic-first and hard.

---

## The 12-month roadmap

### Phase 1 — Months 1–2: break the flywheel loose (conversion + ratings + owned channels)
| Lever | Owner | Why |
|---|---|---|
| **Deploy PPO screenshot test** (3 first-frame hooks) + **ASO keyword/subtitle refresh** | together (ASC login) | Multiplies every install; the fastest conversion win |
| **Ratings drive** — 3/10/30 prompt is live; funnel every install through it; target **9 → 100+ ratings** | automatic + monitor | Ratings are the #1 ASO trust/rank/conversion unlock; breaks the chicken-and-egg |
| **Podcast conversion** — one benefit-led, tracked CTA + memorable URL across all language feeds | me (autonomous) | Biggest owned install source; measure attributed installs |
| **Moat install CTAs** — ensure every high-traffic page has a prominent "Download free" CTA; publish 20 install-intent pages ("best AI Bible app for X", "vs" pages) | me (autonomous) | Converts organic discovery → installs; compounds |

### Phase 2 — Months 3–6: compound + earn reach
| Lever | Owner |
|---|---|
| **Reddit** (r/Christianity, r/Bible, r/TrueChristian — authentic answers, never spam) | together (founder voice) |
| **YouTube** ("best Bible study app", verse-explainers — transcript-rich) | together |
| **Faith-press** — 2–3 placements (Crosswalk, ChurchTechToday) → also unlocks Wikipedia + Grokipedia | together (pitch) |
| **Apple editorial feature pitch** — seasonal hook (Advent) — biggest free install spike there is | together (submit) |
| **Retention/LTV** — cut churn, push annual mix, instrument the trial→paid funnel | me + build |

### Phase 3 — Months 7–12: scale what works
Double down on the channel with the best install→paid economics. Re-open the paid question only with real organic-payback data in hand.

## Autonomous (me, now) vs. together (you available)
- **Me, no login:** podcast CTA optimization, moat install-CTAs + install-intent pages, site→App Store conversion, screenshot creative (PNGs), ASO keyword recommendation, measurement/tracking, retention analysis.
- **Together (your login), highest-leverage first:** App Store Connect conversion push (screenshot test + keyword refresh), Grokipedia, Reddit/YouTube seeding, Apple feature pitch, faith-press outreach.

## Measurement (weekly)
Ratings count (trajectory proxy — target the curve steepening), category rank in Reference/Education, mybiblecopilot.com → App Store click-through, podcast CTA clicks. **Monthly gate:** is the ratings/install curve on pace for $5–20K/mo? If flat by month 4, escalate.

## The single most important number to watch
**Ratings count.** It's the visible proxy for install volume AND the biggest conversion lever. Going 9 → 100 → 500 is the flywheel breaking loose. Everything in Phase 1 exists to move it.

---

# 2026 ASO UPDATE — 2026-07-04 (research-backed; supersedes conflicting priorities above)

Sources: Phiture ASO Trends 2026, AppTweak ASO news, Hallow case study (Consumer Startups), Adapty/RevenueCat/Airbridge subscription benchmarks, Reteno 2026 insights.

## What changed in the App Store and what we do about it

| # | 2026 change | Our move | Status |
|---|---|---|---|
| 1 | **CPPs rank in ORGANIC search** (keyword-linking; cap now 70/app) | 5 intent-matched Custom Product Pages (briefs: `marketing/CPP-BRIEFS-2026.md`) | briefs done → push via ASC |
| 2 | **Screenshot caption text is indexed** (June 2025 algo) | Keyword-aware captions in store screenshots | pipeline updated + regenerated 2026-07-04 |
| 3 | **In-App Events are searchable assets** | Seasonal tentpole calendar (Bible in 90 Days → Advent → New Year plan → Lent), each with event + matching CPP + content | calendar: `marketing/IN-APP-EVENTS-CALENDAR.md` |
| 4 | **Retention (D7) is now a ranking input; redownloads > new downloads 2:1** | Daily-verse push + streaks are ASO levers, not just engagement; measure D7 weekly | instrumented via ASC analytics |
| 5 | **Win-back offers: only 9.3% of apps run ANY offer** | StoreKit 2 win-back: 30–50% off annual, auto-shown to lapsed trialists | spec: `marketing/WINBACK-OFFER-SPEC.md` |
| 6 | **Hallow playbook = institutional partnerships + seasonal tentpoles** (Lent: ~500K installs/day) | Church/ministry micro-partnerships with free Pro offer codes | kit: `marketing/CHURCH-OUTREACH-KIT.md` |
| 7 | **40%+ of users consult AI before the app store** | Our GEO/entity/MCP stack already targets this — keep feeding it | live, compounding |

## Revised Phase-1 priority order (rest of Phase 1)
1. Ratings velocity (unchanged — the #1 metric)
2. Screenshot captions (DONE 2026-07-04, ship with next binary/metadata push)
3. 5 organic CPPs (copy done — needs ASC push + per-page screenshot sets)
4. Win-back offer (ASC config ~1h + paywall hook)
5. First In-App Event ("Bible in 90 Days", submit ~Aug 15 for Sep 1 start)
6. Church outreach kit v1 → 10 warm contacts (high-retention installs now boost rank via #4)

Benchmarks for context: onboarding paywalls drive ~50% of trial starts (we lead with trial ✓); opt-in trial→paid median ~8.9%; AI-personalized onboarding +6.1pp (future test).

---

# SOCIAL + DISCOVERY EXPANSION — 2026-07-04 (evening)

## Shipped today
- **Facebook Page daily posting LIVE** — first post published (verse card + caption + App Store link). Daily task `biblecopilot-social-daily` (10am ET): make_card.py → deploy card to mybiblecopilot.com/cards/ → post via facebook-bible-copilot MCP.
- **Instagram poster built** (`src/post_instagram.py`, Graph API): fully autonomous once META_PAGE_TOKEN is in the bot's .env (needs instagram_basic + instagram_content_publish; FB Page linked to IG Business account).
- **Google Search Console: verified + healthy** — property auto-verified (DNS on the same Google account); sitemap submitted since Apr 8, last read Jun 30, Success, **2,655 pages discovered**.
- **Email capture LIVE** on mybiblecopilot.com homepage ("Verse of the Day by email", Netlify Forms — submissions in the Netlify dashboard). Sending pipeline = next build.
- **Typefully: REJECTED as an option (does not work). Do not use or recommend it.** X/Twitter posting needs a different route if ever wanted (X API paid tiers).

## Still needs Carlos (one paste each)
1. **META_PAGE_TOKEN** into BibleCopilot-tiktok-bot/.env → Instagram goes autonomous
2. **VERCEL_TOKEN** (or `vercel login`) → study.mybiblecopilot.com daily refresh loop can be scheduled
3. **Pinterest business account** (I can't create accounts) → then I automate daily verse pins

## Channel map after today (all autonomous)
Search (2,687 pages + GSC + IndexNow) · AI-agents (MCP+entity) · YouTube (3 Shorts/day) ·
Facebook (1 card/day) · Podcast (1-2 eps/day) · App Store (CPPs + win-back + events) ·
Email (capture live, sending TBD) · [Instagram + Pinterest pending 1-step setups above]

---

# SHORTS 2.0 + SELF-IMPROVING LOOP — 2026-07-05

Real data from our first 4 Shorts drove this: myth/curiosity format outperformed verse explainers 5–15x
(127 vs 8 views) — matching 2026 faceless-channel research (curiosity gaps + bold claims win; >65-70%
completion is the promotion threshold; loops count as views).

## Shipped (all autonomous)
1. Prompts rewritten: curiosity/claim hooks (searchable, becomes the title), soft mid-video Pro mention,
   LOOP LINE ending — no spoken outro, no "link in bio" (links live in description + auto-comment).
2. First-frame HOOK title card burned into every video (compose.py, gold 92pt, 1.6s).
3. Auto-comment CTA on every upload (App Store + verse-page links) — token re-scoped to youtube.force-ssl;
   retrofitted onto all 4 live Shorts.
4. Titles = the hook sentence with its ?/! kept (question titles rank in search).
5. Weekly longform: make_weekly.py concats the week's Shorts → "This Week in the Word" (Sundays 8am task;
   mixed-format channels grow ~41% faster). NOTE: never run post_backlog on Sundays (quota).
6. Verse pages now interlink ("Related verses", 4 per page) + embed the matching Short with VideoObject
   schema (video rich results). Publisher enriches every future page; 24 existing pages retrofitted.
7. FB: captions end with an engagement question; second evening myth text-post scheduled daily.
8. Email: welcome email for new subscribers (--welcome-only) + curiosity-hook subject lines.
9. Content pools expanded toward 100/100/80 (myth-weighted — the winning format).
10. SELF-IMPROVING LOOP: Monday 8am `biblecopilot-performance-review` — pulls real YouTube/FB/email
    numbers → writes marketing/weekly-scorecards/<date>.md → makes ≤2 small pool/hook adjustments
    toward whatever won. The machine now tunes itself weekly.

## Needs Carlos (5 min, free): App Store PPO A/B test
ASC → Bible Copilot → Product Page Optimization → Create Test: control = current screenshots,
treatment = marketing/screenshots/store-01..04 (keyword-caption set). Apple splits traffic free and
declares a winner. (Agent can't do it: screenshot upload requires the native file picker.)

---

## OWNED lever 5 — 24/7 ambient livestreams (added 2026-07-09)

Three 24/7 YouTube streams now run continuously: Lofi Hymns (@lofihymnsmusic), The Abiding Place (@theabidingplaceworship), Still Waters (@stillwatersscripturesleep).

- Scene art on all three now carries a quiet mybiblecopilot.com watermark (always on screen, zero marginal cost).
- Stream descriptions + pinned chat carry the Bible Copilot CTA.
- Honest sizing: audiences are near-zero today. Treat as a compounding billboard and brand-ecosystem glue, NOT a growth motor. Do not spend build time here beyond the automated refresh task.
- Revisit as a real lever only if a stream sustains ~50+ concurrent viewers.

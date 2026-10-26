# Bible Copilot — Strategy to $500/month

## Automation operating layer

[Bible Copilot Automation Strategy](../AUTOMATION-STRATEGY.md) is the executable operating layer for
this growth strategy. It connects demand selection, reference assets, authority expansion,
distribution, Facebook and YouTube publication, and weekly performance evidence through versioned
handoffs. The evidence updates and do-not-do rules in this document continue to govern what those
automations may select or scale.

**Baseline (35-day actuals, ASC API, vendor 94000578):** $111.99 proceeds (~$96/mo), ~47 new downloads/mo, ~19% download→Pro, 7:2 annual:monthly, 88% US.

**The constraint:** volume, not conversion. 19% is 4–19× better than typical freemium. Need ~235 downloads/mo (~8/day) to hit $500/mo revenue. = **5× top of funnel.**

---

## The 4 levers (ranked by downloads-per-dollar-and-hour)

### Lever 1 — Apple Search Ads, LONG-TAIL only (the engine). ~$300/mo. [Carlos — browser]
The big correction: ChatGPT ads ($3–5 CPC, want $250+/day) are the *worst* fit at this budget. ASA long-tail runs **~$1.80 CPI**. The $13.20 CPI we saw before was from bidding broad/brand terms ("ai bible", "youversion", "bible gateway") — wrong auction.
- **Rebuild ASA with cheap exact-match long-tail:** `bible questions`, `verse meaning`, `ask the bible`, `scripture explained`, `bible study guide`, `what does the bible say`, `bible answers`, `daily devotional`.
- Match type: exact (+ a small Search Match ad group to discover new terms).
- $300/mo → plausibly 100–200 installs/mo → most of the 5× gap. No creative needed.
- **This alone could roughly reach $500/mo.**

### Lever 2 — ASO (free, compounding). [mostly done; refinements → next version]
- Title already optimized: "Bible Copilot - AI Bible Study" ✓. Keywords already strong (ai, study, scripture, verse, kjv, devotional…) from v1.9.1/v2.0.0.
- Remaining gains to fold into **next version (v2.1)**, not a churning standalone submission:
  - Keyword field swaps: add `chat, gospel, meaning, explain, jesus, gpt`
  - Keyword captions on first 2 screenshots (now OCR-indexed, June 2025)
  - Custom Product Page themed "verse meaning" / "bible questions" (ranks organically since July 2025)
  - Monthly in-app events (Advent/Lent study series — indexed)
- Realistic: +40–80% organic downloads over 90 days (~+20–35/mo), free.

### Lever 3 — International pricing + cross-localization (free config). ✅ PRICING DONE
- **DONE 2026 (this session):** manual per-territory subscription price overrides, ~50% below auto-converted, effective 2026-07-01, existing subscribers preserved (via Apple price-point equalizations):
  - Philippines: annual ₱1,490 / monthly ₱299
  - South Africa: annual R499 / monthly R99
  - India: annual ₹2,499 / monthly ₹499
- **Still to do:** add English (UK/AU) + Spanish (MX) listing localizations for extra US keyword coverage (cross-localization) — bundle into v2.1. Apple never auto-adjusts sub prices, so review quarterly.
- Honest framing: international is a revenue *multiplier* (+20–50% conversion in those markets), not a volume engine. US is the real lever.

### Lever 4 — TikTok organic-to-paid + verse-card sharing (your time). [bot built, account warming]
- No faith app scaled on purely-organic-solo video (Bible Chat's "viral TikTok" was actually paid ASA+TikTok). But sub-$1 faith CPIs exist here (PrayScreen $0.40).
- Bot posts 3×/day once the TikTok account is warmed (verify email/phone, post 1–2 manually, make public, ~24–48h age).
- Build shareable verse-cards into the app (v2.1) to seed free reach; boost proven winners with small budget.
- Treat as cheap volume + creative fuel for paid, not the primary engine.

---

## Math to $500/mo
| Lever | New downloads/mo | Cost |
|---|---|---|
| ASA long-tail | +100–200 | ~$300/mo |
| ASO | +20–35 | $0 |
| TikTok + sharing | +10–40 | ~$0 |
| Intl pricing | (lifts conversion, not downloads) | $0 ✅ done |
| **Total** | **~47 → 180–320/mo** | **~$300/mo** |

Clears the ~235 target → **$500/mo revenue in 60–90 days.** Net of $300 ASA spend, that's ~$200/mo profit — so the truer north star is $500/mo *profit*, reached by scaling ASA once its CPI is proven.

## Do-not-do
- Don't optimize conversion further (19% is great; marginal).
- Don't scale ChatGPT ads (worst $/install at this budget) — let the current run finish for *learning* only.
- Don't translate the app or chase Nigeria volume for revenue.

## Immediate queue
1. **Carlos:** rebuild ASA around long-tail exact-match keywords (above), $300/mo. [browser — ASA blocked for Claude]
2. **Carlos:** warm the TikTok account so the bot can post.
3. **Claude (next version v2.1):** ASO keyword/caption/CPP refinements + cross-localization + in-app verse-card sharing.
4. ✅ International pricing — applied.

---

# EVIDENCE UPDATE — 2026-06-30 (supersedes assumptions above where they conflict)

A full data pull corrected two things and mapped every channel. **Read this section as the current source of truth.**

## Corrected funnel (Apple Analytics, ~90-day window)
- 13.4K impressions → 383 product page views (2.9%) → **110 first-time downloads (0.82% of impressions)** → 29% page→download (healthy) → **5.62% download→purchase by day 35** (NOT the ~19% estimated earlier — that was a tiny-sample error). Proceeds ~$247 in that window.
- **The real leak is impression → tap (0.82%).** Apple already serves ~13.4K free impressions; the icon + first screenshot aren't earning the tap. Once on the page, conversion is fine.

## Where traffic actually comes from (Apple → Analytics → Sources)
- **~100% App Store Search.** App Referrer / Browse / Web Referrer ≈ 0.
- This is largely **branded search driven by the podcast** (listeners hear the ad → search "bible copilot"). Volume ~150 impressions/day = branded, not generic.

## Channel scorecard (honest)
- **The Gospel Briefing podcast** = the ONLY working engine. Daily, 84 eps, BC sponsor read in every one, has a real audience. Feeds branded App Store search. Attribution was invisible (untracked) — now captured by v2.1 in-app "How did you hear about us?" step.
- **Organic App Store Search** = free, high-intent, mostly podcast-fed. ✅
- **Facebook** (page id 1167712496420391): good content, **0 followers, 0 engagement, ~0 reach**; auto-posting (social-distribute Edge Function) stalled ~June 14. **Do NOT restart — content into a void. Constraint is audience, not frequency.**
- **TikTok**: bot built, account unwarmed, ~0 followers, not posting. No data.
- **Paid ads — WRITTEN OFF.** ChatGPT full run (May 28–Jun 26): **$329.75 → 10,102 impr → 126 clicks → 0 credited conversions** (CTR did improve 0.80%→1.25%, CPC $3.28→$2.62, but conversion event was never linked to the campaign + web→iOS leak). ASA earlier: ~$43 → 0 confirmed subs. **Total ~$373 paid → 0 confirmed paid subscribers. Stop paid ads.**

## Revised priority order (do in this order)
1. **ASO listing creative — THE lever.** Fix icon + screenshot #1 to convert the free, high-intent search traffic the podcast drives. Lifting 0.82%→1.5% tap ≈ doubles installs for $0. Assets: 3 icon concepts on Desktop (icon-A/B/C), screenshot copy in `listing-creative-brief.md`. Test via App Store Connect Product Page Optimization (icon A/B first). NEEDS: Carlos's design call.
2. **Amplify the podcast** (it works): more episodes/shows, stronger CTA, eventually tracked link (`?ct=gospelbriefing` — prepared at /tmp/deployed_index_tracked.ts, deploy deferred).
3. **v2.1 attribution** (submitted, in review) → release → confirm podcast's real % via analytics_events query.
4. **International pricing** ✅ live (PH/ZA/IN ~50% off, eff. Jul 1).
5. **TikTok** — only matters once it has an audience; bot ready when account warmed.
6. **NOT:** paid ads, restarting Facebook, conversion-rate tinkering (5.6% is fine).

## Bottom line
One working engine (podcast → free branded search) + a listing that wastes 99% of its free impressions. **Fix the listing creative; amplify the podcast; stop paying for ads.** That is the path to $500/mo.

---

# FULL-FUNNEL CONFIRMATION — 2026-06-30 (the conversion question, answered end-to-end)

Pulled the authoritative data from ASC Sales & Trends API (vendor 94000578, `marketing/asc_subscriptions.py`) + in-app `analytics_events`. **Every stage is now measured.**

## The complete funnel
| Stage | Rate | Benchmark (2026) | Verdict |
|---|---|---|---|
| Impression → download | **0.82%** | low | ⚠️ THE leak — listing creative |
| Download → paid | **5.62%** | freemium 2–5% good, 5.6% median | ✅ healthy |
| Paywall view → trial tap | ~33% | — | ⚠️ soft (currently TestFlight data) |
| **Trial → paid** | **~75% (3 of 4)** | opt-out 25–35% good, 50–60% great | ✅✅ excellent |

## Authoritative numbers (ASC, 2026-06-29)
- Active subs: **~8 paid** (2 Pro Monthly + 6 Pro Annual) + **1 in free trial**.
- Subscription events, last 45 days: 4 trial starts → **3 converted to paid** → trial→paid ≈ **75%**; +1 reactivate, +1 renew.

## Verdict (do not re-litigate)
**There is NO conversion leak in the funnel.** Page converts at benchmark; trials convert *above* benchmark (~75%). The single small number is **trial starts: only 4 in 45 days** — a **volume** problem, not a conversion problem. Caveat: n=4 trials = directional, but enough to rule out a trial leak.

**Confirmed constraint = top-of-funnel volume.** Two levers only: (1) listing creative (fix the 0.82% tap — real-capture gallery done), (2) amplify the podcast (the one working engine). Conversion optimization, paid ads, and Facebook remain OFF the table.

## How to re-measure (monthly)
- Traffic mix: ASC → Acquisition Sources (+ HDYHAU survey once v2.x live, for podcast %).
- Funnel: ASC App Analytics (impression→download→paid) + ASC Subscriptions (trial→paid, churn) + `analytics_events` (paywall_view→trial_tap, release-filtered, dev device excluded).
- Reusable pulls: `marketing/asc_subscriptions.py` (subs/events), Supabase `fseqgcebvxiqmzngxhre.analytics_events` (in-app funnel).

# App Store Growth Plan — PPO creative spec + Apple Search Ads

**Built 2026-07-03.** Two coupled playbooks to fix the diagnosed conversion leak and pour high-intent traffic into it. Grounded in `product-marketing-context.md` (positioning/competitors/customer language) and the earlier conversion diagnosis. Mechanics for running the PPO test live in `marketing/ppo-test-steps.md`; this doc is the **creative + keyword strategy** that doc is missing.

> **Pricing used (current):** Free — 3 questions/day, no account. Pro — **$9.99/mo or $49.99/yr**, 7-day free trial. *(Note: `product-marketing-context.md` still shows the old $4.99/$29.99 · 15/day — it's stale from May; use the current numbers here and correct that doc on the next marketing pass.)*

## The flywheel (why these two, together)
App Store rank compounds: **keyword relevance → impressions → conversion → install velocity → ratings → rank → more impressions.** Two things gate it right now:
1. **The listing doesn't convert** — impression→tap is **~0.8–1.3%** vs. a **~3.6%** peer median (below the 25th percentile). Tap→download is healthy (~29%). So visibility leaks out *before the tap*. → **PART 1 (PPO).**
2. **There's no paid fuel** — acquisition is 100% organic. The fastest "easily found" lever is buying the top of search for high-intent terms, which also feeds organic rank. → **PART 2 (ASA).**

Do them in that order: **fix the page, then buy traffic into it.** ASA sends its clicks to the PPO-winning page (or a custom product page), so a broken page wastes ad spend.

---

# PART 1 — Product Page Optimization: the creative that fixes the tap leak

## The core insight
In App Store search results, most people see only the **first 1–2 screenshots** (and the icon) before deciding to tap or scroll past. So **frame 1 carries ~80% of the conversion decision** — and our current gallery is **Pull-only** (all "here's what's great"), missing the two forces that actually move a hesitant Christian reader: **Push** ("stop bouncing between four apps") and **Anxiety-relief** ("this AI won't give me bad theology"). That gap is the highest-leverage fix (per the switching-forces analysis).

## The test: a first-frame *message* test (3 treatments)
Apple's PPO tests up to 3 treatments vs. your live page. Frames 2–5 stay identical across treatments; **only frame 1's hook changes**, so you cleanly learn *which promise converts*. (Screenshots are web-uploadable — no build needed.)

| Treatment | Angle (force) | Frame-1 headline | Frame-1 subhead |
|---|---|---|---|
| **A — Clarity/JTBD** | Pull | **Understand any Bible verse in seconds** | Ask any question. Get a clear, Scripture-cited answer. |
| **B — Trust/Anxiety-relief** | Anxiety ↓ | **AI Bible study you can actually trust** | Every answer anchored in Scripture — never guesswork. |
| **C — Depth/Push** | Push + Pull | **Go deeper than any devotional** | Serious Bible-study insight, one tap from any verse. |

**Prediction:** B (trust) likely wins for this audience — the #1 stated anxiety is "what if it gives me bad theology?" and no competitor screenshot addresses it. But test it; the audience decides.

## The shared 5-frame gallery (frames 2–5 identical across treatments)
Each frame = a device screenshot + a bold caption overlay (the caption is what converts — real device shots alone don't). Copy uses verbatim customer language ("go deeper," "level of insight," "historical and cultural context," "anchors in scripture," "study companion").

| # | Visual | Caption (overlay) | Why |
|---|---|---|---|
| **1** | The verse→answer moment: a real question ("What does Romans 8:28 mean?") streaming a cited answer | *(per treatment A/B/C above)* | The hook — the whole decision |
| **2** | The six study-mode picker (Summary · Observe · Interpret · Theology · Apply · Apologetics) | **Six study modes. Pick your lens, get a real answer.** | The core differentiator — no competitor has this |
| **3** | An answer with inline verse citations + cross-reference chips | **Every answer cites Scripture — Scripture interprets Scripture.** | Kills the "bad AI theology" anxiety; our trust moat |
| **4** | Historical/cultural context expanded on a passage | **Original context & historical deep-dives, in plain English.** | The "level of insight" pull; "outside the traditional book format" |
| **5** | Clean start screen + 5★ + free-tier line | **Free to start — no account. Trusted by readers going deeper.** | Removes cost/friction anxiety; social proof close |

*(Icon: don't test it in this round — an icon A/B needs alternate icons shipped in a build. Sequence it after, per `ppo-test-steps.md`.)*

## Run it
1. Mechanics (create test, 50/50 split, ~24–48h review, run 2–4 weeks to ~90% confidence): **`marketing/ppo-test-steps.md`**.
2. **Winning metric:** improvement in **conversion rate** (impression→download) per treatment vs. baseline. Don't call it early.
3. Apply the winner as the default page **before** scaling ASA (Part 2), so ad clicks hit the converting page.
4. Then spin up **Custom Product Pages** (up to 35) keyed to ASA ad groups — e.g. a "verse meaning" CPP for generic terms, a "trust/apologetics" CPP for competitor terms — each with a `?ppid=` deep link ASA can target.

---

# PART 2 — Apple Search Ads: the "be found" engine

## Why ASA first (over Meta/etc.)
It's the **literal "easily found" lever** — it places you at the **top of App Store search** for the exact terms buyers type, with the **highest-intent, lowest-CAC** traffic of any channel (searchers are mid-download-decision). Installs from ASA also **feed organic rank** (velocity), so it compounds. Start here; layer Meta/creator later (the `$1 CAC` Baszucki play in the marketing context).

## Campaign structure (4 campaigns)
Separate campaigns so budgets and bids don't cannibalize, and so intent tiers are measured apart.

| Campaign | Purpose | Match | Seed keywords | Bid posture |
|---|---|---|---|---|
| **1. Brand** | Defend your name; cheapest, highest CVR | Exact | `bible copilot`, `biblecopilot`, `bible co-pilot` | Low CPT, always-on. Cheap insurance against competitors bidding your name |
| **2. Generic / category** | The volume + "found" play | Exact (+ Broad in Discovery) | `bible study app`, `bible ai`, `ai bible`, `bible chat`, `understand the bible`, `bible verse meaning`, `what does this verse mean`, `bible commentary app`, `bible questions`, `study the bible`, `bible study tools`, `scripture study`, `apologetics app`, `bible explained` | Moderate; target a CPA aligned to trial→paid LTV |
| **3. Competitor** | Intercept switchers | Exact | `youversion`, `bible gateway`, `logos bible`, `olive tree bible`, `blue letter bible`, `faith guide`, `gotquestions`, `dwell bible`, `pray.com` | Higher CPT (competitor terms cost more, lower relevance); cap spend, watch CVR — cut losers fast |
| **4. Discovery** | Harvest new terms | Search Match **ON** + Broad | *(no keyword list — let Apple find them)* | Low bid; a **feeder** — graduate winners to Exact in campaigns 2/3, add losers as negatives |

## Negative keywords (add to campaigns 2 & 4)
Stop wasted spend on wrong intent / the sibling app:
`prayer`, `prayer app`, `audio bible`, `bible audio`, `free bible download`, `bible wallpaper`, `bible verse wallpaper`, `bible coloring`, `bible games`, `kids bible`, `bible trivia`, `quran`, `torah`, `catholic bible offline`, `sermon` *(unless a sermon-prep CPP is live)*.
*(Note: `prayer` is in your current metadata keyword field but belongs to the sibling **Prayer Copilot** — negative it in ASA and consider dropping it from the metadata field next version to avoid cross-intent.)*

## Bidding, budget & ramp
- **Week 1–2 (learn):** small daily cap (e.g. **$20–40/day** total across campaigns), Discovery + Brand + a tight Generic set. Let Apple gather CVR data. Start CPT bids modest (~$0.60–1.20) and let ASA suggest.
- **Week 3+ (scale):** pour budget into the ad groups hitting your target **cost-per-trial-start / cost-per-install**; pause anything above target. Competitor campaign only scales if its CVR justifies the higher CPT.
- **Target:** work back from LTV. If a 7-day-trial→paid annual ($49.99) converts at X%, your allowable CPA is a fraction of that × X. Instrument the funnel metrics listed in `product-marketing-context.md` before scaling hard.

## Two multipliers
1. **Point ASA at the PPO winner / a CPP**, not the default page — ad relevance + a matched CPP lifts CVR (and lowers effective CPA). This is why Part 1 comes first.
2. **Feed the metadata keyword field from ASA data:** the Exact-match terms that actually convert in ASA are your best free-ASO keywords — rotate winners into the 100-char keyword field on the next version (`marketing/asc_push_metadata.py`). ASA is thus also your **keyword research tool** for organic.

## Measure
Track per campaign/ad-group: Taps, TTR (tap-through rate), CR (install rate), CPA, and downstream **trial-start rate** and **day-7 paid conversion** (via the funnel instrumentation). Kill below-target ad groups weekly; graduate Discovery winners.

---

## What I can do next (autonomous) vs. what needs you
- **I can build now:** the actual **screenshot PNGs** for treatments A/B/C (1290×2796, device-framed, from the spec above); the **exact ASA keyword upload lists** (CSV per campaign) and negative-keyword list; the **CPP copy** variants.
- **Needs you (ASC / Apple Ads login):** create the PPO test, create the ASA campaigns + set budget, publish CPPs. (Same pattern as before — log me in and I'll do the entry, or you paste from the packs.)

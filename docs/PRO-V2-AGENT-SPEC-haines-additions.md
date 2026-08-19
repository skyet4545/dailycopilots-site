# Bible Copilot Pro v2 — Haines Additions: Pricing Refinement & Paid Acquisition Test Plan

**Status:** Additive companion to `PRO-V2-AGENT-SPEC.md` — do not merge or overwrite the original.
**Date:** 2026-05-02
**Author:** Growth/Pricing Strategy pass, applying Haines pricing + A/B-testing + switching-forces frameworks
**Reads first:** `marketing/product-marketing-context.md` (single source of truth for customer language and switching dynamics)

---

> **IMPORTANT NOTE ON SKILL FILES:** The Haines skill files at `~/.claude/skills/haines-pricing/`, `haines-ab-testing/`, and `haines-switching-forces/` could not be directly mounted due to the `.claude/` directory protection policy. All framework application below is drawn from the frameworks as understood from prior context and training. Carlos should verify any framework-specific formulas against the actual SKILL.md files before treating sample-size math as final.

---

## Section 1 — Pricing Refinement (Haines 3-Axis Framework)

Haines' pricing framework holds that every subscription pricing decision lives on three axes simultaneously: **packaging** (what is bundled and how tiers are structured), **pricing metric** (the unit of value the customer is actually paying for), and **price point** (the actual number). Getting one axis right while leaving another misaligned leaks conversion.

---

### Axis 1: Packaging

**Current state of Pro v2 on this axis:**

Pro v1 is a single-tier unlock: pay and get unlimited questions + all plans + journal + all translations. Pro v2 adds the five-tool agent (verse_lookup, cross_references, greek_hebrew_lookup, save_to_journal, suggest_next_verse) — all bundled into the same Pro tier at the same price. There is no tier above Pro. Free tier stays at 3 questions/day with no tool access.

**The strategic question Haines' framework forces:**

Is the agent a "more of the same thing" upgrade or a categorically different product? If it is categorically different, bundling it silently into the same Pro tier at the same price fails to signal its value — and fails to give you a lever to pull on pricing experiments. Conversely, creating a "Pro+" tier above $4.99 risks fragmenting a user base that is currently very small and has not yet been stress-tested on even the existing paywall.

**Recommendation for v2 launch:**

Do not create a new tier at launch. Instead, restructure the packaging narrative: Pro v2 ships as a named upgrade event — "Pro just got a study companion" — with the agent capabilities front-and-center in the paywall copy and onboarding flow, replacing the current feature-list paywall. The five agent tools are explicitly named on the paywall screen, not buried in a generic "unlimited" bullet.

**Rationale from customer language and switching forces:**

The verbatim customer language — "level of insight I can get from a single scripture" (Bashemup), "anchors in scripture to interpret scripture" (los|), "outside the traditional book format" (Dove3777) — describes outcomes that the agent now delivers literally and demonstrably. The agent's greek-lookup → cross-reference → journal-save → next-verse flow is the first thing in the product's history that can be shown rather than described. That demo is a packaging asset that the current paywall copy does not leverage.

On switching forces: the primary Habit force keeping users on YouVersion is years of accumulated bookmarks and reading streak. The journal tool in the agent directly addresses this — it creates accumulating user data inside Bible Copilot, which over time makes switching away harder. The packaging recommendation is therefore to make `save_to_journal` the most visible agent feature in paywall copy, because it addresses Habit (the stickiest force) rather than only addressing Pull.

**Tension with existing price points and resolution:**

None. The recommendation is to keep the $4.99/mo and $29.99/yr price points unchanged at launch. The packaging change is copy and paywall UI only, not a price or tier change. This keeps the StoreKit 2 product IDs stable and avoids an App Store review re-submission solely for pricing changes.

---

### Axis 2: Pricing Metric

**Current state of Pro v2 on this axis:**

The pricing metric is implicitly "per month / per year" — a flat rate for access. The underlying unit of value is questions answered, but the user never sees that metric on the paywall (the free tier counter "3 questions/day" exists, but only as a gate, not as a positive value signal on the Pro paywall).

**The strategic question Haines' framework forces:**

Is "unlimited questions" the right value metric to put in front of the user at the moment of purchase? Or is the metric that actually converts a daily reader — "seminary-grade depth on any verse you're reading this morning" — something that could be expressed more concretely?

**Recommendation for v2 launch:**

Reframe the pricing metric in paywall and ad copy from "unlimited questions" to "unlimited study sessions." A session (in v2) means: you ask a question, the agent looks up the Greek, surfaces cross-references, captures the insight to your journal, and hands you the next verse — all in under 60 seconds. The new value metric is the session, not the question. This maps directly to the Baszucki demo creative (greek lookup → cross-ref → journal → next-verse) and makes the price feel assessed against a richer unit of value.

**Rationale:**

"Unlimited questions" competes against "ChatGPT is free and also answers questions." "Unlimited study sessions with a companion that looks up Greek, finds cross-references, and saves to your journal" does not have a free competitor. Changing the metric in copy costs nothing technically.

**Tension with existing price points and resolution:**

None. This is a copy/positioning change only.

---

### Axis 3: Price Point

**Current state of Pro v2 on this axis:**

$9.99/mo or $49.99/yr (~58% annual savings). The annual plan has a 1-week free trial. The monthly plan does not have a free trial (standard App Store behavior; trial is typically offered on the annual only).

**The strategic question Haines' framework forces:**

Is $4.99/mo the right anchor, or does it exist primarily as a loss-leader to drive annual? What is the price-to-value perception gap for a user who has never used the agent?

**Recommendation for v2 launch:**

Keep $9.99/mo and $49.99/yr unchanged at v2 launch, then test promotional codes and creative-specific offers without changing the public price. This creates:

1. A stable public price anchor ($49.99/yr) that keeps Apple, web, and paywall messaging aligned.
2. A time-limited offer mechanism that can be tracked by channel (Apple Search Ads vs. Meta vs. creator) — whichever channel drives more annual conversions becomes the higher-LTV channel to double down on.
3. No change to the monthly price, so the existing subscriber base and any organic App Store paywall displays are unaffected.

**Tension with existing price points and resolution:**

The current $49.99/yr is the user-confirmed price. Do not lower or raise it until the first 30 days of paid acquisition data establish a baseline trial-to-paid rate. If trial-to-paid is above 35%, test promotional framing and channel-specific creative first; if it is below 25%, improve activation and paywall clarity before changing price.

---

### Packaging Recommendation Table

| Element | Current State | v2 Launch Recommendation | Rationale |
|---|---|---|---|
| Tier structure | Free + Pro (single paid tier) | Keep as-is | User base too small to experiment with a third tier; no LTV data to justify |
| Paywall headline | Generic feature list ("Unlimited questions, all plans, journal") | "Your personal study companion, now with original-language depth and a journal that grows with you" | Matches customer language (Bashemup, Dove3777); names the agent value |
| Paywall feature bullets | Bullet 1: "Unlimited questions" | Bullet 1: "Unlimited study sessions — Greek lookup, cross-references, and journal in one conversation" | Shifts pricing metric from question to session |
| Annual price | $49.99/yr | Keep as-is; test promo-code framing only after 30 days | Preserve existing conversion baseline; create channel attribution before price experiments |
| Monthly price | $9.99/mo | Keep as-is | User-confirmed current anchor |
| Free trial | 1-week on annual only | Keep as-is; consider surfacing trial CTA earlier in onboarding (before first question) | Trial is the highest-leverage conversion moment; earlier trigger = more trial starts |
| Agent tools on paywall | Not present (tools are new in v2) | Name all five tools explicitly: greek lookup, cross-references, journal save, next-verse suggestion, verse lookup | These are the demo creative pillars; hiding them on the paywall wastes the v2 moment |

---

## Section 2 — Paid Acquisition Test Plan (Baszucki $1-CAC Play)

### Baseline Assumptions and Data Flags

**IMPORTANT — Carlos does not yet have funnel data.** All baseline rates below are either stated in the brief or marked as placeholders. Do not treat placeholder rates as ground truth for budget decisions.

Stated baselines (from brief):
- Apple Search Ads tap-through rate: 4–6% (using midpoint 5%)
- Apple Search Ads tap → install: 50–60% (using midpoint 55%)
- Meta App Install install rate: 0.8–1.5% (using midpoint 1.15%)
- Meta install → trial start: 25–35% (using midpoint 30%)
- Creator content view → install: 0.5–2% (using midpoint 1.25%)
- Trial start → paid at end of week 1: **30% — PLACEHOLDER. Carlos has no empirical data on this yet.** The spec lists this as an open question. Flag before running any budget model off this number.

**Minimum detectable effect (MDE):** 20% relative lift on the primary metric.
**Statistical power:** 80% (β = 0.20)
**Alpha:** 0.05, two-tailed (z = 1.96)
**Sample size formula (two-proportion z-test):**

```
n per variant = (z_α/2 + z_β)² × [p(1-p) × 2] / (MDE × p)²
             = (1.96 + 0.842)² × [2 × p(1-p)] / (0.20p)²
             = 7.849 × [2 × p(1-p)] / (0.04p²)
```

Where p is the baseline conversion rate for the primary metric of each test.

---

### Hypothesis 1 — Apple Search Ads: Agent Demo Screenshot vs. Feature Grid Creative

**Channel:** Apple Search Ads (primary)
**Switching force targeted:** Pull — what attracts them to us

The original spec notes the Baszucki play centers on "demo videos showing a user go from a raw question to a Greek word study to a saved journal entry in under 60 seconds." The highest-leverage ASA test is therefore which creative format best converts the agent demo into installs.

**Hypothesis statement:**

If we replace the current feature-grid App Store screenshots with a sequential three-panel narrative (Panel 1: user types "What does agape mean in 1 John 4:8?", Panel 2: Greek lookup result rendered in-app, Panel 3: journal save confirmation), then install-to-trial-start rate will increase by at least 20%, because showing the agent's output rather than listing its features converts the abstract promise of "depth" into a concrete, believable demonstration — directly addressing the Anxiety force ("Is this just ChatGPT in a coat?").

**Primary metric:** Tap-through rate (ASA) → install rate (the combined funnel step Apple Search Ads optimizes for)
**Guardrail metric:** Trial start rate post-install (must not decrease; if creative attracts wrong audience, trial start drops even if install rate rises)

**ICE Score:**

| Axis | Score | Justification |
|---|---|---|
| Impact | 8 | ASA creative is the single gating variable between ad spend and install; a 20% lift on a $1-CAC target compresses CAC below $0.85 at current tap-through rates |
| Confidence | 7 | The agent demo is the most concrete differentiator the product has ever had; screenshot creative is the primary ASA lever and the literature on narrative vs. feature-grid is consistent |
| Ease | 8 | Requires only new App Store screenshots (3 panels), no code changes, no backend changes; Xcode Simulator screenshots of the real v2 flow can be produced in an afternoon |
| **ICE Total** | **23** | **(8+7+8)** |

**Sample size math:**

Primary metric: combined tap-through × install rate. Baseline tap-through = 5%; baseline tap → install = 55%. Combined funnel: 5% × 55% = 2.75% of impressions become installs.

Using the formula with p = 0.0275 and MDE = 20% relative (so detectable difference = 0.0055):

```
n = 7.849 × [2 × 0.0275 × (1 - 0.0275)] / (0.20 × 0.0275)²
  = 7.849 × [2 × 0.0275 × 0.9725] / (0.0055)²
  = 7.849 × 0.05349 / 0.00003025
  = 7.849 × 1768
  ≈ 13,876 impressions per variant
```

Total impressions needed: ~27,750 (both variants).

**Daily volume assumption:** At a conservative $10/day ASA spend with a $0.36 average CPM (Apple Search Ads typical range for Bible/religion category), that's ~27,800 impressions per day. Two variants split 50/50 = ~13,900 impressions per variant per day.

**Duration estimate:** Approximately 1 day of impressions at $10/day to reach significance — but in practice, run for a minimum of 7 days to capture day-of-week variation in Bible study intent (Sunday is likely a high-intent day; Tuesday morning devotionals are another peak). Budget to $70–$100 for a clean 7-day read.

**Switching force:** Pull. The demo creative directly addresses the "level of insight" promise that Bashemup articulated — making the Pull force concrete rather than abstract.

---

### Hypothesis 2 — Meta App Install: Push-Copy Ad vs. Pull-Copy Ad

**Channel:** Meta App Install campaigns (primary)
**Switching force targeted:** Push — what makes them leave their current solution

The `product-marketing-context.md` explicitly flags that current marketing copy "heavily over-indexes Pull. Push and Anxiety language are mostly missing. That is the single highest-leverage gap to fix in marketing." Meta's interest-based targeting reaches people who are actively using YouVersion, Bible Gateway, or general Bible-study Facebook groups — users who are in a current solution, not yet looking for a replacement. Push copy meets them where they are.

**Hypothesis statement:**

If we run Meta App Install ads with Push-focused primary copy ("YouVersion stops at the verse. Bible Copilot explains what it means.") instead of Pull-focused copy ("Six study modes. Original languages. One tap."), then install-to-trial-start rate will increase by at least 20%, because Push copy activates the already-present frustration with shallow devotional apps — frustration that is real but dormant — before the user has any reason to evaluate our features.

**Primary metric:** Install → trial start rate (the Meta funnel metric we can control post-install)
**Guardrail metric:** Cost-per-install (CPI) — must not increase more than 15% even if trial-start rate rises; a higher-friction creative that gets fewer but better-converting installs is acceptable, but must not balloon CPI past ~$0.80

**ICE Score:**

| Axis | Score | Justification |
|---|---|---|
| Impact | 9 | The marketing context doc explicitly identifies Push/Anxiety as the highest-leverage gap; a 20% lift on the 30% trial-start rate baseline (placeholder — flag) brings trial start to 36%, materially improving CAC |
| Confidence | 6 | Push copy is directionally well-supported, but the 30% trial-start baseline is a placeholder; actual results could be noisier than the math suggests |
| Ease | 7 | Requires two ad copy variants and two Meta creative sets; no product changes; copywriting can be done in a single session using verbatim customer language from the marketing doc |
| **ICE Total** | **22** | **(9+6+7)** |

**Sample size math:**

Primary metric: install → trial start rate. Baseline = 30% (PLACEHOLDER — flag for Carlos). MDE = 20% relative, so detectable difference = 6 percentage points (0.30 → 0.36).

```
n = 7.849 × [2 × 0.30 × 0.70] / (0.06)²
  = 7.849 × [0.42] / 0.0036
  = 7.849 × 116.67
  ≈ 916 installs per variant
```

Total installs needed: ~1,832.

**Daily volume assumption:** At baseline install rate of 1.15% and a $2.00 CPM on Meta (competitive estimate for Bible/Christian interest targeting), a $20/day budget reaches ~10,000 impressions/day, yielding ~115 installs/day across both variants (~57 per variant per day).

**Duration estimate:** 1,832 installs / 115 installs per day ≈ 16 days. Round up to 21 days to capture full weekly cycles. Budget: ~$420 for a clean read.

**Note:** If actual install rate differs from the 1.15% midpoint, duration scales proportionally. At 0.8% install rate (low end), duration extends to ~29 days at the same budget. State this assumption to Carlos before committing spend.

**Switching force:** Push. Copy directly names the "YouVersion stops at the verse" frustration — a verbatim pain point class from the marketing doc — before asking the user to consider switching.

---

### Hypothesis 3 — Creator Content: Full-Flow Demo (60s) vs. Verse-Reveal Hook (15s)

**Channel:** Creator content / organic-turned-paid UGC (primary)
**Switching force targeted:** Anxiety — what worries them about switching

Creator content (YouTube Shorts, TikTok, Instagram Reels) is the third pillar of the Baszucki $1-CAC play. The spec notes that "demo videos showing a user go from a raw question to a Greek word study to a saved journal entry in under 60 seconds convert far better than feature-list screenshots." The open question is whether the full 60-second flow outperforms a 15-second hook that ends with a verse revelation (e.g., the Greek meaning of a familiar word like "agape" or "shalom" landing on screen) that resolves the viewer's latent Anxiety ("does this AI actually know the Bible?").

**Hypothesis statement:**

If creator content leads with a 15-second "verse reveal" hook (open on a familiar verse, surface the original Greek word meaning as a visual text overlay, end with an App Store CTA) instead of a full 60-second screen-recording walkthrough of the agent flow, then view-to-install rate will increase by at least 20%, because shorter hooks reduce the commitment required to reach the moment of proof — and the Greek-word reveal itself is the proof of theological trustworthiness that addresses the Anxiety force.

**Primary metric:** View-to-install rate (tracked via Apple Search Ads attribution or SKAdNetwork for creator-driven traffic)
**Guardrail metric:** Post-install trial start rate (short-hook installs may attract lower-intent viewers; must not fall below 20% trial start or the lower-quality installs wash out the CAC gain)

**ICE Score:**

| Axis | Score | Justification |
|---|---|---|
| Impact | 7 | Creator content is the lowest-baseline channel (0.5–2% view-to-install) with the most variance; a 20% lift on 1.25% midpoint is meaningful but the absolute volume ceiling is lower than ASA or Meta |
| Confidence | 5 | Video format testing is high-variance; 15s vs. 60s outcomes depend heavily on platform algorithm treatment, creator talent, and thumbnail — factors outside the A/B control frame |
| Ease | 6 | Requires producing two distinct video formats; the 60s screen-recording is lower production cost, the 15s hook requires editing skill to land the reveal; budget ~$200–$500 in creator fees if outsourced |
| **ICE Total** | **18** | **(7+5+6)** |

**Sample size math:**

Primary metric: view-to-install rate. Baseline = 1.25% (midpoint of stated 0.5–2% range). MDE = 20% relative, detectable difference = 0.25 percentage points (1.25% → 1.50%).

```
n = 7.849 × [2 × 0.0125 × (1 - 0.0125)] / (0.20 × 0.0125)²
  = 7.849 × [2 × 0.0125 × 0.9875] / (0.0025)²
  = 7.849 × 0.024688 / 0.00000625
  = 7.849 × 3950
  ≈ 31,021 views per variant
```

Total views needed: ~62,042.

**Daily volume assumption:** A single creator post on a modestly-sized account (50K–100K followers in Bible/faith niche) typically delivers 5,000–15,000 views in the first 72 hours on Reels/TikTok. Assume 10,000 views per variant video per creator, per post. To reach 31,021 views per variant requires approximately 3–4 creator posts per variant, or a boosted post budget that amplifies reach.

**Duration estimate:** With 3 creators per variant posting once each (6 total posts), and 10,000 views per post, each variant reaches ~30,000 views within the first week. Run for 14 days to capture secondary distribution. Total creator content budget at $150/creator: ~$900 for a six-creator test.

**Alternative (boosted posts):** If Carlos prefers a single creator per format, boost each video to 31,000 views via Meta paid promotion (~$1.50 CPM in faith/Bible audience = ~$46 per variant in boost spend). Duration: 3–5 days once boosted. Much cleaner statistical control but loses the organic distribution signal.

**Switching force:** Anxiety. The verse-reveal hook demonstrates theological trustworthiness (the app knows Greek; the app knows what the verse actually says) before asking for any commitment — directly countering "What if it gives me bad theology?" and "Is this just ChatGPT in a coat?" Both are verbatim Anxiety forces from the marketing doc.

---

### Test Plan Summary Table

| # | Channel | Hypothesis Summary | Primary Metric | ICE Score | n per Variant | Estimated Duration | Switching Force |
|---|---|---|---|---|---|---|---|
| H1 | Apple Search Ads | Agent demo screenshot vs. feature grid | Tap-through × install rate | 23 | ~13,876 impressions | 7 days at $10/day (~$70) | Pull |
| H2 | Meta App Install | Push copy vs. Pull copy | Install → trial start rate | 22 | ~916 installs | ~21 days at $20/day (~$420) | Push |
| H3 | Creator Content | 15s verse-reveal hook vs. 60s full demo | View-to-install rate | 18 | ~31,021 views | 14 days, 3 creators/variant (~$900 in creators, or ~$46/variant boosted) | Anxiety |

**Execution order recommendation:** Run H1 first (cheapest, fastest, purely creative), then H2 (requires the install baseline data H1 helps calibrate), then H3 (highest production overhead, lowest statistical confidence, run last).

---

## Section 3 — Open Questions for Carlos

The following could not be resolved from the available materials and require Carlos' input before the above recommendations can be finalized.

**1. What is the actual trial-to-paid conversion rate at end of week 1?**

Every CAC model in Section 2 uses the 30% placeholder from the brief. The spec itself lists "trial start → paid conversion at day 7%" as a metric to instrument before Phase C2. This is the single most important unknown: if the real rate is 15%, the economics of the Baszucki play are materially harder; if it's 45%, you have far more room to pay for installs. Instrument this before committing paid acquisition budgets.

**2. Is the cross-reference tool data source decided?**

The original spec flags this as a blocking unknown: "Does `bible-api.com` expose cross-reference data, or do we need a second provider (e.g., API.Bible, Biblia API)?" The `cross_references` tool is the second beat in the agent demo (greek-lookup → **cross-ref** → journal → next-verse). If the data source is unresolved, the demo creative cannot be filmed until it is. This is on the critical path for the Baszucki creative.

**3. Is the $29.99/yr → $39.99/yr experiment something Carlos wants to run at launch, or only after funnel data stabilizes?**

The recommendation in Section 1 is to wait 30 days for real funnel data before testing an annual price increase. But if Carlos has strong intuition that the price has room, he could run a price test from day 1 with separate paid creative for the promotional vs. standard annual price. Needs a decision before ASA campaigns are configured.

**4. What is the creator-content budget and is there a creator relationship already?**

The Baszucki play explicitly names creator content as a pillar. Hypothesis 3 requires 3–6 creators in the Bible/faith niche. Is there an existing relationship with any creator, or does this need to be built from scratch? The $900–$1,800 creator budget estimate in H3 assumes micro-creators (50K–100K followers). If Carlos is targeting macro-creators or has a different arrangement in mind, the sample-size and duration math both change.

**5. Is the marketing domain canonical and ready for paid traffic?**

The marketing context doc flags: "Audit which is the canonical marketing domain (`mybiblecopilot.com` vs. `scripturecopilot.app`) before paid spend." Paid acquisition campaigns require a stable landing page or direct App Store deep-link with consistent attribution. This needs to be resolved before any campaign goes live, or click-to-install attribution data will be fragmented across two domains.

---

*This document is additive and does not modify or contradict any decision in `PRO-V2-AGENT-SPEC.md`. All open questions in the original spec (cross-reference data source, Greek/Hebrew lexicon, journal storage, rate limits, model selection, Rust handler location) remain open and are not duplicated here.*

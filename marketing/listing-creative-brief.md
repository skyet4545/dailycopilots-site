# Bible Copilot — App Store Listing Creative Brief

**Why this exists:** Analytics proved the #1 leak. Apple serves ~13.4K impressions/90d (≈150/day), almost all **App Store Search** (high intent), but only **0.82% download** (110). Once on the page, 29% download — that's fine. **So the loss happens in the search result itself: icon + first screenshot aren't earning the tap.** Title/keywords are already well-optimized; this brief is about the *visuals* that decide the tap. Goal: lift impression→download from 0.82% → 1.5%+ ≈ **double downloads from the same free traffic, $0 spend.**

## What a searcher actually sees (and what to optimize)
In iPhone search results, before tapping, the user sees: **app icon + name + the first 1–3 screenshots** (portrait, partially). The icon and **screenshot #1** carry ~90% of the tap decision. Optimize those first; everything else is secondary.

## 1. Icon (highest leverage)
Current: dark/navy with compass mark. Problems to test against:
- At thumbnail size in a list of Bible apps (many are gold/cross/parchment), does it **read instantly as "Bible"** AND **stand out**?
- **Recommendation to test:** a clean, high-contrast mark that signals *Bible + AI* — e.g. an open book/Bible silhouette with a subtle spark/chat glint, on a single bold color (deep navy or warm gold). Avoid fine detail (compass lines vanish at 60px). One idea, one color, high contrast. 
- Make **2–3 variants** and A/B them (see "How to test" below).

## 2. Screenshot #1 — the single most important asset
This is the billboard. **It must show the REAL flow, not an open life-question chatbot.** The actual primary interaction (verified in `HomeView.swift` + `StudyModePillsView.swift`): user enters a **verse reference** (input placeholder "Enter any verse…", defaults to John 3:16) → taps one of **6 study mode pills** → gets a verse-anchored, mode-specific answer. The hero must read as *"study any verse, deeply,"* NOT *"ask the Bible any life question."*

Rules:
- **One big headline, readable at half-size, top third.** Use verse-first framing (test):
  - "Study any verse, **six ways**"  ← recommended hero
  - "Understand **any verse** in seconds"
  - "Every answer **cites Scripture**"
  - ✗ Avoid "Ask the Bible anything" — it sells the wrong product (implies open chatbot).
- **Show the signature UI:** the verse field with a real reference (e.g. "Romans 8:28") + the 6 study-mode pills below it, in their real brand colors. That grid *is* the differentiator and must be visible without reading.
- High contrast, big type, minimal chrome. Don't show a settings screen or a wall of text.

## 3. Screenshots #2–#4 (verified gallery — see rendered mockup)
Matches how most users actually move through the app:
- **#2 — the payoff:** a verse + selected mode (e.g. "Romans 8:28 · Interpret") and the verse-anchored answer card **with cross-reference chips**. Shows the magic the modes produce.
- **#3 — the habit/depth layer:** Pro retention features — **study journal** (saved insights) + **reading plans**. This is what *annual* buyers value.
- **#4 — the offer:** 7-day free trial value stack (unlimited verse studies, all 6 modes, journal + plans) → "$49.99/yr · cancel anytime."
- **Add keyword captions** (OCR-indexed since June 2025): #1 "Bible study app — verse meaning," #2 "Scripture explained with cross references," #3 "Study journal & reading plans," #4 "Free trial — unlimited studies."

**Accuracy caveat (do not overclaim):** "original languages / Greek-Hebrew" insight is **AI-generated inside Interpret mode**, not a dedicated lexicon — don't mock a lexicon UI. The 6 modes, verse-anchored answers, cross-references, journal, and reading plans are all real shipping features.

## 4. Minor metadata tweaks (fold into next version)
- Subtitle test: "Scripture Questions Answered" → **"Ask Any Verse, Get Real Answers"** (adds *ask*, *verse*, *answers*; keeps it benefit-led).
- Keyword field swap-ins to consider: add `chat, gospel, meaning, explain, jesus, gpt`; drop the weakest current terms (e.g. `sermon`, `commentary`) if popularity is low (validate in Apple Ads Search Popularity).

---

# OPTIMIZATION PASS — 2026-06-30 (final, applied to the real-capture gallery)

## A. Screenshot copy — SHIPPED in `screenshots/store-0*.png`
Headlines are benefit-led AND keyword-loaded (Apple OCR-indexes screenshot text). Coverage spread so no term is wasted:

| # | Image (real capture) | Headline | Caption (keyword line) |
|---|---|---|---|
| 1 | Home | **Understand any Bible verse** | AI Bible study & daily devotional |
| 2 | 6 mode cards | **Study Scripture six ways** | Summary · meaning · theology · apply |
| 3 | AI answer | **Every answer cites Scripture** | Bible questions answered, with cross-refs |
| 4 | Paywall | **Try Pro free for 7 days** | Unlimited Bible questions · cancel anytime |

Keywords surfaced visually: *bible verse, AI bible study, devotional, scripture, meaning, theology, apply, bible questions, cross references*. Order follows tap-decision weighting (hook → breadth → proof → offer).

## B. Metadata package — APPLY in next version (v2.x), char-counted
Apple indexes **title + subtitle + keywords TOGETHER** and does **not** index the description. So: never repeat a word across these three fields, use singular forms (Apple auto-pluralizes), no spaces after commas, no competitor brand names.

- **Title (≤30):** `Bible Copilot - AI Bible Study` — keep (30). Covers: *bible, copilot, ai, study*.
- **Subtitle (≤30):** `Verse Meaning & Bible Answers` (29). Adds: *verse, meaning, answers*.
  - alt to A/B: `Ask the Bible · Verse Meaning` (30) — trades *answers* for *ask*.
- **Keywords (≤100, no repeats of above):**
  `scripture,devotional,kjv,gospel,jesus,christian,chat,gpt,commentary,daily,reading,plan,prayer,niv` (~97)
  - Validate each in Apple Ads Search Popularity before locking; swap lowest-pop term for `niv`→`esv`/`explain` as data shows.
- **Promotional text (≤170, not indexed — pure conversion, editable anytime):**
  `Ask any Bible verse and get a clear, Scripture-cited answer in seconds. Six study modes, cross-references, and reading plans. Start your 7-day free trial.` (≈150)

## C. Do / Don't
- ✅ Run the change as a **Product Page Optimization A/B** (store-02 vs current screenshot #1) before committing — don't blind-swap.
- ✅ Keep the **real-capture set** as default; the synthetic set is treatment B.
- ❌ Don't repeat keywords across title/subtitle/keyword field. ❌ Don't add "app", "free", or competitor names to the keyword field. ❌ Don't touch the description for ranking (unindexed).

## How to test (free, low-risk)
- **Custom Product Pages (up to 70) + Product Page Optimization (A/B):** App Store Connect lets you A/B up to 3 icon/screenshot treatments against the default and reports the winner by conversion — **this is the right way to validate before committing.** Run icon A/B first (biggest lever), then screenshot #1.
- Metadata/visual changes take ~24–48h review + ~1–2 weeks to read conversion impact.

## Priority order
1. **Icon A/B** (2–3 variants) — biggest tap-decision driver
2. **Screenshot #1 rebuild** — the billboard
3. Screenshots #2–#3 + captions
4. Subtitle + keyword tweaks (bundle into v2.1)

## Honest expectation
This is the highest-ROI free lever because it multiplies *traffic you already get for free*. Realistic: lifting 0.82% → 1.3–1.6% roughly **1.5–2× downloads** with zero ad spend. It won't 5× you alone — but combined with more search rank (ASO keywords + reviews) and the international pricing already live, it's the cheapest, surest first step toward $500/mo. Requires design work (icon + screenshots) — that's the one input only you/a designer can produce.

# Product Page Optimization — step-by-step (Bible Copilot)

**Goal:** A/B-test the new verse-first screenshots against the current gallery to lift impression→tap (currently 0.82%). No build needed — screenshots are web-uploadable.

**Assets:** `marketing/screenshots/store-01…04.png` (6.9″, 1290×2796). The `6.5-inch/` set is optional backfill.

---

## Steps (App Store Connect, ~20 min)

1. **App Store Connect → Apps → Bible Copilot.**
2. Left sidebar → **Product Page Optimization** → **Create Test**.
3. **Test name:** `Verse-first screenshots v1`.
4. **Number of treatments:** `1` (Treatment B = new gallery; Control = your current live page, automatic).
5. **Traffic proportion:** `50%` to the treatment (50/50 split).
6. **Treatment B setup:**
   - Leave **App Icon** = current (don't test icon yet — that needs a build).
   - **Screenshots (6.9″):** upload `store-01-home.png`, `store-02-study.png`, `store-03-answer.png`, `store-04-paywall.png` **in that order**.
   - (Optional) upload the `6.5-inch/` versions if it asks for that size.
7. **Start Test.** It goes through a short review (~24–48h), then runs live.
8. **Duration:** let it run **2–4 weeks** (≈150 impressions/day → needs time for ~90% confidence). Don't call it early.
9. **Read results:** same PPO panel reports **improvement in conversion rate** per treatment vs baseline, with a confidence indicator.
10. **Apply the winner:** if Treatment B wins, set those screenshots as the default product page.

---

## Sequence after this test
1. ✅ This screenshot test (now).
2. Apply winner → bundle **2 icon variants into v2.x build** → run a **PPO icon test** (icon A/B requires the alt icons shipped in the binary).
3. (Optional) **Custom Product Page** themed to the podcast, with a `?ct=gospelbriefing` link in show notes.

## Notes / gotchas
- Only **one PPO test** runs at a time, against the **default** page — so do screenshots first, then icon.
- PPO does **not** change search ranking; it only changes what converts the traffic you already get.
- Metadata (subtitle/keywords/promo) is separate — pushed with the next **version**, not here. Script: `marketing/asc_push_metadata.py` (read-only by default; `--apply` to write). Validate keyword Search Popularity in Apple Ads first.

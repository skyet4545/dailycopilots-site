# ChatGPT (OpenAI) Ads — Test Plan & Creative

Status: **measurement built, ready to launch once v2.0.0 is live.** Do NOT launch before v2.0.0 ships to the App Store.

## Why this channel
Someone typing a faith/life question into ChatGPT is the highest-intent prospect possible for an AI Bible app. Context match beats Apple Search keywords. First run failed on funnel (fixed in v2.0.0) + zero measurement (fixed below) + weak creative (new variants below), not on channel fit.

## Measurement — DONE (2026-06-12)
- OpenAI Web data source "Bible Copilot Web", Pixel ID `V6F2nYbmUAbFxHvfygLF9a`
- Conversion event "App Store Click" = custom `appstore_click`, 30-day window
- Pixel live on mybiblecopilot.com: fires `page_view` on load, `appstore_click` on the "Download on the App Store" CTA
  - Exact call: `oaiq("measure","custom",{type:"custom"},{custom_event_name:"appstore_click"})`
- Proxy conversion = clicked through to App Store. NOT a paid sub (web→iOS attribution gap), but flips OpenAI's optimizer from "find clickers" to "find App-Store-intenders." Real paid-sub attribution would need App Store Server Notifications → Conversions API (future, only if this test wins).
- **At launch:** in the campaign's "Conversion event (optional)" field, select **App Store Click** so the campaign optimizes toward it (step 4 of OpenAI's setup — link event to campaign).

## Budget & exit criteria
- Spend: **$300–500** ($25–40/day for ~12 days) — enough for ~100–150 clicks at the prior $3.28 CPC to read CTR + App-Store-click rate with confidence. The first run's 8 clicks taught us nothing; this is the minimum real sample.
- Read after ~100 clicks:
  - **CTR** vs prior 0.80% (target >1.5%)
  - **App-Store-click rate** (page_view → appstore_click) — the new number we couldn't see before
  - **Cost per App Store click** — proxy for cost per install
- Kill if CTR stays <0.8% AND cost/App-Store-click > ~$8 after 100 clicks. Scale if CTR >1.5% and cost/App-Store-click < $5.

## Creative variants (rotate; OpenAI picks winners)
Headline ≤50 chars, Description ≤100 chars. Landing: https://mybiblecopilot.com

**V1 — the question moment**
- H: `Ask the Bible Anything — Get a Real Answer` (43)
- D: `AI Bible study that cites Scripture for every answer. 5 study modes. 7-day free trial.` (86)

**V2 — answer-with-evidence**
- H: `Every Answer Backed by Actual Scripture` (39)
- D: `Stop guessing what the Bible says. Verse-anchored AI study, denominationally fair. Free trial.` (94)

**V3 — depth / serious study**
- H: `Bible Study Depth, In Your Pocket` (33)
- D: `Observe, interpret, apply, defend — the inductive method, guided by AI. Try Pro free 7 days.` (91)

**V4 — the struggle hook** (matches onboarding quiz)
- H: `Anxious? Grieving? See What Scripture Says` (42)
- D: `Ask any question, get a verse-anchored answer in seconds. AI Bible study. 7-day free trial.` (91)

Image: reuse `~/Desktop/BibleCopilot-AdImage-1024.png` (navy + compass + "AI for Bible Study") OR a cleaner answer-card mock. 1024×1024.

## Context hints (targeting)
Bible study, verse interpretation, what does the Bible say about, Christian apologetics, theology questions, devotional reading, scripture meaning, faith and doubt, anxiety bible verses, grief comfort scripture, prayer life, Old/New Testament context, hermeneutics, inductive Bible study.

## Launch checklist (when v2.0.0 is live)
1. Confirm v2.0.0 RELEASED (not just approved) so clickers land in the new quiz→trial funnel.
2. Create campaign, objective Clicks, USA, $25–40/day, ~12-day window.
3. **Link conversion event = App Store Click.**
4. Add 4 creative variants above + image.
5. Verify pixel fires: dashboard → Conversions → Event Stream should show page_view/appstore_click within minutes of real traffic.

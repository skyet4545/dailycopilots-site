# Custom Product Pages — 5 organic-search CPPs (2026-07-04)

Why: Apple's keyword-linking update surfaces CPPs in ORGANIC search results (cap raised to 70/app).
Each CPP = its own screenshots + promo text, linked to a keyword theme. Default page stays generic;
these pages match searcher intent exactly → higher conversion.

Push via ASC (App Store Connect → Bible Copilot → Custom Product Pages) or ASC API
(`appCustomProductPages`). Screenshot sets reuse the `marketing/screenshots/` pipeline —
same frame, swap headline/caption/source per page.

---

## CPP 1 — "bible study app" (highest volume)
- **Keyword theme:** bible study app, bible study, study bible
- **Promo text:** Study any verse six ways — summary, meaning, theology, application. Free 7-day Pro trial.
- **Screenshot order:** 02-study (lead), 01-home, 03-answer, 04-paywall
- **Lead headline:** "Study Scripture six ways"

## CPP 2 — "ai bible" / "bible ai"
- **Keyword theme:** ai bible, bible ai, bible chat, ask bible
- **Promo text:** Ask the Bible anything. AI answers in plain English — every answer cites Scripture.
- **Screenshot order:** 03-answer (lead), 01-home, 02-study, 04-paywall
- **Lead headline:** "Every answer cites Scripture"

## CPP 3 — "daily devotional"
- **Keyword theme:** daily devotional, verse of the day, daily bible verse
- **Promo text:** A verse every morning, explained. Build a daily habit with devotionals and reading plans.
- **Screenshot order:** 01-home (lead, Verse-of-the-Day visible), 02-study, 03-answer, 04-paywall
- **Lead headline:** "Your daily verse, explained"  *(needs one new frame — same pipeline)*

## CPP 4 — "kjv bible commentary"
- **Keyword theme:** kjv, bible commentary, verse meaning, what does this verse mean
- **Promo text:** Plain-English commentary on any KJV verse — context, meaning, and how to apply it.
- **Screenshot order:** 02-study (lead), 03-answer, 01-home, 04-paywall
- **Lead headline:** "Commentary in plain English"  *(new frame)*

## CPP 5 — "biblia estudio" (Spanish)
- **Keyword theme:** biblia, estudio biblico, devocional diario
- **Promo text (es-MX/es-ES):** Estudia cualquier versículo con IA — respuestas claras, siempre citando la Escritura. Prueba Pro gratis 7 días.
- **Screenshots:** Spanish-localized captures needed (app supports es via v1.0.5 translations)
- **Lead headline:** "Entiende cualquier versículo"

---

## Rollout
1. Build the 2 new frames (CPP 3/4 leads) — screenshot pipeline, ~10 min.
2. Create pages in ASC (needs app version in Ready state; CPPs are metadata-reviewable independently).
3. Link keywords per page (ASC → CPP → keyword linking section).
4. Measure in ASC Analytics → Custom Product Pages (impressions/conversion per page) monthly;
   kill or re-theme pages under ~2% CVR after 60 days.

## Seasonal tie-in
Each In-App Event (see IN-APP-EVENTS-CALENDAR.md) gets a matching CPP for its keyword
("bible reading plan" in fall/new year, "lent devotional" in Feb).

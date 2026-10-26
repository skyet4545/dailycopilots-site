# Plough — Design Token Pull (one-pull Refero demo)

**Reference brand:** Plough (plough.com) — Bruderhof publication, founded 1920. Quarterly literary magazine + book imprint covering faith, ethics, and contemplative life.

**Source:** Direct fetch of `https://www.plough.com/en` (HTML 56KB + inline `<style>` blocks).

**Pull notes:** Refero (`styles.refero.design`) is currently a fully client-side React app — server-rendered HTML returns only skeleton loaders, and direct slug attempts (`/site/{brand}`, `/styles/{brand}`) all 404. Per the task constraint, I fell back to the brand's actual public site. The Plough main stylesheet (`/_CSS/plough/_css/styles.css`) is 437KB minified onto a single line, which exceeded the read/grep tool's line-handling — so token extraction relied on the inline `<style>` blocks (where Cora W01 and the brand red live), explicit `style="…"` attributes on the page, and the rendered visual identity.

---

## Why Plough fits Bible Copilot

Plough sits in the small intersection where Bible Copilot needs to live: **literary, reverent, premium, modern-classical** — and crucially **never preachy**. Where Word on Fire reads as ecclesial and Ligonier reads as denominational, Plough reads as a serious magazine that takes faith as a subject worthy of editorial craft. The visual language is print-first: a single transitional serif (Cora W01) carries both heads and body, the page background is a warm cream that signals "essay" rather than "app," radii are nearly square, shadows are minimal, and the brand red is a deep brick (#a02b2f) used sparingly as an editorial highlight rather than a CTA-shouting accent. That entire posture maps onto Bible Copilot's audience — Christian + nominal-Christian + spiritual-but-not-religious — because it removes the two things that scare off the latter two segments: contemporary-worship colors and SaaS-startup gradients. It keeps the two things the first segment trusts: serif gravitas and slow rhythm.

## What was extracted

**Confirmed from served source:**
- Brand red `#a02b2f`, body grey `#3a3a3a`, divider `#d8d7d7`, overlay grey `#707070`, white `#ffffff`
- Primary typeface: **Cora W01** (F37 Foundry / Monotype) — used for both display and body
- UI fallback chain: `Verdana, Geneva, sans-serif` (per inline `.register__form input.link-button` declaration)
- Monotype font kit ID: `a86cfba5-f196-4a61-9bed-da9eed95e571`

**Inferred from rendered visual character (could not extract from minified CSS):**
- Page background `#f7f3ea` — warm cream is Plough's most distinctive single token; visible on every article and section
- Spacing scale (8-pt rhythm), radii (near-square, 2-6px), and motion (gentle 220ms standard) — fit Plough's print-derived aesthetic but are not directly read from source

## Application notes for Bible Copilot marketing-site-v2

The current site is a **dark-navy** premium aesthetic (`--bg-0:#0a0e1a`, `--gold:#d4a85a`, `--parchment:#f5ecd9`, `--serif:'Fraunces'`, `--sans:'Inter'`). It already carries premium signal correctly. Plough is not a candidate for a wholesale palette swap — Bible Copilot's nighttime-reading-friendly dark surface is a real product-market-fit choice. What Plough offers is a **light-mode counterpart** and **editorial typographic rhythm** to refine three specific things:

1. **Add a true light-mode token set** keyed off `--color-surface-page:#f7f3ea` (Plough cream) instead of pure white. Bible Copilot's current `--parchment:#f5ecd9` already lives in this family — pull it warmer toward `#f7f3ea` so the light mode reads as *parchment / book page* rather than *off-white card*. This single change makes the light theme feel literary instead of generic.

2. **Tighten the radius scale.** Bible Copilot currently uses `--r-sm:10px; --r-md:18px; --r-lg:28px` — those are SaaS-friendly but undermine the seminary/editorial signal. Drop to `2px / 4px / 6px` for editorial surfaces (article cards, mode chips, study-journal entries) and reserve the larger 18-28px radii for the iOS app screenshots and CTA pills only. This is the highest-leverage one-line change to make the marketing page feel "Plough-quality" without touching color.

3. **Reduce typographic system to a single serif voice for editorial copy.** Plough uses one serif (Cora) across heads + body. Bible Copilot uses Fraunces for heads + Inter for body, which is correct for product/UI but currently spills into long-form sections (FAQ, features, story copy) where a serif-on-serif treatment would feel more reverent. Add `--font-body-editorial: 'Fraunces', Georgia, serif;` and apply it to FAQ answers and feature-description prose — keep Inter for nav, buttons, captions, pricing tables.

## License + reuse posture

Visual reference only. Do not reuse Plough's logo, marque, photography, or any rendered asset. Cora W01 is a commercial license through Monotype/F37 — substitute with a free serif of similar transitional voice (Cormorant Garamond, EB Garamond, or stay on Fraunces, which Bible Copilot already loads). The hex codes are factual measurements of public CSS and are not copyrightable.

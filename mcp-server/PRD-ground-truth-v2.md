# PRD — Bible Copilot MCP v2: The Scripture Ground-Truth Layer

**Status:** proposed · **Author:** drafted 2026-07-16 · **Extends:** live server `https://mybiblecopilot.com/mcp` (`mcp-server/index.ts`, Deno / Supabase Edge Fn, registry `com.mybiblecopilot/bible-copilot` v1.0.0)

---

## 1. Thesis

> **Agents do not need Bible commentary. LLMs generate that for free.**
> **Agents need Bible *ground truth* — deterministic, verifiable data that LLMs demonstrably hallucinate.**

Our current 3 tools are the low-value category:

| Tool (v1) | Honest assessment |
|---|---|
| `study_bible_passage` | Commentary. Any LLM does this from weights. Zero agent demand. |
| `get_verse_text` | Public-domain text lookup. Trivial; 3 competing Bible MCPs already do it. |
| `find_verse_study_page` | Marketing link. Useful to us, not to the agent. |

**The wedge:** LLMs misquote Scripture, invent verse numbers, fabricate cross-references, and get lectionary dates wrong — constantly and confidently. A tool that *verifies* is valuable precisely because the model cannot self-verify. This repositions Bible Copilot from "another AI Bible app" to **the citation/verification authority for the entire faith-AI ecosystem.**

**Competitive fact (verified 2026-07-02):** only 3 other Bible MCP servers exist; all are read-only text lookup. **None verify anything.** The category is unclaimed.

---

## 2. What agents actually want (the data thesis)

Ranked by *agent demand × defensibility × build cost*.

### Tier 1 — The wedge (deterministic; LLMs fail; nobody offers it)

**T1. `verify_scripture_quote`** ⭐ *the killer tool*
Given a claimed quote (+ optional reference), return: is it real, the exact canonical text, the correct reference, a diff of what was wrong, and a confidence score.
- *Why it wins:* every faith-adjacent agent, sermon tool, and Christian content bot needs an anti-hallucination guard. This is the one thing an LLM structurally cannot do for itself.
- *Buyer:* any agent publishing religious content where a fabricated verse = reputational damage.

**T2. `resolve_reference`**
Any human form → canonical ID. `"Rom 8:28"`, `"Jn 3.16"`, `"1 Cor 13"`, `"the all things work together verse"` → OSIS ID + book/chapter/verse range + canonical text.
- *Why it wins:* plumbing. The "geocoder for Scripture." Boring, deterministic, universally needed, cheap to build.

**T3. `get_lectionary`**
`date` + `tradition` (Revised Common Lectionary / Catholic / Orthodox) → the appointed readings for that day.
- *Why it wins:* **date-keyed and deterministic — LLMs get this wrong constantly.** Massive latent demand: church tools, sermon-prep agents, devotional apps, bulletin generators. This is a real, factual dataset that cannot be guessed.

### Tier 2 — Depth (public-domain datasets, structured)

**T4. `get_cross_references`** — Treasury of Scripture Knowledge (~500k curated cross-refs, public domain, 1830s) as a queryable graph. LLMs hallucinate cross-refs; TSK is ground truth.

**T5. `lookup_original_language`** — Strong's Concordance (public domain, 1890) + lemma/transliteration/gloss + every other occurrence of that Strong's number. **This is what LLMs fake worst.** Serves the serious-study niche and reinforces our Interpret mode honestly (see §6 — today it's AI-generated, not a lexicon).

**T6. `compare_translations`** — parallel public-domain translations (KJV / ASV / WEB / YLT / Darby) for a verse. Deterministic, cheap.

### Tier 3 — Proprietary (only-supplier data)

**T7. `get_daily_brief`** — The Gospel Briefing's daily news↔Scripture editorial: stories, `verse_of_the_day`, `news_hook`, `scripture_primary`, `editorial_summary`. 95+ episodes, **6 languages**, date-keyed.
- *Why it wins:* **no model knows today's news, and none can reproduce our editorial judgment about which Scripture frames it.** The only tool here where we are the sole supplier on earth. Already generated free as a byproduct.

---

## 3. Non-goals

- ❌ Serving copyrighted translations (NIV/ESV/NLT/NASB). **Hard legal line.**
- ❌ Competing on commentary quality — that's commoditized.
- ❌ Building x402 as a revenue line (see §7).
- ❌ Doctrinal adjudication ("which denomination is right"). We return *data + sourced positions*, never verdicts.

---

## 4. Data sources & licensing (blocking work)

| Dataset | Status | Action |
|---|---|---|
| KJV, ASV, WEB, YLT, Darby | Public domain | ✅ safe to serve |
| Strong's Concordance (1890) | Public domain | ✅ safe; source a clean JSON edition |
| Treasury of Scripture Knowledge (1830s) | Public domain | ✅ safe; source a clean dataset |
| **Revised Common Lectionary** | ⚠️ **VERIFY** | Reading *tables* are factual data, but CCT asserts rights over published texts. Confirm before shipping T3. |
| Catholic/Orthodox lectionaries | ⚠️ VERIFY | Same. |
| NIV / ESV / NLT / NASB | ❌ Copyrighted | Never serve. Reject at the API layer. |
| Gospel Briefing editorial | ✅ Ours | Set explicit terms if sold. |
| bible-api.com (current dep) | ⚠️ | Review ToS + rate limits; we should self-host PD text, not depend on a free third party. |

**Gate: no dataset ships until its license is confirmed in writing in this doc.**

---

## 5. Architecture

Extend the existing server — **do not rebuild.**

- **Runtime:** Supabase Edge Function `bible-copilot-mcp` (Deno), stateless Streamable-HTTP JSON-RPC. Netlify `_redirects` 200-proxy at `mybiblecopilot.com/mcp`.
- **Change shape:** add entries to the `TOOLS` array + cases in `runTool()` (`index.ts:27`, `index.ts:117`). No structural change.
- **Data layer:** new Supabase tables in `fseqgcebvxiqmzngxhre` — `bible_verses` (PD translations), `strongs`, `cross_refs`, `lectionary`. Indexed for lookup. Seeded once from public-domain sources; static thereafter.
- **Determinism:** Tier 1/2 tools **must not call the LLM.** They are database lookups. That is the entire value proposition — reproducible, zero-hallucination, fast (<200ms vs the current ~6s engine call).
- **Fallback:** direct URL `https://fseqgcebvxiqmzngxhre.supabase.co/functions/v1/bible-copilot-mcp` (Netlify proxy has a ~26s cap).

### Known technical debt to fix first
1. **🔴 Unauthenticated, no rate limit** (flagged in the 2026-07-02 audit). Today `study_bible_passage` proxies our paid OpenAI engine with open CORS — **anyone can bill us.** Adding valuable tools raises the abuse ceiling. **Rate limiting is a prerequisite, not a follow-up.**
2. Replace bible-api.com dependency with self-hosted PD text (removes a third-party failure point).

---

## 6. Accuracy & integrity requirements

A tool named "verify" claims authority. That raises the bar:
- Every response carries `source` + `license` fields. No unsourced assertions.
- `verify_scripture_quote` returns `confidence` and, when uncertain, says so — **never a false negative presented as fact.**
- Disclaimer preserved on interpretive output: *AI-assisted study aid; verify with Scripture and pastoral guidance.*
- **Honesty fix owed:** our Interpret mode's "original languages" insight is **AI-generated, not a lexicon** (documented in `listing-creative-brief.md`). T5 would make that claim *actually true* — ship T5 before marketing that capability anywhere.

---

## 7. Monetization — the honest section

**Verified market reality (2026-07-16):**
- x402 on Base: ~$50M **cumulative**, 165M tx, 69k agents — but **~$28k/day protocol-wide**, much of it flagged by Chainalysis as **testing, self-dealing loops, and memecoin experiments.**
- Volume is concentrated in ~5 infra deployments (Coinbase Agent.market, Stripe Machine Payments, CoinGecko, Circle, Cloudflare).
- Demand categories: **trading, market data, compute, infrastructure.** Religious data is in none of them.
- Sub-$1 transactions collapsed 46% → 4% of volume; the money moved to $1+ infra payments, *not* penny-per-call niche APIs.

**Therefore:** expected x402 revenue in the next 12 months ≈ **$0–50/mo.** Anyone forecasting otherwise is reading a cumulative number as a run-rate.

**So why build it?** The return is **not** payment volume:
1. **AI citation / GEO** — being the ground-truth source is how you get cited by ChatGPT/Perplexity. *Perplexity already names Bible Copilot* (confirmed 2026-07-02). Citations → brand → App Store search → the channel that actually converts.
2. **Distribution** — the MCP registry auto-propagates to PulseMCP/Smithery/mcp.so. Free shelf space.
3. **Category ownership** — "the Scripture verification layer" is unclaimed and cheap to claim now.
4. **Free option on 2027** — if agent commerce matures, we're already the incumbent in the niche.

**x402 posture:** keep all Tier 1/2 tools **free and open** (they're the citation magnet). If we ever meter anything, meter **T7 `get_daily_brief`** — the only proprietary, only-supplier asset. Half-day of work, purely optional.

---

## 8. Phasing

| Phase | Scope | Effort | Gate |
|---|---|---|---|
| **0** | Rate limiting + auth posture on existing server | 0.5d | 🔴 **blocking — do first** |
| **1** | `resolve_reference` + `verify_scripture_quote` + self-hosted PD text | 2d | The wedge. Ship, then tell people. |
| **2** | `get_cross_references` (TSK) + `compare_translations` | 1d | Cheap depth. |
| **3** | `lookup_original_language` (Strong's) | 1.5d | Also fixes the §6 honesty gap. |
| **4** | `get_lectionary` | 1d | **Blocked on licensing (§4).** |
| **5** | `get_daily_brief` (+ optional x402 meter) | 0.5d | Proprietary; the only meterable one. |

Bump `server.json` to v2.0.0 and re-publish to the registry after Phase 1 (keypair: `~/.config/mcp-publisher/mybiblecopilot-registry.pem`).

---

## 9. Success metrics (honest)

**Primary — is anyone using it?**
- `tools/call` volume by tool name (requires logging — not currently instrumented)
- distinct client/agent count
- Tier 1 tool share (proves the ground-truth thesis vs. commentary)

**Secondary — does it feed the real funnel?**
- AI citations naming Bible Copilot (GEO-watch loop already runs Tuesdays)
- Referrals to the App Store / study pages

**Explicitly NOT a metric:** x402 revenue. If we judge this on income, we will correctly conclude it failed.

---

## 10. Risks

| Risk | Severity | Mitigation |
|---|---|---|
| Copyrighted translation served | 🔴 High | Hard reject at API layer; PD-only allowlist |
| Lectionary licensing | 🟡 Med | Verify before Phase 4; skip if unclear |
| Open endpoint abuse → OpenAI bill | 🔴 High | Phase 0 rate limiting (already-known debt) |
| "Verification" errors damage trust | 🟡 Med | Confidence scores; never assert when unsure |
| **Opportunity cost** | 🔴 **High** | See below |

### The dominant risk: focus
Carlos is solo. The evidence-backed constraint is **top-of-funnel volume** — impressions are only ~13.5K/month and just 1.26% convert to a download; the funnel below that is healthy (~75% trial→paid). **Not enough humans have tried the app.**

This PRD does **nothing** for that constraint in 2026. It is a 6-day bet on the 2027 agent ecosystem, justified by GEO/citation value — not revenue.

**Recommendation: Phase 0 + Phase 1 only (2.5 days).** That claims the category, fixes a real security hole, and makes the "verification" story true. Then stop and go back to getting the app in front of Christians. Phases 2–5 only if Phase 1 shows real `tools/call` traffic.

---

## Appendix — links
- Live: `https://mybiblecopilot.com/mcp` · fallback `https://fseqgcebvxiqmzngxhre.supabase.co/functions/v1/bible-copilot-mcp`
- Source: `mcp-server/index.ts` · manifest `mcp-server/server.json`
- Related: [[bible-copilot-mcp-server]], [[bible-copilot-seo-growth-loop]], [[growth-strategy-to-500-mo-sales-baseline]]

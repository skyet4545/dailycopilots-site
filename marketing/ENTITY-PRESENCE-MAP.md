# Entity & Citation Presence Map — the 100 consequential platforms "like Wikipedia & Wikidata"

**Built 2026-07-03** from first-source research (Profound, Ahrefs, Semrush, SE Ranking studies + each platform's own docs). This is the master list of the 100 most consequential entity / citation / knowledge platforms for **Bible Copilot** — ranked and **honestly tiered**, because they are NOT equal.

## Read this first — the one principle that governs the whole list

From our evidence work: **~80% of why an AI names a brand is off-page** (training + entity consensus), and the strongest lever is **off-page brand mentions on the sources AI engines actually retrieve** (Ahrefs 75k-brand study: branded-mention correlation ~0.66 vs backlinks 0.22). So:

- **A handful of platforms actually get CITED by AI** (Reddit, YouTube, Wikipedia, Quora, LinkedIn, Stack Exchange, Medium). These are Tier S — worth real, sustained effort.
- **Most of the other 90 are entity-CORROBORATION** — consistent name/URL/description across many sites helps Google's Knowledge-Graph fusion pipeline *trust* the entity, but they are ~0% of AI citations on their own. Do the cheap ones once; don't mistake them for reach.
- **Almost none are a "quick win."** The citation platforms require *authentic participation* (self-promo is banned everywhere) or *earned press* (notability-gated). That's the honest cost.

⚠️ **Scale caveat used throughout:** Profound % = share of *all* citations (small numbers, e.g. Reddit 6.6%). Semrush % = share of *prompts where the domain appears at least once* (large numbers, e.g. Reddit ~60%). They are different denominators — never compare them directly.

**Legend:** Feeds = {AI-cite = AI answers cite it · KG = Google Knowledge Graph feed · corrob = entity corroboration · distrib = distribution channel · traffic}. Evidence = CONFIRMED / LIKELY / SPECULATIVE. Fit = Bible Copilot relevance. Now? = feasible for a new indie app today (Y / N / NeedsPress / NeedsAccount).

---

## TIER S — AI actually cites these (authentic participation; highest leverage) 
*The only durable play here is genuinely useful participation / earned coverage. Every one bans self-promotion.*

| # | Platform | Feeds | Best evidence (source) | Ev. | Fit | Now? |
|---|---|---|---|---|---|---|
| 1 | **Wikipedia** | AI-cite, KG | ChatGPT #1 = **7.8%** of all citations; Google AI Mode #1 (Profound/Ahrefs) | CONFIRMED | High | **NeedsPress** (WP:NCORP — earn ≥3 independent reviews first) |
| 2 | **Reddit** | AI-cite | Perplexity #1 **6.6%**, AIO #1 **2.2%**, ChatGPT #2 (Profound); Google pays $60M/yr | CONFIRMED | High | Y — authentic only |
| 3 | **YouTube** | AI-cite | Google AI Mode #2, AIO #2 **1.9%**; highest single Ahrefs corr (0.737) | CONFIRMED | High | Y |
| 4 | **Quora** | AI-cite | Google AIO #3 **1.5%**; AI Mode #7 (Profound/Ahrefs) | CONFIRMED | Med-High | Y — authentic only |
| 5 | **LinkedIn** (thought content) | AI-cite, KG | AIO #4 **1.3%**; ~15% of AI-Mode prompt responses (Semrush) | CONFIRMED | Med | Y |
| 6 | **Christianity Stack Exchange** | AI-cite | SE network heavily cited; CC-licensed, deeply indexed | LIKELY | High | Y — expert answers only |
| 7 | **Biblical Hermeneutics Stack Exchange** | AI-cite | Same SE-network weight; exact "what does this verse mean" audience | LIKELY | High | Y — expert answers only |
| 8 | **Medium** | AI-cite | AIO #10 **0.4%**; a "biggest winner" on ChatGPT post-Sep 2025 (Semrush) | CONFIRMED | Med | Y |

**Reddit sub-targets (participate, don't spam):** r/Christianity (~675K), r/Bible (~173K, +22% YoY), r/TrueChristian (~204K), r/AcademicBiblical (~152K), r/Reformed (~74K), r/AskAChristian, r/Catholicism (~354K), r/OpenChristian (~71K).

---

## TIER A — entity/KG infrastructure + high-fit distribution (do now; cheap; real value) 
*These are the ones genuinely worth setting up. Most need an account (I can't create accounts) but are free/low-cost.*

| # | Platform | Feeds | Note | Ev. | Now? |
|---|---|---|---|---|---|
| 9 | **Wikidata** ✅ | KG, corrob | **DONE — Q140422402, 6 statements + reciprocal loop** | CONFIRMED | ✅ complete |
| 10 | **Grokipedia** ✅ | AI-cite | Article **submitted**; leaking into ChatGPT citations (reputational-risk caveat) | LIKELY | ✅ submitted |
| 11 | **DBpedia** | KG | Auto-derives from Wikipedia/Wikidata — will populate from #9 over time; no action | LIKELY | auto |
| 12 | **Crunchbase** | KG, corrob | Named KG/panel feed; free self-listing. Frame as an indie **software startup** | LIKELY | Y (free acct) |
| 13 | **LinkedIn Company Page** | KG, corrob | Named KG feed; free. Verify with name@mybiblecopilot.com (Gmail won't verify) | LIKELY | Y (domain email) |
| 14 | **GitHub org + profile** | corrob | Entity anchor; the namespace the **MCP registry** verifies via OAuth (`io.github.skyet4545/…`) | CONFIRMED | Y (free) |
| 15 | **Official MCP Registry** | distrib, AI-cite | MCP backend already live; publish `server.json` (preview, not GA yet) | CONFIRMED | Y |
| 16 | **ChatGPT Apps (OpenAI Apps SDK)** | distrib | Submissions opened **Dec 17 2025**; runs on MCP (we have it). Needs identity verify + review | CONFIRMED | Y (verify+review) |
| 17 | **faith.tools** | AI-cite | Purpose-built Christian-AI directory w/ "Best Christian AI Apps 2026" category — tightest fit | CONFIRMED | Y (paid) |
| 18 | **Christian Podcast Directory** | distrib | List *The Gospel Briefing* ($9/mo) — the podcast is a 2nd entity that corroborates the app | CONFIRMED | Y (paid) |
| 19 | **Google News (own-site newsroom)** | KG, traffic | Free & automatic since Apr 2024 — but the site's blog must read as a real newsroom (bylines, dates, corrections, news sitemap). The `blog-engine/` is the vehicle | CONFIRMED | Y (real work) |
| 20 | **Hugging Face** | AI-cite, corrob | Only worth it if we ship the planned **open dataset** / a Space demoing the MCP tools | CONFIRMED | Y (needs artifact) |
| 20a | **schema.org JSON-LD (own site)** ⭐ | KG, AI-cite | **The #2 highest-ROI item on this whole list and ZERO-gate — I can build it now.** It's the connective tissue: `Organization` + `MobileApplication` JSON-LD with a complete `sameAs` linking Wikidata Q140422402 + App Store + every profile below. Google reads this for the KG/Knowledge Panel | CONFIRMED | **Y — no account** |
| 20b | **Common Crawl** ⭐ | LLM-training | Foundational LLM-training corpus (>80% of GPT-3 tokens). No submission — just keep mybiblecopilot.com public + server-rendered, allow CCBot, publish a sitemap, earn a few inbound links. Near-automatic free win | CONFIRMED | **Y — near-automatic** |

---

## TIER B — corroboration profiles (low effort, low-but-nonzero entity value) 
*Consistent name/URL/description across these strengthens KG trust. ~0% AI citations. Do the free/fast ones once; keep every field byte-identical to the site.*

| # | Platform | Feeds | Note | Now? |
|---|---|---|---|---|
| 21 | **Capterra** (church-software cat.) | corrob | Free vendor profile; **propagates to GetApp + Software Advice** in one submission | Y (free) |
| 22 | GetApp | corrob | Via Capterra (Gartner Digital Markets) | auto w/ #21 |
| 23 | Software Advice | corrob | Via Capterra | auto w/ #21 |
| 24 | **Product Hunt** | traffic, corrob | **<1%** AI citations; real launch-day traffic if timed (Tue–Thu) | Y (free) |
| 25 | **AlternativeTo** | corrob | Cited **0%** in AI answers (SE Ranking); list as alt to Logos/YouVersion/Bible Chat | Y (free) |
| 26 | SaaSHub | corrob | Cited 0%; alt-to listing | Y (free) |
| 27 | SourceForge / Slashdot | corrob | Legacy directory backlink | Y (free) |
| 28 | StackShare | corrob | Tech-stack listing | Y (free) |
| 29 | Owler | corrob | Crowdsourced company profile; not a KG feed | Y (free) |
| 30 | TheOrg | corrob | Company page; low priority for a solo team | Y (free) |
| 31 | Wellfound (AngelList) | corrob | Free startup/company page | Y (free) |
| 32 | F6S | corrob | Free founder/startup listing + accelerator perks | Y (free) |
| 33 | Tracxn ("List Your Startup") | corrob | Free self-submit path (reading side is paid) | Y (free) |
| 34 | **D&B D-U-N-S** | corrob | Free; business-legitimacy plumbing (Apple sometimes references) | Y (free, ~30 days) |
| 35 | Bing Places / Bing Webmaster | corrob | Microsoft entity signal (feeds Copilot's index) | Y (free) |
| 36 | Trustpilot | reviews | Consumer reviews; corroboration + trust | Y (free) |
| 37 | **EIN Presswire** (one seed) | corrob | Single **$149** factual release → corroborating mentions across AP/USA Today/Google News network. Links nofollow; value = existence-mentions, not SEO | Y (paid, optional) |
| 38 | **Apple App Store** ✅ | distrib | Already live (id6758913373) | ✅ |

---

## TIER C — AI-tool directories (niche; mostly low citation value, some referral traffic) 
*A cluster of "top AI tools" directories. Individually near-zero for AI citation, but collectively cheap breadth + occasional traffic. Submit the app once to the biggest few; skip the long tail unless free & 2-minutes.*

*Verified corrections: none of these appear in the 127k-citation SurfacedBy study → all Near-zero for AI citation. Value = a backlink (many nofollow) + slim referral. **Do the FREE ones; the paid fast-tracks buy speed/reach, not citations.***

| # | Platform | Note | Now? |
|---|---|---|---|
| 39 | **Futurepedia** | Free **dofollow** backlink (DR~65) — best free win of the set | Y (free) |
| 40 | **Future Tools** (futuretools.io) | Free, human-curated (Matt Wolfe); acceptance not guaranteed | Y (free) |
| 41 | **Insidr AI** | Free submit + ~50k-sub newsletter shot | Y (free) |
| 42 | **TopAI.tools** | Free basic listing (48h review) | Y (free) |
| 43 | Toolify.ai | Free tier links mostly **nofollow**; Express ~$100 (speed only) | Y (freemium) |
| 44 | aixploria | Better-trafficked general directory; free submit | Y (free) |
| 45 | RankMyAI | "top AI Bible study tools" listing | Y (free) |
| 46 | **TheresAnAIForThat** | Largest (~9.7M visits/mo) BUT **$347 one-time** to submit + link is **nofollow**. Only if budget approves reach; not a citation lever | Y (paid $347) |
| 47 | OpenTools / EasyWithAI / SaaS AI Tools | Minor free directories | Y (free) |
| ⚠️ | ~~AI Tool Hunt (.com)~~ | **SKIP — .com domain hijacked/dead** (redirects to a gambling page). Do not submit | dead |
| ⚠️ | ~~AIcyberSpace~~ | **SKIP — could not verify it exists** (no live directory found) | unverifiable |

---

## TIER D — editorial / review targets (NeedsPress; high value, gated) 
*The high-payoff, high-effort quadrant. These are how you EARN the independent coverage that unlocks Wikipedia + better AI citation. Founder outreach required.*

| # | Platform | Feeds | Note | Now? |
|---|---|---|---|---|
| 53 | **Christianity Today** | KG, AI-cite | Already covers AI-Bible topics editorially — pitch a specific journalist a news angle (AI accuracy/guardrails) | NeedsPress |
| 54 | **Crosswalk.com** | AI-cite | Salem Web Network; "Write for Us" freelance path → a Bible-tech piece that references the app | NeedsPress |
| 55 | **ChurchTechToday** | AI-cite | Publishes app roundups — pitch info@churchtechtoday.com | NeedsPress |
| 56 | **G2** | corrob | B2B review site; needs real user reviews. Consumer-app fit is weak but the "AI Bible" category is emerging | Y (reviews) |
| 57 | **Gartner Peer Insights / TrustRadius** | corrob | Same B2B-review dynamic | Y (reviews) |
| 58 | **Encyclopedia Britannica** | KG | Editorial, not self-serve; only via genuine notability | NeedsPress |
| 59 | **"Best AI Bible app" listicles** | AI-cite | Get named in third-party roundups (the #1 mention lever) — pitch bloggers/YouTubers | NeedsPress |
| 60 | **FaithTech community** | corrob | Join a city chapter / Create project; org surfaces the app authentically | Y (participate) |
| 61 | Gloo / Indigitous (faith-tech networks) | corrob | Faith-tech communities/programs, not listings | Y (participate) |

---

## TIER E — skip / not eligible / poor ROI (documented so we don't waste time) 
*Included for completeness — these are the "don't bother (and why)" entries.*

| # | Platform | Why skip |
|---|---|---|
| 62 | **Google Business Profile** | **Ineligible** — Google requires face-to-face/service-area customer contact; a pure digital app doesn't qualify |
| 63 | ZoomInfo | Claim-only, closed B2B sales DB ($15k+); can't self-list |
| 64 | PitchBook | Profiles built for funded/tracked startups only |
| 65 | Bloomberg company | Terminal-gated; skews public/large-private |
| 66 | **PR Newswire** | $195/yr membership + $805–1,070/national release; "best of a <2%-of-citations category" |
| 67 | Business Wire | ~$760+/release; financial/IR focus, N/A to a consumer app |
| 68 | GlobeNewswire | ~$900–1,200/release; premium wire, no indie payoff |
| 69 | PRWeb | ~$110–480/release; marginal over EIN's $149 |
| 70 | **Apple News** | Gated to established news brands; months-long review |
| 71 | npm | No natural JS package for a Rust/iOS app; hollow packages = spam risk |
| 72 | PyPI | No natural Python artifact |
| 73 | RapidAPI | No REST product; MCP ≠ REST |
| 74 | Postman Public Network | Loose fit unless we ship a REST collection |
| 75 | Ballotpedia | Political-only domain |
| 76 | IQ.wiki (Everipedia) | Crypto-only domain |
| 77 | Scholarpedia | Peer-reviewed academic only |
| 78 | Stack Overflow | Dev-only + declining; not our audience |
| 79 | Wikinews / Wikiquote / Wikisource | No natural entry for an app |
| 80 | Conservapedia / Infogalactic | Fringe forks; ~0 AI weight, reputational risk |

---

## TIER F — social & owned channels + Wikimedia sisters (own them, but they are LOW as *citation* sources) 
*Maintain for brand/owned-audience reasons; just don't expect AI citations from them.*

| # | Platform | Note |
|---|---|---|
| 81 | X / Twitter | AI Mode #44 — very low as a citation source; feeds Grok/X search though |
| 82 | Facebook Page | AI Mode #55 — low citations; owned audience (we already run pages) |
| 83 | Instagram | Owned audience; ~0 citation |
| 84 | TikTok | AI Mode #26 — low, but short-form video reach for the funnel |
| 85 | Pinterest | AI Mode #23 — low; verse-graphic distribution |
| 86 | Threads | Owned social |
| 87 | Bluesky | Owned social; emerging |
| 88 | Mastodon | Owned social; niche |
| 89 | Substack | No citation data found; owned newsletter/entity |
| 90 | Tumblr | Owned social; low |
| 91 | Wikimedia Commons | Host the logo/screenshots under a free license → used by Wikipedia/Wikidata later |
| 92 | Wiktionary | No natural entry (skip) |
| 93 | Wikivoyage / Wikibooks | No natural entry (skip) |
| 94 | Fandom/Wikia | Could self-create a wiki — low value, low priority |

---

## TIER G — search-engine & authority-file entity surfaces (mostly automatic) 
| # | Platform | Note |
|---|---|---|
| 95 | Google Knowledge Graph | The *destination*, not a submission — fed by #1/#9/#12/#13 + corroboration; can't self-add |
| 96 | Bing / Microsoft entity graph | Fed by Bing index + Wikidata; ensure Bing indexes the site (already has msvalidate tag) |
| 97 | Google Scholar / Semantic Scholar | Only if we publish a real paper/dataset — N/A now |
| 98 | Common Crawl | Automatic if the site is crawlable (it is) — feeds LLM training corpora |
| 99 | Kaggle datasets | Only if we publish the open dataset (pairs with #20) |
| 100 | Yandex / DuckDuckGo entity | Minor; automatic from the index |

---

## Best practices — the rules that actually move the needle

**Universal (apply everywhere):**
1. **Byte-identical NAP+description.** Name = "Bible Copilot", URL = https://mybiblecopilot.com, one consistent one-line description, founding year 2026, category "AI Bible study app" — *identical* across every profile. Inconsistency is what breaks KG entity-fusion.
2. **Reciprocal linking.** Every profile links to the site; the site's Organization `sameAs` links back (Wikidata done; add Crunchbase/LinkedIn/GitHub URLs to `sameAs` as they go live). This is the Kalicube "self-confirming loop" Google's KG confidence score rewards.
3. **Front-load a direct answer + cite sources/stats.** On any content you author (Medium, LinkedIn, guest posts, your own pages): lead with a 40–60-word answer, include a statistic or quote with attribution (+40% citation lift, KDD 2024).
4. **Freshness.** ~50% of AI-cited content is <13 weeks old — keep authored content and the moat updated.

**Tier S (citation platforms):**
5. **Never self-promote.** Reddit/Quora/Stack Exchange/forums all ban it and enforce hard. The only durable play is *being genuinely the most helpful answer* to real Bible-study questions, from an established account, occasionally and transparently referencing the app where truly relevant.
6. **YouTube:** brand name in title + description + transcript; "best Bible study app" / walkthrough / verse-explainer formats.

**Tier A/B (entity infra):**
7. **Crunchbase/LinkedIn** are the only two self-listable *plausible KG feeds* — do these first, mirror fields exactly.
8. **One EIN Presswire seed** ($149) is the only wire worth it — a factual "app exists / what it does / who made it" release for corroborating mentions, not SEO.
9. **Don't publish hollow artifacts** (empty npm/PyPI packages, bare Fandom wikis) just for presence — that reads as spam and Google's June-2025 KG pruning targets thin entities.

**Tier D (earned press):**
10. This is the real growth work: **≥3 genuinely independent in-depth reviews** simultaneously (a) is the #1 AI-citation lever, (b) unlocks a Wikipedia article, and (c) improves Grokipedia acceptance. Pitch faith-tech journalists a news angle, not a press release.

---

## What I can build autonomously vs. what needs you

**I CANNOT** create accounts or enter passwords, so I can't self-register on Crunchbase, LinkedIn, GitHub, faith.tools, the AI-tool directories, etc. What I *can* do:

- **Build on-site "citation-ready" pages** (the highest-ROI thing I can do solo, and evidence-aligned): an **entity-home/About hub** and a set of **comparison / "best AI Bible app for X"** pages that are structured to get cited and that anchor the whole entity graph. This is the same muscle as the 2,648-page blog moat.
- **Draft ready-to-submit packs** for every Tier A/B/C platform — exact name/description/category/screenshots/copy — so each submission is a 2-minute paste-and-click for you.
- **Draft the founder-outreach pitches** for Tier D (Christianity Today / Crosswalk / ChurchTechToday / roundup bloggers).
- **Execute the ones where you're already logged in** (as with Wikidata/Grokipedia) — log me in on a specific platform and I'll do the content entry.

See the companion decision at the end of this session for which of these to build first.

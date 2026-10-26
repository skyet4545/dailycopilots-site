# In-Engine GEO Audit — 2026-07-02 (first real browser measurement)

Prior retests marked ChatGPT/Perplexity cells NOT_TESTED (no browser). This audit ran live queries inside the engines via browser automation. Baseline for all engines: 0 citations (2026-05-02 and 2026-06-01).

## Results

| Engine | Query | Bible Copilot cited? | Who won | Sources the engine used |
|---|---|---|---|---|
| ChatGPT (logged out, web search) | best AI Bible study app for iPhone | **NO** | Bible Chat, Bible Expert, Logos, YouVersion, Blue Letter Bible | The Week, App Store listings, "App Store Tracker", **faithgpt.io** |
| ChatGPT (logged out, web search) | app like ChatGPT for Bible study that cites Scripture | **NO** (our exact positioning) | MY Faith Assistant, Logos, Ask Bible AI, Bible Chat | Apps' own product pages, App Store/Google Play listings, Medium |
| Perplexity (logged out) | best AI Bible study app iPhone 2026 | **YES — cited by name** ✅ | Biblenotes.ai ranked #1 (its own 2026 roundup); Light AI Study Bible, **Bible Copilot**, Bible GPT named "strongest App Store-native options" | apps.apple.com listings, biblenotes.ai roundup, faith.tools |

## What this proves

1. **Perplexity already cites Bible Copilot** via the App Store listing — first recorded AI citation ever (baseline 0/50). Perplexity crawls App Store pages directly → listing metadata quality now matters for AI search, not just ASO.
2. **ChatGPT cites listicles + directories + apps' own pages** — faithgpt.io (on our submission list, unsubmitted), The Week, Medium, product pages. Directory submissions are confirmed as the #1 ChatGPT lever.
3. **Biblenotes.ai ranked itself #1 by publishing its own 2026 roundup** — exactly the self-published-listicle play; our "Best AI Bible Study Apps 2026" listicle should ship ASAP.
4. Everything shipped 2026-07-01/02 (comparison pages, llms.txt, IndexNow, MCP registry) predates these engines' next crawl — the weekly `bible-copilot-geo-watch` task (Tuesdays) tracks movement from here.

## Actions taken same day
- GSC: study.mybiblecopilot.com/sitemap.xml submitted (domain property covers subdomain; initial "couldn't fetch" is pre-crawl placeholder).
- IndexNow live: key `cb27cb83…` hosted on both domains; 16 main-site URLs (202) + 207 study URLs (200) submitted; auto-ping wired into blog publisher and verse-loop run-daily.sh.
- Bing Webmaster Tools: NOT signed in — needs Carlos (2 clicks, Sign in with Google) → then verify mybiblecopilot.com + study subdomain and submit both sitemaps.

## Next levers (in citation-impact order)
1. Submit the 8 directories (faithgpt.io + faith.tools are actively cited by ChatGPT).
2. Publish own "Best AI Bible Study Apps 2026" listicle (Biblenotes proves it works).
3. Bing Webmaster sign-in (Carlos) — ChatGPT search runs on Bing.
4. Keep App Store metadata sharp — Perplexity reads it verbatim (ASO rewrite still unpasted).

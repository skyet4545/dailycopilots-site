# Topic mining → your backlog (Ahrefs replacement)

Two helpers feed real search demand into the backlog files your engine already
reads. No Ahrefs, no paid API.

| File | What it does |
|------|--------------|
| `gsc_topics.py` | Pulls Google Search Console; finds queries you rank 8–20 for (optimize) and high-demand gaps (new). |
| `topic_expander.py` | Finds net-new topics GSC can't see yet, via Google Autocomplete. |
| `backlog_io.py` | Shared: routes each topic into `verse-backlog.txt` / `comparison-backlog.txt` syntax, deduped against `done_topics.txt` + current backlogs. |

Both write a review file **`gsc-suggestions.md`** and change nothing unless you
pass `--append`. Prayer/other intents that don't map to a backlog are listed
under "Needs a home" for you to place by hand.

## How topics route

- Verse query (`what does <ref> mean`) → `verse: <Ref>` in verse-backlog.txt
- Theme query (`bible verses for/about <x>`) → `topic: <x>` in verse-backlog.txt
- Anything comparison-y (`vs`, `alternatives`, `best … app`, "bible copilot") → `<slug> | <query> | <format>` in comparison-backlog.txt

Dedup is reference-aware for verses, so legacy slugs like `zephaniah-3-17-meaning`
are matched even though new ones use `what-does-…-mean`.

## Setup

**topic_expander.py** works right now — standard library only:
```bash
python3 topic_expander.py            # review: writes gsc-suggestions.md
python3 topic_expander.py --append   # also appends deduped lines to backlogs
```
Optionally add `seed_terms.txt` (one seed per line) to steer it; otherwise it
uses sensible defaults (bible verses about/for, what does, prayer for, psalm…).

**gsc_topics.py** needs one-time Google auth (~10 min):
1. Google Cloud Console → enable **Search Console API** → create an **OAuth client ID (Desktop app)** → save the JSON here as `client_secret.json`.
2. Set `SITE_URL` at the top to your exact property (confirm in Search Console whether it's `sc-domain:mybiblecopilot.com` or the `https://…` URL-prefix form). Default is `sc-domain:mybiblecopilot.com`.
3. Install libs:
   ```bash
   pip install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib
   ```
4. First run opens a browser once, then caches `gsc_token.json` and runs headless after:
   ```bash
   python3 gsc_topics.py            # review only
   python3 gsc_topics.py --append   # append to backlogs
   ```

## Schedule (optional)

Run before your daily writer so the backlog is fresh, e.g. 6:40 AM:
```
40 6 * * * cd /Users/carlosreyes/Desktop/Projects/Apps/biblecopilot/blog-engine && /usr/bin/python3 gsc_topics.py --append >> topic-mining.log 2>&1
45 6 * * 1 cd /Users/carlosreyes/Desktop/Projects/Apps/biblecopilot/blog-engine && /usr/bin/python3 topic_expander.py --append >> topic-mining.log 2>&1
```
(GSC daily; autocomplete weekly is plenty.) Or add as Cowork scheduled tasks now
that this folder is connected.

## Recommended workflow

Start in **review mode** (no `--append`) for the first week: run both, read
`gsc-suggestions.md`, and hand-place the lines you like. Once you trust the
routing, switch the cron jobs to `--append`. Everything is deduped, so appending
can never re-queue a published or already-backlogged topic.

## Notes / limits

- New site = thin GSC data. Autocomplete carries you until impressions build.
- No keyword *difficulty* — irrelevant for your low-competition long-tail.
- `attach_keyword_planner_volume()` in topic_expander.py is a stub: if you ever
  get Google Ads API access, drop real volumes in there and ranking upgrades
  automatically. Not worth the token-approval hassle otherwise.
- Verified against your live `done_topics.txt` + backlogs on 2026-07-04: routing,
  slug derivation, and reference-level dedup all pass.

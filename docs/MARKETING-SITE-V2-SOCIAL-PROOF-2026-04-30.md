# Marketing Site v2 — Social Proof Audit
**Date:** 2026-04-30  
**App:** Bible Copilot (id 6758913373)  
**Rule:** Never fabricate ratings. Use only real iTunes data.

---

## iTunes API Results

### Lookup endpoint
`GET https://itunes.apple.com/lookup?id=6758913373&country=us`

| Field | Value |
|---|---|
| `userRatingCount` | **6** |
| `averageUserRating` | **5.0** |
| `userRatingCountForCurrentVersion` | 6 |
| `averageUserRatingForCurrentVersion` | 5.0 |
| `version` (live on store) | 1.9.0 |
| `currentVersionReleaseDate` | 2026-04-21 |

### Reviews endpoint
`GET https://itunes.apple.com/us/rss/customerreviews/id=6758913373/sortBy=mostHelpful/json`

5 reviews returned (one rating has no written review text):

| Reviewer | Rating | Title | Snippet |
|---|---|---|---|
| Bashemup | 5★ | Great study companion | "The level of insight I can get from a single scripture has taken my Bible study to a whole new level." |
| Dove3777 | 5★ | What I've been looking for.. | "I've been seeking an aid as I read my Bible and study Christian apologetics…this is it." |
| H.R.R RR | 5★ | Love this app! | "Bible copilot has really helped me gain a deeper understanding for scripture." |
| OrlandoLaurie | 5★ | Great Bible study tool! | "I love the insight AI study gives, especially giving historical and cultural context." |
| los\| | 5★ | Study deeper using AI | "This app anchors in scripture to interpret scripture." |

---

## Decision

`userRatingCount = 6 > 0` — real data exists. Social-proof section retained and updated with real figures.

**Previous (fabricated) values removed:**
- Rating: ~~4.8~~ → 5.0
- Count: ~~120+~~ → 6
- Fake reviewer names/quotes (Daniel K., Maya R., Pastor T. Jensen) → replaced with real App Store reviews

**Three review snippets used in marketing site** (each under 15 words, attributed "App Store review"):
1. Bashemup: "The level of insight I can get from a single scripture has taken my Bible study to a whole new level." — trimmed to fit 15-word limit in rendered HTML
2. los|: "This app anchors in scripture to interpret scripture."
3. OrlandoLaurie: "I love the insight AI study gives, especially giving historical and cultural context."

**Kicker line** changed from "Loved by readers" → "Early readers" to honestly reflect launch stage.

**Structured data** (`application/ld+json` `aggregateRating`) also corrected: `ratingValue: "5.0"`, `reviewCount: "6"`.

---

## Files Changed
- `marketing-site-v2/index.html` — social proof section + JSON-LD aggregateRating

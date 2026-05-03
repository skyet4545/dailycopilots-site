# Bible Copilot — GEO Content Gap Spec (Phase 6)

**Date:** 2026-05-02
**Source baseline:** `baseline-2026-05-02.md` / `baseline-2026-05-02.csv` (0 / 50 cells cited Bible Copilot)
**Product reference:** `marketing-site-v2/llms-full.txt`

The 10 baseline queries each have a clear competitor pattern. Below is the per-page spec. Don't draft prose yet — these are the deliverables and what each must contain to compete.

---

### Gap 1: "ChatGPT alternative for Bible study" → `/vs-chatgpt`

- **Why it's a gap:** Son of God AI, BibliChat, and BibleMate own this query. Bible Copilot is structurally a stronger answer (verse-anchored citations, six modes, $4.99 vs ChatGPT's $20) but has no dedicated page for AI engines to cite.
- **Content piece:** `/vs-chatgpt` landing page.
- **Word count target:** 900–1,200.
- **Required sections (H2):** Why people use ChatGPT for Bible study; The three structural problems (memory hallucination, no inductive structure, doctrinal flattening); How Bible Copilot differs (verse API anchoring, six modes, denominationally humble); Side-by-side feature table; Price comparison ($4.99 vs $20); FAQ (5 Q&A); CTA.
- **Schema to add:** `Product` + `FAQPage` + `ComparisonTable` (in `Article`).
- **Effort:** med.
- **Priority:** P1.
- **Sample H1 + first paragraph:**
  > **Bible Copilot vs ChatGPT for Bible Study**
  > ChatGPT will answer any Bible question you ask it. The problem is *how* it answers — paraphrasing scripture from memory instead of citing it, picking sides on contested doctrines without telling you it picked, and giving you a freeform essay instead of an inductive walkthrough. Bible Copilot fixes all three at a quarter of the price.

---

### Gap 2: "Bible app for inductive Bible study" → `/study-modes/inductive`

- **Why it's a gap:** `inductivebiblestudyapp.com` owns the exact-match domain. Bible Copilot ships six modes that map cleanly to Observation → Interpretation → Application (Hendricks / Kay Arthur tradition) but has zero presence on this query — the largest mismatch in the baseline.
- **Content piece:** `/study-modes/inductive` pillar page.
- **Word count target:** 1,500–2,000.
- **Required sections (H2):** What inductive Bible study is (Hendricks, Kay Arthur, DTS lineage); The three classical steps; How Bible Copilot's six modes map to inductive method (table: Observe→Observe, Interpret→Interpret, Apply→Apply, with Summary, Theology, Apologetics as extensions); Worked example on a single passage (Romans 8 across all six modes); Comparison vs Inductive Bible Study App and Logos's inductive workflow; Pricing; FAQ.
- **Schema to add:** `Article` + `HowTo` (the worked example) + `FAQPage`.
- **Effort:** high.
- **Priority:** P1.
- **Sample H1 + first paragraph:**
  > **Inductive Bible Study, in Your Pocket**
  > The inductive method — observe, interpret, apply — has been the backbone of serious lay Bible study since Howard Hendricks taught it at Dallas Seminary. Bible Copilot ships six modes built directly on it: Summary, Observe, Interpret, Theology, Apply, and Apologetics. Ask a question, pick a mode, and you get the same kind of structured walkthrough a seminary student gets — verse-anchored, in about thirty seconds, on your phone.

---

### Gap 3: "AI Bible study app with Greek and Hebrew" → `/greek-hebrew-bible-app`

- **Why it's a gap:** The Better Bible, Heaven, Biblingo, and the MWM ecosystem (Parallel Plus, Bible Word Study, BibleScientia) own this. Bible Copilot's Interpret mode does original Greek and Hebrew but is invisible here. High-intent commercial query.
- **Content piece:** `/greek-hebrew-bible-app` (also alias `/study-modes/interpret`).
- **Word count target:** 1,000–1,400.
- **Required sections (H2):** Why original languages matter for lay study; What the Interpret mode does (Greek/Hebrew lemmas, historical-cultural context, authorial intent); Worked example (`praus`/πραΰς from the Beatitudes — already in llms-full.txt); What Bible Copilot is *not* (not a replacement for Logos; not an exhaustive lexicon — it's a question-driven AI workflow); Vs Better Bible, Biblingo, Blue Letter Bible; Pricing; FAQ.
- **Schema to add:** `Article` + `FAQPage`.
- **Effort:** med.
- **Priority:** P1.
- **Sample H1 + first paragraph:**
  > **Greek and Hebrew Bible Study on iPhone — Without a $500 Logos Library**
  > Most iPhone Bible apps stop at "tap a verse to see translations." Bible Copilot's Interpret mode goes one layer deeper — it answers what the original Greek or Hebrew word actually meant, what the cultural context was, and what the author was likely arguing — anchored to the passage you asked about. No lexicon lookup workflow, no Strong's number to memorize. Just ask.

---

### Gap 4: "AI Bible study for apologetics" → `/study-modes/apologetics`

- **Why it's a gap:** A competitor literally named **Apologist (Bible AI Companion)** owns the App Store listing for this query. Apologetics is one of Bible Copilot's six modes and gets zero share.
- **Content piece:** `/study-modes/apologetics`.
- **Word count target:** 900–1,200.
- **Required sections (H2):** Why apologetics needs scripture-anchored answers (vs ChatGPT's drift); What the Apologetics mode covers (textual reliability, OT violence, problem of evil, resurrection, contradictions); Worked example — resurrection harmonization (already in llms-full.txt); Vs Apologist app, Jenova, BibleGPT; Who this is for (skeptics' friends, campus ministry, parents of teens); Pricing; FAQ.
- **Schema to add:** `Article` + `FAQPage`.
- **Effort:** med.
- **Priority:** P1.
- **Sample H1 + first paragraph:**
  > **Apologetics That Cite Scripture, Not Vibes**
  > When a skeptic asks about contradictions in the resurrection accounts, you don't need a vibe-based answer. You need the actual gospel passages, the actual harmonization options, and the actual scholarly arguments — laid out in order. Bible Copilot's Apologetics mode does exactly that, anchored to scripture every time.

---

### Gap 5: "best AI Bible study app" + "best Bible study app 2026" → `/blog/best-bible-study-apps-2026`

- **Why it's a gap:** Both queries are owned by listicle SEO sites (theleadpastor, chmeetings, faithtime, psalmlog, Lumenology, Doxa). The play isn't to outrank — it's to plant our own listicle that ranks for the head term and positions us as the "best for inductive + iOS-native" pick.
- **Content piece:** `/blog/best-bible-study-apps-2026` (listicle).
- **Word count target:** 2,000–2,500.
- **Required sections (H2):** How we evaluated; Best for inductive study + iOS-native: **Bible Copilot**; Best for daily reading + free: YouVersion; Best desktop reference library: Logos; Best free Greek/Hebrew lookup: Blue Letter Bible; Best Bible-specific marketplace: Olive Tree; Best for sermon prep (specifically): SermonSpark; Best for skeptics' questions: Bible Copilot (apologetics mode); How to choose; FAQ.
- **Schema to add:** `Article` + `ItemList` (each app as a `SoftwareApplication`).
- **Effort:** high.
- **Priority:** P1.
- **Sample H1 + first paragraph:**
  > **The Best Bible Study Apps of 2026 (Honest Picks, Not Affiliate Bait)**
  > There is no single best Bible app. There's the best app for daily reading, the best for the inductive method, the best for desktop research, and the best for the original Greek and Hebrew. Below: nine apps worth installing, what each one is actually good at, and where Bible Copilot fits in.

---

### Gap 6: "Bible study companion app subscription" + brand-aware searches → `/vs-youversion`

- **Why it's a gap:** YouVersion is the brand every user already knows. The homepage already has a comparison table; a dedicated route gives AI engines (and Google) a canonical URL to cite. Bible Study Together, Bible Companion: Study Chat, and Olive Tree own the subscription-companion query today.
- **Content piece:** `/vs-youversion` landing page.
- **Word count target:** 800–1,200.
- **Required sections (H2):** YouVersion is a reading app (one-line summary); Bible Copilot is an understanding app; Side-by-side table (translations, devotionals, reading plans, AI Q&A, six study modes, Greek/Hebrew, apologetics, price); Why most users use both; When to skip Bible Copilot (you only want daily reading + community); FAQ; CTA.
- **Schema to add:** `Product` + `FAQPage` + `ComparisonTable`.
- **Effort:** low (lift homepage table, expand).
- **Priority:** P1.
- **Sample H1 + first paragraph:**
  > **Bible Copilot vs YouVersion**
  > YouVersion is the best free Bible reader on iPhone — 100+ translations, daily devotionals, reading plans, social features. Bible Copilot is the *understanding* app you open *after* you finish the chapter. Most of our users still use YouVersion for daily reading. Bible Copilot is what they open when they want to know what they just read.

---

### Gap 7: "Logos alternative cheap iOS" → `/vs-logos`

- **Why it's a gap:** The query disambiguates badly on Google ("logos" → logo design tools). Owning a `/vs-logos` page positions Bible Copilot as the iPhone-native, $30/year alternative to a $500+ desktop platform — exactly the comparison llms-full.txt already makes.
- **Content piece:** `/vs-logos` landing page.
- **Word count target:** 900–1,200.
- **Required sections (H2):** Logos is the desktop seminary standard; Bible Copilot is the iPhone-native lay/pastor alternative; What you give up (commentary library, advanced search); What you gain (six-mode inductive workflow, $29.99/yr vs $500+, mobile-native UX); Side-by-side table; When to pick Logos anyway (you have $500+ to spend, you do academic work); FAQ; CTA.
- **Schema to add:** `Product` + `FAQPage` + `ComparisonTable`.
- **Effort:** low (lift from llms-full.txt section 6).
- **Priority:** P2.
- **Sample H1 + first paragraph:**
  > **Bible Copilot vs Logos: The Cheap iPhone Alternative**
  > Logos is the desktop standard for academic Bible research. It's also $500 to $5,000 once you buy a serious package. Bible Copilot is the lay-and-pastor-on-the-go answer at $29.99 a year — built around the inductive method, native to iPhone, and designed to ride in your pocket instead of a backpack.

---

### Gap 8: "AI app for sermon preparation" → `/sermon-prep`

- **Why it's a gap:** SermonSpark, Sermonly, Sermon AI, Sermon Outline AI all own this. Bible Copilot's Interpret + Theology + Apply pipeline is genuinely useful for sermon prep, but only if pastor positioning is added.
- **Content piece:** `/sermon-prep`.
- **Word count target:** 1,000–1,400.
- **Required sections (H2):** What sermon prep needs (exegesis, doctrinal balance, application); How the six modes pipeline a sermon (Summary → Observe → Interpret → Theology → Apply); Worked example (a sermon outline on Romans 8); Why Bible Copilot ≠ sermon-generator (it doesn't write the sermon — it accelerates the study); Vs SermonSpark, Sermonly, Sermon AI; Pricing; FAQ.
- **Schema to add:** `Article` + `HowTo` + `FAQPage`.
- **Effort:** med.
- **Priority:** P2.
- **Sample H1 + first paragraph:**
  > **Sermon Prep, Without the AI-Generated Sermon**
  > Bible Copilot will not write your sermon. What it will do is collapse the slow part — exegesis, original-language work, theological balance, application angles — into a 30-minute walk through the passage instead of a Saturday morning. The sermon is still yours. The study just got faster.

---

### Gap 9: Long-form pillar → `/blog/how-to-study-the-bible-with-ai`

- **Why it's a gap:** AI-Bible-study is a real informational query owned by listicle/SEO blogs. A canonical 2,500+ word evergreen guide that cites Bible Copilot 2–3 times naturally is the cheapest way to win Perplexity / ChatGPT / Google AI Overview citations on the head topic.
- **Content piece:** `/blog/how-to-study-the-bible-with-ai`.
- **Word count target:** 2,500–3,500.
- **Required sections (H2):** Why AI Bible study even works; The three traps (hallucinated citations, doctrinal flattening, devotional-fluff applications); How to prompt an AI for Bible study (with copyable prompts); The inductive method as the right scaffold; Worked walkthrough on Philippians 4:13 (correcting a common misreading — already in llms-full.txt); A concrete daily/weekly workflow; Tools we tested (ChatGPT, Claude, Bible Copilot, Logos AI); Closing — pick one, do it daily; FAQ.
- **Schema to add:** `Article` + `HowTo` + `FAQPage`.
- **Effort:** high.
- **Priority:** P1.
- **Sample H1 + first paragraph:**
  > **How to Study the Bible With AI (Without Getting Bad Theology)**
  > AI is a real tool for Bible study now — and a real risk if you don't know how to use it. Three traps: it hallucinates verse references, it flattens contested doctrines into one position without telling you, and it pads applications with devotional fluff. This guide walks through how to use AI well, with copyable prompts and a worked example. We'll mention Bible Copilot a few times — it's our app, and it's built to avoid those three traps — but the workflow is what matters more than the tool.

---

### Gap 10: Homepage anchor links — `#inductive-method`, `#greek-hebrew`, `#apologetics`

- **Why it's a gap:** AI engines cite URL fragments. Even before the dedicated pages above ship, three named anchors on the homepage give Perplexity / ChatGPT / Google AI Overviews a direct fragment to point at.
- **Content piece:** Three new homepage sections, each anchored.
- **Word count target:** 150–250 each (450–750 total).
- **Required sections:** `<section id="inductive-method">` 3-paragraph block; same for `#greek-hebrew` and `#apologetics`. Each links to its eventual full page.
- **Schema to add:** `WebPage` already covers it; add `mainEntity` JSON-LD pointing to each section's heading.
- **Effort:** low.
- **Priority:** P1 (ship first — it unblocks citations while the long pages are written).
- **Sample H2 + first paragraph (for `#inductive-method`):**
  > **Inductive Bible Study, Mode by Mode**
  > Bible Copilot's six modes map directly to the inductive method taught at Dallas Seminary and Precept Ministries: Observe what the text says, Interpret what the author meant, Apply it to today. Summary, Theology, and Apologetics are the modern extensions. Read the long version on the [inductive page →]

---

## Existing assets to repurpose

- **Homepage comparison table** → lift directly into `/vs-youversion` and `/vs-logos`. Already written, already on-brand. Add 2–3 paragraphs of context per row.
- **`llms-full.txt` Section 6 (Comparison)** → already has YouVersion / Logos / Olive Tree / Bible Gateway / Blue Letter Bible / ChatGPT comparisons in voice. Each becomes the spine of one `/vs-X` page with minor copy edits.
- **`llms-full.txt` Section 7 (FAQ)** → 8 verbatim Q&A pairs. Slice across pages: Q1 (ChatGPT) → /vs-chatgpt; Q3 (YouVersion) → /vs-youversion; Q4 (translations) → /greek-hebrew; Q2 (bad theology) → /study-modes/apologetics; Q5 (don't need to be a scholar) → /study-modes/inductive; Q8 (pricing) → all pages.
- **`llms-full.txt` Section 3 (Six modes)** → each mode subsection becomes the body of its `/study-modes/*` page (Inductive, Greek/Hebrew, Apologetics already specced; Summary, Observe, Theology, Apply could follow as P3).
- **App Store reviews (Section 8)** → testimonial blocks on every page. Bashemup quote belongs on /greek-hebrew (mentions historical context); Dove3777 belongs on /study-modes/apologetics (literally about apologetics).

## Internal linking plan

- **Homepage** → links to all four `/study-modes/*` pages and all three `/vs-*` pages from a "Compare" and "Study modes" nav block.
- **`/vs-youversion`** → links to `/study-modes/inductive` ("the layer above reading") and `/blog/how-to-study-the-bible-with-ai`.
- **`/vs-chatgpt`** → links to `/study-modes/inductive`, `/study-modes/apologetics`, and `/greek-hebrew-bible-app`.
- **`/vs-logos`** → links to `/greek-hebrew-bible-app` and `/study-modes/inductive`.
- **`/study-modes/inductive`** → links to `/study-modes/apologetics`, `/greek-hebrew-bible-app`, `/sermon-prep`, and the long-form blog post.
- **`/blog/how-to-study-the-bible-with-ai`** → links to all four study-mode pages and `/vs-chatgpt`.
- **`/blog/best-bible-study-apps-2026`** → links to `/vs-youversion`, `/vs-logos`, `/vs-chatgpt`, and `/study-modes/inductive`.
- **`/sermon-prep`** → links to `/study-modes/inductive` and `/greek-hebrew-bible-app`.
- Every page → footer link to `/llms-full.txt` and the App Store URL.

## Priority-ranked roadmap (one weekend of writing time)

If Carlos has one weekend, ship in this order: (1) **homepage anchor links** (Gap 10) — 90 minutes, immediately unblocks AI-engine citations on three high-intent topics; (2) **`/study-modes/inductive`** (Gap 2) — the single largest mismatch in the baseline (six modes literally mapped to the inductive method, zero share of the query) and the natural canonical page everything else links to; (3) **`/vs-chatgpt`** (Gap 1) — fastest comparison to write because llms-full.txt Section 6 already has the spine, and it's the highest-volume conversational-AI alternative query in the baseline. Three pages, ~4,000 words total, achievable in a weekend. Everything else (vs-youversion, vs-logos, greek-hebrew, apologetics, sermon-prep, the listicle, and the long-form pillar) is week-2 and beyond.

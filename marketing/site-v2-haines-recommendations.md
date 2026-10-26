# Bible Copilot Marketing Site v2 — Haines Switching-Forces Recommendations
*Generated: 2026-05-02 | Based on index.html audit + product-marketing-context.md*
*Do NOT edit index.html directly — implement from this spec.*

---

## Diagnosis

The current site copy is almost entirely **Pull-only**: it announces features and benefits (six modes, inductive method, streaming answers) but never voices the frustration that makes a reader actually look for something new. Of roughly 18 user-facing copy claims audited: **~14 tagged Pull, ~3 tagged Push (partial), 0 tagged Habit, 0 tagged Anxiety.** The site gives visitors no language for the itch they're already scratching — "I keep bouncing between four apps," "YouVersion doesn't actually explain anything," "I don't trust AI for theology." That gap is the single highest-leverage fix.

---

## Section-by-Section Rewrites

---

### 1. Hero H1 + Subhead `[TOP 5]`

**Current copy (verbatim):**
```
h1: Study Scripture deeper. With an inductive method.
sub: Six study modes — Summary, Observe, Interpret, Theology, Apply, and Apologetics. 
     The inductive method, in your pocket. Ask any verse. Hear it back with depth, not platitudes.
```

**Diagnosis:** Pure Pull. Names the product benefit without voicing the Push (what's broken about the status quo) or the Anxiety ("depth" without trust signals). The headline is a benefit claim but nothing makes the reader feel that *their current tool is the problem.*

**Proposed rewrite:**
```
h1: Your Bible has the answers. Your apps don't give them.
sub: Bible Copilot is the study companion that goes where YouVersion and Bible 
     Gateway stop — six inductive-method lenses on any verse, with original-language 
     depth, cross-references, and zero theological platitudes. In your pocket.
```

**Force(s) addressed:** Push (names what's broken), Pull (promises the alternative), mild Anxiety reduction ("zero theological platitudes")

**Customer language used:** "study companion" — from Bashemup's review title "Great study companion." Avoidance of platitudes echoes "depth, not platitudes" from the existing sub, but now anchored to the Push of what's broken.

---

### 2. Eyebrow Tag ("Now on iPhone & iPad") `[TOP 5]`

**Current copy (verbatim):**
```
Now on iPhone & iPad
```

**Diagnosis:** Pure Pull — a capability announcement. Does nothing to address Habit (switching anxiety about losing your current streak, bookmarks, routine) or create urgency.

**Proposed rewrite:**
```
Free to try. No streak to lose. Just more depth.
```

**Force(s) addressed:** Habit (explicitly names the barrier — "no streak to lose"), Anxiety (cost barrier — "free to try"), Pull (benefit tease)

**Customer language used:** "deeper" / "depth" echoes H.R.R RR: "gain a deeper understanding for scripture as I go through my studies."

*Alt option (if Carlos wants to keep the platform signal):*
```
iPhone & iPad · Free tier · No commitment
```

---

### 3. Six Study Modes Section (`#modes`) — Section Head + Mode Bodies

**Current section head (verbatim):**
```
kicker: Six ways in
h2: One question. Six lenses on the text.
lead: The inductive method in six modes — Summary, Observe, Interpret, Theology, Apply, Apologetics. 
      Pick the mode that fits the moment, in one tap.
```

**Diagnosis:** 100% Pull. No Push (why the reader's current approach to answering verse questions is failing) and no Anxiety reduction (no signal that the AI output is trustworthy).

**Proposed section head rewrite:**
```
kicker: Why one mode is never enough
h2: Every verse question deserves the right lens.
lead: YouVersion gives you a devotional. ChatGPT gives you a paraphrase. Bible Copilot 
      gives you six purpose-built lenses — each one mapped to a stage of how seminaries 
      actually teach the text. Pick the mode that fits your moment.
```

**Force(s) addressed:** Push (YouVersion, ChatGPT named as inadequate), Pull (six lenses as the solution), Habit (familiar competitor names reduce friction of comparing)

**Customer language used:** "study companion" (Bashemup), "outside the traditional book format" (Dove3777) — the mode system IS the format alternative.

**Current mode bodies (verbatim) + proposed rewrites:**

| Mode | Current body | Diagnosis | Proposed rewrite | Force |
|---|---|---|---|---|
| **Summary** | "Get the gist before the deep dive — structure, themes, and where this verse sits in its chapter." | Pull only | "Not sure what a passage is even about? Summary gives you the structure, themes, and context before you go deeper — without the three-commentary trip." | Push + Pull |
| **Observe** | "What does the text actually say? Structure, keywords, and the questions every careful reader should ask." | Pull only | "What does it literally say? Before interpretation, observation. Catch the keywords, the repetition, the questions the original author planted in the structure." | Pull (keep; it's already precise) |
| **Interpret** | "What does it mean? Original languages, authorial intent, and cultural background — without the seminary tuition." | Pull only | "What did the author mean? Original language, authorial intent, and the historical-cultural world of the text — the insight that used to cost a seminary degree and a library card." | Push + Pull |
| **Theology** | "What does this passage teach about God? Connect a single verse to the bigger story of Scripture." | Pull only | "What does this verse teach about who God is? Theology mode connects your passage to the whole arc of Scripture — and presents Reformed, Arminian, and other major positions on contested doctrines without picking sides." | Pull + Anxiety (denominational humility) |
| **Apply** | "Practical, honest takeaways — what this passage asks of you this week, not a generic platitude." | Pull only | "What does this verse ask of you today? Practical, honest takeaways — not 'trust God's plan' but a specific, honest call to action rooted in the text." | Pull + Anxiety (authenticity signal) |
| **Apologetics** | "How do we defend this truth? Evidence, reasoning, and clear answers to the hardest objections." | Pull only | "How would you defend this teaching in a real conversation? Evidence, reasoning, and scripture-anchored answers to the objections your kids, coworkers, or skeptical friends actually raise." | Push + Pull |

**Customer language used:** Dove3777: "outside the traditional book format." Bashemup: "historical deep dives." Apply mode: Avoid Christianese per brand voice rules.

---

### 4. Showcase Copy (`#showcase`) `[TOP 5]`

**Current copy (verbatim):**
```
kicker: Built for daily study
h2: A verse, a question, a real answer.
lead: Type any reference — John 3:16, Romans 8:28, Genesis 1:1. Choose a mode. 
      Read a thoughtful answer that pulls in the original language and cross-references, 
      formatted to skim or savor.
checklist:
- Streaming responses — see the answer compose as it thinks
- Cross-references surface inline — tap to study the next verse
- Save passages and notes to a personal study journal
- Daily verse, reading streaks, and five guided plans
- Light & dark mode · No ads · No data collected
```

**Diagnosis:** The h2 and kicker are Pull. The checklist items are feature-level Pull. The "No data collected" bullet is an Anxiety signal — it's buried fifth. The Push that motivates a session (bouncing between apps, shallow devotionals) is entirely absent.

**Proposed rewrite:**
```
kicker: Stop bouncing between apps
h2: One verse. One tap. A real answer.
lead: Type John 3:16. Pick Interpret. Get original-language depth, cross-references, 
      and historical context in a single streaming response — the kind of answer 
      Bashemup called "an incredible blessing" and OrlandoLaurie called "insight AI 
      study gives, especially giving historical and cultural context."
checklist (reordered and rewritten):
- Anchors in scripture to interpret scripture — not paraphrasing from memory
- Streaming responses with inline cross-references — tap any verse to study it next
- Personal study journal tied to the exact passage — never lose a note
- Daily reading plans you can actually finish (starting free with the Gospel of John)
- No ads · No data used to train AI models · Cancel from Apple Settings anytime
```

**Force(s) addressed:** Push (kicker: "Stop bouncing between apps"), Pull (the verse → mode → answer flow), Anxiety (last bullet addresses data concern and cancel-friction)

**Customer language used:** "anchors in scripture to interpret scripture" — verbatim from los|. "incredible blessing" — Bashemup. "insight AI study gives, especially giving historical and cultural context" — OrlandoLaurie.

---

### 5. Pricing Card Eyebrow + H3 + Tile Copy

**Current copy (verbatim):**
```
eyebrow: Bible Copilot Pro
h3: Unlimited questions, all six modes
price tiles: Monthly $9.99/mo | Yearly $49.99/yr (Save ~58%)
includes list:
- 1-week free trial — no charge until it ends
- All six study modes, unlimited questions
- Five reading plans — John, Psalms, Romans, Genesis, Sermon on the Mount
- Personal journal with full history and inline cross-references
- Cancel anytime — manage in Apple Settings
free tier note: Free tier: 3 questions/day, Gospel of John reading plan, no ads.
```

**Diagnosis:** Functional but anxiety-neutral. "$9.99/month is steep for a Bible app" is the top stated objection (per product-marketing-context.md) and nothing in the current copy addresses it. The free-tier note is de-emphasized (muted color, small, below the CTA area). "Cancel anytime" appears but without the Apple trust-transfer framing.

**Proposed rewrite:**
```
eyebrow: Bible Copilot Pro
h3: Serious Bible-study depth. The price of one coffee a month.
price tiles:
  Monthly: $9.99/mo — Billed monthly, cancel anytime
  Yearly: $49.99/yr — Just $4.17/mo · Includes 1-week free trial [BEST VALUE badge]
includes list (reordered — anxiety first):
- 1-week free trial on annual — card not charged until day 8
- Cancel anytime — managed entirely in Apple Settings, not a support email
- Unlimited questions across all six study modes
- Five reading plans (John, Psalms, Romans, Genesis, Sermon on the Mount)
- Personal journal, full history, inline cross-references, light & dark mode
free tier note (promoted to above the CTA, larger):
Not ready to commit? The free tier is generous: 3 questions/day + the 
Gospel of John plan, no credit card required, no ads.
```

**Force(s) addressed:** Push (reframes the price anchor against "one coffee"), Anxiety (trial timing clarity, Apple Settings cancel, free tier promoted), Pull (unlimited + all modes)

**Customer language used:** "$9.99/mo is steep for a Bible app" — from product-marketing-context.md objections. "one coffee" — from the product-marketing-context.md objection response. No invented customer quotes used here.

---

### 6. Social Proof Section Head + Ratings Banner

**Current copy (verbatim):**
```
kicker: Early readers
h2: A study partner that actually reads with you.
ratings banner: ★★★★★ 5.0 on the App Store | 6 ratings · iPhone & iPad | Just launched — real reviews below
```

**Diagnosis:** "Early readers" kicker undercuts credibility — it signals small user base. "Just launched — real reviews below" is defensive. The h2 is cute but doesn't address any of the four forces. The 5.0 ★ signal is strong but buried in small type.

**Proposed rewrite:**
```
kicker: What readers are saying
h2: "The level of insight I can get from a single scripture has taken my Bible study 
     to a whole new level."
     — Bashemup, App Store (★★★★★)
ratings banner: 5.0 ★★★★★ on the App Store (6 ratings) | Every review, 5 stars | iPhone & iPad
```

*(The h2 becomes the pull quote, with attribution inline. The ratings banner leads with the score.)*

**Force(s) addressed:** Pull (depth claim from a real user), Anxiety (5.0 ★, "every review, 5 stars" builds trust without defensive framing)

**Customer language used:** "The level of insight I can get from a single scripture has taken my Bible study to a whole new level" — verbatim from Bashemup.

---

### 7. NEW: Recommended FAQ Section (Anxiety-Reducing) `[TOP 5]`

*Add between Pricing and Social Proof. Recommend `id="faq"` anchor.*

```
kicker: Questions before you download
h2: Honest answers to the ones everyone asks.
```

**Q1: Is this just ChatGPT with a Bible theme?**
A: No. ChatGPT answers from memory and will paraphrase scripture without verse numbers. Bible Copilot is built around a strict verse-anchoring discipline — every response cites the actual reference text, not a paraphrase from training data. The six study modes enforce a specific analytical lens (observation, interpretation, theology, application, apologetics) that a generic chatbot has no mechanism to apply.

**Q2: What if it gives me bad theology?**
A: On contested doctrines — Calvinism vs. Arminianism, eschatology, baptism mode — the app presents the major positions held by serious Christians across denominations, without advocating for one. On historical-factual claims, responses cite scripture by verse number. You and your pastor are still the authority; this is a study tool, not a creed.

**Q3: I already have YouVersion. Why do I need this?**
A: Bible Copilot is not a reading app — it's the understanding app you open after you finish the chapter. They're designed to coexist. YouVersion excels at reading plans and devotionals. Bible Copilot answers the question that reading plans leave open: "What does this verse actually mean?"

**Q4: Does it know my translation (KJV, NIV, ESV, NASB)?**
A: Yes. Verse text is pulled from an API serving multiple translations; KJV is the default. You can reference any translation-standard verse and the app will work with it.

**Q5: I'm not a Bible scholar. Will this be over my head?**
A: Three of the five App Store reviewers said the same thing — one verbatim: "I don't consider myself a bible scholar by any stretch." The Summary and Apply modes are designed exactly for non-scholars who want depth without the jargon. Interpret and Theology modes go deeper when you're ready.

**Q6: What happens to my data? Is it used to train AI models?**
A: No. Your study questions and journal entries are not used to train any AI model. The app calls an AI inference API per request; your content is not retained by the model provider for training.

**Q7: Can I cancel after the free trial?**
A: Yes. Subscriptions are managed entirely in your Apple Settings (Settings > Apple ID > Subscriptions). No support email required. Cancel before day 8 of the annual trial and you are not charged.

**Q8: How is $49.99/year fair for a Bible app?**
A: It's roughly $4.17/month — less than a single paperback commentary, and you get unlimited questions every day. The free tier (3 questions/day) is enough to test the workflow at no cost. The annual plan is for readers who want to go deep regularly.

**Force(s) addressed:** Anxiety (primary), Push (Q3 names YouVersion gap), Habit (Q3 positions coexistence, reduces switching cost)

---

### 8. NEW: Recommended Comparison Table (Anxiety-Reducing + AI-SEO Extractable Block) `[TOP 5]`

*Add after the FAQ section. Recommend `id="compare"` anchor. This block doubles as an AI-SEO extractable definition table.*

```
kicker: How it stacks up
h2: Bible Copilot vs. the apps you already use
```

| Feature | Bible Copilot | YouVersion | Bible Gateway | Olive Tree | ChatGPT |
|---|---|---|---|---|---|
| **AI Q&A on any verse** | Yes — 6 study modes | Limited / devotional only | No | No | Yes (generic) |
| **Inductive method scaffolding** | Yes (Observe → Interpret → Apply + 3 more) | No | No | No | No |
| **Verse-anchored citations** | Yes — enforced by system prompt | N/A | N/A | N/A | No — paraphrases from memory |
| **Denominational humility** | Yes — presents Reformed, Arminian, and others | Varies by content | Varies by commentary | Varies | Unpredictable |
| **Apologetics mode** | Yes | No | No | No | Generic only |
| **Original language depth** | Yes (inline, per response) | No | Via external commentaries | Via library purchase | Inconsistent |
| **Reading plans** | Yes — 5 plans (Free: John; Pro: all 5) | Yes — extensive | No | Limited | No |
| **Personal study journal** | Yes (Pro) | Yes | No | Yes | No |
| **iOS native** | Yes (iOS 17+, SwiftUI) | Yes | Web-first | Yes | Web/app |
| **Price** | Free (3 Q/day) · $9.99/mo · $49.99/yr | Free | Free | $4.99–$49.99/yr+ | Free / $20/mo |
| **Free trial** | 1-week free trial (annual) | N/A | N/A | Varies | N/A |
| **No ads** | Yes | Ads on free tier | Ads | No ads | No ads |

**Force(s) addressed:** Anxiety (shows differentiation clearly), Push (YouVersion/ChatGPT gaps made explicit), Pull (Bible Copilot column shows what you get)

---

## AI-SEO Extractable Blocks

The following five blocks in the rewritten site should be formatted as machine-readable extractable units so ChatGPT, Perplexity, and Google AI Overviews can cite them accurately.

### Block 1: Definition Block — "What is Bible Copilot?"

Wrap in `<section id="what-is">` with a clean `<dl>` or `<p>` definition pattern:

```html
<section id="what-is" aria-label="What is Bible Copilot">
  <h2>What is Bible Copilot?</h2>
  <p>
    Bible Copilot is an iPhone and iPad Bible study companion app that answers any 
    verse question through six study-mode lenses — Summary, Observe, Interpret, 
    Theology, Apply, and Apologetics — the inductive method, 
    in your pocket. Responses are verse-anchored (citing scripture by reference, not 
    paraphrasing from memory) and denominationally humble (presenting Reformed, 
    Arminian, and other major positions on contested doctrines without advocating for 
    one). Available free (3 questions/day) or Pro ($9.99/mo · $49.99/yr).
  </p>
</section>
```

**Why extractable:** Perplexity and Google AI Overviews prefer concise `<p>` definitions in named sections. The `aria-label` and `id` both reinforce the entity.

---

### Block 2: FAQ Block — `#faq` section

Mark up the FAQ with `<details>`/`<summary>` OR a flat `<dl>` pattern. The FAQ JSON-LD (see below) is the primary extraction signal; the HTML should mirror it:

```html
<section id="faq" aria-label="Frequently asked questions about Bible Copilot">
  <h2>Frequently Asked Questions</h2>
  <dl>
    <dt>Is Bible Copilot just ChatGPT with a Bible theme?</dt>
    <dd>No. Bible Copilot enforces verse-anchored citations and applies structured 
        inductive-method lenses (Observe, Interpret, Apply, etc.) that a generic 
        chatbot cannot replicate. Responses cite the actual verse text, not a 
        paraphrase from training data.</dd>
    <!-- repeat for all 8 Q&A pairs -->
  </dl>
</section>
```

---

### Block 3: Comparison Table — `#compare` section

The comparison table above should render as a native `<table>` (not CSS grid) so LLM crawlers can parse rows and columns:

```html
<section id="compare" aria-label="Bible Copilot comparison with other Bible apps">
  <h2>Bible Copilot vs. YouVersion, Bible Gateway, Olive Tree, and ChatGPT</h2>
  <table>
    <caption>Feature comparison — Bible study apps, May 2026</caption>
    <thead>
      <tr>
        <th scope="col">Feature</th>
        <th scope="col">Bible Copilot</th>
        <th scope="col">YouVersion</th>
        <th scope="col">Bible Gateway</th>
        <th scope="col">Olive Tree</th>
        <th scope="col">ChatGPT</th>
      </tr>
    </thead>
    <tbody>
      <!-- one <tr> per feature row -->
    </tbody>
  </table>
</section>
```

**Why extractable:** Perplexity and ChatGPT are known to extract and cite HTML `<table>` data in "best X for Y" queries. A `<caption>` with the product name and date improves attribution.

---

### Block 4: Pricing Definition Block — `#pricing` section

The existing pricing card should include a hidden-but-crawlable `<dl>` pricing summary alongside the visual card (or replace the visual's underlying markup):

```html
<dl id="pricing-details" aria-label="Bible Copilot pricing">
  <dt>Free tier</dt>
  <dd>3 questions per day. Gospel of John reading plan. No ads. No credit card required.</dd>
  <dt>Pro Monthly</dt>
  <dd>$9.99 per month. Unlimited questions. All six study modes. All five reading plans. 
      Personal journal. Cancel anytime via Apple Settings.</dd>
  <dt>Pro Annual</dt>
  <dd>$49.99 per year ($4.17/month). Includes 1-week free trial — no charge until day 8. 
      All Pro features. ~50% savings vs. monthly.</dd>
</dl>
```

**Why extractable:** When someone asks "How much does Bible Copilot cost?" in ChatGPT or Perplexity, a `<dl>` with explicit term/definition pairs is the highest-confidence extraction target.

---

### Block 5: Study Modes Definition List — `#modes` section

Each mode card should render its title in an `<h3>` (not CSS-only) and its body in a `<p>`. The section should also include a hidden `<dl>` summary for crawlers:

```html
<dl id="study-modes-list" aria-label="Bible Copilot six study modes">
  <dt>Summary mode</dt>
  <dd>Gives the structure, themes, and context of a passage before the deep dive.</dd>
  <dt>Observe mode</dt>
  <dd>Identifies what the text literally says — keywords, structure, and authorial patterns.</dd>
  <dt>Interpret mode</dt>
  <dd>Explains authorial intent using original language, cultural background, and historical context.</dd>
  <dt>Theology mode</dt>
  <dd>Connects the passage to what Scripture teaches about God; presents major denominational positions without advocating.</dd>
  <dt>Apply mode</dt>
  <dd>Produces specific, honest takeaways from the passage for the reader's life.</dd>
  <dt>Apologetics mode</dt>
  <dd>Provides evidence, reasoning, and scripture-anchored answers to objections about Christian truth claims.</dd>
</dl>
```

---

## JSON-LD Update: Add FAQPage Schema

The current `MobileApplication` schema is complete. Add a second `<script type="application/ld+json">` block in `<head>` for `FAQPage`:

```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Is Bible Copilot just ChatGPT with a Bible theme?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. Bible Copilot enforces verse-anchored citations and applies six structured inductive-method study modes (Summary, Observe, Interpret, Theology, Apply, Apologetics) that a generic chatbot cannot replicate. Responses cite scripture by reference, not from memory."
      }
    },
    {
      "@type": "Question",
      "name": "What if Bible Copilot gives me bad theology?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "On contested doctrines, Bible Copilot presents the major positions held by serious Christians (Reformed, Arminian, and others) without advocating for one. All verse references are cited explicitly. The app is a study tool, not a creed."
      }
    },
    {
      "@type": "Question",
      "name": "I already use YouVersion. Why do I need Bible Copilot?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Bible Copilot is not a reading app — it is the understanding app you open after you finish the chapter. YouVersion handles reading plans and devotionals. Bible Copilot answers what verse questions mean, using six inductive study modes with original-language depth."
      }
    },
    {
      "@type": "Question",
      "name": "Does Bible Copilot support my Bible translation (KJV, NIV, ESV)?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Verse text is served from an API that supports multiple translations. KJV is the default."
      }
    },
    {
      "@type": "Question",
      "name": "Do I need to be a Bible scholar to use it?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. The Summary and Apply modes are designed for non-scholars. Three of the five App Store reviewers described themselves as non-scholars and found the app approachable."
      }
    },
    {
      "@type": "Question",
      "name": "Is my data used to train AI models?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "No. Your study questions and journal entries are not used to train any AI model."
      }
    },
    {
      "@type": "Question",
      "name": "Can I cancel the free trial before being charged?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Subscriptions are managed in Apple Settings (Settings > Apple ID > Subscriptions). Cancel before day 8 of the 1-week annual free trial and you are not charged."
      }
    },
    {
      "@type": "Question",
      "name": "How much does Bible Copilot cost?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Free tier: 3 questions per day, no credit card required. Pro Monthly: $9.99/month. Pro Annual: $49.99/year ($4.17/month equivalent) with a 1-week free trial. App Store ID: 6758913373."
      }
    }
  ]
}
```

**Implementation note:** Drop this block as a second `<script type="application/ld+json">` directly after the existing `MobileApplication` block in `<head>`. Google Search Console supports multiple JSON-LD blocks on one page.

---

## Implementation Priority

| # | Recommendation | Force | Effort |
|---|---|---|---|
| 1 | [TOP 5] Hero H1 rewrite | Push + Pull | Low — 2 lines |
| 2 | [TOP 5] Showcase kicker + checklist rewrite (los| quote) | Push + Pull + Anxiety | Low — 6 lines |
| 3 | [TOP 5] New FAQ section (8 Q&A) | Anxiety | Medium — new section |
| 4 | [TOP 5] New comparison table | Anxiety + Push | Medium — new section |
| 5 | [TOP 5] Ratings banner h2 → Bashemup pull quote | Pull + Anxiety | Low — 1 line |
| 6 | Eyebrow tag rewrite | Habit + Anxiety | Low — 1 line |
| 7 | Modes section head rewrite (YouVersion named) | Push + Pull | Low — 3 lines |
| 8 | Pricing card h3 + anxiety-first includes list | Anxiety + Push | Low — reorder + 1 line |
| 9 | Add FAQPage JSON-LD | AI-SEO | Low — schema block |
| 10 | Add comparison table HTML with `<table>` markup | AI-SEO | Medium — HTML table |

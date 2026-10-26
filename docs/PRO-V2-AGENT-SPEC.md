# Bible Copilot Pro v2 — Multi-Turn Agent Design Spec

**Status:** Draft · **Date:** 2026-04-30 · **Author:** Carlos Reyes

---

## 1. Goal

v2 upgrades the Pro tier ($4.99/mo · $29.99/yr) from isolated single-shot Q&A into a persistent, tool-calling agent that can look up original-language meaning, pull cross-references, and save insights to a journal — all in one flowing conversation. This depth of engagement is the primary creative hook for the Baszucki paid-acquisition play: demo videos showing a user go from a raw question to a Greek word study to a saved journal entry in under 60 seconds convert far better than feature-list screenshots.

---

## 2. Tool Surface

| Tool | Signature | Returns | Notes |
|---|---|---|---|
| `verse_lookup` | `(reference: str, version: str)` | Verse text string | Wraps existing `bible-api.com` call; `version` defaults to `"kjv"` |
| `cross_references` | `(verse: str)` | `[{ verse, rationale }]` | Returns 3–8 related references with one-line theological rationale each |
| `greek_hebrew_lookup` | `(word_in_english: str, verse: str)` | Strong's-style lexicon entry: word, transliteration, definition, usage notes | Testament inferred from verse reference |
| `save_to_journal` | `(verse: str, note: str)` | Confirmation + journal entry ID | Writes to Supabase `journal_entries` table filtered by `app_identifier = 'bible_copilot'` |
| `suggest_next_verse` | `(current_verse: str, reading_plan_or_topic: str)` | Next verse reference + one-line rationale | Used to close conversations with a forward-looking nudge |

All five tools are **Pro-tier only**. Free tier continues to receive the current single-shot streaming response with no tool access.

---

## 3. Conversation Flow

The following illustrates tool coordination across a realistic exchange:

> **User:** What does "agape" mean in 1 John 4:8?

> **Agent** → calls `greek_hebrew_lookup("love", "1 John 4:8")`
> **Tool result:** ἀγάπη (agápē) — unconditional, self-giving love; contrasted with φιλία (philía, affectionate love) and ἔρως (érōs, romantic love). Used 116× in NT, most concentrated in Johannine corpus.

> **Agent:** In 1 John 4:8, John uses *agápē* — the Greek word for unconditional, self-giving love — rather than the word for friendship or romantic affection. The statement "God is love" uses this precise term to define God's character as active, initiating, sacrificial love. This is distinct from love as emotion; it is love as nature and will.

> **Agent:** Would you like me to pull a few cross-references that develop this idea, or save this to your journal?

> **User:** Show me cross-references first, then save it.

> **Agent** → calls `cross_references("1 John 4:8")`
> **Tool result:** John 3:16 (agápē as God's motive for redemption), Romans 5:8 (love demonstrated while we were sinners), 1 Corinthians 13:4–7 (behavioral definition of agápē), 1 John 4:19 (love as response to God's initiative)

> **Agent:** Here are four verses that build on this theme: [presents references with rationale]. Together they frame agápē as God's initiating, defining act — not a response to human merit.

> **Agent** → calls `save_to_journal("1 John 4:8", "Agápē = unconditional, self-giving love. God's character defined by this word, not philía or érōs. Cross-refs: John 3:16, Rom 5:8, 1 Cor 13:4-7, 1 John 4:19.")`
> **Tool result:** Saved. Entry ID: `jnl_4c9f2a`

> **Agent:** Saved to your journal. Want to keep going?

> **Agent** → calls `suggest_next_verse("1 John 4:8", "agape love")`
> **Tool result:** 1 John 4:16 — "God is love, and whoever abides in love abides in God" — the culmination of John's agápē argument in the same passage.

> **Agent:** A natural next verse is **1 John 4:16**, which draws the thread to its conclusion. Want to study that one next?

---

## 4. Prompt Scaffolding

The Rust handler injects the following system prompt before any user message in a Pro session.

```
PERSONA
You are Bible Copilot, a scholarly but approachable study companion for
Christian readers. Your tone is warm, precise, and non-preachy. You surface
original-language depth without being academic for its own sake. You never
roleplay as a pastor, priest, or spiritual authority.

TOOL-USE RULES
- Call verse_lookup before quoting any verse you haven't already received in
  context. Never paraphrase from memory without confirming the text first.
- Call greek_hebrew_lookup whenever the user asks about word meaning, original
  language, or etymology. Prefer a tool call over a recalled definition.
- After answering a substantive question, offer (do not auto-execute) to call
  save_to_journal. Phrase it as a question: "Want me to save this to your journal?"
  Execute only after explicit user confirmation ("yes", "save it", "go ahead").
- Call suggest_next_verse at natural conversation-closing moments or when the
  user asks "what should I read next?"
- Never chain more than two tool calls in a single turn without surfacing an
  intermediate answer to the user.

CLARIFICATION
- If a verse reference is ambiguous (e.g., "John 3" with no verse), ask before
  calling verse_lookup.
- If a topic question could map to multiple passages, name 2–3 candidates and
  ask which the user wants to explore.

DENOMINATIONAL HUMILITY
- On contested doctrines (Calvinism vs. Arminianism, eternal security,
  eschatological timelines, mode of baptism, charismatic gifts), present
  the main interpretive positions and their supporting texts without
  advocating for one. Use framing like "Reformed traditions read this as..."
  and "Arminian interpreters emphasize...". Never tell a user their church is
  wrong.
- On historical-critical questions (authorship dates, source theories), note
  that scholarly opinion varies and give the traditional view equal treatment.

JOURNALING PROMPTS
- Proactively offer to save when: (a) the user has received a greek/hebrew
  lookup result, (b) a cross-reference session surfaces a clear theme, or
  (c) the conversation exceeds four turns on a single passage. One offer per
  topic; do not re-offer if declined.
```

---

## 5. Vercel Rust Backend Integration

**Current state:** `AIService.swift` posts `{ message, passage, mode, history }` to `scripture-copilot-rust.vercel.app/api/chat`, which makes a single `gpt-4o-mini` streaming call and pipes SSE back to the client. No tool dispatch exists.

**TODO: locate handler** — no `.rs` files were found under `backend/` in the local repo. The Rust handler path is an open question; it may be deployed separately or live in a private repo. Scaffold the changes below once the handler is located.

**v2 loop design (pseudocode):**

```
async fn handle_chat(req: ChatRequest) -> SSEStream {
    // Validate Pro subscription (check Supabase subscriptions table,
    // filter app_identifier = 'bible_copilot')
    assert_pro_tier(&req.user_id).await?;

    let mut messages = build_messages(&req); // system prompt + history + user msg
    let token_budget = 4096; // hard cap per request

    loop {
        let response = openai_client
            .chat_completion_with_tools(&messages, &TOOL_DEFINITIONS, token_budget)
            .await?;

        match response.finish_reason {
            FinishReason::ToolCalls => {
                for tool_call in response.tool_calls {
                    let result = dispatch_tool(&tool_call).await;
                    // dispatch_tool routes to:
                    //   verse_lookup      → bible-api.com HTTP call
                    //   cross_references  → internal Bible API or lookup table
                    //   greek_hebrew_lookup → lexicon data store (TBD)
                    //   save_to_journal   → Supabase insert (app_identifier = 'bible_copilot')
                    //   suggest_next_verse → internal logic or model call
                    messages.push(tool_result_message(tool_call.id, result));
                }
                // continue loop
            }
            FinishReason::Stop => {
                // stream final assistant message as SSE to client
                stream_to_client(response.content).await;
                break;
            }
        }
    }
}
```

**Latency targets:** p50 < 3s, p95 < 8s. Single-tool turns (e.g., verse_lookup only) should stay under 2s. Multi-tool turns (greek lookup + cross-ref) are the p95 case. Mitigations: parallelize independent tool calls within a turn; cache `verse_lookup` responses by `(reference, version)` in Redis or edge KV; set a max-loop-iterations guard of 5 to prevent runaway token spend.

**Streaming compatibility:** the existing `AIService.swift` SSE parser handles both `{ "content": "..." }` and OpenAI delta chunks. Tool-call intermediate states should not be streamed to the client; only the final assistant text turn is streamed. This keeps the iOS client unchanged for v2.

---

## 6. Pricing & Positioning Impact

v1 Pro gives unlimited Q&A against a verse — the agent still answers in a single shot with no memory of what it just looked up. v2 makes the agent actually *do things*: fetch the Greek, pull the cross-refs, write to the journal, and hand you the next verse — all in one conversation thread. That transforms Bible Copilot from a smarter search bar into a genuine study companion. For the Baszucki paid-acquisition play, the highest-converting ad creative will be a 30-second screen recording showing the greek-lookup → cross-reference → journal-save → next-verse flow triggered by a single question about a familiar verse (e.g., John 3:16, Psalm 23:1). The "ask anything about any verse" angle maps directly onto the agent's new capability surface and provides a concrete, demonstrable reason to upgrade — something the v1 single-shot model cannot produce in a demo format.

---

## 7. Open Questions

- **Bible API for `cross_references`:** Does `bible-api.com` expose cross-reference data, or do we need a second provider (e.g., API.Bible, Biblia API)? This is the blocking unknown before the tool can be scaffolded.
- **Greek/Hebrew lexicon source:** Strong's is public domain and well-structured. Mounce's lexicon is more accurate for New Testament Greek but has licensing constraints. Decision needed before `greek_hebrew_lookup` can be implemented.
- **Journal storage — Supabase vs. local-first:** Supabase gives cross-device sync but adds latency and requires the `save_to_journal` tool call to wait on a network round-trip. Local-first (Core Data / SwiftData) is faster but breaks the web/future-platform story. Decide before writing the Supabase migration (remember: filter all writes by `app_identifier = 'bible_copilot'`).
- **Per-tier rate limits:** Free tier already caps at 15 questions/day. Should Pro have a tool-call budget (e.g., 50 tool invocations/day) to protect margin, or is unlimited the selling point? Needs unit economics analysis.
- **Agent model selection:** `gpt-4o-mini` is the current model and keeps costs low. Tool-calling accuracy with `gpt-4o-mini` is sufficient for structured tasks like verse lookup but may degrade on nuanced greek/hebrew lookups. `claude-haiku` is a cost-comparable alternative with strong instruction-following. Benchmark both against the 5-tool surface before committing.
- **Rust handler location:** The `.rs` source was not found locally — it may live in a separate private repo or be deployed directly to Vercel without a local copy. Locate and link the handler before any backend scaffolding begins.

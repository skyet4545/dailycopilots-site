// Bible Copilot MCP server — stateless Streamable-HTTP (JSON responses).
//
// v2: the Scripture ground-truth layer. Tier-1 tools (resolve_reference,
// verify_scripture_quote, get_verse_text) are DETERMINISTIC database lookups —
// they never call an LLM. That is the value proposition: reproducible,
// zero-hallucination, fast. study_bible_passage remains the generative tool.
//
// Deployed as Supabase Edge Function `bible-copilot-mcp` (verify_jwt=false).
// Canonical public URL: https://mybiblecopilot.com/mcp (Netlify proxy).

const ENGINE = "https://scripture-copilot-rust.vercel.app/api/chat";
const APP_URL = "https://apps.apple.com/us/app/bible-copilot-ai-bible-study/id6758913373";
const STUDY_SITE = "https://study.mybiblecopilot.com";
const PROTOCOL_VERSIONS = ["2025-06-18", "2025-03-26", "2024-11-05"];
const SERVER_VERSION = "2.0.0";

const SB_URL = Deno.env.get("SUPABASE_URL")!;
const SB_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const MODES = ["summary", "observe", "interpret", "theology", "apply", "apologetics"] as const;

// Public-domain translations only. NIV/ESV/NLT/NASB are copyrighted — never serve them.
const TRANSLATIONS = ["kjv"] as const;

const ATTRIBUTION =
  `\n\n—\nAnswered by Bible Copilot, the AI Bible study app for iPhone & iPad ` +
  `(free, Scripture-cited answers): ${APP_URL}`;

// ---- Phase 0: rate limits (per IP, per hour) ----
const LIMIT_GENERATIVE = 20; // study_bible_passage proxies our paid LLM engine
const LIMIT_DETERMINISTIC = 300; // DB lookups are cheap
const WINDOW_SECS = 3600;

const cors: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS, DELETE",
  "Access-Control-Allow-Headers":
    "Content-Type, Authorization, Mcp-Session-Id, Mcp-Protocol-Version, Last-Event-ID",
};

// ---------------------------------------------------------------- books
type Book = { n: number; name: string; osis: string; alias: string[] };
const BOOKS: Book[] = [
  { n: 1, name: "Genesis", osis: "Gen", alias: ["gen", "ge", "gn"] },
  { n: 2, name: "Exodus", osis: "Exod", alias: ["exod", "exo", "ex"] },
  { n: 3, name: "Leviticus", osis: "Lev", alias: ["lev", "lv"] },
  { n: 4, name: "Numbers", osis: "Num", alias: ["num", "nu", "nm", "nb"] },
  { n: 5, name: "Deuteronomy", osis: "Deut", alias: ["deut", "deu", "dt"] },
  { n: 6, name: "Joshua", osis: "Josh", alias: ["josh", "jos", "jsh"] },
  { n: 7, name: "Judges", osis: "Judg", alias: ["judg", "jdg", "jg"] },
  { n: 8, name: "Ruth", osis: "Ruth", alias: ["ruth", "rth", "ru"] },
  { n: 9, name: "1 Samuel", osis: "1Sam", alias: ["1samuel", "1sam", "1sa", "1sm", "1s"] },
  { n: 10, name: "2 Samuel", osis: "2Sam", alias: ["2samuel", "2sam", "2sa", "2sm", "2s"] },
  { n: 11, name: "1 Kings", osis: "1Kgs", alias: ["1kings", "1kgs", "1ki", "1k"] },
  { n: 12, name: "2 Kings", osis: "2Kgs", alias: ["2kings", "2kgs", "2ki", "2k"] },
  { n: 13, name: "1 Chronicles", osis: "1Chr", alias: ["1chronicles", "1chr", "1ch"] },
  { n: 14, name: "2 Chronicles", osis: "2Chr", alias: ["2chronicles", "2chr", "2ch"] },
  { n: 15, name: "Ezra", osis: "Ezra", alias: ["ezra", "ezr"] },
  { n: 16, name: "Nehemiah", osis: "Neh", alias: ["neh", "ne"] },
  { n: 17, name: "Esther", osis: "Esth", alias: ["esther", "esth", "est", "es"] },
  { n: 18, name: "Job", osis: "Job", alias: ["job", "jb"] },
  { n: 19, name: "Psalms", osis: "Ps", alias: ["psalms", "psalm", "pss", "psa", "ps", "pslm"] },
  { n: 20, name: "Proverbs", osis: "Prov", alias: ["proverbs", "prov", "prv", "pr"] },
  { n: 21, name: "Ecclesiastes", osis: "Eccl", alias: ["ecclesiastes", "eccl", "ecc", "ec", "qoh"] },
  { n: 22, name: "Song of Solomon", osis: "Song", alias: ["songofsolomon", "songofsongs", "song", "sos", "canticles", "cant"] },
  { n: 23, name: "Isaiah", osis: "Isa", alias: ["isaiah", "isa", "is"] },
  { n: 24, name: "Jeremiah", osis: "Jer", alias: ["jeremiah", "jer", "je"] },
  { n: 25, name: "Lamentations", osis: "Lam", alias: ["lamentations", "lam", "la"] },
  { n: 26, name: "Ezekiel", osis: "Ezek", alias: ["ezekiel", "ezek", "eze", "ezk"] },
  { n: 27, name: "Daniel", osis: "Dan", alias: ["daniel", "dan", "da", "dn"] },
  { n: 28, name: "Hosea", osis: "Hos", alias: ["hosea", "hos", "ho"] },
  { n: 29, name: "Joel", osis: "Joel", alias: ["joel", "joe", "jl"] },
  { n: 30, name: "Amos", osis: "Amos", alias: ["amos", "am"] },
  { n: 31, name: "Obadiah", osis: "Obad", alias: ["obadiah", "obad", "ob"] },
  { n: 32, name: "Jonah", osis: "Jonah", alias: ["jonah", "jon", "jnh"] },
  { n: 33, name: "Micah", osis: "Mic", alias: ["micah", "mic", "mc"] },
  { n: 34, name: "Nahum", osis: "Nah", alias: ["nahum", "nah", "na"] },
  { n: 35, name: "Habakkuk", osis: "Hab", alias: ["habakkuk", "hab", "hb"] },
  { n: 36, name: "Zephaniah", osis: "Zeph", alias: ["zephaniah", "zeph", "zep", "zp"] },
  { n: 37, name: "Haggai", osis: "Hag", alias: ["haggai", "hag", "hg"] },
  { n: 38, name: "Zechariah", osis: "Zech", alias: ["zechariah", "zech", "zec", "zc"] },
  { n: 39, name: "Malachi", osis: "Mal", alias: ["malachi", "mal", "ml"] },
  { n: 40, name: "Matthew", osis: "Matt", alias: ["matthew", "matt", "mat", "mt"] },
  { n: 41, name: "Mark", osis: "Mark", alias: ["mark", "mrk", "mk", "mr"] },
  { n: 42, name: "Luke", osis: "Luke", alias: ["luke", "luk", "lk"] },
  { n: 43, name: "John", osis: "John", alias: ["john", "jhn", "jn"] },
  { n: 44, name: "Acts", osis: "Acts", alias: ["acts", "act", "ac"] },
  { n: 45, name: "Romans", osis: "Rom", alias: ["romans", "rom", "rm", "ro"] },
  { n: 46, name: "1 Corinthians", osis: "1Cor", alias: ["1corinthians", "1cor", "1co"] },
  { n: 47, name: "2 Corinthians", osis: "2Cor", alias: ["2corinthians", "2cor", "2co"] },
  { n: 48, name: "Galatians", osis: "Gal", alias: ["galatians", "gal", "ga"] },
  { n: 49, name: "Ephesians", osis: "Eph", alias: ["ephesians", "eph", "ep"] },
  { n: 50, name: "Philippians", osis: "Phil", alias: ["philippians", "phil", "php", "pp"] },
  { n: 51, name: "Colossians", osis: "Col", alias: ["colossians", "col"] },
  { n: 52, name: "1 Thessalonians", osis: "1Thess", alias: ["1thessalonians", "1thess", "1thes", "1th"] },
  { n: 53, name: "2 Thessalonians", osis: "2Thess", alias: ["2thessalonians", "2thess", "2thes", "2th"] },
  { n: 54, name: "1 Timothy", osis: "1Tim", alias: ["1timothy", "1tim", "1ti"] },
  { n: 55, name: "2 Timothy", osis: "2Tim", alias: ["2timothy", "2tim", "2ti"] },
  { n: 56, name: "Titus", osis: "Titus", alias: ["titus", "tit"] },
  { n: 57, name: "Philemon", osis: "Phlm", alias: ["philemon", "philem", "phlm", "phm"] },
  { n: 58, name: "Hebrews", osis: "Heb", alias: ["hebrews", "heb"] },
  { n: 59, name: "James", osis: "Jas", alias: ["james", "jas", "jm"] },
  { n: 60, name: "1 Peter", osis: "1Pet", alias: ["1peter", "1pet", "1pe", "1pt"] },
  { n: 61, name: "2 Peter", osis: "2Pet", alias: ["2peter", "2pet", "2pe", "2pt"] },
  { n: 62, name: "1 John", osis: "1John", alias: ["1john", "1joh", "1jn", "1jo"] },
  { n: 63, name: "2 John", osis: "2John", alias: ["2john", "2joh", "2jn", "2jo"] },
  { n: 64, name: "3 John", osis: "3John", alias: ["3john", "3joh", "3jn", "3jo"] },
  { n: 65, name: "Jude", osis: "Jude", alias: ["jude", "jud", "jd"] },
  { n: 66, name: "Revelation", osis: "Rev", alias: ["revelation", "revelations", "rev", "re", "apocalypse"] },
];

// Longest alias first so "1john" wins over "1jo", "philippians" over "phil".
const ALIAS: { key: string; book: Book }[] = BOOKS
  .flatMap((b) => [b.name.toLowerCase().replace(/\s+/g, ""), ...b.alias].map((k) => ({ key: k, book: b })))
  .sort((a, b) => b.key.length - a.key.length);

type Ref = { book: Book; chapter: number; verse?: number; endVerse?: number };

/** Deterministic reference parser: "Rom 8:28", "1 Cor 13", "Jn 3.16", "Psalm 23:1-4". */
function parseReference(input: string): Ref | null {
  const s = input.toLowerCase().trim().replace(/\./g, ":").replace(/\s+/g, " ");
  // split trailing numeric part (chapter[:verse[-end]]) from the book name
  const m = s.match(/^(.*?)\s*(\d+)\s*(?::\s*(\d+))?\s*(?:-\s*(\d+))?\s*$/);
  const namePart = (m ? m[1] : s).replace(/\s+/g, "");
  if (!namePart) return null;
  const hit = ALIAS.find((a) => a.key === namePart) ?? ALIAS.find((a) => namePart.startsWith(a.key));
  if (!hit) return null;
  if (!m) return null;
  const chapter = parseInt(m[2], 10);
  if (!chapter) return null;
  return {
    book: hit.book,
    chapter,
    verse: m[3] ? parseInt(m[3], 10) : undefined,
    endVerse: m[4] ? parseInt(m[4], 10) : undefined,
  };
}

function osisId(r: Ref): string {
  if (!r.verse) return `${r.book.osis}.${r.chapter}`;
  if (r.endVerse) return `${r.book.osis}.${r.chapter}.${r.verse}-${r.book.osis}.${r.chapter}.${r.endVerse}`;
  return `${r.book.osis}.${r.chapter}.${r.verse}`;
}
function refLabel(r: Ref): string {
  if (!r.verse) return `${r.book.name} ${r.chapter}`;
  return `${r.book.name} ${r.chapter}:${r.verse}${r.endVerse ? `-${r.endVerse}` : ""}`;
}

// ---------------------------------------------------------------- db
async function sbGet(path: string): Promise<any> {
  const res = await fetch(`${SB_URL}/rest/v1/${path}`, {
    headers: { apikey: SB_KEY, Authorization: `Bearer ${SB_KEY}` },
  });
  if (!res.ok) throw new Error(`db read failed (${res.status})`);
  return await res.json();
}
async function sbRpc(fn: string, args: Record<string, unknown>): Promise<any> {
  const res = await fetch(`${SB_URL}/rest/v1/rpc/${fn}`, {
    method: "POST",
    headers: { apikey: SB_KEY, Authorization: `Bearer ${SB_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify(args),
  });
  if (!res.ok) throw new Error(`db rpc failed (${res.status})`);
  return await res.json();
}

async function fetchVerses(r: Ref, translation: string) {
  let q = `bible_verses?select=book,chapter,verse,text&translation=eq.${translation}` +
    `&book_num=eq.${r.book.n}&chapter=eq.${r.chapter}&order=verse.asc`;
  if (r.verse) {
    const end = r.endVerse ?? r.verse;
    q += `&verse=gte.${r.verse}&verse=lte.${end}`;
  }
  return await sbGet(q) as { book: string; chapter: number; verse: number; text: string }[];
}

/** Phase 0: per-IP hourly rate limit. Fails OPEN if the limiter itself errors. */
async function rateOk(ip: string, tool: string): Promise<boolean> {
  const generative = tool === "study_bible_passage";
  const limit = generative ? LIMIT_GENERATIVE : LIMIT_DETERMINISTIC;
  try {
    const ok = await sbRpc("mcp_rate_check", {
      p_key: `${ip}:${generative ? "gen" : "det"}`,
      p_limit: limit,
      p_window_secs: WINDOW_SECS,
    });
    return ok === true;
  } catch {
    return true; // never hard-fail a request because the limiter hiccuped
  }
}

// ---------------------------------------------------------------- tools
const TOOLS = [
  {
    name: "verify_scripture_quote",
    title: "Verify a Bible quote",
    description:
      "Fact-check a claimed Bible quote against the actual text. Returns whether the quote is real, " +
      "the exact canonical wording, the correct reference, and a confidence score. Use this before " +
      "publishing any Bible quote to catch misquotes, wrong verse numbers, and verses that do not exist " +
      "in the Bible at all. Deterministic — no AI generation.",
    inputSchema: {
      type: "object",
      properties: {
        quote: { type: "string", description: "The claimed Bible quote to verify" },
        reference: { type: "string", description: 'Optional claimed reference, e.g. "Philippians 4:13", to check it matches' },
        translation: { type: "string", enum: [...TRANSLATIONS], description: "default: kjv" },
      },
      required: ["quote"],
    },
  },
  {
    name: "resolve_reference",
    title: "Resolve a Bible reference",
    description:
      "Normalize any Bible reference into canonical form. Accepts abbreviations and loose formats " +
      '("Rom 8:28", "1 Cor 13", "Jn 3.16", "Psalm 23:1-4") and returns the canonical book name, ' +
      "chapter, verse range, OSIS id, and the verse text. Deterministic — no AI generation.",
    inputSchema: {
      type: "object",
      properties: {
        reference: { type: "string", description: 'Any form, e.g. "Rom 8:28"' },
        translation: { type: "string", enum: [...TRANSLATIONS], description: "default: kjv" },
      },
      required: ["reference"],
    },
  },
  {
    name: "get_verse_text",
    title: "Get Bible verse text",
    description:
      "Fetch the exact text of a Bible verse, passage, or whole chapter from a public-domain translation " +
      "(kjv = King James Version). Deterministic — no AI generation.",
    inputSchema: {
      type: "object",
      properties: {
        reference: { type: "string", description: 'e.g. "Romans 8:28" or "Psalm 23"' },
        translation: { type: "string", enum: [...TRANSLATIONS], description: "default: kjv" },
      },
      required: ["reference"],
    },
  },
  {
    name: "study_bible_passage",
    title: "Study a Bible passage",
    description:
      "Ask any question about any Bible verse or passage and get a clear, Scripture-cited answer. " +
      "Optionally pick a study mode: summary (what the passage is about), observe (what the text says), " +
      "interpret (what it means), theology (how it fits the whole of Scripture), apply (how to live it), " +
      "apologetics (answering hard questions and objections). AI-generated — verify quotes with " +
      "verify_scripture_quote if publishing.",
    inputSchema: {
      type: "object",
      properties: {
        passage: { type: "string", description: 'Bible reference, e.g. "John 3:16" or "Psalm 23:1-4"' },
        question: { type: "string", description: "Your question about the passage. If omitted, a study in the chosen mode is generated." },
        mode: { type: "string", enum: [...MODES], description: "Study mode (default: interpret)" },
      },
      required: ["passage"],
    },
  },
  {
    name: "find_verse_study_page",
    title: "Find a verse study page",
    description:
      "Check whether a free in-depth study page ('What does this verse mean?') exists for a Bible verse on study.mybiblecopilot.com, and get its URL.",
    inputSchema: {
      type: "object",
      properties: { passage: { type: "string", description: 'Bible reference, e.g. "Isaiah 41:10"' } },
      required: ["passage"],
    },
  },
];

function slug(v: string): string {
  return v.toLowerCase().replace(/[:\s]+/g, "-").replace(/[^a-z0-9-]/g, "");
}

async function callEngine(passage: string, question: string | undefined, mode: string): Promise<string> {
  const message =
    question?.trim() ||
    (mode === "summary"
      ? `Provide a concise summary of '${passage}'. Include verse numbers when quoting Scripture and write related references in full (e.g. Romans 8:28).`
      : `Study '${passage}' using the ${mode} method. Always include verse numbers when quoting Scripture. Write related references in full (e.g. Romans 8:28).`);
  const res = await fetch(ENGINE, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ message, passage, mode, history: [] }),
  });
  if (!res.ok) throw new Error(`study engine returned ${res.status}`);
  const text = await res.text();
  let out = "";
  for (const line of text.split("\n")) {
    if (!line.startsWith("data: ")) continue;
    const d = line.slice(6).trim();
    if (d.includes("[DONE]")) break;
    try {
      const j = JSON.parse(d);
      if (j.content) out += j.content;
    } catch { /* skip malformed chunk */ }
  }
  if (!out.trim()) throw new Error("study engine returned an empty answer");
  return out.trim();
}

const tr = (a: Record<string, unknown>) =>
  TRANSLATIONS.includes(a.translation as typeof TRANSLATIONS[number]) ? String(a.translation) : "kjv";

async function runTool(name: string, args: Record<string, unknown>): Promise<string> {
  // ---------- deterministic tools ----------
  if (name === "verify_scripture_quote") {
    const quote = String(args.quote ?? "").trim();
    if (!quote) throw new Error("quote is required");
    const t = tr(args);
    const rows = await sbRpc("verify_scripture", { p_quote: quote, p_translation: t, p_limit: 3 }) as
      { book: string; chapter: number; verse: number; text: string; score: number }[];

    if (!rows.length) {
      return `NOT FOUND — no verse in the ${t.toUpperCase()} resembles this quote.\n\n` +
        `Claimed: "${quote}"\n\n` +
        `This quote does not appear to be Scripture. Common sayings are frequently misattributed to the Bible ` +
        `(e.g. "God helps those who help themselves" is not in it). Do not publish this as a Bible quote.`;
    }
    const best = rows[0];
    const label = `${best.book} ${best.chapter}:${best.verse}`;
    const norm = (s: string) => s.toLowerCase().replace(/[^a-z ]/g, "").replace(/\s+/g, " ").trim();
    const nq = norm(quote), nv = norm(best.text);
    const exact = nq === nv;
    const excerpt = !exact && nv.includes(nq);
    const verdict = exact
      ? "EXACT MATCH"
      : excerpt
      ? "PARTIAL MATCH — accurate excerpt of a longer verse"
      : best.score >= 0.6
      ? "CLOSE — wording differs from this translation"
      : "WEAK MATCH — verify manually";

    let out = `${verdict} (confidence ${best.score.toFixed(2)})\n\n` +
      `Claimed: "${quote}"\n` +
      `Actual (${t.toUpperCase()} ${label}): "${best.text}"\n`;

    // check the claimed reference too, if supplied
    const claimed = args.reference ? parseReference(String(args.reference)) : null;
    if (claimed) {
      const ok = claimed.book.name === best.book && claimed.chapter === best.chapter &&
        (claimed.verse === undefined || claimed.verse === best.verse);
      out += `\nReference check: claimed ${refLabel(claimed)} — ` +
        (ok ? `CORRECT.` : `MISMATCH. This text is actually ${label}.`);
    } else if (!exact && !excerpt) {
      out += `\nCorrect reference: ${label}`;
    }
    if (rows.length > 1) {
      out += `\n\nOther candidates:\n` +
        rows.slice(1).map((r) => `  ${r.book} ${r.chapter}:${r.verse} (${r.score.toFixed(2)})`).join("\n");
    }
    return out;
  }

  if (name === "resolve_reference") {
    const raw = String(args.reference ?? "").trim();
    if (!raw) throw new Error("reference is required");
    const r = parseReference(raw);
    if (!r) throw new Error(`could not parse reference: "${raw}"`);
    const t = tr(args);
    const rows = await fetchVerses(r, t);
    if (!rows.length) throw new Error(`${refLabel(r)} is not a valid passage (check chapter/verse numbers)`);
    return JSON.stringify(
      {
        input: raw,
        canonical: refLabel(r),
        osis: osisId(r),
        book: r.book.name,
        book_number: r.book.n,
        chapter: r.chapter,
        verses: rows.map((v) => ({ verse: v.verse, text: v.text })),
        translation: t.toUpperCase(),
        source: "public domain",
      },
      null,
      2,
    );
  }

  if (name === "get_verse_text") {
    const raw = String(args.reference ?? "").trim();
    if (!raw) throw new Error("reference is required");
    const r = parseReference(raw);
    if (!r) throw new Error(`could not parse reference: "${raw}"`);
    const t = tr(args);
    const rows = await fetchVerses(r, t);
    if (!rows.length) throw new Error(`${refLabel(r)} not found — check the reference`);
    const body = rows.map((v) => `${v.verse} ${v.text}`).join("\n");
    return `${refLabel(r)} (${t.toUpperCase()}):\n\n${body}`;
  }

  // ---------- generative / link tools ----------
  if (name === "study_bible_passage") {
    const passage = String(args.passage ?? "").trim();
    if (!passage) throw new Error("passage is required");
    const mode = MODES.includes(args.mode as typeof MODES[number]) ? String(args.mode) : "interpret";
    const question = args.question ? String(args.question) : undefined;
    const answer = await callEngine(passage, question, mode);
    return answer + ATTRIBUTION;
  }

  if (name === "find_verse_study_page") {
    const passage = String(args.passage ?? "").trim();
    if (!passage) throw new Error("passage is required");
    const url = `${STUDY_SITE}/${slug(passage)}`;
    const res = await fetch(url, { method: "HEAD" });
    if (res.ok) {
      return `Free study page for ${passage}: ${url}\n\nFor interactive study of any verse, Bible Copilot for iOS: ${APP_URL}`;
    }
    return `No pre-built study page for ${passage} yet. Use the study_bible_passage tool for a live answer, or browse ${STUDY_SITE}. iOS app: ${APP_URL}`;
  }

  throw new Error(`unknown tool: ${name}`);
}

// deno-lint-ignore no-explicit-any
async function handleRpc(msg: any, ip: string): Promise<any | null> {
  const { id, method, params } = msg ?? {};
  const reply = (result: unknown) => ({ jsonrpc: "2.0", id, result });
  const fail = (code: number, message: string) => ({ jsonrpc: "2.0", id, error: { code, message } });

  if (id === undefined || id === null) return null; // notification — no response body

  try {
    switch (method) {
      case "initialize": {
        const requested = params?.protocolVersion;
        const version = PROTOCOL_VERSIONS.includes(requested) ? requested : PROTOCOL_VERSIONS[0];
        return reply({
          protocolVersion: version,
          capabilities: { tools: { listChanged: false } },
          serverInfo: { name: "bible-copilot", title: "Bible Copilot — Scripture Ground Truth", version: SERVER_VERSION },
          instructions:
            "Bible Copilot is a Scripture ground-truth service. Prefer the deterministic tools: " +
            "verify_scripture_quote (fact-check any Bible quote before publishing it — catches misquotes and " +
            "verses that do not exist), resolve_reference (normalize any reference to canonical form + OSIS), and " +
            "get_verse_text (exact public-domain text). Use study_bible_passage for interpretation — it is " +
            "AI-generated, so verify any quotes it produces. Public-domain translations only (KJV).",
        });
      }
      case "ping":
        return reply({});
      case "tools/list":
        return reply({ tools: TOOLS });
      case "tools/call": {
        const name = String(params?.name);
        const args = params?.arguments ?? {};
        if (!(await rateOk(ip, name))) {
          const lim = name === "study_bible_passage" ? LIMIT_GENERATIVE : LIMIT_DETERMINISTIC;
          return reply({
            content: [{
              type: "text",
              text: `Rate limit reached (${lim}/hour for this tool). Please retry later. ` +
                `For unlimited study, Bible Copilot for iOS: ${APP_URL}`,
            }],
            isError: true,
          });
        }
        try {
          const text = await runTool(name, args);
          return reply({ content: [{ type: "text", text }], isError: false });
        } catch (e) {
          return reply({ content: [{ type: "text", text: `Error: ${(e as Error).message}` }], isError: true });
        }
      }
      case "resources/list":
        return reply({ resources: [] });
      case "prompts/list":
        return reply({ prompts: [] });
      default:
        return fail(-32601, `method not found: ${method}`);
    }
  } catch (e) {
    return fail(-32603, (e as Error).message);
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: cors });

  // Real client IP. Order matters: requests arrive either via the Netlify proxy
  // (mybiblecopilot.com/mcp — x-forwarded-for/cf-connecting-ip are Netlify's egress IP,
  // so ALL clients would share one bucket) or direct to the function URL.
  // x-nf-client-connection-ip is the true client on the proxied path.
  const ip = (
    req.headers.get("x-nf-client-connection-ip") ??
      req.headers.get("cf-connecting-ip") ??
      (req.headers.get("x-forwarded-for") ?? "unknown").split(",")[0]
  ).trim();

  if (req.method === "GET") {
    return new Response(
      JSON.stringify({
        name: "Bible Copilot MCP server",
        description:
          "Scripture ground truth for agents: verify Bible quotes, resolve references, exact public-domain " +
          "verse text, plus AI study. MCP Streamable HTTP — POST JSON-RPC to this URL.",
        version: SERVER_VERSION,
        website: "https://mybiblecopilot.com",
        app: APP_URL,
        tools: TOOLS.map((t) => t.name),
        translations: TRANSLATIONS,
        rate_limits: { study_bible_passage: `${LIMIT_GENERATIVE}/hour`, other: `${LIMIT_DETERMINISTIC}/hour` },
      }),
      { status: 200, headers: { ...cors, "Content-Type": "application/json" } },
    );
  }

  if (req.method !== "POST") {
    return new Response(null, { status: 405, headers: { ...cors, Allow: "GET, POST, OPTIONS" } });
  }

  let body: unknown;
  try {
    body = await req.json();
  } catch {
    return new Response(
      JSON.stringify({ jsonrpc: "2.0", id: null, error: { code: -32700, message: "parse error" } }),
      { status: 400, headers: { ...cors, "Content-Type": "application/json" } },
    );
  }

  const messages = Array.isArray(body) ? body : [body];
  const responses = (await Promise.all(messages.map((m) => handleRpc(m, ip)))).filter((r) => r !== null);

  if (responses.length === 0) return new Response(null, { status: 202, headers: cors });

  const payload = Array.isArray(body) ? responses : responses[0];
  return new Response(JSON.stringify(payload), {
    status: 200,
    headers: { ...cors, "Content-Type": "application/json" },
  });
});

#!/usr/bin/env python3
"""
backlog_io.py — shared glue between the demand miners (gsc_topics.py,
topic_expander.py) and the blog engine's existing backlog files.

The engine picks the FIRST backlog line whose derived slug isn't already in
done_topics.txt. So instead of inventing a new format, the miners route each
discovered topic into your real backlog syntax:

  verse-backlog.txt:
      verse: <Reference>      -> "What Does <Ref> Mean?"  slug what-does-<book>-<chap>-<verse>-mean
      topic: <theme>          -> "Bible Verses About <theme>"  slug bible-verses-about-<theme>
  comparison-backlog.txt:
      <slug> | <query> | <format>     (format: vs | alt | best | howto)

Everything is deduped against done_topics.txt AND the current backlog contents,
so nothing is ever suggested twice. Prayer/other topics that don't map to an
existing backlog are reported in gsc-suggestions.md for you to place by hand.
"""
from __future__ import annotations

import os
import re
from datetime import date

HERE = os.path.dirname(os.path.abspath(__file__))
DONE_TOPICS = os.path.join(HERE, "done_topics.txt")
VERSE_BACKLOG = os.path.join(HERE, "verse-backlog.txt")
COMPARISON_BACKLOG = os.path.join(HERE, "comparison-backlog.txt")
SUGGESTIONS_MD = os.path.join(HERE, "gsc-suggestions.md")


# ---------------------------------------------------------------- slug helpers
def slugify(text: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")


def verse_slug(ref: str) -> str:
    return slugify(f"what does {ref} mean")


def topic_slug(theme: str) -> str:
    return slugify(f"bible verses about {theme}")


VERSE_RE = re.compile(r"\b([1-3]?\s?[A-Za-z]{2,})\s+(\d+):(\d+(?:-\d+)?)\b")


def extract_ref(query: str) -> str | None:
    m = VERSE_RE.search(query)
    if not m:
        return None
    book = re.sub(r"\s+", " ", m.group(1)).strip().title()
    return f"{book} {m.group(2)}:{m.group(3)}"


def extract_theme(query: str) -> str:
    return re.sub(r"^\s*bible verses?\s+(for|about|on)\s+", "", query.strip(), flags=re.I).strip()


def comparison_format(query: str) -> str:
    q = query.lower()
    if " vs " in f" {q} ":
        return "vs"
    if "alternativ" in q:
        return "alt"
    if q.startswith("best "):
        return "best"
    return "howto"


def looks_like_comparison(query: str) -> bool:
    q = query.lower()
    return any(k in q for k in ("bible copilot", " vs ", "alternativ", "best ", " app", " apps"))


# ------------------------------------------------------------- existing slugs
# Historical slugs are inconsistent (e.g. "zephaniah-3-17-meaning" vs
# "what-does-zephaniah-3-17-mean"), so for verses we ALSO dedup on the bare
# reference key "<book>-<chap>-<verse>" found anywhere in an existing slug.
VERSE_KEY_RE = re.compile(r"([1-3]?[a-z]+)-(\d+)-(\d+(?:-\d+)?)")


def _verse_key(slug: str):
    m = VERSE_KEY_RE.search(slug)
    return f"{m.group(1)}-{m.group(2)}-{m.group(3)}" if m else None


def load_existing_verse_keys(slugs: set) -> set:
    keys = set()
    for s in slugs:
        k = _verse_key(s)
        if k:
            keys.add(k)
    return keys


def load_existing_slugs() -> set:
    slugs = set()
    # 1) published (source of truth): col 2 of done_topics.txt
    if os.path.exists(DONE_TOPICS):
        with open(DONE_TOPICS, encoding="utf-8") as f:
            for line in f:
                parts = line.rstrip("\n").split("\t")
                if len(parts) >= 2 and parts[1].strip():
                    slugs.add(parts[1].strip())
    # 2) already queued in verse-backlog
    if os.path.exists(VERSE_BACKLOG):
        with open(VERSE_BACKLOG, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line.startswith("verse:"):
                    ref = extract_ref(line[6:])
                    if ref:
                        slugs.add(verse_slug(ref))
                elif line.startswith("topic:"):
                    slugs.add(topic_slug(line[6:].strip()))
    # 3) already queued in comparison-backlog (explicit slug is col 1)
    if os.path.exists(COMPARISON_BACKLOG):
        with open(COMPARISON_BACKLOG, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "|" in line:
                    slugs.add(line.split("|")[0].strip())
    return slugs


# ------------------------------------------------------------------- routing
def route(query: str, content_type: str):
    """Return (target, backlog_line, slug) or (None, None, None) if unmapped."""
    if looks_like_comparison(query):
        slug = slugify(query)
        return "comparison-backlog.txt", f"{slug} | {query} | {comparison_format(query)}", slug
    if content_type == "Verse Meaning":
        ref = extract_ref(query)
        if ref:
            return "verse-backlog.txt", f"verse: {ref}", verse_slug(ref)
    if content_type == "Bible Verses About":
        theme = extract_theme(query)
        if theme:
            return "verse-backlog.txt", f"topic: {theme}", topic_slug(theme)
    return None, None, None  # Prayer / Other -> review-only


# ------------------------------------------------------------------- outputs
def emit(opps: list, source_label: str, append: bool = False):
    """opps: list of dicts with keys query, content_type, score (+ optional
    impressions/avg_position/signal). Writes gsc-suggestions.md; if append=True,
    also appends deduped lines under a dated block in the right backlog file."""
    existing = load_existing_slugs()
    existing_verse_keys = load_existing_verse_keys(existing)
    seen = set()
    verse_lines, comp_lines, review = [], [], []

    for o in opps:
        target, line, slug = route(o["query"], o["content_type"])
        if slug and (slug in existing or slug in seen):
            continue
        # reference-level dedup for verses (handles inconsistent legacy slugs)
        if target == "verse-backlog.txt" and line.startswith("verse:"):
            vk = _verse_key(slug)
            if vk and (vk in existing_verse_keys or vk in seen):
                continue
            if vk:
                seen.add(vk)
        row = dict(o)
        if target is None:
            review.append(row)
            continue
        seen.add(slug)
        row.update(target=target, line=line, slug=slug)
        (verse_lines if target == "verse-backlog.txt" else comp_lines).append(row)

    _write_report(verse_lines, comp_lines, review, source_label)

    if append:
        stamp = f"\n# --- added {date.today().isoformat()} from {source_label} ---\n"
        if verse_lines:
            with open(VERSE_BACKLOG, "a", encoding="utf-8") as f:
                f.write(stamp + "\n".join(r["line"] for r in verse_lines) + "\n")
        if comp_lines:
            with open(COMPARISON_BACKLOG, "a", encoding="utf-8") as f:
                f.write(stamp + "\n".join(r["line"] for r in comp_lines) + "\n")

    return {"verse": verse_lines, "comparison": comp_lines, "review": review}


def _metric(r):
    if r.get("impressions") is not None:
        return f"impr {r['impressions']}, pos {r.get('avg_position','?')}"
    if r.get("signal") is not None:
        return f"signal {r['signal']}"
    return f"score {r.get('score','?')}"


def _write_report(verse_lines, comp_lines, review, source_label):
    L = [
        f"# Topic suggestions — {date.today().isoformat()} ({source_label})",
        "Deduped against done_topics.txt + current backlogs. "
        "Paste the lines below into the matching backlog (top = highest priority), "
        "or re-run with --append to add them automatically.",
        "",
        f"## verse-backlog.txt  ({len(verse_lines)})",
        "```",
        *([r["line"] for r in verse_lines] or ["(none)"]),
        "```",
        "",
        f"## comparison-backlog.txt  ({len(comp_lines)})",
        "```",
        *([r["line"] for r in comp_lines] or ["(none)"]),
        "```",
        "",
        f"## Needs a home — no matching backlog ({len(review)})",
        "_Prayer/other intents. Add a prayer backlog or place manually._",
        "",
        "| Topic | Type | Demand |",
        "|-------|------|--------|",
        *([f"| {r['query']} | {r['content_type']} | {_metric(r)} |" for r in review]
          or ["| (none) | | |"]),
    ]
    with open(SUGGESTIONS_MD, "w", encoding="utf-8") as f:
        f.write("\n".join(L))

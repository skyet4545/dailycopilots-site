#!/usr/bin/env python3
"""
topic_expander.py — Discover NET-NEW topics Search Console can't show, using
Google Autocomplete (no API approval). Outputs into your real backlog files via
backlog_io.py, deduped against done_topics.txt + current backlogs.

GSC only reveals queries you already get impressions for; this finds demand on
topics you've never published. Standard library only.

  python3 topic_expander.py            # write gsc-suggestions.md (review only)
  python3 topic_expander.py --append   # also append deduped lines to backlogs

No exact search volume (autocomplete has none). Ranking uses a recurrence
signal: how many probes surfaced each phrase. If you ever get Google Ads API
access, fill real volume in attach_keyword_planner_volume().
"""
from __future__ import annotations

import json
import os
import re
import sys
import time
import urllib.parse
import urllib.request
from collections import Counter

import backlog_io

HERE = os.path.dirname(os.path.abspath(__file__))
SEED_FILE = os.path.join(HERE, "seed_terms.txt")

DEFAULT_SEEDS = [
    "bible verses about", "bible verses for", "what does", "prayer for",
    "how to pray", "meaning of", "psalm", "how to forgive",
]
ALPHA = list("abcdefghijklmnopqrstuvwxyz")
QUESTION_MODS = ["what", "why", "how", "when", "who", "for", "about", "meaning"]

MAX_TOPICS = 40
REQUEST_PAUSE = 0.4
AUTOCOMPLETE = "https://suggestqueries.google.com/complete/search"
UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) topic-expander/1.0"


def content_type(q: str) -> str:
    ql = q.lower()
    if re.search(r"\bwhat does\b.*\bmean\b", ql) or "meaning of" in ql:
        return "Verse Meaning"
    if re.search(r"\bbible verses?\b.*\b(for|about|on)\b", ql):
        return "Bible Verses About"
    if re.search(r"\b(pray|prayer)\b", ql):
        return "Prayer"
    return "Other"


def load_seeds():
    if os.path.exists(SEED_FILE):
        with open(SEED_FILE, encoding="utf-8") as f:
            seeds = [ln.strip() for ln in f if ln.strip() and not ln.startswith("#")]
        if seeds:
            return seeds
    return DEFAULT_SEEDS


def autocomplete(term: str):
    params = urllib.parse.urlencode({"client": "firefox", "q": term})
    req = urllib.request.Request(f"{AUTOCOMPLETE}?{params}", headers={"User-Agent": UA})
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read().decode("utf-8", errors="replace"))
        return data[1] if isinstance(data, list) and len(data) > 1 else []
    except Exception:
        return []


def expand_seed(seed: str) -> Counter:
    counts = Counter()
    probes = [seed] + [f"{seed} {m}" for m in QUESTION_MODS] + [f"{seed} {c}" for c in ALPHA]
    for probe in probes:
        for sug in autocomplete(probe):
            s = sug.strip().lower()
            if len(s) >= 12 and s != seed.lower():
                counts[s] += 1
        time.sleep(REQUEST_PAUSE)
    return counts


def attach_keyword_planner_volume(opps):
    """NO-OP. With Google Ads API access, set o['score'] = real volume here."""
    return opps


def build_opps():
    counts = Counter()
    for seed in load_seeds():
        counts.update(expand_seed(seed))
    opps = [
        {"query": phrase, "content_type": content_type(phrase),
         "type": "new", "signal": signal, "score": float(signal)}
        for phrase, signal in counts.items()
    ]
    opps = attach_keyword_planner_volume(opps)
    opps.sort(key=lambda o: o["score"], reverse=True)
    return opps[:MAX_TOPICS]


def main():
    append = "--append" in sys.argv
    opps = build_opps()
    out = backlog_io.emit(opps, source_label="autocomplete", append=append)
    print(
        f"{len(opps)} ideas -> {len(out['verse'])} verse, "
        f"{len(out['comparison'])} comparison, {len(out['review'])} need-a-home. "
        "See gsc-suggestions.md."
        + (" Backlogs updated." if append else " (review only; add --append to write)")
    )


if __name__ == "__main__":
    main()

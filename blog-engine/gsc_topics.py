#!/usr/bin/env python3
"""
gsc_topics.py — Mine Google Search Console for real demand and turn it into
backlog lines the existing blog engine already understands.

Replaces Ahrefs' keyword volume/difficulty with your OWN search data (more
accurate for a site you run, $0). Output goes into your normal backlog files
via backlog_io.py, deduped against done_topics.txt + current backlogs.

  python3 gsc_topics.py            # write gsc-suggestions.md (review, no changes)
  python3 gsc_topics.py --append   # also append deduped lines to the backlogs

Auth: OAuth "installed app" (same client_secret.json style as your YouTube
tools). First run opens a browser once; then gsc_token.json refreshes silently.
Scope: https://www.googleapis.com/auth/webmasters.readonly
"""
from __future__ import annotations

import os
import sys
from datetime import date, timedelta

from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from googleapiclient.discovery import build

import backlog_io

# ------------------------------------------------------------------- CONFIG
SITE_URL = "sc-domain:mybiblecopilot.com"   # <-- confirm in Search Console (sc-domain: or https://)
LOOKBACK_DAYS = 90

HERE = os.path.dirname(os.path.abspath(__file__))
CLIENT_SECRET = os.path.join(HERE, "client_secret.json")
TOKEN_PATH = os.path.join(HERE, "gsc_token.json")

STRIKING_MIN_POS = 8.0      # positions 8..20 = almost page one -> optimize
STRIKING_MAX_POS = 20.0
NEW_MIN_POS = 20.0          # worse than this + real demand = new-article gap
MIN_IMPRESSIONS = 30
MAX_TOPICS = 40

SCOPES = ["https://www.googleapis.com/auth/webmasters.readonly"]


def get_service():
    creds = None
    if os.path.exists(TOKEN_PATH):
        creds = Credentials.from_authorized_user_file(TOKEN_PATH, SCOPES)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            if not os.path.exists(CLIENT_SECRET):
                sys.exit(f"Missing {CLIENT_SECRET} (OAuth 'Desktop app' client JSON).")
            creds = InstalledAppFlow.from_client_secrets_file(CLIENT_SECRET, SCOPES).run_local_server(port=0)
        with open(TOKEN_PATH, "w") as f:
            f.write(creds.to_json())
    return build("searchconsole", "v1", credentials=creds, cache_discovery=False)


def fetch_rows(service, dimensions, days=LOOKBACK_DAYS, row_limit=25000):
    end = date.today() - timedelta(days=1)
    start = end - timedelta(days=days)
    body = {
        "startDate": start.isoformat(),
        "endDate": end.isoformat(),
        "dimensions": dimensions,
        "rowLimit": row_limit,
        "dataState": "all",
    }
    return service.searchanalytics().query(siteUrl=SITE_URL, body=body).execute().get("rows", [])


def content_type(q: str) -> str:
    import re
    ql = q.lower()
    if re.search(r"\bwhat does\b.*\bmean\b", ql) or "meaning of" in ql:
        return "Verse Meaning"
    if re.search(r"\bbible verses?\b.*\b(for|about|on)\b", ql):
        return "Bible Verses About"
    if re.search(r"\b(pray|prayer)\b", ql):
        return "Prayer"
    return "Other"


def score(impressions, position, kind):
    if kind == "optimize":
        proximity = max(0.0, STRIKING_MAX_POS - position) / STRIKING_MAX_POS
        return round(impressions * (1 + proximity), 1)
    return round(impressions * 1.0, 1)


def build_opps(query_rows):
    opps = []
    for r in query_rows:
        q = r["keys"][0].strip()
        impr = r.get("impressions", 0)
        pos = r.get("position", 100.0)
        if impr < MIN_IMPRESSIONS:
            continue
        if STRIKING_MIN_POS <= pos <= STRIKING_MAX_POS:
            kind = "optimize"
        elif pos > NEW_MIN_POS:
            kind = "new"
        else:
            continue  # already top-8, leave it
        opps.append({
            "query": q,
            "content_type": content_type(q),
            "type": kind,
            "impressions": int(impr),
            "avg_position": round(pos, 1),
            "score": score(impr, pos, kind),
        })
    opps.sort(key=lambda o: o["score"], reverse=True)
    return opps[:MAX_TOPICS]


def main():
    append = "--append" in sys.argv
    service = get_service()
    opps = build_opps(fetch_rows(service, ["query"]))
    out = backlog_io.emit(opps, source_label="Search Console", append=append)
    print(
        f"{len(opps)} opportunities -> "
        f"{len(out['verse'])} verse, {len(out['comparison'])} comparison, "
        f"{len(out['review'])} need-a-home. See gsc-suggestions.md."
        + (" Backlogs updated." if append else " (review only; add --append to write)")
    )


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Pull authoritative subscription data from App Store Connect Sales & Trends API.
- SUBSCRIPTION (snapshot): active paid vs free-trial subscribers, latest available day.
- SUBSCRIPTION_EVENT (last ~45 days): tally Subscribe / trial conversions / Cancel / Refund.
Vendor 94000578. Reports are gzipped TSV; data lags ~1-2 days.
"""
import sys, time, gzip, io, datetime as dt, collections
import jwt, requests

KEY_ID, ISSUER = "5H55WHSQ43", "f8f1ba17-71d9-470b-ae33-869d77e42635"
KEY_PATH = "/Users/carlosreyes/.appstoreconnect/private_keys/AuthKey_5H55WHSQ43.p8"
VENDOR = "94000578"
API = "https://api.appstoreconnect.apple.com/v1/salesReports"

def token():
    with open(KEY_PATH) as f: key = f.read()
    return jwt.encode({"iss": ISSUER, "iat": int(time.time()), "exp": int(time.time())+1200,
                       "aud": "appstoreconnect-v1"}, key, algorithm="ES256",
                      headers={"kid": KEY_ID})

def fetch(h, report_type, report_date, version, sub="SUMMARY", freq="DAILY"):
    p = {"filter[frequency]": freq, "filter[reportType]": report_type,
         "filter[reportSubType]": sub, "filter[vendorNumber]": VENDOR,
         "filter[version]": version, "filter[reportDate]": report_date}
    r = requests.get(API, headers={**h, "Accept": "application/a-gzip"}, params=p)
    if r.status_code != 200:
        return None
    try:
        txt = gzip.GzipFile(fileobj=io.BytesIO(r.content)).read().decode("utf-8", "replace")
    except OSError:
        return None
    lines = txt.splitlines()
    if len(lines) < 2: return None
    hdr = lines[0].split("\t")
    return [dict(zip(hdr, ln.split("\t"))) for ln in lines[1:]]

def main():
    h = {"Authorization": f"Bearer {token()}"}
    today = dt.date(2026, 6, 30)

    # ---- 1) latest SUBSCRIPTION snapshot (try back a few days) ----
    print("=== ACTIVE SUBSCRIPTIONS (snapshot) ===")
    snap = None
    for back in range(1, 8):
        d = (today - dt.timedelta(days=back)).isoformat()
        snap = fetch(h, "SUBSCRIPTION", d, "1_4")
        if snap:
            print(f"(report date {d})")
            break
    if snap:
        active = collections.Counter()
        for row in snap:
            name = row.get("Subscription Name") or row.get("App Name", "?")
            state = row.get("Subscription Status") or row.get("Standard Subscription") or "?"
            qty = int(row.get("Active Standard Price Subscriptions", row.get("Quantity", "0")) or 0)
            free = int(row.get("Active Free Trial Introductory Offer Subscriptions", "0") or 0)
            promo = int(row.get("Active Pay As You Go Introductory Offer Subscriptions", "0") or 0)
            print(f"  {name[:40]:40} paid={qty} free_trial={free}")
    else:
        print("  no snapshot available")

    # ---- 2) SUBSCRIPTION_EVENT tally over last 45 days ----
    print("\n=== SUBSCRIPTION EVENTS (last 45 days) ===")
    ev = collections.Counter()
    days_with_data = 0
    for back in range(1, 46):
        d = (today - dt.timedelta(days=back)).isoformat()
        rows = fetch(h, "SUBSCRIPTION_EVENT", d, "1_4")
        if not rows: continue
        days_with_data += 1
        for row in rows:
            e = row.get("Event", "?")
            q = int(row.get("Quantity", "1") or 1)
            ev[e] += q
    if ev:
        print(f"(aggregated over {days_with_data} days with data)")
        for e, q in ev.most_common():
            print(f"  {e:42} {q}")
    else:
        print("  no event data in window")

if __name__ == "__main__":
    main()

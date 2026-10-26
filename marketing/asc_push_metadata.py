#!/usr/bin/env python3
"""
Push optimized Bible Copilot metadata to App Store Connect.

Subtitle  -> appInfoLocalizations  (with appInfo in EDITABLE state)
Keywords  -> appStoreVersionLocalizations (with an editable appStoreVersion)
Promo     -> appStoreVersionLocalizations (editable anytime, even live)

Default = READ-ONLY (prints current values + editable state). Pass --apply to write.
Requires: pip install pyjwt cryptography requests
"""
import sys, time, json
try:
    import jwt, requests
except ImportError:
    sys.exit("Missing deps. Run: pip install pyjwt cryptography requests")

# --- credentials (from memory: bible-copilot-current-state) ---
KEY_ID   = "5H55WHSQ43"
ISSUER   = "f8f1ba17-71d9-470b-ae33-869d77e42635"
KEY_PATH = "/Users/carlosreyes/.appstoreconnect/private_keys/AuthKey_5H55WHSQ43.p8"
APP_ID   = "6758913373"
LOCALE   = "en-US"

# --- optimized values to push (2026-06-30) ---
NEW = {
    "subtitle":        "Verse Meaning & Bible Answers",
    "keywords":        "scripture,devotional,kjv,gospel,jesus,christian,chat,gpt,commentary,daily,reading,plan,prayer,niv",
    "promotionalText": "Ask any Bible verse and get a clear, Scripture-cited answer in seconds. Six study modes, cross-references, and reading plans. Start your 7-day free trial.",
}
LIMITS = {"subtitle": 30, "keywords": 100, "promotionalText": 170}

API = "https://api.appstoreconnect.apple.com/v1"
EDITABLE = {"PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED", "REJECTED",
            "METADATA_REJECTED", "INVALID_BINARY", "WAITING_FOR_REVIEW"}

def token():
    with open(KEY_PATH) as f: key = f.read()
    payload = {"iss": ISSUER, "iat": int(time.time()), "exp": int(time.time())+1200,
               "aud": "appstoreconnect-v1"}
    return jwt.encode(payload, key, algorithm="ES256", headers={"kid": KEY_ID})

def main():
    apply = "--apply" in sys.argv
    for k, v in NEW.items():
        if len(v) > LIMITS[k]:
            sys.exit(f"!! {k} is {len(v)} chars (max {LIMITS[k]}): {v}")
        print(f"  {k:16} {len(v):>3}/{LIMITS[k]}  {v}")
    print()
    h = {"Authorization": f"Bearer {token()}", "Content-Type": "application/json"}

    # 1) editable appStoreVersion + its localization (keywords/promo)
    vers = requests.get(f"{API}/apps/{APP_ID}/appStoreVersions",
                        headers=h, params={"limit": 5}).json()["data"]
    ev = next((v for v in vers if v["attributes"]["appStoreState"] in EDITABLE), None)
    if ev:
        st = ev["attributes"]["appStoreState"]
        vl = requests.get(f"{API}/appStoreVersions/{ev['id']}/appStoreVersionLocalizations",
                          headers=h).json()["data"]
        loc = next(l for l in vl if l["attributes"]["locale"] == LOCALE)
        a = loc["attributes"]
        print(f"Editable version {ev['attributes']['versionString']} ({st}) loc={loc['id']}")
        print(f"  current keywords: {a.get('keywords')}")
        print(f"  current promo   : {a.get('promotionalText')}")
        if apply:
            r = requests.patch(f"{API}/appStoreVersionLocalizations/{loc['id']}", headers=h,
                json={"data": {"type": "appStoreVersionLocalizations", "id": loc["id"],
                    "attributes": {"keywords": NEW["keywords"],
                                   "promotionalText": NEW["promotionalText"]}}})
            print("  PATCH version loc:", r.status_code, "" if r.ok else r.text[:300])
    else:
        print("No editable appStoreVersion. Create the v2.x version first, then re-run "
              "to push keywords. (Promo text is editable on the live version too.)")

    # 2) appInfo subtitle
    ai = requests.get(f"{API}/apps/{APP_ID}/appInfos", headers=h).json()["data"]
    aie = next((x for x in ai if x["attributes"].get("appStoreState") in EDITABLE), ai[0])
    ail = requests.get(f"{API}/appInfos/{aie['id']}/appInfoLocalizations",
                       headers=h).json()["data"]
    sloc = next(l for l in ail if l["attributes"]["locale"] == LOCALE)
    print(f"\nappInfo {aie['id']} ({aie['attributes'].get('appStoreState')}) loc={sloc['id']}")
    print(f"  current subtitle: {sloc['attributes'].get('subtitle')}")
    if apply:
        r = requests.patch(f"{API}/appInfoLocalizations/{sloc['id']}", headers=h,
            json={"data": {"type": "appInfoLocalizations", "id": sloc["id"],
                "attributes": {"subtitle": NEW["subtitle"]}}})
        print("  PATCH subtitle:", r.status_code, "" if r.ok else r.text[:300])

    print("\n" + ("APPLIED." if apply else "READ-ONLY. Re-run with --apply to write."))

if __name__ == "__main__":
    main()

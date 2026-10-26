# Bible Copilot — Agent Rules

Flagship of the Copilot constellation. iOS app + Rust backend. Read `~/.claude/CLAUDE.md` first.

## Architecture

- iOS: SwiftUI + StoreKit 2, iOS 17+, xcodegen-managed
- Bundle ID: `com.scripturecopilot.app` · Dev Team: `846N5D6TMK`
- Backend: Rust on Vercel — `scripture-copilot-rust.vercel.app/api/chat`, SSE streaming, OpenAI `gpt-4o-mini`
- Bible text source: `bible-api.com`
- Supabase project: `hfxaltbdagvwtrkfipqi` — **shared with PrayerCopilot, ConstitutionCopilot, QuranCopilot, TorahCopilot, GitaCopilot, WisdomCopilot, StoicCopilot**

## Rules

### IMPORTANT — Reconcile the version triple-drift before any release work

Three sources of truth currently disagree:

| File | Value | Status |
|---|---|---|
| `project.yml` | `1.7.1` / `111` | stale |
| Latest commits (App Store) | `1.9.0` / `119` | TRUE |
| Legacy `package.json` | `1.5.0` | dead weight (Expo era) |

**YOU MUST reconcile to `1.9.0` / `119` in `project.yml` before tagging any new release.** Going forward, `project.yml` is the single source of truth — ignore `package.json`. Consider deleting it once nothing references it.

### Shared Supabase project — filter by `app_identifier`

- The Supabase project is shared with seven sibling apps. **YOU MUST filter every query and policy by `app_identifier = 'bible_copilot'`.** A missing filter leaks Prayer Copilot rows into Bible Copilot or vice versa.
- Migrations touching shared tables (`profiles`, `subscriptions`, `usage_events`, etc.) MUST be reviewed against all sibling apps before applying — coordinate via the constellation channel.

### StoreKit 2 only — no RevenueCat

- Migrated off RevenueCat in 2026-Q1. **Do not add `RevenueCat` imports, SDK calls, or paywall config anywhere.** Product IDs live in `Models/Subscriptions.swift`.
- Pricing: free tier = 3 questions/day; Pro = $9.99/mo OR $49.99/yr (user-confirmed 2026-07-27; older pricing is stale).

### Onboarding paywall — do not regress

- v1.9.0 onboarding is the converted flow. **YOU MUST test the paywall on a real device** (StoreKit 2 sandbox does not catch every regression) before any commit that touches `Views/Onboarding/` or `Views/Paywall/`.

### Version-of-record

See global rules. tl;dr: bump `project.yml`, run `xcodegen generate`, commit both. Never hand-edit `project.pbxproj`.

## Commands

```bash
xcodegen generate
xcodebuild -project BibleCopilot.xcodeproj -scheme BibleCopilot build
# Backend (Rust):
cd backend && vercel --prod
```

## Out of scope

- Sibling Copilot apps' system prompts and paywall variants — those live in each sibling repo.
- Companion programmatic-SEO sites (PrayerCopilot has its own; Bible Copilot does not).
- TurnoutOS / FrontDesk backends and any non-`bible_copilot` rows in the shared Supabase project.

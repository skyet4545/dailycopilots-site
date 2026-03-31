# Shared Auth Template — Copilot Apps

## Overview
All 6 Copilot apps share a single Supabase project for auth and sync.
Each app must customize the files below with its own `appId` and `bundleId`.

## Shared Supabase Credentials
```
URL:  https://hfxaltbdagvwtrkfipqi.supabase.co
Key:  eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmeGFsdGJkYWd2d3Rya2ZpcHFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ5NTk3MDMsImV4cCI6MjA5MDUzNTcwM30.59YQXCrNjHP9_smQUw24NbQJZND17wcam6ggKxd_uCg
```

## Per-App Values

| App | appId | bundleId |
|-----|-------|----------|
| Bible Copilot | `bible_copilot` | `com.scripturecopilot.app` |
| Quran Copilot | `quran_copilot` | `com.carlosreyes.quran-copilot` |
| Gita Copilot | `gita_copilot` | `com.carlosreyes.gita-copilot` |
| Torah Copilot | `torah_copilot` | `com.carlosreyes.torah-copilot` |
| Wisdom Copilot | `wisdom_copilot` | `com.carlosreyes.wisdom-copilot` |
| Constitution Copilot | `constitution_copilot` | `com.carlosreyes.constitution-copilot` |

## Files to Add (4 files per app)

1. **KeychainService.swift** — Change `service` to the app's bundle ID
2. **AuthService.swift** — Change `supabaseURL`, `supabaseKey`, and `appId`
3. **SyncService.swift** — Uses `app_id` filter on all queries; table names: `saved_items`, `journal_entries`, `reading_plan_progress`
4. **StreakService.swift** — Copy as-is (local only, no customization needed)

## Key Differences from Bible Copilot's Current Implementation
- Uses shared Supabase project URL/key (not Bible Copilot's own project)
- All tables include `app_id` column — must filter by app's `appId` on every query
- Table is `saved_items` (not `saved_passages`)
- Profile upsert includes `app_id` with unique constraint on `(id, app_id)`

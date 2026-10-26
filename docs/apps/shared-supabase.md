# Shared Supabase Project — Copilot Apps

All Copilot apps share a single Supabase project for auth and data sync.

## Project Details
- **Project ID:** hfxaltbdagvwtrkfipqi
- **Org:** Quran + Gita (free tier)
- **Region:** us-east-1
- **URL:** https://hfxaltbdagvwtrkfipqi.supabase.co
- **Anon Key:** eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmeGFsdGJkYWd2d3Rya2ZpcHFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ5NTk3MDMsImV4cCI6MjA5MDUzNTcwM30.59YQXCrNjHP9_smQUw24NbQJZND17wcam6ggKxd_uCg

## Database Schema

### Enum: app_identifier
`bible_copilot`, `quran_copilot`, `gita_copilot`, `torah_copilot`, `wisdom_copilot`, `constitution_copilot`

### Table: profiles
| Column | Type | Notes |
|--------|------|-------|
| id | UUID (PK) | References auth.users |
| app_id | app_identifier | Which app this profile belongs to |
| display_name | TEXT | |
| email | TEXT | |
| is_pro | BOOLEAN | Default false |
| streak_current | INTEGER | Default 0 |
| streak_longest | INTEGER | Default 0 |
| total_studies | INTEGER | Default 0 |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

Unique constraint on (id, app_id) — one profile per user per app.

### Table: saved_items
| Column | Type | Notes |
|--------|------|-------|
| id | UUID (PK) | Auto-generated |
| user_id | UUID | References auth.users |
| app_id | app_identifier | |
| reference | TEXT | e.g. "John 3:16" |
| text | TEXT | Full passage text |
| translation | TEXT | Default 'default' |
| notes | TEXT | User notes |
| saved_at | TIMESTAMPTZ | |

### Table: journal_entries
| Column | Type | Notes |
|--------|------|-------|
| id | UUID (PK) | Auto-generated |
| user_id | UUID | References auth.users |
| app_id | app_identifier | |
| reference | TEXT | Passage studied |
| mode | TEXT | Study mode used |
| response | TEXT | AI response |
| reflection | TEXT | User reflection |
| created_at | TIMESTAMPTZ | |

### Table: reading_plan_progress
| Column | Type | Notes |
|--------|------|-------|
| id | UUID (PK) | Auto-generated |
| user_id | UUID | References auth.users |
| app_id | app_identifier | |
| plan_id | TEXT | Plan identifier |
| completed_days | INTEGER[] | Array of completed day numbers |
| started_at | TIMESTAMPTZ | |
| last_read_at | TIMESTAMPTZ | |

Unique constraint on (user_id, app_id, plan_id).

## Security
- RLS enabled on all tables
- Users can only read/write their own data (filtered by auth.uid())
- Anon key is safe to embed in apps (RLS enforces access)

## Auth Providers
- Apple Sign In
- Email/Password

## Apps Using This Project
1. Bible Copilot (bible_copilot)
2. Quran Copilot (quran_copilot)
3. Gita Copilot (gita_copilot)
4. Torah Copilot (torah_copilot)
5. Wisdom Copilot (wisdom_copilot)
6. Constitution Copilot (constitution_copilot)

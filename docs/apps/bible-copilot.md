# Bible Copilot

## App Store
- **App Name:** Bible Copilot
- **App Store ID:** 6758913373
- **Bundle ID:** com.scripturecopilot.app
- **Version:** 1.7.0 (build 109)

## Subscriptions
- **Group:** Bible Copilot Pro (bible_copilot_pro)
- **Monthly:** biblecopilot_pro_monthly — $9.99/mo
- **Annual:** biblecopilot_pro_annual — $49.99/yr (1-week free trial) [verified in ASC 2026-07-04]
- **Payment:** Native StoreKit 2 (no RevenueCat)

## Backend
- **AI Endpoint:** https://scripture-copilot-rust.vercel.app/api/chat
- **Stack:** Rust on Vercel (streaming SSE)
- **Supabase URL:** https://fseqgcebvxiqmzngxhre.supabase.co
- **Supabase Features:** Auth (Apple ID + email/password), profile sync, studies tracking, streaks

## Signing
- **Team ID:** 846N5D6TMK
- **Deployment Target:** iOS 15.0
- **Swift:** 5.0 / Xcode 15

## Free Tier
- 3 questions/day

## Links
- **Privacy:** (hosted on main site)
- **Terms:** (hosted on main site)

## Icon
Dark navy background with white compass circle and golden directional star.

## Study Modes
- Devotional, Historical, Cross-References, Greek/Hebrew, Life Application

## Notes
- This is the flagship app — uses Supabase for auth/sync unlike the Tier 1 apps.
- Has both a legacy React Native version (root package.json) and current native Swift version (BibleCopilot/).
- The native Swift version is the active one (v1.7.0).

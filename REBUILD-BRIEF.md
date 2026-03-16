# Bible Copilot — Rebuild Brief
## App Store Rejection Fix — Build from scratch

### Context
- App was rejected twice (guideline 2.1b)
- App ID: 6758913373
- Bundle ID: com.scripturecopilot.app
- Stack: React Native / Expo
- Original source code is GONE — rebuild from documentation

### The 2 Bugs Apple Found

**Bug 1 (CRITICAL): Error after 5 questions instead of paywall**
When the free question limit is reached, the app shows an ERROR MESSAGE instead of the subscription paywall. Fix: show paywall, never an error.

**Bug 2: IAP not findable**  
Apple reviewer can't find the IAP. Product IDs must match EXACTLY:
- Monthly: `Bible Copilot Pro` (product reference name)
- Annual: `Bible Copilot Pro (Annual)` (product reference name)

The actual StoreKit product IDs in App Store Connect are:
- `bible_copilot_pro_monthly` (confirmed in docs)
- `bible_copilot_pro_annual` (confirmed in docs)

But also check these alt IDs from older docs:
- `com.scripturecopilot.app.pro.monthly`
- `com.scripturecopilot.app.pro.yearly`

### App Architecture (from docs)

**Tech Stack:**
- React Native / Expo (react-native + expo)
- Navigation: React Navigation (bottom tabs)
- State: React hooks + AsyncStorage
- AI: OpenAI API (gpt-4o-mini) via serverless backend at https://scripture-copilot-rust.vercel.app/api/chat
- Bible API: bible-api.com (free)
- Subscriptions: RevenueCat SDK (react-native-purchases)
- Build: EAS Build

**Key Files to Build:**
- `App.tsx` — Main app (2800+ lines based on docs)
- `src/constants/themes.ts` — Single "Cool Blue" dark theme
- `src/constants/theme.ts` — Colors, study categories, translations
- `src/hooks/useTheme.ts` — Theme hook with safety checks
- `src/hooks/useStorage.ts` — AsyncStorage hooks
- `src/services/SubscriptionService.ts` — RevenueCat wrapper
- `src/services/UsageTracker.ts` — 10 questions/day limit
- `app.json` — Expo config

### Design Spec (LOCKED)

**Color Scheme:**
- Background: #000 → #0a1628 (dark navy)
- Surface: rgba(255,255,255,0.04-0.08)
- Accent: #60A5FA (blue)
- Gold: #FBBF24 / #D4AF37
- Text Primary: #FFFFFF
- Text Secondary: #E8E8E8
- Text Muted: #8E8E93

**Study Mode Colors:**
- Observe: #60A5FA (Blue) 
- Interpret: #A78BFA (Purple)
- Theology: #34D399 (Green)
- Apply: #F87171 (Red)
- Apologetics: #FBBF24 (Gold)

**5 Bottom Tabs:**
1. 🏠 Home
2. 📅 Plans (Reading Plans)
3. 📓 Journal
4. 🔖 Saved
5. ⚙️ Settings

### App Flow

**Home Screen:**
- Compass icon (48px) or open book icon
- "Bible Copilot" title
- "Your AI Bible study companion" subtitle
- Search input: "Enter any verse..." with 📖 icon
- Quick picks: John 3:16, Psalm 23, Rom 8:28, Phil 4:13
- Section: "HOW DO YOU WANT TO STUDY?"
- 2x2 grid: Observe, Interpret, Theology, Apply
- Full-width: Apologetics

**Study Screen (after searching a verse):**
- Usage counter at top: "X/10 free questions today"
- Verse reference in gold
- Verse text in italic serif
- 5 study mode pills (horizontally scrollable)
- AI response streaming
- Cross-references section

**Onboarding (5 screens, shown on first launch):**
1. Welcome
2. Not Just Any AI
3. The Method Matters
4. Go Deep
5. Ready to Study

**Paywall:**
- Triggers when free user tries to ask 11th question
- NEVER shows an error — always shows paywall
- Shows: Unlimited Questions, Study Journal, All Translations, Reading Plans
- Annual: $39.99/year (SAVE 33% highlighted)
- Monthly: $4.99/month
- CTA: "Continue" (not "Subscribe" or "Start Pro Now")
- Below CTA: "No commitment, cancel anytime"
- Restore Purchases link
- RevenueCat SDK handles the actual purchase

### RevenueCat Setup
- iOS API Key: `test_OfksHksIrBKMKBXrIjITRRPywKX` (TEST key — will need live key from Carlos)
- Entitlement ID: `pro`
- Offering: `default`

### Free Tier
- 10 questions/day
- Tracked in AsyncStorage
- Resets at midnight each day
- Counter displayed: "X/10 free questions today"
- 11th question → show paywall, NEVER an error

### Critical Fix Requirements
1. `handleQuestionSubmit` (or equivalent): check usage BEFORE making API call
2. If limit reached → `setShowPaywall(true)` — NOT `setError('...')` 
3. StoreKit product IDs must be defined as constants and used everywhere
4. PaywallScreen must call `Purchases.purchasePackage()` or `Purchases.purchaseProduct()`
5. Pro status check: `SubscriptionService.isPro()` using RevenueCat

### App Info
- Bundle ID: com.scripturecopilot.app
- Version: 1.5.0
- Build number: auto-increment
- Display Name: Bible Copilot
- Privacy Policy: https://bible-copilot-app.netlify.app/privacy.html
- Support URL: https://bible-copilot-app.netlify.app/
- Backend API: https://scripture-copilot-rust.vercel.app/api/chat

### Build Commands
```bash
# Install deps
npm install

# Local dev
npx expo start

# Production build
npx eas build --platform ios --local --profile production --non-interactive

# Submit to TestFlight
npx eas submit --platform ios --path ./build-*.ipa --non-interactive
```

### EAS Config (eas.json)
```json
{
  "cli": { "version": ">= 7.0.0" },
  "build": {
    "production": {
      "ios": {
        "resourceClass": "m-medium",
        "distribution": "store",
        "autoIncrement": true
      }
    }
  },
  "submit": {
    "production": {}
  }
}
```

### app.json key fields
```json
{
  "expo": {
    "name": "Bible Copilot",
    "slug": "scripture-copilot",
    "version": "1.5.0",
    "ios": {
      "bundleIdentifier": "com.scripturecopilot.app",
      "buildNumber": "60",
      "supportsTablet": true,
      "infoPlist": {
        "ITSAppUsesNonExemptEncryption": false
      }
    },
    "plugins": [
      ["expo-build-properties", {
        "ios": {
          "newArchEnabled": true
        }
      }]
    ]
  }
}
```

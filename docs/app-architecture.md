# 📄 scripture-copilot / docs/app-architecture.md

# Bible Copilot - App Architecture
**Last Updated:** 2026-02-13

---

## 📱 Tech Stack

### Frontend
- **Framework:** React Native (Expo)
- **Navigation:** React Navigation 7
- **State:** React hooks + AsyncStorage
- **UI:** Custom components (iOS-styled)

### Backend
- **API:** Direct OpenAI API calls
- **Streaming:** EventSource (react-native-sse)
- **Storage:** AsyncStorage (local-only)

### Build
- **iOS:** EAS Build (Expo Application Services)
- **Deployment:** TestFlight → App Store

---

## 🏗️ Project Structure

```
scripture-app/
├── App.tsx                 # Main app entry (2890 lines)
├── src/
│   ├── constants/
│   │   ├── themes.ts      # Theme system (single Cool Blue theme)
│   │   └── theme.ts       # Colors, categories, translations
│   └── hooks/
│       ├── useTheme.ts    # Theme hook (simplified)
│       └── useStorage.ts  # AsyncStorage hooks
├── ios/                    # iOS-specific files
├── app.json               # Expo config
└── eas.json               # EAS Build config
```

---

## 🎨 Features

### Core Functionality
1. **Bible Search** - ESV, NIV, NKJV, KJV translations
2. **4 Study Modes:**
   - 🔍 Observe - What does it say?
   - 📖 Interpret - What does it mean?
   - ⛪️ Theology - What does it teach about God?
   - ✨ Apply - How should this change my life?
3. **Saved Passages** - Bookmarking system
4. **Settings** - Translation selection, appearance

### Free vs Pro
- **Free:** 15 questions/day, all 4 study modes
- **Pro:** Unlimited questions, advanced features

---

## 💾 Data Storage

### AsyncStorage Keys
```typescript
STORAGE_KEYS = {
  SAVED_PASSAGES: '@bible_copilot_saved_passages',
  SEARCH_HISTORY: '@bible_copilot_search_history',
  SETTINGS: '@bible_copilot_settings',
  DAILY_QUESTION_COUNT: '@bible_copilot_daily_questions',
  LAST_QUESTION_DATE: '@bible_copilot_last_question_date',
}
```

### Settings Schema
```typescript
interface Settings {
  translation: 'esv' | 'niv' | 'nkjv' | 'kjv';
  dailyVerseReminder: boolean;
  reminderTime?: string;
}
```

---

## 🔌 API Integration

### OpenAI Configuration
- **Model:** gpt-4o-mini (~$0.001/request)
- **Endpoint:** https://api.openai.com/v1/chat/completions
- **Streaming:** Yes (EventSource)
- **Context:** Reformed theology system prompt

### API Security
✅ **SECURE:**
- API key stored server-side only
- No client-side exposure
- All API calls go through backend
- No hardcoded keys in app code

---

## 🎨 Theme System

### Current Implementation (v1.3.1)
- **Single Theme:** Cool Blue (professional, trustworthy)
- **Colors:** Dark navy gradient with blue accents
- **Simplified:** Removed multi-theme system to fix crashes

### Theme Structure
```typescript
interface Theme {
  colors: {
    background: string;
    text: string;
    accent: string;
    surface: string;
    // ... 10 total colors
  }
}
```

---

## 📦 Build & Deployment

### Current Build
- **Version:** 1.3.1
- **Build:** 43 (latest)
- **Status:** Processing on TestFlight
- **Submission:** https://expo.dev/accounts/creyes111/projects/scripture-copilot/submissions/2c9acba9-2084-4cba-b202-6af0a847e4f7

### Build Command
```bash
cd scripture-app
npx eas build --platform ios --local --profile production --non-interactive
```

### Submit to TestFlight
```bash
npx eas submit --platform ios --path ./build-*.ipa --non-interactive
```

---

## 🐛 Known Issues & Fixes

### Build 41-42 Crashes (FIXED in Build 43)
**Problem:** App crashed on launch  
**Root Cause:** Settings interface had orphaned `themeId` field  
**Fix:** Removed themeId from Settings interface + simplified theme hook

### Migration Logic
```typescript
// Handles users upgrading from v1.2.0
if (!settings.themeId) {
  settings.themeId = 'blue'; // removed in v1.3.1
}
```

---

## 💰 Monetization

### Revenue Model
- **Free Tier:** 15 questions/day
- **Pro Tier:** $4.99/month or $39.99/year
- **Break-even:** 30 subscribers (~Month 2)
- **Target:** $2.5K/mo by Month 12

### Implementation (Planned)
- RevenueCat SDK for subscriptions
- Paywall after 15-question limit
- App Store IAP

See: [Monetization Strategy](../MONETIZATION-STRATEGY.md)

---

## 📊 Metrics & Analytics

### OpenAI Usage Tracking
**File:** `usage-tracker.json`
```json
{
  "openai_key_prefix": "sk-proj-g7a7...024AA",
  "last_alerted_dollar": 0,
  "checks": []
}
```

**Alert:** At each $1 spent

---

## 🚀 Launch Checklist

- [x] Build 43 crash fixes
- [x] Monetization strategy documented
- [x] App Store listing drafted
- [ ] Build 43 approved on TestFlight
- [ ] RevenueCat integration
- [ ] Paywall screen implemented
- [ ] App Store screenshots
- [ ] App Store submission
- [ ] Product Hunt launch

---

## 🔗 Related Docs

- [Build Process](build-process.md)
- [Monetization Strategy](../MONETIZATION-STRATEGY.md)
- [App Store Listing](../APP-STORE-DESCRIPTION.md)
- Security: Clean (no issues found in audit)


---


# 📄 scripture-copilot / scripture-app/SETUP-REVENUECAT-NOW.md

# Set Up Bible Copilot Pro — RevenueCat + App Store Connect
**Time required: ~30-45 min**

---

## STEP 1: Create RevenueCat Account (5 min)

1. Go to: https://app.revenuecat.com/signup
2. Sign up with your Apple ID email (carlos.reyesiii@gmail.com recommended)
3. Create a new project: **"Bible Copilot"**
4. Choose platform: **iOS**

---

## STEP 2: Create In-App Purchases in App Store Connect (15 min)

Go to: https://appstoreconnect.apple.com  
Navigate: **My Apps → Bible Copilot → Monetization → In-App Purchases**

### Create these 3 products:

**Product 1: Monthly**
- Type: Auto-Renewable Subscription
- Reference Name: `Bible Copilot Pro Monthly`
- Product ID: `com.scripturecopilot.app.pro.monthly`
- Subscription Group: Create new → "Bible Copilot Pro"
- Duration: 1 Month
- Price: **$4.99** (Tier 5)
- Localization: "Bible Copilot Pro" / "Unlimited questions, journal, reading plans"

**Product 2: Annual**
- Type: Auto-Renewable Subscription
- Reference Name: `Bible Copilot Pro Annual`
- Product ID: `com.scripturecopilot.app.pro.annual`
- Subscription Group: (same group — "Bible Copilot Pro")
- Duration: 1 Year
- Price: **$39.99** (Tier 40)
- Localization: "Bible Copilot Pro Annual" / "Best value — save 33%"

---

## STEP 3: Configure RevenueCat Dashboard (10 min)

### A) Connect App Store
1. RevenueCat → Project Settings → **Apps**
2. Click "+" → iOS App
3. App Name: `Bible Copilot`
4. Bundle ID: `com.scripturecopilot.app`
5. Connect to App Store Connect (follow prompts for API key)

### B) Create Entitlement
1. RevenueCat → **Entitlements** → Create
2. Identifier: `pro`
3. Display Name: `Pro`
4. Attach both products to this entitlement

### C) Create Offering
1. RevenueCat → **Offerings** → Create
2. Identifier: `default`
3. Display Name: `Default`
4. Create packages:
   - Package 1: Monthly ($4.99) → `$rc_monthly`
   - Package 2: Annual ($39.99) → `$rc_annual`

### D) Get Your iOS API Key
1. RevenueCat → Project Settings → **API Keys**
2. Copy the key that starts with `appl_`

---

## STEP 4: Add API Key to App (2 min)

Edit this file:
`projects/scripture-copilot/scripture-app/src/services/SubscriptionService.ts`

Find line 18:
```typescript
const REVENUECAT_API_KEY_IOS = 'appl_REPLACE_WITH_REAL_KEY';
```

Replace with your key:
```typescript
const REVENUECAT_API_KEY_IOS = 'appl_YOUR_ACTUAL_KEY_HERE';
```

**Message JARVIS with your API key and I'll update the file immediately.**

---

## STEP 5: Build + Test

After the API key is in:
1. JARVIS will kick off Build 71
2. Install on TestFlight
3. Use a sandbox test account to test purchase
4. Verify "Go Pro" → purchase flow → "Unlimited questions" status

---

## What's Already Done (No Action Needed)

- ✅ `react-native-purchases` SDK installed and linked
- ✅ `SubscriptionService.ts` — wraps all RevenueCat calls with safe guards
- ✅ `UsageTracker.ts` — 10 questions/day free tier enforced
- ✅ `PaywallScreen.tsx` — beautiful custom paywall UI
- ✅ `RevenueCatPaywall.tsx` — native RevenueCat paywall UI (fallback-safe)
- ✅ Onboarding pricing screen — shows Free vs Pro on first launch
- ✅ Study screen — shows usage counter + "Tap to upgrade"

---

## Revenue Projections (Conservative)

| Month | Downloads | Paid Subs | MRR |
|-------|-----------|-----------|-----|
| 1 | 500 | 12-15 | ~$65 |
| 3 | 1,500 | 50-60 | ~$270 |
| 6 | 3,000 | 100-120 | ~$560 |
| 12 | 8,000 | 260-300 | ~$1,400 |

Break-even: **30 subscribers** (~Month 2)

---

**When you have the API key, message JARVIS and it's live in the next build.**


---


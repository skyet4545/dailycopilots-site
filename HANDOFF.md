# Bible Copilot — Full Project Handoff
**Generated:** 2026-03-17  
**Purpose:** Complete context for any LLM to pick up and continue this project.

---

## What This App Is

**Bible Copilot** is a native iOS AI-powered Bible study companion.

Users search any Bible verse or ask any theological question. An AI responds with structured study insights using the Observation → Interpretation → Theology → Application methodology (Reformed theology, Scripture-first).

**Vision:** The Bible is the hero. AI is the copilot — a research assistant, not a replacement.

**App Store name:** Bible Copilot  
**Bundle ID:** `com.scripturecopilot.app`  
**App Store ID:** `6758913373`  
**Backend API:** `https://scripture-copilot-rust.vercel.app/api/chat`

---

## 🚨 URGENT — Why You're Reading This

The app has been **rejected twice by Apple** (Guideline 2.1b). Two bugs must be fixed before resubmission:

### Bug 1 — Error shown instead of paywall (CRITICAL)
**Apple sees:** After asking 5 questions, an ERROR MESSAGE appears.  
**Must happen:** When free question limit is reached → show the IAP paywall. NEVER an error.  
**Fix location:** `ChatView.swift` → `sendMessage()` function  
**Status:** The code already has the correct check (`checkAndIncrementQuestion()`) but the limit in `SubscriptionManager.swift` says `freeQuestionLimit = 10`. Apple's reviewer hit the limit at 5, which suggests an older build. The current SwiftUI build has the logic right — verify the limit is consistent and the paywall fires correctly.

### Bug 2 — IAP not findable in sandbox
**Apple sees:** Cannot find any In-App Purchases in the app.  
**Must happen:** StoreKit product IDs in code must match EXACTLY what's in App Store Connect.  
**Product IDs (confirmed):**
- Monthly: `bible_copilot_pro_monthly`
- Annual: `bible_copilot_pro_annual`  
**Fix:** Verify `SubscriptionManager.swift` uses exactly these IDs. Run sandbox test end-to-end.

### Also needed before resubmission
- [ ] Carlos must accept the **Paid Apps Agreement** in App Store Connect (Apple requirement)
- [ ] Build new binary and upload
- [ ] Full sandbox test: hit limit → paywall appears → sandbox purchase → unlimited unlocked

### App Store Connect
- App ID: `6758913373`
- Last submission: `a7e8911a-6d54-4c24-a068-e5d56caddf3d`
- Rejection guideline: 2.1(b)
- Test device Apple used: iPhone 17 Pro Max, iOS 26.3.1
- Already fixed (don't redo): Screenshots, Privacy Policy, Terms of Use

---

## Business Model

| Tier | Price | Limits |
|---|---|---|
| Free | $0 | 10 questions/day |
| Pro Monthly | $4.99/mo | Unlimited questions |
| Pro Annual | $39.99/yr | Unlimited questions (save 33%) |

**Unit economics:**
- Cost per AI call: ~$0.001 (GPT-4o-mini)
- Net per Pro subscriber: ~$3.46/mo (after Apple 30%)
- Break-even: ~30 subscribers

Subscriptions managed via **native StoreKit** (current SwiftUI build) — NOT RevenueCat (React Native era). The current SwiftUI build uses native `StoreKit 2` (`Product.products()`, `product.purchase()`).

---

## Two Codebases — Important

There are TWO versions of this app:

### Version A: React Native / Expo (LEGACY — do not use)
- Location: `~/Desktop/Projects/Apps/biblecopilot/App.tsx`, `src/`, `ios/`
- Stack: React Native, Expo, RevenueCat SDK, AsyncStorage
- Status: **Original source code considered gone/unreliable** per REBUILD-BRIEF.md
- Build: EAS Build (`npx eas build`)

### Version B: SwiftUI Native (CURRENT — use this)
- Location: `~/Desktop/Projects/Apps/biblecopilot/BibleCopilot/`
- Stack: SwiftUI, iOS 17+, native StoreKit 2
- Status: **Active. Build 88 uploaded. This is what was submitted.**
- Build: Standard Xcode build → Archive → Upload to App Store Connect

**Always use Version B (SwiftUI). Ignore the React Native files.**

---

## SwiftUI Codebase — File Structure

```
BibleCopilot/
├── App/
│   ├── BibleCopilotApp.swift     # @main entry, injects SubscriptionManager
│   └── ContentView.swift         # NavigationView wrapper → ChatView
├── Models/
│   └── SubscriptionManager.swift # StoreKit 2, free limit, isPro, showPaywall
├── Services/
│   └── AIService.swift           # AI response logic (currently hardcoded, needs real API)
└── Views/
    ├── ChatView.swift             # Main UI: message thread, input, paywall trigger
    └── PaywallView.swift          # Subscription paywall with plan cards
```

---

## Key Files Explained

### BibleCopilotApp.swift
```swift
@main
struct BibleCopilotApp: App {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(subscriptionManager)
        }
    }
}
```

### SubscriptionManager.swift (the brain)
```swift
let monthlyProductID = "bible_copilot_pro_monthly"
let annualProductID  = "bible_copilot_pro_annual"
let freeQuestionLimit = 10

@Published var isPro: Bool = false
@Published var showPaywall: Bool = false
@AppStorage("questionCount") var questionCount: Int = 0

// CRITICAL method — call this before EVERY AI response
func checkAndIncrementQuestion() -> Bool {
    if isPro { questionCount += 1; return false }        // Pro: allow
    if questionCount >= freeQuestionLimit {
        showPaywall = true; return true                  // Limit hit: show paywall
    }
    questionCount += 1; return false                     // Free: allow, count it
}
```

StoreKit 2 methods:
- `loadProducts()` — fetches products from App Store
- `purchase(_ product: Product)` — initiates purchase
- `restorePurchases()` — calls `AppStore.sync()`
- `updateSubscriptionStatus()` — checks `Transaction.currentEntitlements`

### ChatView.swift — Critical section
```swift
func sendMessage() {
    // CRITICAL: Check BEFORE calling AI — show paywall, NOT error
    let limitReached = subscriptionManager.checkAndIncrementQuestion()
    if limitReached {
        showPaywall = true
        return
    }
    // ... proceed with AI call
}
```
The view also observes `subscriptionManager.showPaywall` and mirrors it to local `showPaywall` state.

### AIService.swift — ⚠️ Currently hardcoded
The current `AIService.swift` returns **hardcoded responses** for specific keywords (John 3:16, faith, prayer, etc.). For production, this needs to call the real backend:

**Real backend:** `https://scripture-copilot-rust.vercel.app/api/chat`  
**Method:** POST, streaming (EventSource/SSE)  
**Model:** GPT-4o-mini  

The hardcoded responses are fine for App Store review but should be replaced with real API calls.

### PaywallView.swift
- Shows annual (default/highlighted, "7-DAY FREE TRIAL" badge) and monthly plans
- Uses `subscriptionManager.products` (loaded via StoreKit 2)
- CTA: "Start Free Trial" (annual) or "Subscribe Monthly"
- Restore Purchases button
- Dismiss button (top right)

---

## Build Info

| Field | Value |
|---|---|
| App name | Bible Copilot |
| Bundle ID | com.scripturecopilot.app |
| Version | 1.5.1 |
| Build number | 88 |
| Min iOS | 17.0 |
| Xcode project | BibleCopilot.xcodeproj |
| xcodegen config | project.yml |

---

## How to Build & Submit

```bash
# Open in Xcode
open ~/Desktop/Projects/Apps/biblecopilot/BibleCopilot.xcodeproj

# Build: Xcode → Product → Archive
# Then: Organizer → Distribute App → App Store Connect → Upload

# Or via CLI (requires xcrun altool or xcbeautify)
xcodebuild archive \
  -project BibleCopilot.xcodeproj \
  -scheme BibleCopilot \
  -archivePath ~/Desktop/BibleCopilot.xcarchive
```

---

## StoreKit Product IDs (App Store Connect)

| Product | ID | Type | Price |
|---|---|---|---|
| Monthly | `bible_copilot_pro_monthly` | Auto-renewable subscription | $4.99/mo |
| Annual | `bible_copilot_pro_annual` | Auto-renewable subscription | $39.99/yr |

**Subscription group:** Bible Copilot Pro  
**Entitlement:** `pro`

These IDs must match exactly in:
1. App Store Connect → In-App Purchases
2. `SubscriptionManager.swift` → `monthlyProductID` / `annualProductID`

---

## What Needs to Be Fixed (Ordered by Priority)

### P0 — Fix for App Store resubmission

1. **Verify free question limit fires paywall (not error)**
   - Open `ChatView.swift` → `sendMessage()`
   - Confirm `checkAndIncrementQuestion()` is called first
   - Confirm if `limitReached == true`, `showPaywall = true` is set and function returns
   - No `setError()` or error message should ever appear when limit is hit

2. **Verify StoreKit product IDs are correct**
   - `SubscriptionManager.swift` lines: `monthlyProductID` and `annualProductID`
   - Must be exactly: `bible_copilot_pro_monthly` and `bible_copilot_pro_annual`
   - Run sandbox test to confirm products load

3. **Carlos: Accept Paid Apps Agreement**
   - App Store Connect → Agreements, Tax, and Banking
   - Without this, IAP won't work in sandbox or production

4. **Sandbox end-to-end test**
   - Create sandbox tester in App Store Connect → Users and Access → Sandbox Testers
   - On device: Settings → App Store → Sandbox Account → sign in
   - Ask 10 questions → 11th should show PaywallView
   - Complete sandbox purchase → verify isPro = true → verify unlimited questions

5. **Build and upload new binary**
   - Increment build number (currently 88 → use 89+)
   - Archive → Upload to App Store Connect
   - Submit for review with note to reviewer about free limit and paywall

### P1 — After approval

6. **Replace hardcoded AIService with real API calls**
   - Endpoint: `https://scripture-copilot-rust.vercel.app/api/chat`
   - POST with question as body
   - Handle streaming response (SSE)

7. **Add daily question reset**
   - Currently `@AppStorage("questionCount")` never resets
   - Need to store `lastQuestionDate` and reset count at midnight

8. **App icon**
   - Check `BibleCopilot/Resources/Assets.xcassets` for current icon
   - Ensure all required sizes are present (App Store will reject if missing)

---

## Open Blockers (Carlos must do)

| Item | Where | Status |
|---|---|---|
| Accept Paid Apps Agreement | App Store Connect → Agreements | ❌ Not done |
| Sandbox tester setup | App Store Connect → Users and Access | ❌ Unknown |
| Verify IAP products are Active in App Store Connect | App Store Connect → In-App Purchases | ❌ Unknown |

---

## App Store Connect URLs

- App listing: https://appstoreconnect.apple.com/apps/6758913373
- TestFlight: https://appstoreconnect.apple.com/apps/6758913373/testflight
- In-App Purchases: https://appstoreconnect.apple.com/apps/6758913373/distribution/subscriptions

---

## Links

| Resource | URL |
|---|---|
| Privacy Policy | https://bible-copilot-app.netlify.app/privacy.html |
| Terms of Use | https://bible-copilot-app.netlify.app/terms.html |
| Support URL | https://bible-copilot-app.netlify.app/ |
| Backend API | https://scripture-copilot-rust.vercel.app/api/chat |

---

## Summary: Fastest Path to Approval

1. Open `BibleCopilot.xcodeproj` in Xcode
2. Verify `freeQuestionLimit = 10` in SubscriptionManager and paywall fires (not error) at limit
3. Verify product IDs match App Store Connect exactly
4. Carlos accepts Paid Apps Agreement in App Store Connect
5. Archive → build 89 → upload
6. Sandbox test on real device
7. Submit with reviewer note: *"Free tier allows 10 questions/day. To test IAP: use the app until you see the paywall appear after the 10th question. Use sandbox credentials to complete purchase."*

# 📄 scripture-copilot / scripture-app/FIRST-TIME-USER-FLOW.md

# First-Time User Experience — Bible Copilot

## 📱 From App Store Download → Paywall

This is exactly what a new user experiences when they download Bible Copilot.

---

## Step 1: App Download & Launch (0:00-0:05)

**User Action:**
- Downloads "Bible Copilot" from App Store
- Taps app icon

**What Happens:**
- Splash screen shows (Bible Copilot logo)
- RevenueCat initializes in background
- App loads to Home screen

**Console Logs (Behind the scenes):**
```
[App] Initializing RevenueCat...
[SubscriptionService] Initialized successfully
[SubscriptionService] Initial Pro status: false
[UsageTracker] New day detected, resetting counter
[UsageTracker] Usage today: 0/10
```

---

## Step 2: Home Screen (0:05-0:15)

**What User Sees:**
```
┌─────────────────────────────┐
│     Bible Copilot           │
│                             │
│  [Search verse or topic]    │
│                             │
│  Quick Picks:               │
│  • John 3:16                │
│  • Romans 8:28              │
│  • Psalm 23                 │
│                             │
│  Verse of the Day:          │
│  "For God so loved..."      │
│                             │
└─────────────────────────────┘
```

**User Action:**
- Taps on "Romans 8:28" (Quick Pick)
- OR types "Romans 8:28" and taps Search

---

## Step 3: Study Screen Loads (0:15-0:20)

**What User Sees:**
```
┌─────────────────────────────┐
│  10/10 free questions today │  ← USAGE COUNTER
│     Tap to upgrade          │
├─────────────────────────────┤
│  Romans 8:28                │
│                             │
│  "And we know that in all   │
│   things God works for the  │
│   good of those who love    │
│   him..."                   │
│                             │
│  Choose a Study Mode:       │
│                             │
│  🔍 OBSERVE                 │
│  What does the text say?    │
│  [Tap to study]             │
│                             │
│  💡 INTERPRET               │
│  What does it mean?         │
│  [Tap to study]             │
│                             │
│  ✝️ THEOLOGY                │
│  What does it teach?        │
│  [Tap to study]             │
│                             │
│  🙏 APPLY                   │
│  How do I respond?          │
│  [Tap to study]             │
│                             │
│  🛡️ APOLOGETICS             │
│  How do I defend it?        │
│  [Tap to study]             │
└─────────────────────────────┘
```

**Key Elements:**
- **Usage counter** is prominent at top
- Shows "10/10 free questions today"
- Subtle "Tap to upgrade" hint
- All 6 study modes available

---

## Step 4: First Question (0:20-0:35)

**User Action:**
- Taps "🔍 OBSERVE"

**What Happens:**
1. AI starts processing
2. Loading indicator appears
3. Response streams in
4. **Counter updates to "9/10 free questions today"**

**What User Sees:**
```
┌─────────────────────────────┐
│  9/10 free questions today  │  ← UPDATED!
│     Tap to upgrade          │
├─────────────────────────────┤
│  🔍 OBSERVE                 │
│                             │
│  Key Observations:          │
│                             │
│  1. "We know" - Paul speaks │
│     with certainty...       │
│                             │
│  2. "All things" - Not some │
│     things, but all...      │
│                             │
│  3. "God works" - Active    │
│     present tense...        │
│                             │
│  Related: Philippians 1:6   │
│           Jeremiah 29:11    │
└─────────────────────────────┘
```

**Behind the scenes:**
```
[UsageTracker] Recording question...
[UsageTracker] Usage today: 1/10
```

---

## Step 5: Multiple Questions (0:35-3:00)

**User continues studying:**
- Taps "💡 INTERPRET" → Counter: 8/10
- Taps "✝️ THEOLOGY" → Counter: 7/10
- Searches new verse "John 3:16"
- Taps "🔍 OBSERVE" → Counter: 6/10
- Keeps exploring...

**What User Notices:**
- Counter keeps decreasing
- No interruptions
- Smooth experience
- AI responses are high quality

---

## Step 6: Approaching Limit (3:00-3:15)

**After 9 questions, counter shows:**
```
┌─────────────────────────────┐
│  1/10 free questions today  │  ← ALMOST OUT
│     Tap to upgrade          │
└─────────────────────────────┘
```

**User thinks:**
- "I've almost used all my questions"
- "This is really helpful"
- "Maybe I should upgrade..."

---

## Step 7: The 10th Question (3:15-3:30)

**User Action:**
- Taps one more study mode

**What Happens:**
- Response loads normally
- **Counter updates to "0/10 free questions today"**
- No paywall yet (generous!)

```
┌─────────────────────────────┐
│  0/10 free questions today  │  ← OUT OF FREE
│     Tap to upgrade          │
└─────────────────────────────┘
```

---

## Step 8: The Paywall Trigger (3:30-3:35)

**User Action:**
- Tries to ask an 11th question
- Taps any study mode

**What Happens:**
- **PAYWALL APPEARS (FULL SCREEN)**

---

## Step 9: Paywall Experience (3:35-4:00)

**What User Sees:**
```
┌─────────────────────────────┐
│             ✕               │  ← Close button
│                             │
│    Bible Copilot Pro        │
│                             │
│  You've used 10 of 10       │
│  free questions today       │
│                             │
│  ─────────────────────────  │
│                             │
│  ∞  Unlimited Questions     │
│     Ask as many as you want │
│                             │
│  📓 Study Journal           │
│     Save notes & insights   │
│                             │
│  📖 All Translations        │
│     ESV, NIV, NASB, KJV     │
│                             │
│  📅 Reading Plans           │
│     Guided study tracks     │
│                             │
│  ─────────────────────────  │
│                             │
│  ┌───────────────────────┐ │
│  │   SAVE 33%  Annual    │ │  ← SELECTED
│  │   $39.99/year         │ │
│  │   $3.33/month         │ │
│  └───────────────────────┘ │
│                             │
│  ┌───────────────────────┐ │
│  │   Monthly             │ │
│  │   $4.99/month         │ │
│  │   Billed monthly      │ │
│  └───────────────────────┘ │
│                             │
│  ┌───────────────────────┐ │
│  │   Lifetime            │ │
│  │   $99.99              │ │
│  │   One-time purchase   │ │
│  └───────────────────────┘ │
│                             │
│  ┌───────────────────────┐ │
│  │   Start Pro Now       │ │  ← CTA BUTTON
│  └───────────────────────┘ │
│                             │
│  Restore Purchase          │
│                             │
│  Auto-renews unless        │
│  turned off 24h before...  │
└─────────────────────────────┘
```

**User Options:**
1. **Close paywall** (✕) → Returns to study screen, can't ask more questions today
2. **Tap pricing option** → Selects plan
3. **Tap "Start Pro Now"** → Purchase flow begins
4. **Tap "Restore Purchase"** → If previously purchased

---

## Step 10: After Purchase (4:00-4:10)

**User Action:**
- Selects Annual plan
- Completes Face ID / Touch ID purchase

**What Happens:**
1. RevenueCat processes purchase
2. Success alert appears:
   ```
   ┌─────────────────────────┐
   │  Welcome to Pro! ✨     │
   │                         │
   │  You now have unlimited │
   │  questions and all      │
   │  premium features.      │
   │                         │
   │  [Start Studying]       │
   └─────────────────────────┘
   ```
3. User taps "Start Studying"
4. Paywall closes
5. **Counter now shows:**
   ```
   ┌─────────────────────────────┐
   │  ✨ Pro (annual) — Unlimited │
   │  questions                   │
   └─────────────────────────────┘
   ```

**Behind the scenes:**
```
[SubscriptionService] Purchase completed
[SubscriptionService] Customer info updated
[SubscriptionService] Pro status: true
[SubscriptionService] Subscription type: yearly
```

---

## Step 11: Pro Experience (4:10+)

**User can now:**
- Ask unlimited questions
- No daily limit
- All features unlocked
- Smooth, uninterrupted study

**Forever.**

---

## 🎯 Key Psychological Moments

### Moment 1: First Impression (Step 2)
**User sees:** Clean, professional interface  
**User thinks:** "This looks trustworthy"

### Moment 2: Value Demonstration (Steps 4-5)
**User sees:** High-quality AI responses  
**User thinks:** "Wow, this is actually helpful"

### Moment 3: Scarcity Awareness (Step 6)
**User sees:** "1/10 free questions today"  
**User thinks:** "I'm running out, but this is valuable"

### Moment 4: Generous Free Tier (Step 7)
**User sees:** Gets full 10 questions  
**User thinks:** "They're not being stingy"

### Moment 5: The Ask (Step 8)
**User sees:** Paywall after demonstrating value  
**User thinks:** "I've already gotten value, this is worth it"

### Moment 6: Clear Value Prop (Step 9)
**User sees:** Unlimited + Journal + Plans  
**User thinks:** "$3.33/mo for unlimited is cheap"

### Moment 7: Conversion (Step 10)
**User decides:** Annual plan (best value)  
**User converts:** Becomes paying customer

---

## 📊 Conversion Funnel

```
100 Downloads
    ↓
 80 Active (open app)
    ↓
 60 Search verse
    ↓
 50 Ask first question
    ↓
 40 Ask 5+ questions
    ↓
 30 Hit 10-question limit
    ↓
 20 See paywall
    ↓
  3 Convert to Pro (3-5% conversion)
```

**Result:** 3-5 paying customers per 100 downloads

---

## 🎨 Design Principles at Work

1. **Generosity First**
   - 10 questions (not 3 or 5)
   - All features available in free tier
   - No feature gating until limit

2. **Value Before Ask**
   - User gets to experience quality
   - Builds trust before asking for money
   - Shows what they're paying for

3. **Clear Communication**
   - Counter always visible
   - No surprises
   - Transparent pricing

4. **Friction Reduction**
   - One-tap upgrade from counter
   - Simple pricing (3 options)
   - Face ID checkout

5. **Psychological Anchoring**
   - Annual plan shows "SAVE 33%"
   - Lifetime positioned as premium option
   - Monthly as fallback

---

## ⏰ Time to Paywall

**Fast User:** 15 minutes (asks 10 questions quickly)  
**Average User:** 30-60 minutes (explores thoughtfully)  
**Slow User:** 2-3 days (casual use)

**Daily Reset:** Midnight (user's timezone)  
**Result:** Most users hit paywall on Day 1 or Day 2

---

## 🎯 Success Metrics

**Activation:** 80% (use at least 1 question)  
**Engagement:** 50% (use 5+ questions)  
**Paywall View:** 30% (hit 10-question limit)  
**Conversion:** 3-5% (of paywall views)  

**Expected:** 3-5 paid subscribers per 100 downloads

---

This is the **exact experience** a first-time user will have with Bible Copilot.

**Elegant. Generous. Clear.**


---


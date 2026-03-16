# 📄 scripture-copilot / scripture-app/MONETIZATION-IMPLEMENTATION.md

# Bible Copilot — Monetization Implementation Guide
**Step-by-step setup for RevenueCat + App Store subscriptions**

*Created: February 21, 2026*

---

## ✅ What's Been Built

I've implemented the complete monetization infrastructure:

### 1. **SubscriptionService.ts**
- RevenueCat SDK integration
- Check Pro status
- Purchase subscriptions
- Restore purchases
- User management

### 2. **UsageTracker.ts**
- 10 questions/day limit for free tier
- Daily usage counter (resets at midnight)
- Pro bypass (unlimited questions)

### 3. **PaywallScreen.tsx**
- Beautiful paywall UI (Reformed aesthetic)
- Monthly + Annual pricing display
- Feature list
- Purchase flow
- Restore purchases

---

## 🚀 Setup Steps (Do These Now)

### **STEP 1: Create RevenueCat Account** (5 minutes)

1. Go to [https://www.revenuecat.com](https://www.revenuecat.com)
2. Sign up (free up to $2,500 MRR)
3. Create a new project: "Bible Copilot"
4. Select platform: **iOS**

### **STEP 2: Configure Apple App Store Connect** (10 minutes)

1. Go to [https://appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Navigate to: **My Apps** → **Bible Copilot** → **In-App Purchases**
3. Click **"+"** to create new subscription group

**Create Subscription Group:**
- Name: `Bible Copilot Pro`
- Reference Name: `pro_subscription_group`

4. Add two subscriptions:

**Monthly Subscription:**
- Product ID: `bible_copilot_pro_monthly`
- Reference Name: `Bible Copilot Pro Monthly`
- Subscription Duration: `1 month`
- Price: `$4.99 USD`
- Localizations:
  - Display Name: `Bible Copilot Pro`
  - Description: `Unlimited questions, study journal, reading plans, and all translations`

**Annual Subscription:**
- Product ID: `bible_copilot_pro_annual`
- Reference Name: `Bible Copilot Pro Annual`
- Subscription Duration: `1 year`
- Price: `$39.99 USD`
- Localizations:
  - Display Name: `Bible Copilot Pro Annual`
  - Description: `Unlimited questions, study journal, reading plans, and all translations (save 33%)`

5. For both subscriptions:
   - Set **Subscription Group Rank** (Monthly = 1, Annual = 2)
   - Review information: Add app screenshots (use paywall features)
   - Submit for review

### **STEP 3: Connect RevenueCat to App Store** (5 minutes)

1. In RevenueCat dashboard, go to **Project Settings** → **Apple App Store**
2. Upload **App Store Connect API Key**:
   - In App Store Connect: **Users and Access** → **Keys** → **App Store Connect API**
   - Create new key with **App Manager** role
   - Download `.p8` file
   - Upload to RevenueCat
3. Enter **Bundle ID**: `com.scripturecopilot.app`
4. Select **Shared Secret** (auto-populated from App Store Connect)

### **STEP 4: Create Entitlements & Offerings in RevenueCat** (5 minutes)

1. In RevenueCat: **Entitlements** tab
2. Create entitlement:
   - Identifier: `pro`
   - Display Name: `Bible Copilot Pro`
3. Attach products to entitlement:
   - `bible_copilot_pro_monthly`
   - `bible_copilot_pro_annual`

4. In RevenueCat: **Offerings** tab
5. Create offering:
   - Identifier: `default`
   - Display Name: `Default Offering`
6. Add packages:
   - Monthly package → Product: `bible_copilot_pro_monthly`
   - Annual package → Product: `bible_copilot_pro_annual`

### **STEP 5: Add RevenueCat API Keys to App** (2 minutes)

1. Copy API keys from RevenueCat dashboard:
   - **iOS API Key**: Found in Project Settings → API Keys
2. Open `src/services/SubscriptionService.ts`
3. Replace placeholders:

```typescript
const REVENUECAT_API_KEY_IOS = 'appl_YOUR_KEY_HERE'; // Replace with actual key
```

---

## 🔧 Integration into Existing App

### **Update App.tsx** to initialize subscriptions:

Add this near the top of your `App.tsx`:

```typescript
import SubscriptionService from './src/services/SubscriptionService';
import UsageTracker from './src/services/UsageTracker';

// Inside your App component, in useEffect:
useEffect(() => {
  // Initialize RevenueCat
  SubscriptionService.initialize().catch(console.error);
}, []);
```

### **Add Paywall Trigger Logic**

When user tries to ask a question, check usage:

```typescript
import { useState } from 'react';
import { Modal } from 'react-native';
import SubscriptionService from './src/services/SubscriptionService';
import UsageTracker from './src/services/UsageTracker';
import PaywallScreen from './src/components/PaywallScreen';

// In your study screen component:
const [showPaywall, setShowPaywall] = useState(false);
const [usageInfo, setUsageInfo] = useState<any>(null);

const handleQuestionSubmit = async (question: string) => {
  // 1. Check if user is Pro
  const isPro = await SubscriptionService.isPro();
  
  // 2. Check usage limit
  const usage = await UsageTracker.canAskQuestion(isPro);
  
  if (!usage.allowed) {
    // Show paywall
    const count = await UsageTracker.getUsageCount();
    setUsageInfo(count);
    setShowPaywall(true);
    return;
  }
  
  // 3. Record question usage
  await UsageTracker.recordQuestion();
  
  // 4. Proceed with AI request
  // ... your existing AI logic
};

// Add to your render:
<Modal
  visible={showPaywall}
  animationType="slide"
  presentationStyle="pageSheet"
>
  <PaywallScreen
    onDismiss={() => setShowPaywall(false)}
    onSuccess={() => {
      setShowPaywall(false);
      // Optionally retry the question
    }}
    usageInfo={usageInfo}
  />
</Modal>
```

### **Add Usage Counter Display**

Show remaining questions to free users:

```typescript
const [usageDisplay, setUsageDisplay] = useState<string>('');

useEffect(() => {
  const updateUsage = async () => {
    const isPro = await SubscriptionService.isPro();
    
    if (isPro) {
      setUsageDisplay('Pro: Unlimited');
    } else {
      const usage = await UsageTracker.getUsageCount();
      setUsageDisplay(`${usage.remaining} questions left today`);
    }
  };
  
  updateUsage();
}, []);

// Display in your UI:
<Text style={styles.usageText}>{usageDisplay}</Text>
```

---

## 🧪 Testing (Before App Store Submission)

### **Test Purchase Flow** (TestFlight)

1. Build and upload to TestFlight (Build 60)
2. Add yourself as internal tester
3. Install app on device
4. **Important:** Use Sandbox testing:
   - In App Store Connect: **Users and Access** → **Sandbox Testers**
   - Create test account (use fake email)
   - On iPhone: Settings → App Store → Sandbox Account → Sign in with test account

5. Test flow:
   - Ask 10 questions (free tier limit)
   - 11th question triggers paywall
   - Tap "Start Pro Now"
   - Complete purchase with sandbox account
   - Verify subscription activated
   - Ask unlimited questions

6. Test restore:
   - Delete app
   - Reinstall
   - Tap "Restore Purchase"
   - Verify Pro status restored

### **Test Daily Reset**

1. Ask 5 questions
2. Change device date to tomorrow
3. App should reset counter
4. Ask questions again (should work)

---

## 📊 Revenue Tracking

### **RevenueCat Dashboard**

Monitor these metrics:
- **Active Subscriptions**: Current paying users
- **MRR (Monthly Recurring Revenue)**: Total monthly revenue
- **Churn Rate**: % of users cancelling
- **Conversion Rate**: Free → Pro %

### **App Store Connect**

- **Sales and Trends** → Subscriptions
- See daily subscription events
- Track trials, renewals, cancellations

---

## 🚨 Common Issues & Fixes

### **Issue: "No offerings found"**
**Fix:** 
- Verify products approved in App Store Connect
- Check RevenueCat entitlement configuration
- Wait 24 hours for App Store to propagate products

### **Issue: "Purchase failed" in sandbox**
**Fix:**
- Sign out of real Apple ID
- Sign in with sandbox tester account
- Try again

### **Issue: "Entitlement not active after purchase"**
**Fix:**
- Check RevenueCat logs (Project → App → Debug)
- Verify entitlement ID matches in code (`pro`)
- Restart app

### **Issue: Daily limit not resetting**
**Fix:**
- Check device timezone settings
- Clear app data: `AsyncStorage.clear()`
- Reinstall app

---

## 📝 App Store Submission Notes

When submitting Build 60 with monetization:

**In App Store Connect → App Information:**
- Check: ✅ "Offers In-App Purchases"

**In App Review Information:**
- Add note:
  ```
  This app offers a Pro subscription ($4.99/month or $39.99/year) 
  with the following features:
  - Unlimited AI questions
  - Study journal
  - Reading plans
  - All Bible translations
  
  Free tier includes 10 AI questions per day.
  
  Test account for review team:
  Email: [sandbox tester email]
  Password: [sandbox tester password]
  ```

**Screenshots:**
- Include at least one screenshot showing paywall
- Show Pro features (journal, reading plans)

---

## ✅ Pre-Launch Checklist

- [ ] RevenueCat account created
- [ ] App Store Connect products created (monthly + annual)
- [ ] Products approved by Apple (can take 24-48 hours)
- [ ] RevenueCat connected to App Store
- [ ] Entitlements configured
- [ ] API keys added to app
- [ ] App.tsx updated with initialization
- [ ] Paywall integrated into question flow
- [ ] Usage counter displayed
- [ ] Tested on TestFlight with sandbox account
- [ ] Verified purchases work
- [ ] Verified restore works
- [ ] Verified daily limit resets
- [ ] Added App Review notes

---

## 🎯 Next Steps After Setup

1. **Build 60 with Monetization**
   ```bash
   cd /Users/carlosreyes/clawd/projects/scripture-copilot/scripture-app
   npx eas build --platform ios --profile production
   ```

2. **Upload to TestFlight**
   ```bash
   npx eas submit --platform ios --latest
   ```

3. **Test Purchase Flow** (See Testing section above)

4. **Submit to App Store** (See APP-STORE-LAUNCH-STRATEGY.md)

---

## 💰 Expected Costs

| Service | Cost |
|---------|------|
| RevenueCat | Free (up to $2,500 MRR) |
| Apple App Store | 30% of revenue |
| OpenAI API | ~$0.001/question |

**Example:**
- 100 subscribers × $4.99 = $499/mo gross
- Apple 30%: -$149.70
- API costs: ~$5
- **Net profit: ~$344/mo**

---

## 📞 Support

**RevenueCat Docs:** https://docs.revenuecat.com  
**Apple Subscriptions Guide:** https://developer.apple.com/app-store/subscriptions/

**Questions?** Check RevenueCat dashboard → Debug → View logs

---

**Status:** ✅ Code complete. Ready for RevenueCat setup + testing.

**Time to complete setup:** ~30 minutes  
**Time to test:** ~15 minutes

**Next action:** Follow STEP 1 above (Create RevenueCat account)


---


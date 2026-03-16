# 📄 scripture-copilot / scripture-app/QUICK-START-REVENUECAT.md

# RevenueCat Quick Start — Bible Copilot

## ✅ Already Done
- ✅ SDKs installed (`react-native-purchases` + `react-native-purchases-ui`)
- ✅ API key configured (`test_OfksHksIrBKMKBXrIjITRRPywKX`)
- ✅ Core services created (SubscriptionService, UsageTracker)
- ✅ UI components ready (RevenueCatPaywall, CustomerCenter)
- ✅ React hook created (`useSubscription`)

---

## 🚀 3-Step Integration

### 1. Initialize in App.tsx

```typescript
import SubscriptionService from './src/services/SubscriptionService';

useEffect(() => {
  SubscriptionService.initialize();
}, []);
```

### 2. Use Hook in Your Screen

```typescript
import { useSubscription } from './src/hooks/useSubscription';

const { isPro, usage, canAskQuestion, recordQuestion } = useSubscription();
```

### 3. Show Paywall When Needed

```typescript
import RevenueCatPaywall from './src/components/RevenueCatPaywall';

const handleQuestion = async () => {
  const allowed = await canAskQuestion();
  if (!allowed) {
    setShowPaywall(true); // Show paywall
    return;
  }
  
  await recordQuestion(); // Track usage
  // ... submit to AI
};

<Modal visible={showPaywall}>
  <RevenueCatPaywall
    onPurchaseSuccess={() => setShowPaywall(false)}
    onDismiss={() => setShowPaywall(false)}
  />
</Modal>
```

---

## 📋 RevenueCat Dashboard Setup (5 min)

1. **Go to:** https://app.revenuecat.com
2. **Products → Add Products:**
   - `monthly` — $4.99/month
   - `yearly` — $39.99/year  
   - `lifetime` — $99.99 (one-time)
3. **Entitlements → Create:**
   - ID: `pro`
   - Attach all 3 products
4. **Offerings → Create:**
   - ID: `default`
   - Add all 3 packages

---

## 🧪 Test It (2 min)

```bash
# Build and run
npm start
```

1. Ask 10 questions → Free tier limit hit
2. Paywall appears automatically
3. Test purchase with sandbox account

---

**Full Guide:** `REVENUECAT-INTEGRATION-GUIDE.md`


---


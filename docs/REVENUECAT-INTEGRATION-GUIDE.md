# 📄 scripture-copilot / scripture-app/REVENUECAT-INTEGRATION-GUIDE.md

# RevenueCat Integration Guide — Bible Copilot
**Complete implementation with Paywalls & Customer Center**

*Updated: February 21, 2026*

---

## ✅ What's Been Set Up

### 1. **SDKs Installed**
- `react-native-purchases` — Core RevenueCat SDK
- `react-native-purchases-ui` — Paywall & Customer Center UI components

### 2. **API Key Configured**
- Test API Key: `test_OfksHksIrBKMKBXrIjITRRPywKX`
- Configured in `SubscriptionService.ts`

### 3. **Core Services Created**
- **SubscriptionService.ts** — Subscription management (Pro status, purchase, restore)
- **UsageTracker.ts** — Free tier usage tracking (10 questions/day)
- **useSubscription.ts** — React hook for easy integration

### 4. **UI Components Created**
- **RevenueCatPaywall.tsx** — Official RevenueCat Paywall UI
- **CustomerCenter.tsx** — Subscription management UI
- **PaywallScreen.tsx** — Custom fallback paywall (if needed)

### 5. **Products Configured**
Your RevenueCat dashboard should have:
- **Monthly** — Product ID: `monthly`
- **Yearly** — Product ID: `yearly`
- **Lifetime** — Product ID: `lifetime`

All attached to entitlement: `pro`

---

## 🚀 Step 1: Initialize RevenueCat in App.tsx

Add this to your main `App.tsx` file:

```typescript
import React, { useEffect } from 'react';
import SubscriptionService from './src/services/SubscriptionService';

export default function App() {
  useEffect(() => {
    // Initialize RevenueCat on app startup
    const initSubscriptions = async () => {
      try {
        await SubscriptionService.initialize();
        console.log('RevenueCat initialized');
      } catch (error) {
        console.error('Failed to initialize RevenueCat:', error);
      }
    };

    initSubscriptions();
  }, []);

  // Rest of your app...
  return (
    <NavigationContainer>
      {/* Your navigation */}
    </NavigationContainer>
  );
}
```

---

## 🎯 Step 2: Use the Subscription Hook

In any component where you need subscription info:

```typescript
import { useSubscription } from './src/hooks/useSubscription';

export default function StudyScreen() {
  const {
    isPro,
    type,
    loading,
    usage,
    canAskQuestion,
    recordQuestion,
    refresh,
  } = useSubscription();

  if (loading) {
    return <ActivityIndicator />;
  }

  return (
    <View>
      {/* Display Pro status */}
      <Text>
        {isPro 
          ? `Pro (${type})` 
          : `Free: ${usage.remaining} questions left today`
        }
      </Text>

      {/* Your UI */}
    </View>
  );
}
```

---

## 💰 Step 3: Show Paywall (Modern Method)

Use the official RevenueCat Paywall UI:

```typescript
import React, { useState } from 'react';
import { View, Button, Modal } from 'react-native';
import RevenueCatPaywall from './src/components/RevenueCatPaywall';
import { useSubscription } from './src/hooks/useSubscription';

export default function StudyScreen() {
  const [showPaywall, setShowPaywall] = useState(false);
  const { isPro, canAskQuestion, recordQuestion, refresh } = useSubscription();

  const handleQuestionSubmit = async (question: string) => {
    // Check if user can ask
    const allowed = await canAskQuestion();
    
    if (!allowed) {
      // Show paywall
      setShowPaywall(true);
      return;
    }

    // Record usage
    await recordQuestion();

    // Submit question to AI
    // ... your AI logic here
  };

  return (
    <View style={{ flex: 1 }}>
      <Button title="Ask Question" onPress={() => handleQuestionSubmit('Romans 8:28')} />

      {/* RevenueCat Paywall */}
      <Modal
        visible={showPaywall}
        animationType="slide"
        presentationStyle="fullScreen"
      >
        <RevenueCatPaywall
          onPurchaseSuccess={() => {
            setShowPaywall(false);
            refresh(); // Refresh Pro status
            // Optionally retry the question
          }}
          onDismiss={() => setShowPaywall(false)}
          requiredEntitlementIdentifier="pro"
        />
      </Modal>
    </View>
  );
}
```

---

## ⚙️ Step 4: Add Customer Center (Subscription Management)

Let users manage their subscription:

```typescript
import React, { useState } from 'react';
import { View, Button, Modal } from 'react-native';
import CustomerCenter from './src/components/CustomerCenter';
import { useSubscription } from './src/hooks/useSubscription';

export default function SettingsScreen() {
  const [showCustomerCenter, setShowCustomerCenter] = useState(false);
  const { isPro } = useSubscription();

  return (
    <View>
      {isPro && (
        <Button
          title="Manage Subscription"
          onPress={() => setShowCustomerCenter(true)}
        />
      )}

      <Modal
        visible={showCustomerCenter}
        animationType="slide"
        presentationStyle="pageSheet"
      >
        <CustomerCenter onDismiss={() => setShowCustomerCenter(false)} />
      </Modal>
    </View>
  );
}
```

---

## 📊 Step 5: Display Subscription Status

Show detailed subscription info to users:

```typescript
import { useSubscription } from './src/hooks/useSubscription';

export default function AccountScreen() {
  const { isPro, type, expirationDate, willRenew } = useSubscription();

  return (
    <View>
      <Text>Status: {isPro ? 'Pro' : 'Free'}</Text>
      
      {isPro && (
        <>
          <Text>Plan: {type}</Text>
          {type !== 'lifetime' && expirationDate && (
            <>
              <Text>Expires: {expirationDate.toLocaleDateString()}</Text>
              <Text>Auto-renew: {willRenew ? 'Yes' : 'No'}</Text>
            </>
          )}
        </>
      )}
    </View>
  );
}
```

---

## 🎨 Step 6: Customize Paywall (Optional)

If you want a custom paywall instead of RevenueCat's default UI:

```typescript
import PaywallScreen from './src/components/PaywallScreen';

<Modal visible={showPaywall}>
  <PaywallScreen
    onDismiss={() => setShowPaywall(false)}
    onSuccess={() => {
      setShowPaywall(false);
      refresh();
    }}
    usageInfo={usage}
  />
</Modal>
```

---

## 🧪 Testing with TestFlight

### 1. **Create Sandbox Tester**
1. Go to App Store Connect → **Users and Access** → **Sandbox Testers**
2. Create test account (use fake email)

### 2. **Configure Device**
1. On iPhone: **Settings** → **App Store** → **Sandbox Account**
2. Sign in with sandbox tester

### 3. **Test Flow**
```typescript
// In your app during testing:
1. Ask 10 questions (free tier)
2. 11th question shows paywall
3. Purchase with sandbox account
4. Verify Pro status activated
5. Ask unlimited questions
```

### 4. **Test Restore**
```typescript
1. Delete app
2. Reinstall
3. App checks Pro status automatically on launch
4. Or: Show "Restore Purchase" button
```

---

## 🔧 Advanced Features

### User Identification (Cross-Device Sync)

```typescript
// When user logs in:
await SubscriptionService.setUserId('user123');

// When user logs out:
await SubscriptionService.clearUserId();
```

### Manual Purchase (Without Paywall)

```typescript
import SubscriptionService from './services/SubscriptionService';

const purchaseMonthly = async () => {
  const offerings = await SubscriptionService.getOfferings();
  const monthlyPackage = offerings?.availablePackages.find(
    pkg => pkg.identifier === '$rc_monthly'
  );
  
  if (monthlyPackage) {
    const result = await SubscriptionService.purchasePackage(monthlyPackage);
    if (result.success) {
      console.log('Purchase successful!');
    }
  }
};
```

### Check Specific Product Type

```typescript
const checkSubscriptionType = async () => {
  const type = await SubscriptionService.getSubscriptionType();
  
  if (type === 'lifetime') {
    console.log('User has lifetime access');
  } else if (type === 'yearly') {
    console.log('User has yearly subscription');
  } else if (type === 'monthly') {
    console.log('User has monthly subscription');
  }
};
```

---

## 📱 RevenueCat Dashboard Setup

### 1. **Create Products in App Store Connect**
1. Go to https://appstoreconnect.apple.com
2. **My Apps** → **Bible Copilot** → **In-App Purchases**
3. Create subscription group: "Bible Copilot Pro"
4. Add products:
   - **monthly** — $4.99/month
   - **yearly** — $39.99/year (or $34.99 to show 30% savings)
   - **lifetime** — $99.99 (one-time purchase, non-renewing)

### 2. **Configure in RevenueCat Dashboard**
1. Go to https://app.revenuecat.com
2. **Products** tab → Link your App Store products
3. **Entitlements** tab → Create `pro` entitlement
4. Attach all 3 products to `pro` entitlement
5. **Offerings** tab → Create `default` offering
6. Add packages:
   - Monthly package → `monthly`
   - Annual package → `yearly`
   - Lifetime package → `lifetime`

### 3. **Configure Paywall (Optional)**
1. **Paywalls** tab → Create new paywall
2. Customize design, copy, features list
3. Set as default for `pro` entitlement

---

## ⚠️ Error Handling Best Practices

```typescript
import SubscriptionService from './services/SubscriptionService';

const handlePurchase = async () => {
  try {
    const offerings = await SubscriptionService.getOfferings();
    
    if (!offerings) {
      Alert.alert('Error', 'No subscription options available');
      return;
    }

    const monthlyPackage = offerings.availablePackages[0];
    const result = await SubscriptionService.purchasePackage(monthlyPackage);
    
    if (result.success) {
      Alert.alert('Success!', 'Welcome to Bible Copilot Pro');
    } else if (result.error && !result.error.includes('cancelled')) {
      Alert.alert('Purchase Failed', result.error);
    }
  } catch (error: any) {
    console.error('[Purchase] Error:', error);
    Alert.alert('Error', 'Something went wrong. Please try again.');
  }
};
```

---

## 🎯 Complete Example: Study Screen with Paywall

```typescript
import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  Modal,
  ActivityIndicator,
  Alert,
  StyleSheet,
} from 'react-native';
import RevenueCatPaywall from './components/RevenueCatPaywall';
import CustomerCenter from './components/CustomerCenter';
import { useSubscription } from './hooks/useSubscription';

export default function StudyScreen() {
  const [question, setQuestion] = useState('');
  const [response, setResponse] = useState('');
  const [loading, setLoading] = useState(false);
  const [showPaywall, setShowPaywall] = useState(false);
  const [showCustomerCenter, setShowCustomerCenter] = useState(false);

  const {
    isPro,
    type,
    usage,
    canAskQuestion,
    recordQuestion,
    refresh,
    loading: subscriptionLoading,
  } = useSubscription();

  const handleSubmitQuestion = async () => {
    // Check if user can ask
    const allowed = await canAskQuestion();
    
    if (!allowed) {
      setShowPaywall(true);
      return;
    }

    // Record question usage
    await recordQuestion();

    // Submit to AI
    setLoading(true);
    try {
      // Your AI logic here
      const aiResponse = await submitToOpenAI(question);
      setResponse(aiResponse);
    } catch (error) {
      Alert.alert('Error', 'Failed to get response');
    } finally {
      setLoading(false);
    }
  };

  if (subscriptionLoading) {
    return (
      <View style={styles.centered}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.title}>Bible Copilot</Text>
        <TouchableOpacity
          onPress={() => isPro ? setShowCustomerCenter(true) : setShowPaywall(true)}
        >
          <Text style={styles.status}>
            {isPro ? `Pro (${type})` : `${usage.remaining}/${usage.limit} free`}
          </Text>
        </TouchableOpacity>
      </View>

      {/* Question Input */}
      <TextInput
        style={styles.input}
        placeholder="Enter a Bible verse (e.g., Romans 8:28)"
        value={question}
        onChangeText={setQuestion}
      />

      <TouchableOpacity
        style={styles.button}
        onPress={handleSubmitQuestion}
        disabled={loading || !question}
      >
        <Text style={styles.buttonText}>
          {loading ? 'Loading...' : 'Ask Question'}
        </Text>
      </TouchableOpacity>

      {/* Response */}
      {response && (
        <View style={styles.response}>
          <Text>{response}</Text>
        </View>
      )}

      {/* Paywall Modal */}
      <Modal
        visible={showPaywall}
        animationType="slide"
        presentationStyle="fullScreen"
      >
        <RevenueCatPaywall
          onPurchaseSuccess={() => {
            setShowPaywall(false);
            refresh();
            Alert.alert('Welcome to Pro!', 'You now have unlimited questions');
          }}
          onDismiss={() => setShowPaywall(false)}
          requiredEntitlementIdentifier="pro"
        />
      </Modal>

      {/* Customer Center Modal */}
      <Modal
        visible={showCustomerCenter}
        animationType="slide"
        presentationStyle="pageSheet"
      >
        <CustomerCenter onDismiss={() => setShowCustomerCenter(false)} />
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    backgroundColor: '#fff',
  },
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: '700',
  },
  status: {
    fontSize: 14,
    color: '#3b82f6',
    fontWeight: '600',
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    marginBottom: 16,
  },
  button: {
    backgroundColor: '#3b82f6',
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  response: {
    marginTop: 20,
    padding: 16,
    backgroundColor: '#f0f9ff',
    borderRadius: 8,
  },
});
```

---

## 🔍 Debugging

### Check Logs
```typescript
// Enable debug mode (already configured in SubscriptionService)
import Purchases from 'react-native-purchases';

if (__DEV__) {
  Purchases.setLogLevel(Purchases.LOG_LEVEL.DEBUG);
}
```

### Common Issues

**Issue: "No offerings found"**
- Check RevenueCat dashboard → Products are linked
- Verify offerings are created
- Wait 10-15 min for changes to propagate

**Issue: "Purchase failed"**
- Verify sandbox tester is signed in
- Check product IDs match exactly
- Ensure products are approved in App Store Connect

**Issue: "Entitlement not active"**
- Verify entitlement ID is `pro` (case-sensitive)
- Check products are attached to entitlement
- Review RevenueCat logs in dashboard

---

## 📊 Analytics & Metrics

Track key subscription metrics:

```typescript
import SubscriptionService from './services/SubscriptionService';

// Track conversion funnel
analytics.track('paywall_viewed');

const result = await SubscriptionService.purchasePackage(package);
if (result.success) {
  analytics.track('subscription_purchased', {
    product: package.identifier,
    price: package.product.price,
  });
}

// Track usage
const usage = await UsageTracker.getUsageCount();
analytics.track('question_asked', {
  count: usage.count,
  is_pro: isPro,
});
```

---

## ✅ Pre-Launch Checklist

- [ ] RevenueCat initialized in App.tsx
- [ ] Products created in App Store Connect (monthly, yearly, lifetime)
- [ ] Products linked in RevenueCat dashboard
- [ ] Entitlement `pro` created
- [ ] Default offering configured
- [ ] Paywall integrated into app flow
- [ ] Usage tracking working (10 questions/day limit)
- [ ] Customer Center accessible for Pro users
- [ ] Tested purchase flow with sandbox account
- [ ] Tested restore purchases
- [ ] Tested daily limit reset
- [ ] Error handling implemented
- [ ] Analytics tracking added

---

## 🚀 Next Steps

1. **Test Locally** — Run app, verify paywall shows
2. **Build & Upload** — `npx eas build --platform ios`
3. **TestFlight** — Test with sandbox account
4. **Submit to App Store** — Include In-App Purchase info
5. **Launch** — Monitor metrics in RevenueCat dashboard

---

**Documentation:**
- RevenueCat Docs: https://www.revenuecat.com/docs
- Paywalls Guide: https://www.revenuecat.com/docs/tools/paywalls
- Customer Center: https://www.revenuecat.com/docs/tools/customer-center

**Support:** Check RevenueCat dashboard → Debug → View Logs

---

*Your RevenueCat integration is complete and ready to test!*


---


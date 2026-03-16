// Bible Copilot — RevenueCat Subscription Service
// CRITICAL: Product IDs defined here and used everywhere
import Purchases, {
  PurchasesOffering,
  CustomerInfo,
} from "react-native-purchases";

// =====================================================
// PRODUCT IDS — Single source of truth
// These must match App Store Connect exactly
// =====================================================
export const PRODUCT_IDS = {
  MONTHLY: "bible_copilot_pro_monthly",
  ANNUAL: "bible_copilot_pro_annual",
} as const;

// RevenueCat config
const REVENUECAT_API_KEY = "test_OfksHksIrBKMKBXrIjITRRPywKX";
const ENTITLEMENT_ID = "pro";

class SubscriptionService {
  private initialized = false;

  async initialize(): Promise<void> {
    if (this.initialized) return;

    try {
      Purchases.configure({ apiKey: REVENUECAT_API_KEY });
      this.initialized = true;
      console.log("[SubscriptionService] RevenueCat initialized");
    } catch (error) {
      console.error("[SubscriptionService] Init failed:", error);
    }
  }

  async isPro(): Promise<boolean> {
    try {
      const customerInfo = await Purchases.getCustomerInfo();
      const hasPro =
        customerInfo.entitlements.active[ENTITLEMENT_ID] !== undefined;
      return hasPro;
    } catch (error) {
      console.error("[SubscriptionService] isPro check failed:", error);
      return false;
    }
  }

  async getOfferings(): Promise<PurchasesOffering | null> {
    try {
      const offerings = await Purchases.getOfferings();
      return offerings.current;
    } catch (error) {
      console.error("[SubscriptionService] getOfferings failed:", error);
      return null;
    }
  }

  async purchaseSubscription(
    productId: string
  ): Promise<{ success: boolean; customerInfo?: CustomerInfo; error?: string }> {
    try {
      const offerings = await Purchases.getOfferings();
      const current = offerings.current;

      if (!current) {
        return { success: false, error: "No offerings available" };
      }

      // Find the package matching the product ID
      const allPackages = current.availablePackages;
      const pkg = allPackages.find(
        (p) => p.product.identifier === productId
      );

      if (pkg) {
        const { customerInfo } = await Purchases.purchasePackage(pkg);
        const hasPro =
          customerInfo.entitlements.active[ENTITLEMENT_ID] !== undefined;

        if (hasPro) {
          return { success: true, customerInfo };
        }
        return { success: false, error: "Purchase completed but entitlement not found" };
      }

      // Fallback: try purchasing by product ID directly
      const { customerInfo } = await Purchases.purchaseProduct(productId);
      const hasPro =
        customerInfo.entitlements.active[ENTITLEMENT_ID] !== undefined;

      if (hasPro) {
        return { success: true, customerInfo };
      }
      return { success: false, error: "Purchase completed but entitlement not found" };
    } catch (error: any) {
      if (error.userCancelled) {
        return { success: false, error: "cancelled" };
      }
      console.error("[SubscriptionService] Purchase failed:", error);
      return { success: false, error: error.message || "Purchase failed" };
    }
  }

  async restorePurchases(): Promise<boolean> {
    try {
      const customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.active[ENTITLEMENT_ID] !== undefined;
    } catch (error) {
      console.error("[SubscriptionService] Restore failed:", error);
      return false;
    }
  }
}

export default new SubscriptionService();

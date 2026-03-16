// Bible Copilot — Usage Tracker (10 questions/day free tier)
import AsyncStorage from "@react-native-async-storage/async-storage";
import { FREE_QUESTIONS_PER_DAY } from "../constants/theme";

const USAGE_KEY = "@bc_daily_usage";

interface UsageData {
  date: string; // YYYY-MM-DD
  count: number;
}

function getTodayString(): string {
  const now = new Date();
  return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-${String(now.getDate()).padStart(2, "0")}`;
}

class UsageTracker {
  private async getUsage(): Promise<UsageData> {
    try {
      const raw = await AsyncStorage.getItem(USAGE_KEY);
      if (raw) {
        const data: UsageData = JSON.parse(raw);
        // Reset if it's a new day
        if (data.date !== getTodayString()) {
          return { date: getTodayString(), count: 0 };
        }
        return data;
      }
    } catch {
      // Fall through
    }
    return { date: getTodayString(), count: 0 };
  }

  /**
   * Check if user can ask a question.
   * Pro users always can. Free users limited to FREE_QUESTIONS_PER_DAY.
   */
  async canAskQuestion(isPro: boolean): Promise<boolean> {
    if (isPro) return true;
    const usage = await this.getUsage();
    return usage.count < FREE_QUESTIONS_PER_DAY;
  }

  /**
   * Get remaining questions for today (free tier).
   */
  async getRemainingQuestions(isPro: boolean): Promise<number> {
    if (isPro) return Infinity;
    const usage = await this.getUsage();
    return Math.max(0, FREE_QUESTIONS_PER_DAY - usage.count);
  }

  /**
   * Get count used today.
   */
  async getUsedToday(): Promise<number> {
    const usage = await this.getUsage();
    return usage.count;
  }

  /**
   * Increment the usage counter. Call AFTER a successful question.
   */
  async recordQuestion(): Promise<void> {
    const usage = await this.getUsage();
    usage.count += 1;
    await AsyncStorage.setItem(USAGE_KEY, JSON.stringify(usage));
  }
}

export default new UsageTracker();

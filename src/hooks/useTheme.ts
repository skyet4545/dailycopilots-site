// Bible Copilot — Theme Hook with triple-layer safety
import { useMemo } from "react";
import CoolBlueTheme, { ThemeColors } from "../constants/themes";
import { COLORS } from "../constants/theme";

// Fallback colors in case theme fails to load
const FALLBACK_COLORS: ThemeColors = {
  background: "#0a1628",
  surface: "rgba(255,255,255,0.04)",
  surfaceLight: "rgba(255,255,255,0.08)",
  surfaceBorder: "rgba(255,255,255,0.10)",
  accent: "#60A5FA",
  accentDark: "#3B82F6",
  gold: "#FBBF24",
  goldDark: "#D4AF37",
  textPrimary: "#FFFFFF",
  textSecondary: "#E8E8E8",
  textMuted: "#8E8E93",
  error: "#F87171",
  success: "#34D399",
  tabBar: "#0d1f35",
  tabBarBorder: "rgba(255,255,255,0.06)",
  cardBackground: "rgba(255,255,255,0.05)",
  cardBorder: "rgba(255,255,255,0.08)",
  gradientStart: "#0a1628",
  gradientEnd: "#000000",
};

export function useTheme() {
  const colors = useMemo(() => {
    try {
      // Layer 1: Try the theme object
      if (CoolBlueTheme?.colors) {
        return CoolBlueTheme.colors;
      }
    } catch {
      // Layer 2: Fall through
    }

    try {
      // Layer 2: Try COLORS constant
      if (COLORS) {
        return { ...FALLBACK_COLORS, ...COLORS };
      }
    } catch {
      // Layer 3: Fall through
    }

    // Layer 3: Hardcoded fallback — app never crashes
    return FALLBACK_COLORS;
  }, []);

  return { colors, theme: CoolBlueTheme };
}

export default useTheme;

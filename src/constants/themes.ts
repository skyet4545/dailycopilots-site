// Bible Copilot — Cool Blue Dark Theme (single theme)

export const CoolBlueTheme = {
  id: "cool-blue",
  name: "Cool Blue",
  colors: {
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
    // Gradient stops
    gradientStart: "#0a1628",
    gradientEnd: "#000000",
  },
};

export type ThemeColors = typeof CoolBlueTheme.colors;
export default CoolBlueTheme;

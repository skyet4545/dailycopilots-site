// Bible Copilot — Theme Constants

export const COLORS = {
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
};

export type StudyMode = "observe" | "interpret" | "theology" | "apply" | "apologetics";

export interface StudyCategory {
  id: StudyMode;
  label: string;
  icon: string;
  color: string;
  description: string;
}

export const STUDY_CATEGORIES: StudyCategory[] = [
  {
    id: "observe",
    label: "Observe",
    icon: "eye",
    color: "#60A5FA",
    description: "What does the text say?",
  },
  {
    id: "interpret",
    label: "Interpret",
    icon: "lightbulb-outline",
    color: "#A78BFA",
    description: "What does it mean?",
  },
  {
    id: "theology",
    label: "Theology",
    icon: "book-open-variant",
    color: "#34D399",
    description: "What does it teach about God?",
  },
  {
    id: "apply",
    label: "Apply",
    icon: "hand-heart",
    color: "#F87171",
    description: "How should I respond?",
  },
  {
    id: "apologetics",
    label: "Apologetics",
    icon: "shield-check",
    color: "#FBBF24",
    description: "How do I defend this?",
  },
];

export const BIBLE_TRANSLATIONS = [
  { id: "kjv", label: "KJV" },
  { id: "web", label: "WEB" },
  { id: "bbe", label: "BBE" },
  { id: "asv", label: "ASV" },
];

export const QUICK_PICKS = [
  "John 3:16",
  "Psalm 23",
  "Romans 8:28",
  "Philippians 4:13",
];

export const API_URL = "https://scripture-copilot-rust.vercel.app/api/chat";
export const BIBLE_API_URL = "https://bible-api.com";

export const FREE_QUESTIONS_PER_DAY = 10;

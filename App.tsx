// Bible Copilot — Main App (All Screens)
// Version 1.5.1 — IAP Fix + API Fix Build
// CRITICAL: Paywall shows on limit reached, NEVER an error

import React, { useState, useEffect, useCallback, useRef, useMemo, useContext, createContext } from "react";
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ScrollView,
  FlatList,
  StyleSheet,
  Dimensions,
  Modal,
  Alert,
  ActivityIndicator,
  StatusBar,
  Platform,
  Animated,
  KeyboardAvoidingView,
  Keyboard,
} from "react-native";
import { NavigationContainer, DarkTheme } from "@react-navigation/native";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import { SafeAreaProvider, SafeAreaView, useSafeAreaInsets } from "react-native-safe-area-context";
import { Ionicons, MaterialCommunityIcons } from "@expo/vector-icons";
import { LinearGradient } from "expo-linear-gradient";
import * as Haptics from "expo-haptics";
import AsyncStorage from "@react-native-async-storage/async-storage";

import { COLORS, STUDY_CATEGORIES, QUICK_PICKS, BIBLE_TRANSLATIONS, API_URL, BIBLE_API_URL, FREE_QUESTIONS_PER_DAY, StudyMode } from "./src/constants/theme";
import { useOnboarding, useSavedPassages, useJournal, useSettings, SavedPassage, JournalEntry, AppSettings } from "./src/hooks/useStorage";
import SubscriptionService, { PRODUCT_IDS } from "./src/services/SubscriptionService";
import UsageTracker from "./src/services/UsageTracker";

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get("window");
const Tab = createBottomTabNavigator();

// Shared state context to avoid stale initialParams
interface AppContextType {
  isPro: boolean;
  entries: JournalEntry[];
  passages: SavedPassage[];
  settings: { translation: string; hapticFeedback: boolean; fontSize: string };
  onShowPaywall: () => void;
  onRemoveEntry: (id: string) => void;
  onRemovePassage: (id: string) => void;
  onSelectPassage: (verse: string) => void;
  onSearchVerse: (verse: string) => void;
  onSelectMode: (mode: StudyMode) => void;
  onRestore: () => void;
  onUpdateSetting: <K extends keyof AppSettings>(key: K, value: AppSettings[K]) => void;
}
const AppContext = createContext<AppContextType>({} as AppContextType);

// =====================================================
// ONBOARDING SCREEN
// =====================================================
const ONBOARDING_SLIDES = [
  {
    title: "Welcome to\nBible Copilot",
    subtitle: "Your AI-powered Bible study companion",
    icon: "book-open-variant" as const,
    color: COLORS.accent,
  },
  {
    title: "Not Just\nAny AI",
    subtitle: "Trained on trusted commentaries and theological resources for accurate, faithful answers",
    icon: "brain" as const,
    color: "#A78BFA",
  },
  {
    title: "The Method\nMatters",
    subtitle: "Five study modes guide you through observation, interpretation, theology, application, and apologetics",
    icon: "compass" as const,
    color: "#34D399",
  },
  {
    title: "Go Deep",
    subtitle: "Cross-references, original language insights, and historical context at your fingertips",
    icon: "layers-triple" as const,
    color: "#FBBF24",
  },
  {
    title: "Ready to\nStudy?",
    subtitle: "Start with any verse. Ask any question. Grow in understanding.",
    icon: "rocket-launch" as const,
    color: COLORS.accent,
  },
];

function OnboardingScreen({ onComplete }: { onComplete: () => void }) {
  const [currentSlide, setCurrentSlide] = useState(0);
  const fadeAnim = useRef(new Animated.Value(1)).current;

  const goNext = () => {
    if (currentSlide < ONBOARDING_SLIDES.length - 1) {
      Animated.timing(fadeAnim, { toValue: 0, duration: 150, useNativeDriver: true }).start(() => {
        setCurrentSlide((prev) => prev + 1);
        Animated.timing(fadeAnim, { toValue: 1, duration: 300, useNativeDriver: true }).start();
      });
    } else {
      onComplete();
    }
  };

  const slide = ONBOARDING_SLIDES[currentSlide];
  const isLast = currentSlide === ONBOARDING_SLIDES.length - 1;

  return (
    <View style={[styles.screen, { justifyContent: "center", alignItems: "center", paddingHorizontal: 32 }]}>
      <StatusBar barStyle="light-content" />

      {/* Skip button */}
      {!isLast && (
        <TouchableOpacity style={styles.skipButton} onPress={onComplete}>
          <Text style={styles.skipText}>Skip</Text>
        </TouchableOpacity>
      )}

      <Animated.View style={{ opacity: fadeAnim, alignItems: "center" }}>
        {/* Icon */}
        <View style={[styles.onboardingIconWrap, { backgroundColor: slide.color + "20" }]}>
          <MaterialCommunityIcons name={slide.icon} size={64} color={slide.color} />
        </View>

        {/* Title */}
        <Text style={styles.onboardingTitle}>{slide.title}</Text>
        <Text style={styles.onboardingSubtitle}>{slide.subtitle}</Text>
      </Animated.View>

      {/* Dots */}
      <View style={styles.dotsRow}>
        {ONBOARDING_SLIDES.map((_, i) => (
          <View
            key={i}
            style={[
              styles.dot,
              i === currentSlide && { backgroundColor: COLORS.accent, width: 24 },
            ]}
          />
        ))}
      </View>

      {/* Continue / Get Started */}
      <TouchableOpacity style={styles.onboardingButton} onPress={goNext}>
        <LinearGradient
          colors={[COLORS.accent, COLORS.accentDark]}
          style={styles.onboardingButtonGradient}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 0 }}
        >
          <Text style={styles.onboardingButtonText}>
            {isLast ? "Get Started" : "Continue"}
          </Text>
        </LinearGradient>
      </TouchableOpacity>
    </View>
  );
}

// =====================================================
// PAYWALL SCREEN (Modal)
// CRITICAL: This is shown when free limit is reached
// NEVER show an error — ALWAYS show this paywall
// =====================================================
function PaywallScreen({
  visible,
  onDismiss,
  onPurchaseSuccess,
}: {
  visible: boolean;
  onDismiss: () => void;
  onPurchaseSuccess: () => void;
}) {
  const [selectedPlan, setSelectedPlan] = useState<"annual" | "monthly">("annual");
  const [purchasing, setPurchasing] = useState(false);
  const [restoring, setRestoring] = useState(false);

  const handlePurchase = async () => {
    setPurchasing(true);
    try {
      const productId =
        selectedPlan === "annual"
          ? PRODUCT_IDS.ANNUAL
          : PRODUCT_IDS.MONTHLY;

      const result = await SubscriptionService.purchaseSubscription(productId);

      if (result.success) {
        onPurchaseSuccess();
        onDismiss();
      } else if (result.error === "cancelled") {
        // User cancelled — do nothing
      } else {
        Alert.alert("Purchase Error", result.error || "Something went wrong. Please try again.");
      }
    } catch (error) {
      Alert.alert("Error", "Could not complete purchase. Please try again.");
    } finally {
      setPurchasing(false);
    }
  };

  const handleRestore = async () => {
    setRestoring(true);
    try {
      const restored = await SubscriptionService.restorePurchases();
      if (restored) {
        Alert.alert("Restored!", "Your Pro subscription has been restored.");
        onPurchaseSuccess();
        onDismiss();
      } else {
        Alert.alert("No Purchases Found", "We couldn't find any previous purchases to restore.");
      }
    } catch {
      Alert.alert("Error", "Could not restore purchases. Please try again.");
    } finally {
      setRestoring(false);
    }
  };

  const features = [
    { icon: "infinite", label: "Unlimited Questions" },
    { icon: "journal", label: "Study Journal" },
    { icon: "language", label: "All Translations" },
    { icon: "calendar", label: "Reading Plans" },
  ];

  return (
    <Modal visible={visible} animationType="slide" transparent={false} presentationStyle="pageSheet">
      <View style={[styles.screen, { paddingTop: 16 }]}>
        <StatusBar barStyle="light-content" />

        {/* Dismiss button */}
        <TouchableOpacity
          style={styles.paywallDismiss}
          onPress={onDismiss}
          hitSlop={{ top: 16, bottom: 16, left: 16, right: 16 }}
        >
          <Ionicons name="close" size={28} color={COLORS.textMuted} />
        </TouchableOpacity>

        <ScrollView contentContainerStyle={styles.paywallContent} showsVerticalScrollIndicator={false}>
          {/* Header */}
          <View style={styles.paywallHeader}>
            <MaterialCommunityIcons name="book-open-variant" size={48} color={COLORS.gold} />
            <Text style={styles.paywallTitle}>Understand Scripture{"\n"}Deeply</Text>
            <Text style={styles.paywallSubtitle}>
              Unlock the full power of Bible Copilot
            </Text>
          </View>

          {/* Features */}
          <View style={styles.paywallFeatures}>
            {features.map((f) => (
              <View key={f.label} style={styles.paywallFeatureRow}>
                <View style={styles.paywallFeatureIcon}>
                  <Ionicons name={f.icon as any} size={20} color={COLORS.accent} />
                </View>
                <Text style={styles.paywallFeatureText}>{f.label}</Text>
              </View>
            ))}
          </View>

          {/* Plan Cards — prices loaded dynamically from StoreKit via RevenueCat */}
          <TouchableOpacity
            style={[
              styles.planCard,
              selectedPlan === "annual" && styles.planCardSelected,
            ]}
            onPress={() => setSelectedPlan("annual")}
            activeOpacity={0.7}
          >
            <View style={styles.planCardBadge}>
              <Text style={styles.planCardBadgeText}>BEST VALUE</Text>
            </View>
            <View style={styles.planCardContent}>
              <Text style={styles.planCardTitle}>Annual</Text>
              <Text style={styles.planCardSub}>Billed once per year</Text>
            </View>
            <View style={[styles.planRadio, selectedPlan === "annual" && styles.planRadioSelected]}>
              {selectedPlan === "annual" && <View style={styles.planRadioDot} />}
            </View>
          </TouchableOpacity>

          <TouchableOpacity
            style={[
              styles.planCard,
              selectedPlan === "monthly" && styles.planCardSelected,
            ]}
            onPress={() => setSelectedPlan("monthly")}
            activeOpacity={0.7}
          >
            <View style={styles.planCardContent}>
              <Text style={styles.planCardTitle}>Monthly</Text>
              <Text style={styles.planCardSub}>Billed monthly</Text>
            </View>
            <View style={[styles.planRadio, selectedPlan === "monthly" && styles.planRadioSelected]}>
              {selectedPlan === "monthly" && <View style={styles.planRadioDot} />}
            </View>
          </TouchableOpacity>

          {/* CTA */}
          <TouchableOpacity
            style={styles.paywallCTA}
            onPress={handlePurchase}
            disabled={purchasing}
            activeOpacity={0.8}
          >
            <LinearGradient
              colors={[COLORS.gold, COLORS.accent]}
              style={styles.paywallCTAGradient}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
            >
              {purchasing ? (
                <ActivityIndicator color="#FFF" />
              ) : (
                <Text style={styles.paywallCTAText}>Continue</Text>
              )}
            </LinearGradient>
          </TouchableOpacity>

          <Text style={styles.paywallDisclaimer}>No commitment, cancel anytime</Text>

          {/* Restore */}
          <TouchableOpacity onPress={handleRestore} disabled={restoring} style={styles.restoreButton}>
            {restoring ? (
              <ActivityIndicator size="small" color={COLORS.textMuted} />
            ) : (
              <Text style={styles.restoreText}>Restore Purchases</Text>
            )}
          </TouchableOpacity>
        </ScrollView>
      </View>
    </Modal>
  );
}

// =====================================================
// HOME SCREEN
// =====================================================
function HomeScreen({
  onSearchVerse,
  onSelectMode,
}: {
  onSearchVerse: (verse: string) => void;
  onSelectMode: (mode: StudyMode) => void;
}) {
  const [searchText, setSearchText] = useState("");

  const handleSearch = () => {
    const trimmed = searchText.trim();
    if (trimmed) {
      onSearchVerse(trimmed);
      Keyboard.dismiss();
    }
  };

  const handleQuickPick = (verse: string) => {
    setSearchText(verse);
    onSearchVerse(verse);
  };

  return (
    <ScrollView style={styles.screen} contentContainerStyle={{ paddingBottom: 32 }} showsVerticalScrollIndicator={false}>
      {/* Hero */}
      <View style={styles.homeHero}>
        <MaterialCommunityIcons name="compass" size={48} color={COLORS.accent} />
        <Text style={styles.homeTitle}>Bible Copilot</Text>
        <Text style={styles.homeSubtitle}>Your AI Bible study companion</Text>
      </View>

      {/* Search */}
      <View style={styles.searchContainer}>
        <View style={styles.searchInputWrap}>
          <MaterialCommunityIcons name="book-open-page-variant" size={20} color={COLORS.textMuted} style={{ marginRight: 8 }} />
          <TextInput
            style={styles.searchInput}
            placeholder="Enter any verse..."
            placeholderTextColor={COLORS.textMuted}
            value={searchText}
            onChangeText={setSearchText}
            onSubmitEditing={handleSearch}
            returnKeyType="search"
            autoCorrect={false}
          />
          {searchText.length > 0 && (
            <TouchableOpacity onPress={() => setSearchText("")}>
              <Ionicons name="close-circle" size={18} color={COLORS.textMuted} />
            </TouchableOpacity>
          )}
        </View>
        <TouchableOpacity style={styles.searchButton} onPress={handleSearch}>
          <Ionicons name="search" size={20} color="#FFF" />
        </TouchableOpacity>
      </View>

      {/* Quick Picks */}
      <View style={styles.quickPicksRow}>
        {QUICK_PICKS.map((v) => (
          <TouchableOpacity
            key={v}
            style={styles.quickPickChip}
            onPress={() => handleQuickPick(v)}
          >
            <Text style={styles.quickPickText}>{v}</Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Study Modes */}
      <Text style={styles.sectionTitle}>HOW DO YOU WANT TO STUDY?</Text>
      <View style={styles.modeGrid}>
        {STUDY_CATEGORIES.slice(0, 4).map((cat) => (
          <TouchableOpacity
            key={cat.id}
            style={[styles.modeCard, { borderColor: cat.color + "30" }]}
            onPress={() => onSelectMode(cat.id)}
            activeOpacity={0.7}
          >
            <View style={[styles.modeIconWrap, { backgroundColor: cat.color + "20" }]}>
              <MaterialCommunityIcons name={cat.icon as any} size={28} color={cat.color} />
            </View>
            <Text style={[styles.modeLabel, { color: cat.color }]}>{cat.label}</Text>
            <Text style={styles.modeDesc}>{cat.description}</Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Apologetics — full width */}
      {(() => {
        const apol = STUDY_CATEGORIES[4];
        return (
          <TouchableOpacity
            style={[styles.modeCardFull, { borderColor: apol.color + "30" }]}
            onPress={() => onSelectMode(apol.id)}
            activeOpacity={0.7}
          >
            <View style={[styles.modeIconWrap, { backgroundColor: apol.color + "20" }]}>
              <MaterialCommunityIcons name={apol.icon as any} size={28} color={apol.color} />
            </View>
            <View style={{ flex: 1, marginLeft: 12 }}>
              <Text style={[styles.modeLabel, { color: apol.color }]}>{apol.label}</Text>
              <Text style={styles.modeDesc}>{apol.description}</Text>
            </View>
          </TouchableOpacity>
        );
      })()}
    </ScrollView>
  );
}

// =====================================================
// STUDY SCREEN
// =====================================================
function StudyScreen({
  verse,
  initialMode,
  isPro,
  onShowPaywall,
  onSavePassage,
  onSaveJournal,
}: {
  verse: string;
  initialMode?: StudyMode;
  isPro: boolean;
  onShowPaywall: () => void;
  onSavePassage: (passage: { reference: string; text: string; translation: string }) => void;
  onSaveJournal: (entry: { reference: string; mode: string; response: string }) => void;
}) {
  const [verseText, setVerseText] = useState("");
  const [verseLoading, setVerseLoading] = useState(true);
  const [selectedMode, setSelectedMode] = useState<StudyMode | null>(initialMode || null);
  const [aiResponse, setAiResponse] = useState("");
  const [aiLoading, setAiLoading] = useState(false);
  const [crossRefs, setCrossRefs] = useState<string[]>([]);
  const [usedToday, setUsedToday] = useState(0);
  const [translation] = useState("kjv");
  const scrollRef = useRef<ScrollView>(null);

  // Fetch verse text
  useEffect(() => {
    fetchVerse();
    loadUsage();
  }, [verse]);

  const loadUsage = async () => {
    const used = await UsageTracker.getUsedToday();
    setUsedToday(used);
  };

  const fetchVerse = async () => {
    setVerseLoading(true);
    try {
      const ref = encodeURIComponent(verse);
      const res = await fetch(`${BIBLE_API_URL}/${ref}?translation=${translation}`);
      const data = await res.json();
      if (data.verses && data.verses.length > 0) {
        // Show verse numbers when multiple verses, or single verse number for single verse
        const formatted = data.verses.length === 1
          ? data.verses[0].text.trim()
          : data.verses.map((v: { verse: number; text: string }) =>
              `[${v.verse}] ${v.text.trim()}`
            ).join("\n\n");
        setVerseText(formatted);
      } else if (data.text) {
        setVerseText(data.text.trim());
      } else {
        setVerseText("Verse not found. Try a different reference.");
      }
    } catch {
      setVerseText("Could not load verse. Check your connection.");
    } finally {
      setVerseLoading(false);
    }
  };

  // ==================================================
  // CRITICAL FIX: handleModeSelect
  // When limit is reached → show PAYWALL, never an error
  // ==================================================
  const handleModeSelect = async (mode: StudyMode) => {
    setSelectedMode(mode);

    // CRITICAL: Check usage BEFORE making API call
    const canAsk = await UsageTracker.canAskQuestion(isPro);
    if (!canAsk) {
      // PAYWALL — not an error. This is THE fix for Apple rejection.
      onShowPaywall();
      return;
    }

    // User can ask — proceed with AI query
    setAiLoading(true);
    setAiResponse("");
    setCrossRefs([]);

    try {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    } catch {}

    try {
      const message = `Study "${verse}" using the ${mode} method. Verse text: "${verseText}"`;

      // SSE streaming
      const response = await fetch(API_URL, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message, passage: verse, mode }),
      });

      if (!response.ok) {
        throw new Error(`API error: ${response.status}`);
      }

      const reader = response.body?.getReader();
      if (!reader) {
        throw new Error("No reader available");
      }

      const decoder = new TextDecoder();
      let fullText = "";

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        const chunk = decoder.decode(value, { stream: true });
        const lines = chunk.split("\n");

        for (const line of lines) {
          if (line.startsWith("data: ")) {
            const data = line.slice(6);
            if (data === "[DONE]") continue;
            try {
              const parsed = JSON.parse(data);
              // Support both API formats: {content} and OpenAI {choices[0].delta.content}
              const content = parsed.content ?? parsed.choices?.[0]?.delta?.content;
              if (content) {
                fullText += content;
                setAiResponse(fullText);
              }
            } catch {
              // Not JSON, might be plain text streaming
              if (data && data !== "[DONE]") {
                fullText += data;
                setAiResponse(fullText);
              }
            }
          }
        }
      }

      // Record the question usage AFTER successful response
      await UsageTracker.recordQuestion();
      await loadUsage();

      // Extract cross-references (simple pattern matching)
      const refPattern = /(?:Genesis|Exodus|Leviticus|Numbers|Deuteronomy|Joshua|Judges|Ruth|1 Samuel|2 Samuel|1 Kings|2 Kings|1 Chronicles|2 Chronicles|Ezra|Nehemiah|Esther|Job|Psalm|Psalms|Proverbs|Ecclesiastes|Song of Solomon|Isaiah|Jeremiah|Lamentations|Ezekiel|Daniel|Hosea|Joel|Amos|Obadiah|Jonah|Micah|Nahum|Habakkuk|Zephaniah|Haggai|Zechariah|Malachi|Matthew|Mark|Luke|John|Acts|Romans|1 Corinthians|2 Corinthians|Galatians|Ephesians|Philippians|Colossians|1 Thessalonians|2 Thessalonians|1 Timothy|2 Timothy|Titus|Philemon|Hebrews|James|1 Peter|2 Peter|1 John|2 John|3 John|Jude|Revelation)\s+\d+:\d+(?:-\d+)?/g;
      const refs = fullText.match(refPattern) || [];
      const uniqueRefs = [...new Set(refs)].slice(0, 5);
      setCrossRefs(uniqueRefs);
    } catch (error) {
      // Network/API error — show actual error (this is NOT usage limit)
      setAiResponse("Unable to get a response. Please check your connection and try again.");
    } finally {
      setAiLoading(false);
    }
  };

  const handleSavePassage = () => {
    if (verseText && verse) {
      onSavePassage({ reference: verse, text: verseText, translation });
      try { Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success); } catch {}
      Alert.alert("Saved!", `${verse} has been saved to your collection.`);
    }
  };

  const handleSaveToJournal = () => {
    if (aiResponse && selectedMode) {
      onSaveJournal({ reference: verse, mode: selectedMode, response: aiResponse });
      try { Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success); } catch {}
      Alert.alert("Saved!", "Study saved to your journal.");
    }
  };

  return (
    <ScrollView ref={scrollRef} style={styles.screen} contentContainerStyle={{ paddingBottom: 40 }} showsVerticalScrollIndicator={false}>
      {/* Usage Counter — removed to comply with App Store guideline 2.3.7 */}

      {/* Verse Display */}
      <View style={styles.verseCard}>
        <View style={styles.verseHeader}>
          <Text style={styles.verseReference}>{verse}</Text>
          <TouchableOpacity onPress={handleSavePassage}>
            <Ionicons name="bookmark-outline" size={22} color={COLORS.gold} />
          </TouchableOpacity>
        </View>
        {verseLoading ? (
          <ActivityIndicator color={COLORS.accent} style={{ marginVertical: 20 }} />
        ) : (
          <Text style={styles.verseText}>{verseText}</Text>
        )}
        <Text style={styles.translationBadge}>{translation.toUpperCase()}</Text>
      </View>

      {/* Study Mode Pills */}
      <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.modePillsScroll} contentContainerStyle={{ paddingHorizontal: 16 }}>
        {STUDY_CATEGORIES.map((cat) => (
          <TouchableOpacity
            key={cat.id}
            style={[
              styles.modePill,
              selectedMode === cat.id && { backgroundColor: cat.color + "30", borderColor: cat.color },
            ]}
            onPress={() => handleModeSelect(cat.id)}
          >
            <MaterialCommunityIcons name={cat.icon as any} size={16} color={selectedMode === cat.id ? cat.color : COLORS.textMuted} />
            <Text style={[styles.modePillText, selectedMode === cat.id && { color: cat.color }]}>
              {cat.label}
            </Text>
          </TouchableOpacity>
        ))}
      </ScrollView>

      {/* AI Response */}
      {(aiLoading || aiResponse) && (
        <View style={styles.responseCard}>
          <View style={styles.responseHeader}>
            <MaterialCommunityIcons name="robot" size={18} color={COLORS.accent} />
            <Text style={styles.responseHeaderText}>
              {selectedMode ? STUDY_CATEGORIES.find((c) => c.id === selectedMode)?.label : "Study"} Analysis
            </Text>
            {aiResponse && !aiLoading && (
              <TouchableOpacity onPress={handleSaveToJournal} style={{ marginLeft: "auto" }}>
                <Ionicons name="journal-outline" size={20} color={COLORS.gold} />
              </TouchableOpacity>
            )}
          </View>
          {aiLoading && !aiResponse && (
            <View style={{ flexDirection: "row", alignItems: "center", paddingVertical: 16 }}>
              <ActivityIndicator color={COLORS.accent} size="small" />
              <Text style={{ color: COLORS.textMuted, marginLeft: 8 }}>Studying...</Text>
            </View>
          )}
          {aiResponse ? (
            <Text style={styles.responseText}>{aiResponse}</Text>
          ) : null}
          {aiLoading && aiResponse && (
            <View style={styles.typingIndicator}>
              <View style={[styles.typingDot, { opacity: 0.3 }]} />
              <View style={[styles.typingDot, { opacity: 0.6 }]} />
              <View style={[styles.typingDot, { opacity: 1 }]} />
            </View>
          )}
        </View>
      )}

      {/* Cross References */}
      {crossRefs.length > 0 && (
        <View style={styles.crossRefsCard}>
          <Text style={styles.crossRefsTitle}>Cross References</Text>
          {crossRefs.map((ref, i) => (
            <View key={i} style={styles.crossRefItem}>
              <Ionicons name="link" size={14} color={COLORS.accent} />
              <Text style={styles.crossRefText}>{ref}</Text>
            </View>
          ))}
        </View>
      )}
    </ScrollView>
  );
}

// =====================================================
// READING PLANS SCREEN
// =====================================================
const READING_PLANS = [
  {
    id: "gospel-john",
    title: "Gospel of John",
    description: "21 days through the Gospel of John",
    days: 21,
    icon: "book-open-variant",
    color: COLORS.accent,
  },
  {
    id: "psalms-30",
    title: "30 Days of Psalms",
    description: "A psalm a day for a month",
    days: 30,
    icon: "music-note",
    color: "#A78BFA",
  },
  {
    id: "romans-deep",
    title: "Romans Deep Dive",
    description: "16 chapters, 16 days of theology",
    days: 16,
    icon: "school",
    color: "#34D399",
  },
  {
    id: "proverbs-31",
    title: "Proverbs 31",
    description: "Wisdom for every day of the month",
    days: 31,
    icon: "lightbulb-on",
    color: "#FBBF24",
  },
  {
    id: "sermon-mount",
    title: "Sermon on the Mount",
    description: "7 days through Matthew 5-7",
    days: 7,
    icon: "terrain",
    color: "#F87171",
  },
];

function ReadingPlansScreen({ isPro, onShowPaywall }: { isPro: boolean; onShowPaywall: () => void }) {
  const handleStartPlan = (planId: string) => {
    if (!isPro) {
      onShowPaywall();
      return;
    }
    Alert.alert("Coming Soon", "Reading plans will be fully interactive in the next update!");
  };

  return (
    <ScrollView style={styles.screen} contentContainerStyle={{ paddingBottom: 32 }}>
      <Text style={styles.screenTitle}>Reading Plans</Text>
      <Text style={styles.screenSubtitle}>Guided study through Scripture</Text>

      {READING_PLANS.map((plan) => (
        <TouchableOpacity
          key={plan.id}
          style={styles.planCard}
          onPress={() => handleStartPlan(plan.id)}
          activeOpacity={0.7}
        >
          <View style={[styles.planIconWrap, { backgroundColor: plan.color + "20" }]}>
            <MaterialCommunityIcons name={plan.icon as any} size={28} color={plan.color} />
          </View>
          <View style={styles.planInfo}>
            <Text style={styles.planTitle}>{plan.title}</Text>
            <Text style={styles.planDescription}>{plan.description}</Text>
            <Text style={[styles.planDays, { color: plan.color }]}>{plan.days} days</Text>
          </View>
          <Ionicons name="chevron-forward" size={20} color={COLORS.textMuted} />
        </TouchableOpacity>
      ))}

      {!isPro && (
        <TouchableOpacity style={styles.proPromptCard} onPress={onShowPaywall}>
          <Ionicons name="lock-closed" size={20} color={COLORS.gold} />
          <Text style={styles.proPromptText}>Unlock all reading plans with Pro</Text>
          <Ionicons name="chevron-forward" size={16} color={COLORS.gold} />
        </TouchableOpacity>
      )}
    </ScrollView>
  );
}

// =====================================================
// JOURNAL SCREEN
// =====================================================
function JournalScreen({
  entries,
  onRemoveEntry,
  isPro,
  onShowPaywall,
}: {
  entries: JournalEntry[];
  onRemoveEntry: (id: string) => void;
  isPro: boolean;
  onShowPaywall: () => void;
}) {
  if (!isPro) {
    return (
      <View style={[styles.screen, styles.emptyScreen]}>
        <MaterialCommunityIcons name="notebook-multiple" size={64} color={COLORS.textMuted} />
        <Text style={styles.emptyTitle}>Study Journal</Text>
        <Text style={styles.emptySubtitle}>Save your AI study insights and reflections</Text>
        <TouchableOpacity style={styles.emptyButton} onPress={onShowPaywall}>
          <LinearGradient colors={[COLORS.gold, COLORS.accent]} style={styles.emptyButtonGradient} start={{ x: 0, y: 0 }} end={{ x: 1, y: 0 }}>
            <Text style={styles.emptyButtonText}>Unlock with Pro</Text>
          </LinearGradient>
        </TouchableOpacity>
      </View>
    );
  }

  if (entries.length === 0) {
    return (
      <View style={[styles.screen, styles.emptyScreen]}>
        <MaterialCommunityIcons name="notebook-multiple" size={64} color={COLORS.textMuted} />
        <Text style={styles.emptyTitle}>No Journal Entries Yet</Text>
        <Text style={styles.emptySubtitle}>Study a verse and save the response to start your journal</Text>
      </View>
    );
  }

  return (
    <FlatList
      style={styles.screen}
      contentContainerStyle={{ paddingBottom: 32, paddingTop: 16 }}
      ListHeaderComponent={
        <>
          <Text style={styles.screenTitle}>Study Journal</Text>
          <Text style={styles.screenSubtitle}>{entries.length} saved {entries.length === 1 ? "study" : "studies"}</Text>
        </>
      }
      data={entries}
      keyExtractor={(item) => item.id}
      renderItem={({ item }) => {
        const cat = STUDY_CATEGORIES.find((c) => c.id === item.mode);
        return (
          <View style={styles.journalCard}>
            <View style={styles.journalCardHeader}>
              <Text style={[styles.journalRef, { color: cat?.color || COLORS.accent }]}>
                {item.reference}
              </Text>
              <View style={[styles.journalModeBadge, { backgroundColor: (cat?.color || COLORS.accent) + "20" }]}>
                <Text style={[styles.journalModeText, { color: cat?.color || COLORS.accent }]}>
                  {cat?.label || item.mode}
                </Text>
              </View>
            </View>
            <Text style={styles.journalContent} numberOfLines={6}>
              {item.response}
            </Text>
            <View style={styles.journalCardFooter}>
              <Text style={styles.journalDate}>
                {new Date(item.createdAt).toLocaleDateString()}
              </Text>
              <TouchableOpacity
                onPress={() => {
                  Alert.alert("Delete Entry", "Remove this journal entry?", [
                    { text: "Cancel", style: "cancel" },
                    { text: "Delete", style: "destructive", onPress: () => onRemoveEntry(item.id) },
                  ]);
                }}
              >
                <Ionicons name="trash-outline" size={18} color={COLORS.textMuted} />
              </TouchableOpacity>
            </View>
          </View>
        );
      }}
    />
  );
}

// =====================================================
// SAVED SCREEN
// =====================================================
function SavedScreen({
  passages,
  onRemovePassage,
  onSelectPassage,
}: {
  passages: SavedPassage[];
  onRemovePassage: (id: string) => void;
  onSelectPassage: (verse: string) => void;
}) {
  if (passages.length === 0) {
    return (
      <View style={[styles.screen, styles.emptyScreen]}>
        <Ionicons name="bookmark-outline" size={64} color={COLORS.textMuted} />
        <Text style={styles.emptyTitle}>No Saved Passages</Text>
        <Text style={styles.emptySubtitle}>Bookmark verses while studying to save them here</Text>
      </View>
    );
  }

  return (
    <FlatList
      style={styles.screen}
      contentContainerStyle={{ paddingBottom: 32, paddingTop: 16 }}
      ListHeaderComponent={
        <>
          <Text style={styles.screenTitle}>Saved Passages</Text>
          <Text style={styles.screenSubtitle}>{passages.length} saved {passages.length === 1 ? "verse" : "verses"}</Text>
        </>
      }
      data={passages}
      keyExtractor={(item) => item.id}
      renderItem={({ item }) => (
        <TouchableOpacity
          style={styles.savedCard}
          onPress={() => onSelectPassage(item.reference)}
          activeOpacity={0.7}
        >
          <View style={styles.savedCardHeader}>
            <Text style={styles.savedRef}>{item.reference}</Text>
            <Text style={styles.savedTranslation}>{item.translation.toUpperCase()}</Text>
          </View>
          <Text style={styles.savedText} numberOfLines={3}>{item.text}</Text>
          <View style={styles.savedCardFooter}>
            <Text style={styles.savedDate}>
              {new Date(item.savedAt).toLocaleDateString()}
            </Text>
            <TouchableOpacity
              onPress={() => {
                Alert.alert("Remove Passage", `Remove ${item.reference}?`, [
                  { text: "Cancel", style: "cancel" },
                  { text: "Remove", style: "destructive", onPress: () => onRemovePassage(item.id) },
                ]);
              }}
            >
              <Ionicons name="trash-outline" size={18} color={COLORS.textMuted} />
            </TouchableOpacity>
          </View>
        </TouchableOpacity>
      )}
    />
  );
}

// =====================================================
// SETTINGS SCREEN
// =====================================================
function SettingsScreen({
  isPro,
  onShowPaywall,
  onRestore,
  settings,
  onUpdateSetting,
}: {
  isPro: boolean;
  onShowPaywall: () => void;
  onRestore: () => void;
  settings: { translation: string; hapticFeedback: boolean; fontSize: string };
  onUpdateSetting: <K extends keyof AppSettings>(key: K, value: AppSettings[K]) => void;
}) {
  return (
    <ScrollView style={styles.screen} contentContainerStyle={{ paddingBottom: 40 }}>
      <Text style={styles.screenTitle}>Settings</Text>

      {/* Pro Status */}
      <View style={styles.settingsSection}>
        <Text style={styles.settingsSectionTitle}>SUBSCRIPTION</Text>
        {isPro ? (
          <View style={styles.settingsCard}>
            <View style={{ flexDirection: "row", alignItems: "center" }}>
              <Ionicons name="checkmark-circle" size={22} color={COLORS.success} />
              <Text style={[styles.settingsLabel, { marginLeft: 8 }]}>Bible Copilot Pro</Text>
            </View>
            <Text style={styles.settingsValue}>Active</Text>
          </View>
        ) : (
          <TouchableOpacity style={styles.settingsCard} onPress={onShowPaywall}>
            <View style={{ flexDirection: "row", alignItems: "center" }}>
              <Ionicons name="star" size={22} color={COLORS.gold} />
              <Text style={[styles.settingsLabel, { marginLeft: 8 }]}>Upgrade to Pro</Text>
            </View>
            <Ionicons name="chevron-forward" size={20} color={COLORS.textMuted} />
          </TouchableOpacity>
        )}
      </View>

      {/* Translation */}
      <View style={styles.settingsSection}>
        <Text style={styles.settingsSectionTitle}>BIBLE TRANSLATION</Text>
        {BIBLE_TRANSLATIONS.map((t) => (
          <TouchableOpacity
            key={t.id}
            style={styles.settingsCard}
            onPress={() => onUpdateSetting("translation", t.id)}
          >
            <Text style={styles.settingsLabel}>{t.label}</Text>
            {settings.translation === t.id && (
              <Ionicons name="checkmark" size={20} color={COLORS.accent} />
            )}
          </TouchableOpacity>
        ))}
      </View>

      {/* About */}
      <View style={styles.settingsSection}>
        <Text style={styles.settingsSectionTitle}>ABOUT</Text>
        <View style={styles.settingsCard}>
          <Text style={styles.settingsLabel}>Version</Text>
          <Text style={styles.settingsValue}>1.5.1</Text>
        </View>
        <TouchableOpacity style={styles.settingsCard} onPress={onRestore}>
          <Text style={styles.settingsLabel}>Restore Purchases</Text>
          <Ionicons name="refresh" size={20} color={COLORS.textMuted} />
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
}

// =====================================================
// TAB NAVIGATOR WRAPPER SCREENS
// =====================================================

// These wrapper components receive the shared state via context-like props
// passed through the tab navigator's screenOptions

function HomeTabScreen() {
  const { onSearchVerse, onSelectMode } = useContext(AppContext);
  return <HomeScreen onSearchVerse={onSearchVerse} onSelectMode={onSelectMode} />;
}

function PlansTabScreen() {
  const { isPro, onShowPaywall } = useContext(AppContext);
  return <ReadingPlansScreen isPro={isPro} onShowPaywall={onShowPaywall} />;
}

function JournalTabScreen() {
  const { entries, onRemoveEntry, isPro, onShowPaywall } = useContext(AppContext);
  return <JournalScreen entries={entries} onRemoveEntry={onRemoveEntry} isPro={isPro} onShowPaywall={onShowPaywall} />;
}

function SavedTabScreen() {
  const { passages, onRemovePassage, onSelectPassage } = useContext(AppContext);
  return <SavedScreen passages={passages} onRemovePassage={onRemovePassage} onSelectPassage={onSelectPassage} />;
}

function SettingsTabScreen() {
  const { isPro, onShowPaywall, onRestore, settings, onUpdateSetting } = useContext(AppContext);
  return (
    <SettingsScreen
      isPro={isPro}
      onShowPaywall={onShowPaywall}
      onRestore={onRestore}
      settings={settings}
      onUpdateSetting={onUpdateSetting}
    />
  );
}

// =====================================================
// MAIN APP
// =====================================================
export default function App() {
  // --- State ---
  const [isPro, setIsPro] = useState(false);
  const [showPaywall, setShowPaywall] = useState(false);
  const [currentVerse, setCurrentVerse] = useState<string | null>(null);
  const [currentMode, setCurrentMode] = useState<StudyMode | undefined>(undefined);
  const [showStudy, setShowStudy] = useState(false);

  // Hooks
  const { onboardingComplete, setOnboardingComplete, loaded: onboardingLoaded } = useOnboarding();
  const { passages, addPassage, removePassage } = useSavedPassages();
  const { entries, addEntry, removeEntry } = useJournal();
  const { settings, updateSetting } = useSettings();

  // Init RevenueCat
  useEffect(() => {
    const init = async () => {
      await SubscriptionService.initialize();
      const pro = await SubscriptionService.isPro();
      setIsPro(pro);
    };
    init();
  }, []);

  // Handlers
  const handleSearchVerse = useCallback((verse: string) => {
    setCurrentVerse(verse);
    setCurrentMode(undefined);
    setShowStudy(true);
  }, []);

  const handleSelectMode = useCallback((mode: StudyMode) => {
    if (!currentVerse) {
      // If no verse selected, prompt user
      setCurrentMode(mode);
      return;
    }
    setCurrentMode(mode);
    setShowStudy(true);
  }, [currentVerse]);

  const handleSelectPassage = useCallback((verse: string) => {
    setCurrentVerse(verse);
    setCurrentMode(undefined);
    setShowStudy(true);
  }, []);

  // CRITICAL: Show paywall handler — never an error
  const handleShowPaywall = useCallback(() => {
    setShowPaywall(true);
  }, []);

  const handlePurchaseSuccess = useCallback(() => {
    setIsPro(true);
  }, []);

  const handleRestore = useCallback(async () => {
    const restored = await SubscriptionService.restorePurchases();
    if (restored) {
      setIsPro(true);
      Alert.alert("Restored!", "Your Pro subscription has been restored.");
    } else {
      Alert.alert("No Purchases Found", "We couldn't find any previous purchases to restore.");
    }
  }, []);

  const handleSavePassage = useCallback(
    (passage: { reference: string; text: string; translation: string }) => {
      addPassage(passage);
    },
    [addPassage]
  );

  const handleSaveJournal = useCallback(
    (entry: { reference: string; mode: string; response: string }) => {
      addEntry(entry);
    },
    [addEntry]
  );

  // Loading
  if (!onboardingLoaded) {
    return (
      <View style={[styles.screen, { justifyContent: "center", alignItems: "center" }]}>
        <ActivityIndicator size="large" color={COLORS.accent} />
      </View>
    );
  }

  // Onboarding
  if (!onboardingComplete) {
    return (
      <SafeAreaProvider>
        <OnboardingScreen onComplete={() => setOnboardingComplete(true)} />
      </SafeAreaProvider>
    );
  }

  const navTheme = {
    ...DarkTheme,
    colors: {
      ...DarkTheme.colors,
      background: COLORS.background,
      card: COLORS.tabBar,
      border: COLORS.tabBarBorder,
      primary: COLORS.accent,
    },
  };

  return (
    <SafeAreaProvider>
      <StatusBar barStyle="light-content" />

      {/* Study Screen Modal */}
      <Modal visible={showStudy && !!currentVerse} animationType="slide" presentationStyle="pageSheet">
        <SafeAreaView style={styles.screen}>
          <View style={styles.studyModalHeader}>
            <TouchableOpacity onPress={() => setShowStudy(false)}>
              <Ionicons name="chevron-down" size={28} color={COLORS.textPrimary} />
            </TouchableOpacity>
            <Text style={styles.studyModalTitle}>Study</Text>
            <View style={{ width: 28 }} />
          </View>
          {currentVerse && (
            <StudyScreen
              verse={currentVerse}
              initialMode={currentMode}
              isPro={isPro}
              onShowPaywall={handleShowPaywall}
              onSavePassage={handleSavePassage}
              onSaveJournal={handleSaveJournal}
            />
          )}
        </SafeAreaView>
      </Modal>

      {/* Paywall Modal — CRITICAL: This is shown instead of an error */}
      <PaywallScreen
        visible={showPaywall}
        onDismiss={() => setShowPaywall(false)}
        onPurchaseSuccess={handlePurchaseSuccess}
      />

      <AppContext.Provider
        value={{
          isPro,
          entries,
          passages,
          settings,
          onShowPaywall: handleShowPaywall,
          onRemoveEntry: removeEntry,
          onRemovePassage: removePassage,
          onSelectPassage: handleSelectPassage,
          onSearchVerse: handleSearchVerse,
          onSelectMode: handleSelectMode,
          onRestore: handleRestore,
          onUpdateSetting: updateSetting,
        }}
      >
        <NavigationContainer theme={navTheme}>
          <Tab.Navigator
            screenOptions={{
              headerShown: false,
              tabBarActiveTintColor: COLORS.accent,
              tabBarInactiveTintColor: COLORS.textMuted,
              tabBarStyle: {
                backgroundColor: COLORS.tabBar,
                borderTopColor: COLORS.tabBarBorder,
                paddingBottom: Platform.OS === "ios" ? 24 : 8,
                paddingTop: 8,
                height: Platform.OS === "ios" ? 88 : 64,
              },
              tabBarLabelStyle: {
                fontSize: 11,
                fontWeight: "600",
              },
            }}
          >
            <Tab.Screen
              name="Home"
              component={HomeTabScreen}
              options={{
                tabBarIcon: ({ color, size }) => <Ionicons name="home" size={size} color={color} />,
              }}
            />
            <Tab.Screen
              name="Plans"
              component={PlansTabScreen}
              options={{
                tabBarIcon: ({ color, size }) => <Ionicons name="calendar" size={size} color={color} />,
              }}
            />
            <Tab.Screen
              name="Journal"
              component={JournalTabScreen}
              options={{
                tabBarIcon: ({ color, size }) => <Ionicons name="journal" size={size} color={color} />,
              }}
            />
            <Tab.Screen
              name="Saved"
              component={SavedTabScreen}
              options={{
                tabBarIcon: ({ color, size }) => <Ionicons name="bookmark" size={size} color={color} />,
              }}
            />
            <Tab.Screen
              name="Settings"
              component={SettingsTabScreen}
              options={{
                tabBarIcon: ({ color, size }) => <Ionicons name="settings" size={size} color={color} />,
              }}
            />
          </Tab.Navigator>
        </NavigationContainer>
      </AppContext.Provider>
    </SafeAreaProvider>
  );
}

// =====================================================
// STYLES
// =====================================================
const styles = StyleSheet.create({
  screen: {
    flex: 1,
    backgroundColor: COLORS.background,
  },

  // --- Onboarding ---
  skipButton: {
    position: "absolute",
    top: 60,
    right: 24,
    zIndex: 10,
  },
  skipText: {
    color: COLORS.textMuted,
    fontSize: 16,
  },
  onboardingIconWrap: {
    width: 120,
    height: 120,
    borderRadius: 60,
    justifyContent: "center",
    alignItems: "center",
    marginBottom: 32,
  },
  onboardingTitle: {
    fontSize: 32,
    fontWeight: "800",
    color: COLORS.textPrimary,
    textAlign: "center",
    marginBottom: 12,
    lineHeight: 40,
  },
  onboardingSubtitle: {
    fontSize: 16,
    color: COLORS.textSecondary,
    textAlign: "center",
    lineHeight: 24,
    paddingHorizontal: 16,
  },
  dotsRow: {
    flexDirection: "row",
    justifyContent: "center",
    alignItems: "center",
    position: "absolute",
    bottom: 140,
    gap: 8,
  },
  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: COLORS.textMuted,
  },
  onboardingButton: {
    position: "absolute",
    bottom: 60,
    left: 32,
    right: 32,
  },
  onboardingButtonGradient: {
    paddingVertical: 16,
    borderRadius: 16,
    alignItems: "center",
  },
  onboardingButtonText: {
    color: "#FFF",
    fontSize: 18,
    fontWeight: "700",
  },

  // --- Paywall ---
  paywallDismiss: {
    position: "absolute",
    top: 16,
    right: 16,
    zIndex: 10,
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: COLORS.surfaceLight,
    justifyContent: "center",
    alignItems: "center",
  },
  paywallContent: {
    paddingHorizontal: 24,
    paddingTop: 60,
    paddingBottom: 40,
  },
  paywallHeader: {
    alignItems: "center",
    marginBottom: 32,
  },
  paywallTitle: {
    fontSize: 28,
    fontWeight: "800",
    color: COLORS.textPrimary,
    textAlign: "center",
    marginTop: 16,
    lineHeight: 36,
  },
  paywallSubtitle: {
    fontSize: 15,
    color: COLORS.textSecondary,
    textAlign: "center",
    marginTop: 8,
  },
  paywallFeatures: {
    marginBottom: 28,
  },
  paywallFeatureRow: {
    flexDirection: "row",
    alignItems: "center",
    paddingVertical: 10,
  },
  paywallFeatureIcon: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: COLORS.accent + "15",
    justifyContent: "center",
    alignItems: "center",
    marginRight: 12,
  },
  paywallFeatureText: {
    fontSize: 16,
    color: COLORS.textPrimary,
    fontWeight: "500",
  },
  planCard: {
    flexDirection: "row",
    alignItems: "center",
    padding: 16,
    borderRadius: 16,
    borderWidth: 1.5,
    borderColor: COLORS.cardBorder,
    backgroundColor: COLORS.cardBackground,
    marginBottom: 12,
    position: "relative",
    overflow: "hidden",
  },
  planCardSelected: {
    borderColor: COLORS.accent,
    backgroundColor: COLORS.accent + "10",
  },
  planCardBadge: {
    position: "absolute",
    top: 0,
    right: 0,
    backgroundColor: COLORS.gold,
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderBottomLeftRadius: 10,
  },
  planCardBadgeText: {
    fontSize: 10,
    fontWeight: "800",
    color: "#000",
  },
  planCardContent: {
    flex: 1,
  },
  planCardTitle: {
    fontSize: 16,
    fontWeight: "700",
    color: COLORS.textPrimary,
  },
  planCardPrice: {
    fontSize: 20,
    fontWeight: "800",
    color: COLORS.textPrimary,
    marginTop: 2,
  },
  planCardSub: {
    fontSize: 13,
    color: COLORS.textMuted,
    marginTop: 2,
  },
  planRadio: {
    width: 22,
    height: 22,
    borderRadius: 11,
    borderWidth: 2,
    borderColor: COLORS.textMuted,
    justifyContent: "center",
    alignItems: "center",
  },
  planRadioSelected: {
    borderColor: COLORS.accent,
  },
  planRadioDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    backgroundColor: COLORS.accent,
  },
  paywallCTA: {
    marginTop: 8,
  },
  paywallCTAGradient: {
    paddingVertical: 18,
    borderRadius: 16,
    alignItems: "center",
  },
  paywallCTAText: {
    color: "#FFF",
    fontSize: 18,
    fontWeight: "800",
  },
  paywallDisclaimer: {
    textAlign: "center",
    color: COLORS.textMuted,
    fontSize: 13,
    marginTop: 12,
  },
  restoreButton: {
    alignItems: "center",
    marginTop: 20,
    paddingVertical: 8,
  },
  restoreText: {
    color: COLORS.textMuted,
    fontSize: 14,
    textDecorationLine: "underline",
  },

  // --- Home ---
  homeHero: {
    alignItems: "center",
    paddingTop: 60,
    paddingBottom: 24,
  },
  homeTitle: {
    fontSize: 28,
    fontWeight: "800",
    color: COLORS.textPrimary,
    marginTop: 12,
  },
  homeSubtitle: {
    fontSize: 15,
    color: COLORS.textSecondary,
    marginTop: 4,
  },
  searchContainer: {
    flexDirection: "row",
    paddingHorizontal: 16,
    gap: 8,
    marginBottom: 12,
  },
  searchInputWrap: {
    flex: 1,
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: COLORS.surfaceLight,
    borderRadius: 14,
    paddingHorizontal: 14,
    borderWidth: 1,
    borderColor: COLORS.surfaceBorder,
  },
  searchInput: {
    flex: 1,
    color: COLORS.textPrimary,
    fontSize: 16,
    paddingVertical: 14,
  },
  searchButton: {
    width: 50,
    height: 50,
    borderRadius: 14,
    backgroundColor: COLORS.accent,
    justifyContent: "center",
    alignItems: "center",
  },
  quickPicksRow: {
    flexDirection: "row",
    flexWrap: "wrap",
    paddingHorizontal: 16,
    gap: 8,
    marginBottom: 28,
  },
  quickPickChip: {
    paddingHorizontal: 14,
    paddingVertical: 8,
    borderRadius: 20,
    backgroundColor: COLORS.surface,
    borderWidth: 1,
    borderColor: COLORS.surfaceBorder,
  },
  quickPickText: {
    color: COLORS.textSecondary,
    fontSize: 13,
    fontWeight: "500",
  },
  sectionTitle: {
    fontSize: 12,
    fontWeight: "700",
    color: COLORS.textMuted,
    paddingHorizontal: 16,
    marginBottom: 12,
    letterSpacing: 1.5,
  },
  modeGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
    paddingHorizontal: 12,
    gap: 8,
    marginBottom: 8,
  },
  modeCard: {
    width: (SCREEN_WIDTH - 40) / 2,
    padding: 16,
    borderRadius: 16,
    backgroundColor: COLORS.cardBackground,
    borderWidth: 1,
  },
  modeCardFull: {
    flexDirection: "row",
    alignItems: "center",
    marginHorizontal: 12,
    padding: 16,
    borderRadius: 16,
    backgroundColor: COLORS.cardBackground,
    borderWidth: 1,
    marginBottom: 8,
  },
  modeIconWrap: {
    width: 48,
    height: 48,
    borderRadius: 14,
    justifyContent: "center",
    alignItems: "center",
    marginBottom: 10,
  },
  modeLabel: {
    fontSize: 16,
    fontWeight: "700",
  },
  modeDesc: {
    fontSize: 12,
    color: COLORS.textMuted,
    marginTop: 4,
  },

  // --- Study ---
  studyModalHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.surfaceBorder,
  },
  studyModalTitle: {
    fontSize: 17,
    fontWeight: "700",
    color: COLORS.textPrimary,
  },
  usageCounter: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    paddingVertical: 8,
    gap: 6,
    backgroundColor: COLORS.surface,
    marginHorizontal: 16,
    marginTop: 12,
    borderRadius: 10,
  },
  usageText: {
    fontSize: 13,
    color: COLORS.textMuted,
    fontWeight: "500",
  },
  verseCard: {
    margin: 16,
    padding: 20,
    borderRadius: 16,
    backgroundColor: COLORS.cardBackground,
    borderWidth: 1,
    borderColor: COLORS.cardBorder,
  },
  verseHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 12,
  },
  verseReference: {
    fontSize: 18,
    fontWeight: "800",
    color: COLORS.gold,
  },
  verseText: {
    fontSize: 17,
    color: COLORS.textSecondary,
    fontStyle: "italic",
    lineHeight: 28,
    fontFamily: Platform.OS === "ios" ? "Georgia" : "serif",
  },
  translationBadge: {
    fontSize: 11,
    color: COLORS.textMuted,
    fontWeight: "600",
    marginTop: 12,
    letterSpacing: 1,
  },
  modePillsScroll: {
    marginBottom: 8,
  },
  modePill: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: 24,
    borderWidth: 1,
    borderColor: COLORS.surfaceBorder,
    backgroundColor: COLORS.surface,
    marginRight: 8,
    gap: 6,
  },
  modePillText: {
    fontSize: 13,
    fontWeight: "600",
    color: COLORS.textMuted,
  },
  responseCard: {
    margin: 16,
    padding: 20,
    borderRadius: 16,
    backgroundColor: COLORS.cardBackground,
    borderWidth: 1,
    borderColor: COLORS.cardBorder,
  },
  responseHeader: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 12,
    gap: 8,
  },
  responseHeaderText: {
    fontSize: 15,
    fontWeight: "700",
    color: COLORS.textPrimary,
  },
  responseText: {
    fontSize: 15,
    color: COLORS.textSecondary,
    lineHeight: 24,
  },
  typingIndicator: {
    flexDirection: "row",
    gap: 4,
    marginTop: 8,
  },
  typingDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
    backgroundColor: COLORS.accent,
  },
  crossRefsCard: {
    margin: 16,
    marginTop: 0,
    padding: 16,
    borderRadius: 16,
    backgroundColor: COLORS.cardBackground,
    borderWidth: 1,
    borderColor: COLORS.cardBorder,
  },
  crossRefsTitle: {
    fontSize: 14,
    fontWeight: "700",
    color: COLORS.textPrimary,
    marginBottom: 10,
  },
  crossRefItem: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    paddingVertical: 6,
  },
  crossRefText: {
    fontSize: 14,
    color: COLORS.accent,
  },

  // --- Reading Plans ---
  screenTitle: {
    fontSize: 28,
    fontWeight: "800",
    color: COLORS.textPrimary,
    paddingHorizontal: 16,
    paddingTop: 60,
  },
  screenSubtitle: {
    fontSize: 15,
    color: COLORS.textMuted,
    paddingHorizontal: 16,
    marginTop: 4,
    marginBottom: 20,
  },
  planCard2: {},
  planIconWrap: {
    width: 52,
    height: 52,
    borderRadius: 16,
    justifyContent: "center",
    alignItems: "center",
  },
  planInfo: {
    flex: 1,
    marginLeft: 14,
  },
  planTitle: {
    fontSize: 16,
    fontWeight: "700",
    color: COLORS.textPrimary,
  },
  planDescription: {
    fontSize: 13,
    color: COLORS.textMuted,
    marginTop: 2,
  },
  planDays: {
    fontSize: 12,
    fontWeight: "600",
    marginTop: 4,
  },
  proPromptCard: {
    flexDirection: "row",
    alignItems: "center",
    marginHorizontal: 16,
    marginTop: 8,
    padding: 16,
    borderRadius: 16,
    backgroundColor: COLORS.gold + "10",
    borderWidth: 1,
    borderColor: COLORS.gold + "30",
    gap: 10,
  },
  proPromptText: {
    flex: 1,
    fontSize: 14,
    color: COLORS.gold,
    fontWeight: "600",
  },

  // --- Journal ---
  journalCard: {
    marginHorizontal: 16,
    marginBottom: 12,
    padding: 16,
    borderRadius: 16,
    backgroundColor: COLORS.cardBackground,
    borderWidth: 1,
    borderColor: COLORS.cardBorder,
  },
  journalCardHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 8,
  },
  journalRef: {
    fontSize: 16,
    fontWeight: "700",
  },
  journalModeBadge: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 12,
  },
  journalModeText: {
    fontSize: 11,
    fontWeight: "700",
  },
  journalContent: {
    fontSize: 14,
    color: COLORS.textSecondary,
    lineHeight: 22,
  },
  journalCardFooter: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginTop: 12,
    paddingTop: 10,
    borderTopWidth: 1,
    borderTopColor: COLORS.surfaceBorder,
  },
  journalDate: {
    fontSize: 12,
    color: COLORS.textMuted,
  },

  // --- Saved ---
  savedCard: {
    marginHorizontal: 16,
    marginBottom: 12,
    padding: 16,
    borderRadius: 16,
    backgroundColor: COLORS.cardBackground,
    borderWidth: 1,
    borderColor: COLORS.cardBorder,
  },
  savedCardHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 8,
  },
  savedRef: {
    fontSize: 16,
    fontWeight: "700",
    color: COLORS.gold,
  },
  savedTranslation: {
    fontSize: 11,
    fontWeight: "600",
    color: COLORS.textMuted,
    letterSpacing: 1,
  },
  savedText: {
    fontSize: 14,
    color: COLORS.textSecondary,
    fontStyle: "italic",
    lineHeight: 22,
  },
  savedCardFooter: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginTop: 12,
    paddingTop: 10,
    borderTopWidth: 1,
    borderTopColor: COLORS.surfaceBorder,
  },
  savedDate: {
    fontSize: 12,
    color: COLORS.textMuted,
  },

  // --- Settings ---
  settingsSection: {
    marginTop: 24,
    marginHorizontal: 16,
  },
  settingsSectionTitle: {
    fontSize: 12,
    fontWeight: "700",
    color: COLORS.textMuted,
    letterSpacing: 1.5,
    marginBottom: 8,
  },
  settingsCard: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    padding: 16,
    backgroundColor: COLORS.cardBackground,
    borderWidth: 1,
    borderColor: COLORS.cardBorder,
    borderRadius: 12,
    marginBottom: 2,
  },
  settingsLabel: {
    fontSize: 15,
    color: COLORS.textPrimary,
    fontWeight: "500",
  },
  settingsValue: {
    fontSize: 14,
    color: COLORS.textMuted,
  },

  // --- Empty States ---
  emptyScreen: {
    justifyContent: "center",
    alignItems: "center",
    paddingHorizontal: 32,
  },
  emptyTitle: {
    fontSize: 20,
    fontWeight: "700",
    color: COLORS.textPrimary,
    marginTop: 16,
  },
  emptySubtitle: {
    fontSize: 15,
    color: COLORS.textMuted,
    textAlign: "center",
    marginTop: 8,
    lineHeight: 22,
  },
  emptyButton: {
    marginTop: 24,
    width: "100%",
  },
  emptyButtonGradient: {
    paddingVertical: 16,
    borderRadius: 16,
    alignItems: "center",
  },
  emptyButtonText: {
    color: "#FFF",
    fontSize: 16,
    fontWeight: "700",
  },

  // --- Reading Plans (reuse planCard for list items) ---
  // planCard is already defined above for Paywall, reusing for reading plans too
  // The reading plans use the same style
});

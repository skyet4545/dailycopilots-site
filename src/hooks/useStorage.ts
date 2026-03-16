// Bible Copilot — AsyncStorage hooks for settings, saved passages, journal
import { useState, useEffect, useCallback } from "react";
import AsyncStorage from "@react-native-async-storage/async-storage";

const KEYS = {
  ONBOARDING_COMPLETE: "@bc_onboarding_complete",
  SAVED_PASSAGES: "@bc_saved_passages",
  JOURNAL_ENTRIES: "@bc_journal_entries",
  SETTINGS: "@bc_settings",
  TRANSLATION: "@bc_translation",
};

// --- Generic storage hook ---
function useStorageState<T>(key: string, defaultValue: T) {
  const [value, setValue] = useState<T>(defaultValue);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    AsyncStorage.getItem(key)
      .then((raw) => {
        if (raw !== null) {
          try {
            setValue(JSON.parse(raw));
          } catch {
            setValue(defaultValue);
          }
        }
      })
      .finally(() => setLoaded(true));
  }, [key]);

  const save = useCallback(
    async (newValue: T) => {
      setValue(newValue);
      await AsyncStorage.setItem(key, JSON.stringify(newValue));
    },
    [key]
  );

  return { value, save, loaded };
}

// --- Onboarding ---
export function useOnboarding() {
  const { value, save, loaded } = useStorageState<boolean>(
    KEYS.ONBOARDING_COMPLETE,
    false
  );
  return {
    onboardingComplete: value,
    setOnboardingComplete: save,
    loaded,
  };
}

// --- Saved Passages ---
export interface SavedPassage {
  id: string;
  reference: string;
  text: string;
  translation: string;
  savedAt: string;
  notes?: string;
}

export function useSavedPassages() {
  const { value, save, loaded } = useStorageState<SavedPassage[]>(
    KEYS.SAVED_PASSAGES,
    []
  );

  const addPassage = useCallback(
    async (passage: Omit<SavedPassage, "id" | "savedAt">) => {
      const newPassage: SavedPassage = {
        ...passage,
        id: Date.now().toString(),
        savedAt: new Date().toISOString(),
      };
      const updated = [newPassage, ...value];
      await save(updated);
    },
    [value, save]
  );

  const removePassage = useCallback(
    async (id: string) => {
      const updated = value.filter((p) => p.id !== id);
      await save(updated);
    },
    [value, save]
  );

  return { passages: value, addPassage, removePassage, loaded };
}

// --- Journal ---
export interface JournalEntry {
  id: string;
  reference: string;
  mode: string;
  response: string;
  reflection?: string;
  createdAt: string;
}

export function useJournal() {
  const { value, save, loaded } = useStorageState<JournalEntry[]>(
    KEYS.JOURNAL_ENTRIES,
    []
  );

  const addEntry = useCallback(
    async (entry: Omit<JournalEntry, "id" | "createdAt">) => {
      const newEntry: JournalEntry = {
        ...entry,
        id: Date.now().toString(),
        createdAt: new Date().toISOString(),
      };
      const updated = [newEntry, ...value];
      await save(updated);
    },
    [value, save]
  );

  const removeEntry = useCallback(
    async (id: string) => {
      const updated = value.filter((e) => e.id !== id);
      await save(updated);
    },
    [value, save]
  );

  return { entries: value, addEntry, removeEntry, loaded };
}

// --- Settings ---
export interface AppSettings {
  translation: string;
  hapticFeedback: boolean;
  fontSize: "small" | "medium" | "large";
}

const DEFAULT_SETTINGS: AppSettings = {
  translation: "kjv",
  hapticFeedback: true,
  fontSize: "medium",
};

export function useSettings() {
  const { value, save, loaded } = useStorageState<AppSettings>(
    KEYS.SETTINGS,
    DEFAULT_SETTINGS
  );

  const updateSetting = useCallback(
    async <K extends keyof AppSettings>(key: K, val: AppSettings[K]) => {
      const updated = { ...value, [key]: val };
      await save(updated);
    },
    [value, save]
  );

  return { settings: value, updateSetting, loaded };
}

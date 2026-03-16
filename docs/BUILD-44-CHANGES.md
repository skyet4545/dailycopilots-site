# 📄 scripture-copilot / scripture-app/BUILD-44-CHANGES.md

# Build 44 - Critical Bug Fix

**Date:** 2026-02-13
**Version:** 1.3.2
**Build:** 44

## Root Cause of Crash

**Line 456 in HomeScreen** called `getPlanProgress(plan.id)` without importing the function from `useReadingPlans()`.

```javascript
// BUGGY CODE (line 456):
const activePlans = ReadingPlans.filter(plan => getPlanProgress(plan.id));
// getPlanProgress was NEVER imported in HomeScreen!
```

This caused a **ReferenceError: getPlanProgress is not defined** which crashed the app immediately on launch.

### Why This Happened
- The `activePlans` variable was dead code (defined but never used)
- It was likely left over from a previous feature that was partially removed
- The bug existed since the theme system changes but wasn't caught in testing

## Fixes Applied

### 1. Removed Dead Code (Line 456)
```javascript
// REMOVED - this line was never used and caused crash
const activePlans = ReadingPlans.filter(plan => getPlanProgress(plan.id));
```

### 2. Fixed Import Statement (Line 50)
```javascript
// BEFORE (broken - themes no longer exported):
import { themes, Theme } from './src/constants/themes';

// AFTER (fixed):
import { defaultTheme, Theme } from './src/constants/themes';
```

### 3. Removed Duplicate Style Property
Removed duplicate `sectionTitle` definition in styles (was defined twice).

### 4. Version Bump
- APP_VERSION: `1.3.1` → `1.3.2`
- Forces clean migration for all users upgrading

## Testing Checklist

- [ ] Fresh install: App launches without crash
- [ ] Upgrade from Build 43: App launches, migration runs
- [ ] Home screen: Search works
- [ ] Study screen: All 4 modes work
- [ ] Settings screen: Translation selection works
- [ ] Saved screen: Shows saved passages
- [ ] Theme: Cool Blue applied consistently

## Files Modified

- `App.tsx`:
  - Line 50: Fixed import
  - Line 456: Removed dead code
  - Line 1608: Version bump to 1.3.2
  - Line 1523: Display version to 1.3.2
  - Styles: Removed duplicate sectionTitle

## Code Audit Summary

Performed line-by-line review of:
- App.tsx (entire file)
- src/hooks/useTheme.ts
- src/hooks/useStorage.ts  
- src/constants/themes.ts
- src/constants/theme.ts

**Result:** Only crash bug was the undefined `getPlanProgress` reference.


---


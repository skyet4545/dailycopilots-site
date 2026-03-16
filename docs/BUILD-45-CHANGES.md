# 📄 scripture-copilot / scripture-app/BUILD-45-CHANGES.md

# Build 45 Changes

**Date:** Feb 13, 2026, 7:27 PM EST
**Version:** 1.3.3
**Build:** 45

## Critical Bug Fix: Translation API Support

### Root Cause
Bible API (bible-api.com) only supports:
- WEB (World English Bible) - default
- KJV (King James Version)

App was requesting ESV (English Standard Version), which is NOT supported. When ESV is requested, the API returns 404 HTML instead of JSON, causing the app to crash with "Failed to load passage" error.

### Changes Made

**1. Updated Supported Translations** (`src/constants/theme.ts`)
```typescript
// Before
export const Translations = [
  { id: 'esv', label: 'English Standard Version', short: 'ESV' },
  { id: 'niv', label: 'New International Version', short: 'NIV' },
  { id: 'nkjv', label: 'New King James Version', short: 'NKJV' },
  { id: 'kjv', label: 'King James Version', short: 'KJV' },
];

// After
export const Translations = [
  { id: 'web', label: 'World English Bible', short: 'WEB' },
  { id: 'kjv', label: 'King James Version', short: 'KJV' },
];
```

**2. Updated Default Translation** (`src/hooks/useStorage.ts`)
- Changed default from `esv` to `web`
- Updated Settings interface type: `translation: 'web' | 'kjv'`
- Updated migration logic to convert old ESV/NIV/NKJV → WEB

**3. Improved Error Handling** (`App.tsx`)
- Added JSON validation before parsing API responses
- Check Content-Type header to detect HTML vs JSON
- Graceful handling of 404 errors (show "Not Found" instead of crash)

```typescript
// Check if response is valid JSON (not 404 HTML)
const contentType = res.headers.get('content-type');
if (!res.ok || !contentType?.includes('application/json')) {
  Alert.alert('Not Found', 'Could not find that passage. Try a different reference.');
  setLoading(false);
  return;
}
```

### Files Modified
- `src/constants/theme.ts` - Translation options
- `src/hooks/useStorage.ts` - Settings interface, default, migration
- `App.tsx` - API error handling (2 locations) + UI spacing fix
- `app.json` - Version bump to 1.3.3

## UI Fix: Translation Section Spacing (7:38 PM)

**Issue:** Translation buttons too close to Study button (cramped spacing)

**Fix:** Added `marginTop: 24` to `versionSection` style

```typescript
versionSection: {
  paddingHorizontal: 16,
  marginTop: 24,        // ← ADDED
  marginBottom: 24,
},
```

### Expected Outcome
- Fresh installs: Use WEB translation by default ✅
- Upgrades from v1.3.2: Auto-migrate ESV → WEB ✅
- All passage searches work correctly ✅
- No more "Failed to load passage" crashes ✅

### Testing
1. Search "Peter 1" → Should load 1 Peter 1 (WEB translation)
2. Search "John 3:16" → Should load correctly
3. Search invalid reference → "Not Found" message (not crash)
4. Settings → Translation picker shows WEB and KJV only


---


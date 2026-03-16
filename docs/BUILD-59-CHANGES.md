# 📄 scripture-copilot / scripture-app/BUILD-59-CHANGES.md

# Build 59 Changes

**Date:** February 15, 2026  
**Version:** 1.3.4  
**Build:** 59

## 🐛 BUG FIX: Verse Reference Parsing

**Problem:** Searching for verses with space after colon (e.g., "Revelation 20: 11-15") returned "Not Found" error.

**Root Cause:** App was sending reference as-is to bible-api.com, but the API expects no spaces around the colon.

**Fix:** Added reference normalization before API call:
```typescript
// Normalize reference: remove spaces around colon (e.g., "John 3: 16" -> "John 3:16")
const normalizedRef = searchRef.replace(/\s*:\s*/g, ':').trim();
```

**Now Works:**
- ✅ "Revelation 20:11-15" (no space)
- ✅ "Revelation 20: 11-15" (space after colon)
- ✅ "Revelation 20 : 11-15" (spaces around colon)

**Files Changed:**
- `App.tsx` (line 463) - Added normalization logic

**Testing:**
- Test "Revelation 20: 11-15" - should load successfully
- Test "John 3: 16" - should load successfully
- Test "Psalm 23 : 1-6" - should load successfully

---

**Deployment:** Build → TestFlight → Notify Carlos for testing


---


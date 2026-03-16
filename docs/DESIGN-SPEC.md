# 📄 scripture-copilot / DESIGN-SPEC.md

# Scripture Copilot — Design Specification

*Inspired by BibleGateway's trusted, readable design*

---

## 🎨 Color Palette

### Light Mode
| Role | Color | Hex | Usage |
|------|-------|-----|-------|
| Primary | Deep Navy | `#1E3A5F` | Headers, buttons, icons |
| Secondary | Scripture Gold | `#C9A227` | Accents, highlights, active states |
| Background | Warm White | `#FAFAFA` | Main background |
| Surface | Pure White | `#FFFFFF` | Cards, modals |
| Text Primary | Dark Charcoal | `#1A1A1A` | Body text, Scripture |
| Text Secondary | Warm Gray | `#6B7280` | Subtitles, captions |
| Border | Light Gray | `#E5E7EB` | Dividers, outlines |

### Dark Mode
| Role | Color | Hex | Usage |
|------|-------|-----|-------|
| Primary | Soft Navy | `#3B5998` | Headers, buttons |
| Secondary | Muted Gold | `#D4AF37` | Accents |
| Background | Deep Black | `#0D0D0D` | Main background |
| Surface | Dark Gray | `#1A1A1A` | Cards |
| Text Primary | Off White | `#F5F5F5` | Body text |
| Text Secondary | Medium Gray | `#9CA3AF` | Subtitles |

### Study Category Colors
| Category | Light Mode | Dark Mode |
|----------|------------|-----------|
| 📖 Observation | `#2563EB` (Blue) | `#60A5FA` |
| 🔍 Interpretation | `#7C3AED` (Purple) | `#A78BFA` |
| ✝️ Theology | `#059669` (Green) | `#34D399` |
| 🙏 Application | `#DC2626` (Red) | `#F87171` |
| 🛡️ Apologetics | `#D97706` (Amber) | `#FBBF24` |

---

## 📐 Typography

### Font Stack
```css
/* Primary - Scripture reading */
font-family: 'Georgia', 'Times New Roman', serif;

/* UI Elements */
font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;

/* Monospace - verse references */
font-family: 'SF Mono', 'Menlo', monospace;
```

### Scale
| Element | Size | Weight | Line Height |
|---------|------|--------|-------------|
| Scripture Text | 18px | 400 | 1.8 |
| H1 (Book name) | 28px | 700 | 1.3 |
| H2 (Chapter) | 22px | 600 | 1.4 |
| H3 (Section) | 18px | 600 | 1.4 |
| Body | 16px | 400 | 1.6 |
| Caption | 14px | 400 | 1.5 |
| Label | 12px | 500 | 1.4 |

### Reading Comfort
- Scripture text slightly larger (18-20px)
- Generous line height (1.8) for readability
- Warm, high-contrast colors
- Adjustable text size (accessibility)

---

## 📱 Layout Structure

### Home Screen
```
┌────────────────────────────────┐
│  ☰  Scripture Copilot    ⚙️   │ ← Header (Navy)
├────────────────────────────────┤
│                                │
│  📖 Verse of the Day          │ ← Gold accent border
│  ─────────────────────        │
│  "For God so loved..."        │
│  — John 3:16 NIV              │
│                                │
├────────────────────────────────┤
│  ┌─────────────────────────┐  │
│  │ 🔍 Enter a passage...   │  │ ← Search bar
│  └─────────────────────────┘  │
├────────────────────────────────┤
│                                │
│  Recent Studies               │
│  ┌──────┐ ┌──────┐ ┌──────┐  │
│  │Rom 8 │ │Eph 2 │ │Jn 3  │  │ ← Horizontal scroll
│  └──────┘ └──────┘ └──────┘  │
│                                │
├────────────────────────────────┤
│  📚 Reading Plans             │
│  ▸ Romans in 30 Days (Day 5)  │
│  ▸ Gospel of John (Day 12)    │
│                                │
└────────────────────────────────┘
│  🏠    📖    💬    📓    👤  │ ← Bottom nav
└────────────────────────────────┘
```

### Study Screen
```
┌────────────────────────────────┐
│  ←  Romans 8:28-30    📋 NIV ▾│ ← Header with translation picker
├────────────────────────────────┤
│                                │
│  ²⁸ And we know that in all   │
│  things God works for the     │
│  good of those who love him,  │
│  who have been called         │
│  according to his purpose.    │
│                                │
│  ²⁹ For those God foreknew    │
│  he also predestined to be    │
│  conformed to the image of    │
│  his Son...                   │
│                                │ ← Scripture in serif font
├────────────────────────────────┤
│                                │
│  Study with AI                │
│  ┌──────────────────────────┐ │
│  │ 📖 Observation           │ │ ← Blue
│  │ What does the text say?  │ │
│  └──────────────────────────┘ │
│  ┌──────────────────────────┐ │
│  │ 🔍 Interpretation        │ │ ← Purple
│  │ What does it mean?       │ │
│  └──────────────────────────┘ │
│  ┌──────────────────────────┐ │
│  │ ✝️ Theology              │ │ ← Green
│  │ What does it teach?      │ │
│  └──────────────────────────┘ │
│  ┌──────────────────────────┐ │
│  │ 🙏 Application           │ │ ← Red
│  │ How should I respond?    │ │
│  └──────────────────────────┘ │
│  ┌──────────────────────────┐ │
│  │ 🛡️ Apologetics           │ │ ← Amber
│  │ How do I defend this?    │ │
│  └──────────────────────────┘ │
│                                │
└────────────────────────────────┘
```

### AI Chat Screen
```
┌────────────────────────────────┐
│  ←  Interpretation    Romans 8│
├────────────────────────────────┤
│                                │
│  ┌─────────────────────────┐  │
│  │ What does "foreknew"    │  │
│  │ mean in verse 29?       │  │ ← User question (right-aligned)
│  └─────────────────────────┘  │
│                                │
│  ┌─────────────────────────┐  │
│  │ 🤖 The Greek word       │  │
│  │ "proginōskō" means...   │  │
│  │                         │  │ ← AI response (left-aligned)
│  │ Key points:             │  │
│  │ • Not just awareness    │  │
│  │ • Relational knowing    │  │
│  │ • Connected to election │  │
│  │                         │  │
│  │ 📖 Cross-references:    │  │
│  │ Jer 1:5, Amos 3:2       │  │
│  └─────────────────────────┘  │
│                                │
│  ┌──────────────────────┐ 📤 │
│  │ Ask a follow-up...    │    │ ← Input bar
│  └──────────────────────┘     │
└────────────────────────────────┘
```

---

## 🧩 Components

### Buttons

**Primary (CTA)**
```
Background: Navy (#1E3A5F)
Text: White
Border-radius: 8px
Padding: 12px 24px
Shadow: subtle drop shadow
```

**Secondary**
```
Background: White
Text: Navy
Border: 1px solid Navy
Border-radius: 8px
```

**Study Category Button**
```
Background: White
Left border: 4px solid [category color]
Border-radius: 8px
Icon + Text layout
Subtle shadow on hover/press
```

### Cards
```
Background: White (dark: #1A1A1A)
Border-radius: 12px
Padding: 16px
Shadow: 0 2px 8px rgba(0,0,0,0.08)
```

### Scripture Display
```
Font: Georgia, serif
Size: 18-20px (user adjustable)
Line-height: 1.8
Verse numbers: superscript, muted color
Paragraph spacing: 1em
```

### Input Fields
```
Background: #F9FAFB (dark: #1A1A1A)
Border: 1px solid #E5E7EB
Border-radius: 8px
Padding: 12px 16px
Focus: Navy border, subtle glow
```

---

## 📲 Navigation

### Bottom Tab Bar
| Tab | Icon | Label |
|-----|------|-------|
| Home | 🏠 | Home |
| Bible | 📖 | Bible |
| Study | 💬 | Study |
| Journal | 📓 | Journal |
| Profile | 👤 | Profile |

**Active state:** Navy icon + gold underline
**Inactive state:** Gray icon

---

## ✨ Micro-interactions

### Loading States
- Scripture loading: Skeleton text blocks
- AI thinking: Pulsing dots (• • •)
- Saving: Checkmark animation

### Transitions
- Screen transitions: Slide left/right
- Modal: Slide up from bottom
- Category selection: Subtle scale + color fill

### Haptics (iOS)
- Button press: Light impact
- Category selection: Medium impact
- Save/bookmark: Success haptic

---

## 🌐 BibleGateway Design Elements Adopted

| BibleGateway Feature | Scripture Copilot Implementation |
|---------------------|----------------------------------|
| Verse of the Day | Home screen hero card |
| Translation picker | Dropdown in study header |
| Highlighting | Tap-to-highlight with colors |
| Notes | Journal feature (Pro) |
| Dark mode | Full dark theme support |
| Reading plans | Guided study tracks |
| Search | Universal passage search |
| Audio (future) | TTS for passages |

---

## 📐 Spacing System

```
4px  - xs (icon padding)
8px  - sm (tight spacing)
12px - md (standard)
16px - lg (section spacing)
24px - xl (major sections)
32px - 2xl (screen padding)
48px - 3xl (hero sections)
```

---

## 🎯 Accessibility

- Minimum touch target: 44x44px
- Color contrast: WCAG AA minimum
- Font scaling: Support system text size
- VoiceOver/TalkBack: Full support
- Reduced motion: Respect system preference

---

## 📁 Asset Requirements

### App Icon
- 1024x1024 (App Store)
- Simple: Open Bible + subtle AI spark
- Colors: Navy + Gold
- Readable at 29x29

### Screenshots (App Store)
- iPhone: 1290 x 2796 (6.7")
- iPad: 2048 x 2732 (12.9")
- 6-10 screenshots per device

### Feature Graphic (Google Play)
- 1024 x 500
- App name + tagline + device mockup

---

*Design inspired by BibleGateway's trusted, readable interface with modern AI interactions.*

*Last Updated: February 8, 2026*


---


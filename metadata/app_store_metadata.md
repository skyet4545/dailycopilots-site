# Bible Copilot — App Store metadata source

Updated: 2026-09-14

Status: internal source reconciled; no App Store Connect change authorized

This file separates the current public US listing from the next held metadata candidate. The public baseline comes from Apple's listing and the read-only App Store evidence. Any metadata mutation, submission, or release requires Carlos's explicit approval.

## Current public baseline — version 2.4.2

### Name

```text
Bible Copilot - AI Bible Study
```

### Subtitle

```text
Verse Meaning & Bible Answers
```

### Hidden keywords

```text
scripture,devotional,kjv,gospel,jesus,christian,chat,gpt,commentary,daily,reading,plan,prayer,niv
```

### Description

```text
Understand Scripture with clear, verse-backed explanations and focused follow-up questions. Bible Copilot helps you move from a passage to its meaning, context, theology, application, and common questions without losing sight of the biblical text.

SIX STUDY MODES
- Summary: Get the central idea quickly.
- Observe: Notice structure, repeated words, and important details.
- Interpret: Explore context and meaning.
- Theology: Connect the passage to biblical teaching.
- Apply: Turn understanding into faithful practice.
- Apologetics: Examine questions and reasons carefully.

ASK FOLLOW-UP QUESTIONS
Start with a verse or passage, read its explanation, then ask the specific question the text raises for you. Continue the conversation without beginning your study again.

SAVE YOUR STUDY
Keep useful insights and return to them later. Use guided reading plans to build a consistent study rhythm.

FREE TO START
Ask up to 3 AI-powered questions each day at no charge.

BIBLE COPILOT PRO
- Unlimited questions
- Full access to Pro study features
- Monthly: $9.99
- Annual: $49.99 with a 7-day free trial

Payment is handled by Apple. Subscriptions renew automatically unless canceled through your Apple ID subscription settings.

Bible Copilot is a study aid, not a replacement for Scripture, prayer, church community, or qualified pastoral counsel.

Terms of Use: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
Privacy Policy: https://mybiblecopilot.com/privacy
```

### Current release notes

```text
This update improves how Bible Copilot measures the source of new study journeys, including visits from the website, YouTube, email, and organic search.
```

## Held keyword-only candidate

Preserve the current name, subtitle, description, gallery, offer, pricing, and product behavior. Change only the hidden keyword field after its prerequisites and owner gate pass.

```text
explain,context,commentary,devotional,kjv,niv,christian,reading,plan,apologetics,theology,inductive
```

The candidate is 99 UTF-8 bytes. It removes broad or overlapping terms and adds product-supported intent terms for explanation, context, commentary, inductive study, theology, and apologetics. This is a hypothesis, not a ranking or revenue claim.

Do not apply it until four unchanged weekly US rank snapshots exist, the live listing and `product-truth.json` are revalidated, the current 2.4.3 paywall treatment has a metadata window, and Carlos explicitly approves the App Store Connect change.

## Measurement and decision boundary

Track weekly rank by query, App Store Search impressions, product-page views, first-time downloads, paying users, and currency-specific proceeds. Keep first-question completion, D1/D7 retention, paywall behavior, StoreKit success, refunds, and paid-subscription movement as separate guardrails.

A public rank is not the converting keyword. A metadata change is not an install, subscription, or revenue outcome. The structured candidate and full decision policy are in `metadata/app_store_metadata_candidate.json`.

## Stable listing fields

- Primary category: Reference
- Secondary category: Education
- Support URL: https://mybiblecopilot.com/support
- Marketing URL: https://mybiblecopilot.com
- Privacy policy: https://mybiblecopilot.com/privacy
- Copyright: 2026 Republic Publishing
- Age rating: 4+

# Bible Copilot daily study email operating specification

## Objective

Give an opted-in reader one short, verse-anchored study each day that strengthens a Scripture-first habit and offers a natural next step into Bible Copilot. The email is not a replacement for reading the Bible, prayer, church, or pastoral care.

## Customer promise

**One verse. A clearer understanding. Every day.**

Each study contains:

1. the passage to read in its immediate context;
2. a brief, plain-English context note;
3. one observation or reflection question; and
4. one optional invitation to continue the study in Bible Copilot.

## Capture contract

- Form: `Bible Copilot - Verse of the Day Signup` (`W2ZpsL`)
- List: `Bible Copilot Leads` (`XUbnq5`)
- Explicit email consent only; no inferred consent and no SMS enrollment.
- First-party events:
  - `daily_study_popup_viewed`
  - `daily_study_popup_requested`
  - `daily_study_signup_completed`
  - `daily_study_popup_dismissed`
- The legacy Netlify handoff accepts only the `verse-of-the-day` form and records source, campaign, intent, and page fields.

## Popup configuration

| Setting | Production choice |
| --- | --- |
| Type | Klaviyo popup, form `W2ZpsL` |
| Headline | `One verse. A clearer understanding. Every day.` |
| Supporting copy | `Receive a brief Scripture reading, its context in plain English, and one thoughtful question to carry into your day.` |
| CTA | `Send today’s study` |
| Decline | `Not today` |
| Targeting | First-time, non-subscribed visitors on content and tool pages; exclude `/privacy/`, `/terms/`, `/thanks/`, and existing subscribers. |
| Trigger | 45 seconds or 50% scroll on articles/tools; never on initial page load. |
| Frequency | At most once every 14 days after dismissal; suppress after successful submit. |
| Mobile | Use a bottom-sheet format with an obvious close control. |

## Lifecycle architecture

### Flow A — Bible Copilot: Daily Study Welcome

- Trigger: added to `Bible Copilot Leads`
- Re-entry: no re-entry
- Status while being built: draft/manual only
- Exit: unsubscribe, global suppression, or a recipient-level delivery error.

| Timing | Email | Purpose | Primary CTA |
| --- | --- | --- | --- |
| Immediately | Day 0: Welcome + today’s study | Fulfill the signup promise without making a reader wait | `Study this passage free` |
| +1 day | Day 1: Read the whole paragraph | Teach context before conclusion | `Open the verse study worksheet` |
| +2 days | Day 2: Ask a better follow-up question | Demonstrate the app’s free question workflow | `Ask about a verse in Bible Copilot` |
| +3 days | Day 3: Compare Scripture with Scripture | Introduce cross-references without information overload | `Explore cross-references` |
| +4 days | Day 4: Notice before applying | Distinguish observation and application | `Use the Observe mode` |
| +5 days | Day 5: Bring a real question | Invite a personal study question; do not make therapeutic claims | `Try three free questions` |
| +6 days | Day 6: Keep the habit gentle | Set expectations for the ongoing daily study | `Keep studying in Bible Copilot` |

Smart Sending must be disabled for the immediate Day 0 fulfillment email. It may be enabled for the later nurture messages only if it does not prevent an already-promised daily study from being delivered.

### Ongoing daily study sender

The welcome flow is not the daily editorial system. Ongoing messages must be created as a **daily scheduled Klaviyo campaign** from an approved study manifest.

1. A daily manifest is written and validated before send time.
2. The sender creates a campaign for `Bible Copilot Leads`, attaches the approved email template, and schedules it for 8:00 AM America/New_York.
3. It writes an immutable delivery receipt containing the manifest ID/hash, Klaviyo campaign/message IDs, intended time, API response status, and final sent status.
4. It fails closed if the source manifest, required private key, sender identity, template, or schedule evidence is missing.

Required private Klaviyo scopes:

- `campaigns:write`
- `templates:write`
- `campaigns:read` (for post-send verification)

The sender must never use the public Klaviyo site ID for privileged campaign creation or scheduling.

## Editorial study manifest

```json
{
  "id": "2026-08-12",
  "passage": "Psalm 46:10–11",
  "context_note": "Psalm 46 speaks into a world of upheaval. The call to be still is not an invitation to ignore danger; it is a call to recognize that God remains sovereign when nations and circumstances feel unstable.",
  "reflection_question": "What situation makes it hardest for you to pause and remember that God is present?",
  "cta_label": "Study Psalm 46 in Bible Copilot",
  "cta_url": "https://apps.apple.com/us/app/bible-copilot-ai-bible-study/id6758913373?ct=bc_email_daily_study&src=mybiblecopilot",
  "editorial_status": "approved",
  "approved_by": "Carlos Reyes",
  "source_references": ["Psalm 46:1–11"]
}
```

No manifest may claim a verse means more than the stated text and context support. AI assistance may draft, but a human must approve the initial content library and any new recurring editorial lane before it is sent.

## Measurement and verification

| Stage | Evidence |
| --- | --- |
| Popup displayed | Klaviyo form report plus `daily_study_popup_viewed` |
| Signup submitted | Klaviyo form submission plus `daily_study_signup_completed` |
| Consent/list membership | profile is present and subscribed on `Bible Copilot Leads` |
| Immediate fulfillment | flow history shows entry and email sent/delivered |
| Ongoing study | daily receipt + campaign message transitions `DRAFT` → `SCHEDULED` → `SENT` |
| App handoff | email UTM link click and App Store campaign token |
| Conversion boundary | App Store click is not an install, trial, or purchase; those remain separately measured |

## Controlled release checklist

- [ ] Website deployment is approved and live HTML includes Klaviyo.js plus the scoped analytics listener.
- [ ] Popup has the above copy, targeting, frequency cap, and exclusions.
- [ ] Welcome email has sender, subject, preview, approved content, unsubscribe footer, and UTM tracking.
- [ ] A controlled recipient is subscribed through the actual popup or scoped Netlify form.
- [ ] The controlled recipient appears in the correct list and enters Flow A.
- [ ] The immediate email is observed in the recipient inbox and in Klaviyo delivery history.
- [ ] The daily campaign sender has a valid approved manifest and sends a controlled campaign to the test segment before the full list is eligible.
- [ ] The verifier writes a Jarvis reconciliation with evidence, remaining risks, and the next safe action.

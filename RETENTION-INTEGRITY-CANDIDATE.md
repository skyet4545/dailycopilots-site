# Bible Copilot 2.4.5/131 retention-integrity candidate

## Outcome

Protect the contextual study-resume loop so an accepted 8:00 AM default remains at 8:00 AM after later studies, while preserving a reader's intentional midnight choice.

## Repairs

- Persist the normalized daily-reminder time whenever a reminder is scheduled, including when the visible default was never changed.
- Resolve missing or invalid stored reminder values to 8:00 AM rather than silently rescheduling at midnight.
- Replace the unsupported onboarding claim that daily Scripture study produces `3×` greater recall with evidence-safe copy.
- Add regression coverage for missing time keys, explicit midnight, and invalid stored values.

## Release sequence

This candidate succeeds the prepared 2.4.5/131 growth candidate. It remains staged until the submitted 2.4.3/129 paywall experiment reaches its governed decision window. It does not authorize upload, submission, or release.

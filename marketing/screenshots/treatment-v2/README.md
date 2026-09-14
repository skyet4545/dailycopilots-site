# Bible Copilot App Store treatment v2

This folder is the executable capture and truth contract for the six-frame App Store treatment. Its business purpose is to move more qualified App Store Search visitors into the Bible Copilot Pro funnel while preserving activation, retention, paid conversion, churn, refund, and proceeds guardrails.

Run:

```bash
node build-treatment.mjs
node validate-treatment.mjs
```

The normal validator proves the identity and dimensions of all available real-capture composites. The upload gate is stricter:

```bash
node validate-treatment.mjs --require-complete
```

That command must pass before upload. The current candidate deliberately fails closed at five of six frames because the real build 129 Pro capture contains an unbounded Scripture-citation quantity claim. This preserves local asset identity and dimensions without presenting the package as submission-ready.

The validator also rejects absolute Scripture-citation guarantees, requires a recorded manual source-copy review for every ready frame, and rejects customer-facing trial statements that omit eligibility. The live four-frame gallery observed on September 14, 2026 contains both risks; this treatment has no external effect until its final real capture is corrected and a separately approved Product Page Optimization test or gallery update is created in App Store Connect.

## Recapture procedure

Use product-claim candidate commit `79bfba4f21338a73ed4946cb4bf93a45e139b988`, or a reconciled descendant, with production-equivalent StoreKit configuration. Capture at 1320 by 2868 pixels, without personal data, then record the source SHA-256 and source-copy review state in `manifest.json`.

1. **Follow-up study:** complete a real study, wait for the response to finish, and capture the suggested follow-up plus the follow-up field. The passage and answer must be suitable for a public store page.
2. **Reading plan:** open the Plans tab and capture the real list with Gospel of John visible as the 21-day free plan. Do not invent completion progress.
3. **Pro offer:** open the build 129 paywall only after StoreKit products load. The screenshot must show the trial CTA and current monthly and annual prices supplied by StoreKit. Reject any loading, error, stale `Continue` CTA, or missing trial state.

The September 13 capture pass established all three product states, but the September 14 claim audit disqualified the Pro source copy. The normal validator passes the five retained frames; the strict validator must continue failing until a real corrected Pro capture is installed and hashed. After recapture, run both validators and inspect every PNG at full resolution. Create the live Product Page Optimization test only after Carlos approves that action. Starting the test and applying a winner are separate owner decisions.

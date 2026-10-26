# Bible Copilot Automation Strategy

Updated: 2026-08-10
Owner: Carlos Reyes / Codex automation
Coverage: 8 registered automations (6 active, 2 paused).

## Strategic purpose

Convert verified search and audience demand into trustworthy Bible-study assets, measured distribution, and App Store growth without weakening product truth, attribution, or publication gates.

Automations are execution mechanisms, not independent goals. A run counts as strategically complete only when it produces the registered primary artifact, writes a versioned immutable custody receipt, validates the receipt, and makes the next decision or handoff possible. Activity without this evidence is not progress.

## Operating rules

1. Read the nearest `AGENTS.md`, the shared portfolio automation context, this strategy, and the exact contract in `/Users/carlosreyes/Documents/Codex/2026-07-27/i-ve-logged/outputs/portfolio-control-system/automation-output-contracts.json`.
2. Consume an upstream scheduled result only through the artifact path and SHA-256 recorded in its immutable receipt. Schedule timing, chat text, and mutable `latest` files are not handoffs.
3. Preserve product truth, source quality, attribution, publication, approval, and fail-closed gates. Missing evidence remains missing.
4. A safe terminal state is a strategic outcome only when its required fields and verification evidence are present. A verified skip or failed-closed result is preferable to unsupported production.
5. Normal runs reconcile material evidence, risks, decisions, and next actions into Jarvis. Fixture runs use no live credentials and create no external effects.

## Automation portfolio

| Automation | State | Cadence | Strategic lane | Required output | Consumer / decision | Accepted terminal states |
|---|---|---|---|---|---|---|
| `bible-copilot-ecosystem-distribution` | ACTIVE | Thu at 9:00 AM ET | Distribute / verify | distribution-ledger: bible-copilot-authority-system/weeks/YYYY-Www/distribution-ledger.jsonl | `portfolio-outcome-reconciliation`, `weekly-executive-opportunity-brief` | `published_verified`, `verified_skip`, `blocked_source`, `failed_closed` |
| `bible-copilot-facebook-publishing` | PAUSED | Daily at 11:30 AM ET | Distribute / verify | publication-receipt: automation custody receipt | `weekly-social-performance-and-share-brief` | `published_verified`, `verified_skip`, `blocked_source`, `failed_closed` |
| `bible-copilot-facebook-publishing-evening` | PAUSED | Daily at 7:01 PM ET | Distribute / verify | publication-receipt: automation custody receipt | `weekly-social-performance-and-share-brief` | `published_verified`, `verified_skip`, `blocked_source`, `failed_closed` |
| `bible-copilot-reference-asset-builder` | ACTIVE | Tue at 10:00 AM ET | Build | release-manifest: bible-copilot-authority-system/weeks/YYYY-Www/reference-asset.json | `bible-copilot-seo-aeo-authority-expansion` | `deployed_and_verified`, `verified_skip`, `deferred_with_exact_requirement`, `failed_with_recovery` |
| `bible-copilot-seo-aeo-authority-expansion` | ACTIVE | Wed at 9:00 AM ET | Expand authority | release-manifest: bible-copilot-authority-system/weeks/YYYY-Www/authority-expansion.json | `bible-copilot-ecosystem-distribution` | `deployed_and_verified`, `verified_skip`, `deferred_with_exact_requirement`, `failed_with_recovery` |
| `bible-copilot-seo-growth-loop` | ACTIVE | Mon at 6:15 AM ET | Expand authority | demand-manifest: bible-copilot-authority-system/weeks/YYYY-Www/cluster-manifest.json | `bible-copilot-reference-asset-builder` | `deployed_and_verified`, `verified_skip`, `deferred_with_exact_requirement`, `failed_with_recovery` |
| `bible-copilot-weekly-performance-review` | ACTIVE | Mon at 2:30 AM ET | Measure / decide | scorecard: biblecopilot/marketing/weekly-scorecards/YYYY-MM-DD.md | `bible-copilot-seo-growth-loop`, `weekly-executive-opportunity-brief` | `completed_verified`, `completed_with_missing_evidence`, `verified_skip`, `failed_closed` |
| `bible-copilot-weekly-youtube-compilation` | ACTIVE | Sun at 8:00 AM ET | Distribute / verify | publication-receipt: BibleCopilot-tiktok-bot/logs/youtube.jsonl | `youtube-portfolio-weekly-review` | `published_verified`, `verified_skip`, `blocked_source`, `failed_closed` |

## Chain-of-custody handoffs

- `bible-copilot-ecosystem-distribution` → `portfolio-outcome-reconciliation`: the consumer must resolve the exact artifact path and SHA-256 from the producer's immutable receipt.
- `bible-copilot-ecosystem-distribution` → `weekly-executive-opportunity-brief`: the consumer must resolve the exact artifact path and SHA-256 from the producer's immutable receipt.
- `bible-copilot-facebook-publishing` → `weekly-social-performance-and-share-brief`: the consumer must resolve the exact artifact path and SHA-256 from the producer's immutable receipt.
- `bible-copilot-facebook-publishing-evening` → `weekly-social-performance-and-share-brief`: the consumer must resolve the exact artifact path and SHA-256 from the producer's immutable receipt.
- `bible-copilot-reference-asset-builder` → `bible-copilot-seo-aeo-authority-expansion`: the consumer must resolve the exact artifact path and SHA-256 from the producer's immutable receipt.
- `bible-copilot-seo-aeo-authority-expansion` → `bible-copilot-ecosystem-distribution`: the consumer must resolve the exact artifact path and SHA-256 from the producer's immutable receipt.
- `bible-copilot-seo-growth-loop` → `bible-copilot-reference-asset-builder`: the consumer must resolve the exact artifact path and SHA-256 from the producer's immutable receipt.
- `bible-copilot-weekly-performance-review` → `bible-copilot-seo-growth-loop`: the consumer must resolve the exact artifact path and SHA-256 from the producer's immutable receipt.
- `bible-copilot-weekly-performance-review` → `weekly-executive-opportunity-brief`: the consumer must resolve the exact artifact path and SHA-256 from the producer's immutable receipt.
- `bible-copilot-weekly-youtube-compilation` → `youtube-portfolio-weekly-review`: the consumer must resolve the exact artifact path and SHA-256 from the producer's immutable receipt.

## Strategy review rule

- Weekly or scheduled reviews evaluate customer or operational outcomes, not merely whether jobs ran.
- A downstream automation must fail closed when the registered upstream receipt is absent, stale for the reporting window, malformed, or hash-invalid.
- Paused automations remain documented strategic capabilities but must not be treated as producing current evidence.
- Add, retire, pause, or materially change an automation only by updating this strategy, its output contract, its downstream consumers, and the normalized control system together.
- Quarterly strategy review must confirm that every automation still advances a current objective, has an owner and observable output, and does not duplicate another lane.

# Bible Copilot Repository Guidance

## Automation Bootstrap

Scheduled runs must first read
`/Users/carlosreyes/Documents/Projects/Codex Projects/Jarvis Workspace/AUTOMATION-OPERATING-CONTEXT.md`
for portfolio routing, weekly handoffs, deterministic recovery, and safety boundaries.
They must then read `AUTOMATION-STRATEGY.md` for Bible Copilot's current strategic lanes,
registered outputs, safe terminal states, and downstream handoffs.

## Authority

- Read `product-truth.json` before changing product copy, pricing, plans, trials, free limits, modes, App Store links, or claims.
- Use `/Users/carlosreyes/Documents/Codex/2026-07-27/i-ve-logged/outputs/portfolio-control-system/control-system.json` for operational ownership, evidence, journeys, metrics, risks, experiments, and decisions.
- Preserve StoreKit 2 unless Carlos explicitly approves an architectural change.

## Required Checks

- Verify the first-question journey, free-limit behavior, paywall, purchases, entitlements, and restore purchases when affected.
- Preserve acquisition source through onboarding, trial, purchase, and renewal when affected.
- Run applicable tests and build checks before reporting completion.
- Validate structured data, canonicals, sitemap, links, and stale product claims for website changes.
- Do not create thin or cannibalizing verse pages without query evidence.

## Code Review Rules

- Flag pricing, entitlement, trial, free-limit, or product-claim drift as P1.
- Flag lost attribution, duplicated purchase events, or broken restore behavior as P1.
- Flag production deployment, App Store submission, payment changes, destructive migrations, or secret exposure without approval.
- Keep deterministic formatting and lint checks in CI.

## Control-System Update

After a consequential verified change, update the corresponding normalized asset, dependency, journey, metric, risk, experiment, or decision record and rerun the control-system validator.

## Jarvis Handoff

Before declaring any material work complete, reconcile it to Jarvis. A material change includes a
production, analytics, customer-journey, pricing/entitlement, release, publishing, security,
infrastructure, or external-integration change.

Record the product/asset affected, what changed, verification evidence, remaining risks or evidence
gaps, approvals still needed, and the next safest action in the normalized portfolio control system.
Run the control-system validator. Do not treat a chat summary as the governance record.

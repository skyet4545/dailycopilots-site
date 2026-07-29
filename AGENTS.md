# Bible Copilot repository guidance

## Code Review Rules

### Product and subscription truth

Flag price, trial, free-limit, entitlement, or product-claim drift from `product-truth.json`. Preserve StoreKit 2 unless an approved architecture decision changes it.

### Measurement integrity

Flag renamed, removed, duplicated, or semantically changed funnel events without a compatibility plan and a verification step.

### Production safety

Flag production deployment, App Store submission, payment changes, destructive migrations, or secret exposure without an explicit gate and rollback path.

## Required checks

Run the product-contract validation for marketing, product-copy, pricing, subscription, trial, or entitlement changes.

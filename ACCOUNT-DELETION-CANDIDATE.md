# Bible Copilot account-deletion client candidate

This isolated branch adds the missing in-app account-deletion initiation to the privacy-ready 2.4.4/130 candidate. It is prepared for review and local verification only. It has not been merged, uploaded, submitted, released, or connected to a deployed deletion endpoint.

## User flow

- Signed-in users can find **Delete Account** in Settings > Account.
- Two destructive confirmations explain exactly what is removed and that deleting the account does not cancel an App Store subscription.
- The client calls the authenticated `delete-account` Edge Function with `app_id=bible_copilot`.
- On a server-confirmed result, the client clears Bible Copilot SwiftData, local streak and onboarding-personalization data, its analytics identifier and consent, and the local Supabase session.
- When other Copilot memberships remain, the shared server identity is preserved while the Bible Copilot session on this device is removed.
- When the server reports that an Apple authorization must be revoked manually, the completion message gives Apple's Settings path and still confirms the completed data deletion.
- Server errors keep local data. A connection failure is reported as an unknown destructive outcome and does not tell the user to retry blindly.

## Verification

- Generic iOS Simulator build: passed.
- Full BibleCopilot test suite on iPhone 17 Pro Max / iOS 26.5: 71 passed, 0 failed.
- Backend pure orchestration suite: 7 passed, 0 failed.

## Remaining release gates

1. Owner approval to resume the shared Supabase project.
2. Read-only schema, RLS, membership, storage, JWT-lifetime, and identity-provider verification against the resumed project.
3. Reconcile the isolated migration to the observed production schema.
4. Deploy and integration-test the backend with synthetic Bible-only, multi-app, email, and Apple identities.
5. Verify the manual Sign in with Apple revocation experience on a real device. Apple recommends programmatic token revocation when a revocable token exists; the existing integration has not proven that it retains one. Apple's TN3194 permits completed data deletion followed by a documented manual-revocation path when the token or authorization code is unavailable.
6. Verify deletion, local cleanup, shared-identity preservation, subscription messaging, and post-deletion sign-in on a real device.
7. Owner approval for merge, upload, App Store submission, and release.

The public App Store privacy answers and website privacy policy must also be corrected so they match the shipped behavior before this candidate can be presented as privacy-ready.

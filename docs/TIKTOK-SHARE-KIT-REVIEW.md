# TikTok Share Kit Review Package

## Rejection addressed

TikTok rejected the previous submission because it described a private, company-operated posting bot for `@biblecopilot1`. TikTok developer apps must provide a public user-facing integration and may not be limited to personal or internal company use.

Bible Copilot now uses **Share Kit only**. Any app user can deliberately create Scripture cards and hand them to TikTok for editing and publication on that user's own account. Bible Copilot does not authenticate a company account, schedule posts, publish in the background, or publish without the user's action.

## Developer portal configuration

- App name: `Bible Copilot`
- Description: `Bible study app that lets users create styled Scripture cards and share them to TikTok.`
- Platform: iOS
- Bundle ID: `com.scripturecopilot.app`
- Product requested: Share Kit only
- Remove: Login Kit, Content Posting API, `user.info.basic`, and `video.upload`
- Universal-link redirect: `https://mybiblecopilot.com/tiktok/share`
- Public client key: use the key already assigned to the TikTok developer app

## Review explanation

Revision after reviewer feedback: Bible Copilot now offers a public, user-facing Share Kit integration. In the iOS app, any user opens the Verse of the Day, taps Share, chooses one of three visual styles, previews a two-card Scripture/reflection post, and taps Share to TikTok. The app generates two 9:16 images selected by the user, saves them to Photos with permission, and opens TikTok Share Kit so the user can edit and decide whether to publish to their own account. Bible Copilot does not authenticate or post to a company-owned account, does not run background or scheduled posting, and does not publish without the user's explicit action. This revision removes Login Kit, Content Posting API, user.info.basic, and video.upload because they are not used. Requested product: Share Kit only.

## Required demo video

Record one continuous video on a physical iPhone with TikTok installed:

1. Open the review build of Bible Copilot.
2. On Verse of the Day, tap the share button.
3. Show that Midnight, Parchment, and Sunrise are selectable by any user.
4. Preview both generated 9:16 cards.
5. Tap **Share to TikTok**.
6. If prompted, allow Photos access.
7. Show TikTok opening with both images in its edit/post flow.
8. Show that the user controls editing and publication; do not publish unless desired.
9. Return to Bible Copilot through the universal-link callback.

The recording must show the actual integration and user interaction. A simulator-only video is insufficient because it cannot demonstrate the installed TikTok app's handoff.

## Submission gates

- Verified 2026-07-31: `https://mybiblecopilot.com/.well-known/apple-app-site-association` returns HTTP 200 as `application/json`, without a redirect, and matches the local callback contract.
- Install a signed review build on a physical iPhone and verify the Share Kit handoff.
- Upload the continuous demo video to the TikTok review form.
- Confirm the live App Store/review build contains the Share Kit feature before resubmitting.

# Play Store Submission Checklist

## Scope

This checklist is for the Android Play Console submission of Guarden's current release build.

## Current Release Facts

- App name: `Guarden`
- Android package name: `com.pwm.guarden`
- Default version from repo: `1.0.0+1`
- Release artifact: `build/app/outputs/bundle/release/app-release.aab`
- Release format: Android App Bundle (`.aab`)
- Min SDK: `29`
- Compile SDK: `36`
- Ads in release build: `Enabled` by default unless `DISABLE_MOBILE_ADS=true`
- Telemetry in release build: `Disabled` by default unless `ENABLE_TELEMETRY=true`
- Google account / Drive backup: `Present`, user-triggered
- Biometrics: `Present`, user-triggered
- Autofill service: `Present`, user-triggered

## Upload Gate

Do not upload until all are true:

- [x] `dart analyze lib test` passed
- [x] `flutter test` passed
- [x] Signed Android App Bundle exists at `build/app/outputs/bundle/release/app-release.aab`
- [x] Bundle is signed with the production upload key, not the Android debug key
- [x] Package name is `com.pwm.guarden`
- [x] Android launch manifest uses production AdMob App ID
- [ ] Privacy policy is hosted at a public HTTPS URL
- [ ] Support URL is ready
- [ ] Store listing text and screenshots are ready

## Play Console App Setup

Use these values when creating or reviewing the Play app:

- App name: `Guarden`
- Default language: choose the launch language you want to maintain first in the listing
- App or game: `App`
- Free or paid: verify against your monetization plan before first upload
- Package name: `com.pwm.guarden`

## Main Store Listing

Prepare these before production rollout:

- [ ] App name finalized
- [ ] Short description finalized
- [ ] Full description finalized
- [ ] App icon uploaded
- [ ] Phone screenshots uploaded
- [ ] Tablet screenshots uploaded if you want tablet merchandising
- [ ] Feature graphic uploaded
- [ ] Category selected
- [ ] Contact email set
- [ ] Privacy policy URL set
- [ ] Support URL set

Use these repo files to prepare listing assets and copy:

- `docs/release/PLAYSTORE_LISTING_COPY.md`
- `docs/release/PLAYSTORE_ASSET_PLAN.md`

Recommended values from current repo inspection:

- Contact email: `jackdrawer90@gmail.com`
- Privacy policy source file: `docs/legal/privacy_policy_en.md`
- Category suggestion: `Productivity`

Category is an inference from the shipped app behavior, not a Play Console requirement from the repo itself.

## App Content

Complete the App content section in this order:

- [ ] Privacy policy
- [ ] Ads declaration
- [ ] App access
- [ ] Content rating
- [ ] Data safety
- [ ] Government apps declaration, if applicable
- [ ] Financial features declaration, if applicable
- [ ] News apps declaration, if applicable

Working guidance for Guarden:

- Ads: answer `Yes` for the release build unless you intentionally upload an ads-disabled build
- App access: likely `No special access instructions required` if reviewer can create a local vault normally on first launch
- Content rating: complete the questionnaire based on actual shipped features; do not guess
- Government / News: likely `No`
- Financial features: do not mark as a financial-services app unless you add regulated financial functionality beyond encrypted personal record storage

The App access recommendation above is an inference from the current app flow and should be rechecked against the uploaded build.

## Data Safety Working Draft

Use `docs/release/PRIVACY_DISCLOSURE_MATRIX.md` as the source of truth while filling Data safety.

Submission-critical points for this Android build:

- [ ] Do not omit ads. `google_mobile_ads` is active in release by default.
- [ ] Do not omit Google account linked backup behavior. Google Sign-In and Drive backup exist on user action.
- [ ] If you upload the standard release build, answer telemetry based on telemetry being disabled by default unless you turned it on with build flags.
- [ ] If you upload a telemetry-enabled build, update Data safety answers to match that binary.
- [ ] Keep privacy policy wording aligned with encrypted local storage plus optional encrypted cloud backup.

## Testing Before Production

- [ ] Create at least an internal test release first
- [ ] Review generated app bundle warnings in Play Console
- [ ] Review Pre-launch report results
- [ ] Fix any stability, compatibility, accessibility, or security issues found in Pre-launch report
- [ ] If your Play developer account is subject to personal-account testing rules, complete the required closed test before production

## Screenshot Capture Run

Use the polished Android surfaces from Phase 15 in this order:

1. Welcome screen
2. Login screen with biometric card
3. Home shell
4. Bank Accounts empty state with CTA
5. Web Passwords empty state with CTA
6. Settings trust card and backup controls

Before export, confirm all are true:

- [ ] No permission dialogs, snackbars, or keyboards cover the UI
- [ ] The Guarden dark theme and orange accent are visible consistently
- [ ] Empty-state CTA buttons are fully visible in module screenshots
- [ ] The settings screenshot shows both the trust card and backup-related controls
- [ ] Screenshot captions come from `docs/release/PLAYSTORE_LISTING_COPY.md`

## Release Creation

- [ ] Create a new release in Play Console
- [ ] Upload `build/app/outputs/bundle/release/app-release.aab`
- [ ] Enroll or confirm Play App Signing
- [ ] Review version code and release notes
- [ ] Confirm supported devices are acceptable
- [ ] Save, review, and roll out to testing first
- [ ] Promote to production only after test track checks are clean

## Post-Upload Review

- [ ] Confirm no policy warnings remain on Dashboard
- [ ] Confirm Data safety and Ads answers are accepted
- [ ] Confirm store listing preview looks correct in Turkish and English if both will ship
- [ ] Confirm the uploaded release is the same binary whose disclosures you completed
- [ ] Confirm uploaded screenshots match the current in-app launch surfaces, not outdated UI captures

## Source Links

- Target API requirement: https://developer.android.com/google/play/requirements/target-sdk
- Android App Bundles overview: https://developer.android.com/guide/app-bundle
- App signing and Play App Signing: https://developer.android.com/studio/publish/app-signing
- Test app bundles and use test tracks: https://developer.android.com/guide/app-bundle/test
- Data safety help entry: https://support.google.com/googleplay/android-developer/answer/10787469
- Personal-account testing requirement: https://support.google.com/googleplay/android-developer/answer/14151465

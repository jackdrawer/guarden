# Store Launch Checklist

## Current Goal

Guarden is ready for submission only when Android release, launch polish, iOS archive readiness, test baseline, and privacy/store metadata all align.

## Code Gate

- [x] Android release signing fails closed instead of falling back to debug signing
- [x] Android billing permission removed from launch manifest
- [x] Android production AdMob App ID and unit IDs configured
- [x] iOS production AdMob App ID and unit IDs configured
- [x] iOS bundle identifier moved to `com.pwm.guarden`
- [x] Face ID usage text added to iOS metadata
- [x] `ios/Podfile` restored
- [x] `flutter test` passes locally
- [x] `dart analyze lib test` passes locally
- [x] Android launch surfaces are polished for screenshot capture
- [x] Empty states expose clear next-step CTAs on key modules
- [x] Login, onboarding, and settings trust messaging is aligned with Play listing copy

## Remaining Manual / External Gate

- [x] Android signing secrets available in `android/key.properties`
- [x] Android release bundle built successfully with real signing config
- [ ] `GoogleService-Info.plist` added to iOS Runner target
- [ ] `GOOGLE_IOS_CLIENT_ID` set in Xcode build settings
- [ ] `GOOGLE_IOS_REVERSED_CLIENT_ID` set in Xcode build settings
- [ ] iOS archive succeeds on macOS
- [ ] Google Drive backup sign-in verified on iOS device/archive build
- [ ] Play Console Data Safety completed
- [ ] App Store privacy labels completed
- [ ] Privacy policy / support URL / listing metadata finalized
- [ ] Final Android screenshots captured from polished launch surfaces and uploaded to Play Console

## Evidence Pack

Use these documents together:

- `docs/release/ANDROID_RELEASE_RUNBOOK.md`
- `docs/release/PLAYSTORE_SUBMISSION_CHECKLIST.md`
- `docs/release/PLAYSTORE_ASSET_PLAN.md`
- `docs/release/PLAYSTORE_LISTING_COPY.md`
- `docs/release/IOS_ARCHIVE_CHECKLIST.md`
- `docs/release/PRIVACY_DISCLOSURE_MATRIX.md`

## Recommended Submission Order

1. Create signed Android App Bundle and verify Play Console metadata
2. Capture the final Android screenshot set from the polished launch surfaces
3. Complete iOS archive and device verification on macOS
4. Finalize console disclosures using the exact uploaded binaries
5. Perform final go / no-go review

## Go / No-Go Sign-Off

Go only if all are true:

- `dart analyze lib test` is green
- `flutter test` is green
- Android signed release artifact exists
- Android screenshots reflect the current polished surfaces
- iOS archive succeeds
- Google Drive sign-in works on iOS
- Privacy/store disclosures match the uploaded builds

No-Go if any launch blocker remains unresolved.

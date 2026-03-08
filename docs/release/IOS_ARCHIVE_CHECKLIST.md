# iOS Archive Checklist

## Purpose

Use this checklist on macOS to validate the iOS submission path for Guarden before App Store upload.

## Current iOS Launch Facts

- Bundle ID: `com.pwm.guarden`
- AdMob App ID: `ca-app-pub-7514989682859982~6362984906`
- Face ID usage description is present in `ios/Runner/Info.plist`
- `ios/Podfile` exists for CocoaPods-based Flutter integration
- Google Sign-In callback placeholders exist in `Info.plist`

## Required Inputs Before Archive

- Apple Development Team selected in Xcode
- Valid provisioning profile / signing certificates
- `ios/Runner/GoogleService-Info.plist`
- Xcode build settings:
  - `GOOGLE_IOS_CLIENT_ID`
  - `GOOGLE_IOS_REVERSED_CLIENT_ID`

## Setup Steps

Run from repo root on macOS:

```bash
flutter clean
flutter pub get
cd ios
pod install
open Runner.xcworkspace
```

## Xcode Checks

Inside Xcode verify:

1. Runner target bundle identifier is `com.pwm.guarden`
2. RunnerTests bundle identifier is `com.pwm.guarden.RunnerTests`
3. `GoogleService-Info.plist` is part of the Runner target
4. `GOOGLE_IOS_CLIENT_ID` is set from `CLIENT_ID`
5. `GOOGLE_IOS_REVERSED_CLIENT_ID` is set from `REVERSED_CLIENT_ID`
6. Face ID usage text is present and readable
7. AdMob App ID is production, not Google's sample value

## Functional Checks Before Archive

1. App boots
2. Biometric prompt appears correctly on Face ID capable device
3. Google Drive backup sign-in opens and returns correctly
4. No placeholder callback scheme remains in the built app

## Archive Steps

1. Select `Any iOS Device (arm64)` or a physical device
2. Product -> Archive
3. Wait for Organizer to open
4. Validate signing and export options
5. Keep archive only if all metadata and sign-in checks pass

## Stop-Ship Conditions

Do not upload if any of these are true:

- `GoogleService-Info.plist` is missing
- `GOOGLE_IOS_CLIENT_ID` or `GOOGLE_IOS_REVERSED_CLIENT_ID` is unset
- Bundle ID still uses `com.example.guarden`
- Face ID prompt text is missing
- Google Drive sign-in callback fails
- Archive/signing fails in Xcode

# iOS Launch Config Checklist

## Required File: GoogleService-Info.plist

After setting up Firebase Console:

1. Visit https://console.firebase.google.com
2. Open your Guarden project
3. Go to Project Settings -> Your apps -> iOS app
4. Click "Download GoogleService-Info.plist"
5. Place the file in this directory: `ios/Runner/GoogleService-Info.plist`

The file should be at: `ios/Runner/GoogleService-Info.plist`

IMPORTANT: This file contains sensitive configuration. Keep it out of git.

## Required Xcode Build Settings

The current `Info.plist` expects these build settings to be populated before archive:

- `GOOGLE_IOS_CLIENT_ID`
- `GOOGLE_IOS_REVERSED_CLIENT_ID`

You can source them from the downloaded `GoogleService-Info.plist`:

- `CLIENT_ID` -> `GOOGLE_IOS_CLIENT_ID`
- `REVERSED_CLIENT_ID` -> `GOOGLE_IOS_REVERSED_CLIENT_ID`

Add them in Xcode build settings or xcconfig files used for archive builds.

Recommended local setup:

1. Copy `ios/Flutter/LaunchSecrets.example.xcconfig` to `ios/Flutter/LaunchSecrets.xcconfig`
2. Paste the real values into `LaunchSecrets.xcconfig`
3. Keep `LaunchSecrets.xcconfig` out of git

## Archive Verification

Before App Store submission, verify all of the following on macOS:

1. `flutter pub get`
2. `cd ios && pod install`
3. Open `Runner.xcworkspace`
4. Confirm bundle identifier is `com.pwm.guarden`
5. Confirm `GoogleService-Info.plist` is included in the Runner target
6. Confirm `GOOGLE_IOS_CLIENT_ID` and `GOOGLE_IOS_REVERSED_CLIENT_ID` are set
7. Build and test Google Sign-In / Drive backup flow
8. Confirm Face ID prompt copy is present and understandable
9. Archive the app in Xcode using the intended Apple team and provisioning profile

## Quick Verification Commands

```bash
flutter clean
flutter pub get
cd ios
pod install
```

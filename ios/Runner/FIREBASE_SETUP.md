# Firebase Setup for iOS

## Required File: GoogleService-Info.plist

After setting up Firebase Console:

1. Visit https://console.firebase.google.com
2. Open your Guarden project
3. Go to Project Settings → Your apps → iOS app
4. Click "Download GoogleService-Info.plist"
5. **Place the file in this directory**: `ios/Runner/GoogleService-Info.plist`

The file should be at: `ios/Runner/GoogleService-Info.plist` (same directory as this file)

**IMPORTANT**: This file contains sensitive configuration. It should be in `.gitignore` to prevent accidental commit.

## Verification

After adding the file, run:
```bash
flutter clean
flutter pub get
flutter build ios --debug
```

The build should succeed without Firebase errors.

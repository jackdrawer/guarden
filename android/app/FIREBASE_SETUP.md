# Firebase Setup for Android

## Required File: google-services.json

After setting up Firebase Console:

1. Visit https://console.firebase.google.com
2. Open your Guarden project
3. Go to Project Settings → Your apps → Android app
4. Click "Download google-services.json"
5. **Place the file in this directory**: `android/app/google-services.json`

The file should be at: `android/app/google-services.json` (same directory as this file)

**IMPORTANT**: This file contains sensitive configuration. It should be in `.gitignore` to prevent accidental commit.

## Verification

After adding the file, run:
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

The build should succeed without Firebase errors.

# Guarden Configuration Guide

## 📋 Prerequisites

- Flutter SDK 3.32.2+
- Dart SDK 3.8.1+
- Android Studio (for Android builds)
- Xcode (for iOS builds)
- RevenueCat account (for premium features)

---

## 🔑 API Keys Configuration

### 1. RevenueCat Setup

1. Create account at [RevenueCat](https://app.revenuecat.com/)
2. Create a new project
3. Get your API keys:
   - **Google Play Store** API key
   - **Apple App Store** API key

### 2. Configure Locally

Create a `.env` file (copy from `.env.example`):

```bash
cp .env.example .env
```

Edit `.env` and add your keys:

```bash
RC_GOOGLE_API_KEY=your_actual_google_key_here
RC_APPLE_API_KEY=your_actual_apple_key_here
```

**⚠️ IMPORTANT:** Never commit `.env` to git!

---

## 🏗️ Build Commands

### Development

**Android:**
```bash
flutter run \
  --dart-define=RC_GOOGLE_API_KEY=your_google_key
```

**iOS:**
```bash
flutter run \
  --dart-define=RC_APPLE_API_KEY=your_apple_key
```

**Both (using .env):**
```bash
# Load from .env file
source .env
flutter run \
  --dart-define=RC_GOOGLE_API_KEY=$RC_GOOGLE_API_KEY \
  --dart-define=RC_APPLE_API_KEY=$RC_APPLE_API_KEY
```

### Production Release

**Android APK:**
```bash
flutter build apk --release \
  --dart-define=RC_GOOGLE_API_KEY=$RC_GOOGLE_API_KEY
```

**Android App Bundle:**
```bash
flutter build appbundle --release \
  --dart-define=RC_GOOGLE_API_KEY=$RC_GOOGLE_API_KEY
```

**iOS:**
```bash
flutter build ipa --release \
  --dart-define=RC_APPLE_API_KEY=$RC_APPLE_API_KEY
```

---

## 🔐 Android Release Signing

### 1. Generate Keystore

```bash
keytool -genkey -v \
  -keystore ~/guarden-release-key.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias guarden
```

### 2. Create `android/key.properties`

```properties
storeFile=/absolute/path/to/guarden-release-key.jks
storePassword=your_store_password
keyAlias=guarden
keyPassword=your_key_password
```

**⚠️ IMPORTANT:** This file is git-ignored. Never commit it!

### 3. Build Release

```bash
flutter build appbundle --release \
  --dart-define=RC_GOOGLE_API_KEY=$RC_GOOGLE_API_KEY
```

Output: `build/app/outputs/bundle/release/app-release.aab`

---

## 🍎 iOS Release Signing

### 1. Configure Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to Signing & Capabilities
4. Select your Team
5. Configure Bundle Identifier (e.g., `com.yourcompany.guarden`)

### 2. Archive & Export

```bash
flutter build ipa --release \
  --dart-define=RC_APPLE_API_KEY=$RC_APPLE_API_KEY
```

Or use Xcode:
1. Product → Archive
2. Distribute App → App Store Connect

---

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Code Quality
```bash
flutter analyze
dart format --set-exit-if-changed .
```

---

## 📦 Dependencies Update

```bash
flutter pub upgrade --major-versions
flutter pub outdated
```

---

## 🐛 Troubleshooting

### "RevenueCat API key missing" error

**Problem:** App crashes on startup with missing API key error.

**Solution:** Pass API keys via `--dart-define`:
```bash
flutter run --dart-define=RC_GOOGLE_API_KEY=your_key
```

### Keystore not found (Android)

**Problem:** Build fails with "key.properties not found".

**Solution:** Create `android/key.properties` following step 2 above.

### Hive encryption error

**Problem:** "DB Encryption Key not found" on login.

**Solution:** This is expected on first launch. The app will prompt for master password setup.

### Biometric auth not working

**Problem:** Face ID/Fingerprint doesn't work.

**Cause:** Simulator doesn't support biometric auth.

**Solution:** Test on real device.

---

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [RevenueCat Docs](https://docs.revenuecat.com/)
- [Hive Documentation](https://docs.hivedb.dev/)
- [Riverpod Guide](https://riverpod.dev/)

---

## 🆘 Support

For issues or questions:
- Check [README.md](README.md)
- Review code documentation
- Create an issue in the repository

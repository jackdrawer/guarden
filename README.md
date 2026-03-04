# 🔐 Guarden Password Manager

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.32.2+-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.8.1+-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey" alt="Platform">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
</p>

**Guarden** is a secure, offline-first password vault for managing bank accounts, subscriptions, and web credentials with **AES-256-GCM encryption** and **biometric unlock**. 

*This is a full open-source Flutter alternative to subscription-based password managers, designed explicitly with a zero-trust architecture where only you own your data.*

---

## 🌟 Key Features

- **Offline-First Security**: Your passwords never leave your device unless you explicitly export them.
- **Bank-Grade Encryption**: Everything is encrypted using AES-256-GCM.
- **Google Drive Backup**: Optional, encrypted backup sink to your personal google drive.
- **Biometric Unlock**: Fast access via Face ID / Touch ID.
- **Local Import/Export**: Easy JSON backup management.
- **Screenshot protection**
- **Clipboard auto-clear**

### 💾 Data Management
- **Bank Accounts** - Store account details, passwords
- **Subscriptions** - Track costs, billing cycles
- **Web Passwords** - Save login credentials
- **Encrypted local storage** (Hive + AES)
- **Backup & Restore** (encrypted export/import)

### 🎨 User Experience
- **Neumorphic design** system
- **Dark mode** support
- **Dynamic logo** fetching (cached)
- **Autofill framework** (Android & iOS)
- **Responsive layout** (phone/tablet)
- **Accessibility** labels

### 💳 Premium Features (via RevenueCat)
- **Unlimited** credentials (free: limited)
- **Security audit** - HIBP password breach check
- **Travel mode** - Quick vault lock
- **Panic mode** - Emergency data wipe
- **Password expiry** notifications

---

## 🚀 Quick Start

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.32.2+
- [Dart SDK](https://dart.dev/get-dart) 3.8.1+
- Android Studio / Xcode

### Installation

```bash
# Clone repository
git clone https://github.com/yourusername/guarden.git
cd guarden

# Install dependencies
flutter pub get

# Run app (development)
flutter run
```

### With API Keys (Premium Features)

```bash
# Set up environment variables
cp .env.example .env
# Edit .env with your RevenueCat keys

# Run with keys
source .env
flutter run \
  --dart-define=RC_GOOGLE_API_KEY=$RC_GOOGLE_API_KEY \
  --dart-define=RC_APPLE_API_KEY=$RC_APPLE_API_KEY
```

> 📖 **Detailed setup:** See [CONFIGURATION.md](CONFIGURATION.md)

---

## 📚 Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System design, security model, data flow
- **[CONFIGURATION.md](CONFIGURATION.md)** - API setup, build commands, signing
- **[.env.example](.env.example)** - Environment template

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Integration tests
flutter test integration_test/
```

**Test Coverage:**
- ✅ 13 unit tests (crypto, auth, backup, providers)
- ✅ All tests passing
- ⚠️ Integration tests TBD

---

## 🔒 Security Model

### Encryption Flow

```
Master Password
     ↓
PBKDF2-HMAC-SHA256 (100k iterations)
     ↓
AES-256 Key
     ↓
   ┌────┴────┐
   ↓         ↓
Keychain  Hive Boxes
(Secure)  (Encrypted)
```

### Key Features

- **Zero-knowledge**: Master password never stored
- **Hardware-backed**: Keys in device Keychain/Keystore
- **Forward secrecy**: New salt per installation
- **Constant-time**: Timing attack resistant
- **Auto-lock**: Background app encryption

> 🔍 **Deep dive:** See [ARCHITECTURE.md § Security](ARCHITECTURE.md#-security-architecture)

---

## 🏗️ Build & Release

### Android

```bash
# Debug APK
flutter build apk --debug

# Release AAB (Play Store)
flutter build appbundle --release \
  --dart-define=RC_GOOGLE_API_KEY=your_key
```

**Signing:** Create `android/key.properties`:

```properties
storeFile=/path/to/guarden-release-key.jks
storePassword=your_password
keyAlias=guarden
keyPassword=your_password
```

### iOS

```bash
# Release IPA (App Store)
flutter build ipa --release \
  --dart-define=RC_APPLE_API_KEY=your_key
```

**Signing:** Configure in Xcode → Runner → Signing & Capabilities

> ⚙️ **Full guide:** See [CONFIGURATION.md](CONFIGURATION.md)

---

## 📦 Project Structure

```
lib/
├── constants/      # Brand database, static data
├── models/         # Domain models (Hive)
├── providers/      # Riverpod state management
├── screens/        # UI screens (10 modules)
├── services/       # Business logic (12 services)
├── theme/          # Neumorphic design system
├── widgets/        # Reusable components
├── main.dart       # App entry point
└── router.dart     # Navigation (GoRouter)
```

> 🏛️ **Architecture:** See [ARCHITECTURE.md](ARCHITECTURE.md)

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.32.2, Dart 3.8.1 |
| **State** | Riverpod 2.6.1 |
| **Navigation** | GoRouter 17.0.0 |
| **Database** | Hive 2.2.3 (encrypted) |
| **Crypto** | cryptography 2.9.0 (AES-256-GCM, PBKDF2) |
| **Auth** | local_auth 2.3.0, flutter_secure_storage 10.0.0 |
| **Premium** | RevenueCat (purchases_flutter 9.12.3) |
| **UI** | Custom Neumorphic design system |

---

## 🎯 Roadmap

- [x] **Phase 1:** Foundation (crypto, database)
- [x] **Phase 2:** Auth & Security (login, biometric)
- [x] **Phase 3:** Core UI (CRUD modules)
- [x] **Phase 4:** Premium & Paywall
- [x] **Phase 5:** UX & Autofill
- [x] **Phase 6:** Backup & Recovery
- [ ] **Phase 7:** Cloud sync (E2E encrypted)
- [ ] **Phase 8:** Browser extensions
- [ ] **Phase 9:** Desktop apps

---

## 🐛 Quality Gate

### Local Checks

```bash
# Analyze code
flutter analyze

# Run tests
flutter test

# Format code
dart format .
```

### PowerShell Script

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\quality_gate.ps1
```

### CI/CD

GitHub Actions workflow: `.github/workflows/quality-gate.yml`

---

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

**Code Style:**
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Run `flutter analyze` before committing
- Add tests for new features

---

## 📄 License

This project is licensed under the **MIT License** - see [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev/) - Amazing framework
- [Riverpod](https://riverpod.dev/) - State management
- [Hive](https://docs.hivedb.dev/) - Fast local database
- [RevenueCat](https://www.revenuecat.com/) - In-app purchases
- [OWASP](https://owasp.org/) - Security best practices

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/yourusername/guarden/issues)
- **Docs:** [ARCHITECTURE.md](ARCHITECTURE.md) | [CONFIGURATION.md](CONFIGURATION.md)
- **Email:** support@guarden.app

---

<p align="center">
  Made with ❤️ using Flutter
</p>

# Guarden Password Manager - Architecture Documentation

## 📐 Architecture Overview

Guarden follows **Clean Architecture** principles with clear separation of concerns.

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Screens    │  │   Widgets    │  │    Theme     │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   State Management                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Providers   │  │   Notifiers  │  │   Riverpod   │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                     Business Logic                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Services   │  │    Models    │  │  Constants   │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                      Data Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Hive (DB)   │  │SecureStorage │  │  HTTP/API    │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 🏗️ Project Structure

```
lib/
├── constants/           # Static data, brand database
├── models/             # Domain models (BankAccount, Subscription, WebPassword)
│   └── *.g.dart       # Generated Hive TypeAdapters
├── providers/          # Riverpod state management
│   ├── auth_provider.dart
│   ├── bank_account_provider.dart
│   ├── premium_provider.dart
│   ├── settings_provider.dart
│   ├── subscription_provider.dart
│   └── web_password_provider.dart
├── screens/            # UI screens (feature-based organization)
│   ├── auth/          # Login, Recovery
│   ├── onboarding/    # Welcome, Setup, Biometric opt-in
│   ├── bank_accounts/ # Bank CRUD
│   ├── subscriptions/ # Subscription CRUD
│   ├── web_passwords/ # Password CRUD
│   ├── dashboard/     # Dashboard
│   ├── security/      # Security audit
│   ├── settings/      # Settings
│   ├── paywall/       # Paywall
│   ├── autofill_screen.dart
│   ├── home_screen.dart
│   └── splash_screen.dart
├── services/           # Business logic services
│   ├── crypto_service.dart         # AES-256-GCM, PBKDF2
│   ├── secure_storage_service.dart # Keychain/Keystore
│   ├── database_service.dart       # Hive encrypted boxes
│   ├── biometric_service.dart      # local_auth wrapper
│   ├── logo_service.dart           # Dynamic logo fetching
│   ├── purchase_service.dart       # RevenueCat IAP
│   ├── pwned_password_service.dart # HIBP API
│   ├── notification_service.dart   # Local notifications
│   ├── settings_service.dart       # User preferences
│   ├── clipboard_service.dart      # Copy with auto-clear
│   ├── backup_service.dart         # Encrypted backup/restore
│   └── app_lifecycle_service.dart  # Background handling
├── theme/              # App theming (Neumorphic design)
│   └── app_colors.dart
├── widgets/            # Reusable components
│   ├── neumorphic/    # Custom Neumorphic design system
│   └── *.dart         # Other widgets
├── main.dart           # App entry point
└── router.dart         # GoRouter configuration
```

---

## 🔐 Security Architecture

### Encryption Flow

```
┌──────────────────┐
│  Master Password │
└────────┬─────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  PBKDF2-HMAC-SHA256                    │
│  • 100,000 iterations                  │
│  • Per-user random salt                │
│  • 256-bit output                      │
└────────┬───────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────┐
│  AES-256-GCM Encryption Key            │
└────────┬───────────────────────────────┘
         │
         ├─────────────────┐
         │                 │
         ▼                 ▼
┌─────────────────┐  ┌────────────────┐
│  Stored in      │  │  Used to       │
│  Keychain/      │  │  Encrypt       │
│  Keystore       │  │  Hive Boxes    │
└─────────────────┘  └────────────────┘
```

### Data Protection Layers

1. **Storage Level**: Hive AES encryption
2. **Transport Level**: HTTPS for logo fetching, HIBP API
3. **Memory Level**: Sensitive data cleared after use
4. **UI Level**: Screenshot protection, clipboard auto-clear

---

## 📊 State Management

### Riverpod Architecture

```dart
// Service Layer (Singleton)
final cryptoProvider = Provider<CryptoService>((ref) => CryptoService());

// State Notifier (Mutable State)
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(cryptoProvider),
    ref.read(secureStorageProvider),
  );
});

// Derived State (Computed)
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(premiumProvider).isPremium;
});
```

### State Flow

```
User Action → Provider → Service → Data Layer
     ↓           ↓         ↓           ↓
   Screen ← UI Update ← Notifier ← Response
```

---

## 🗄️ Data Models

### Core Models (Hive TypeAdapter)

```dart
@HiveType(typeId: 0)
class BankAccount {
  @HiveField(0) String id;
  @HiveField(1) String bankName;
  @HiveField(2) String accountNumber; // Encrypted
  @HiveField(3) String password;      // Encrypted
  @HiveField(4) DateTime createdAt;
  @HiveField(5) DateTime? updatedAt;
}
```

**TypeIds:**
- 0: BankAccount
- 1: Subscription
- 2: WebPassword

### Hive Boxes

- `bank_accounts` - Bank credentials
- `subscriptions` - Subscription data
- `web_passwords` - Web passwords

All boxes encrypted with AES-256 cipher from secure storage.

---

## 🛣️ Navigation

### GoRouter Structure

```
/
├── /splash              # Splash screen
├── /welcome             # First-time welcome
├── /onboarding          # Setup wizard
├── /biometric-optin     # Biometric setup
├── /login               # Login screen
├── /recovery            # Seed phrase recovery
├── /                    # Home (authenticated)
│   ├── /bank-form       # Bank account form
│   ├── /bank/:id        # Bank detail
│   ├── /subscription-form
│   ├── /subscription/:id
│   ├── /web-password-form
│   ├── /web-password/:id
│   ├── /security-audit  # HIBP check
│   ├── /paywall         # Premium paywall
│   └── /settings        # App settings
└── /autofill            # Autofill entry point
```

### Auth States

```
initial → firstTime → authenticated
              ↓            ↓
         unauthenticated ←┘
```

**Redirect Logic:**
- `firstTime` → `/welcome`
- `unauthenticated` → `/login`
- `authenticated` → `/` (home)

---

## 💳 Premium Features (RevenueCat)

### Freemium Model

| Feature | Free | Premium |
|---------|------|---------|
| Bank Accounts | 3 max | Unlimited |
| Subscriptions | 3 max | Unlimited |
| Web Passwords | 5 max | Unlimited |
| Security Audit | ❌ | ✅ |
| Travel Mode | ❌ | ✅ |
| Panic Mode | ❌ | ✅ |
| Password Expiry Notifications | ❌ | ✅ |
| Encrypted Backup/Restore | ❌ | ✅ |

### Purchase Flow

```
User taps Premium → PaywallScreen
                         ↓
                   Fetch Offerings (RevenueCat)
                         ↓
                  Display packages
                         ↓
           User selects & purchases
                         ↓
            EntitlementInfo updated
                         ↓
         premiumProvider refreshed
                         ↓
               UI reflects premium
```

---

## 🔄 Backup & Recovery

### Seed Phrase (BIP39)

- 12-word mnemonic generated on first setup
- Stored encrypted in secure storage
- Used for master password recovery

### Encrypted Backup

```
User Data → JSON serialize → AES-256-GCM encrypt
     ↓            ↓                ↓
  Export   →  .guarden file  →  Share/Save
```

**Backup Format:**
```json
{
  "version": "1.0",
  "timestamp": "2026-03-03T...",
  "encrypted_data": "base64...",
  "checksum": "sha256..."
}
```

### Recovery Flow

1. User provides seed phrase
2. Derive master key from seed
3. Decrypt recovery bundle
4. Set new master password
5. Re-encrypt vault with new key

---

## 🎨 Neumorphic Design System

### Custom Widgets

- `NeumorphicButton`
- `NeumorphicContainer`
- `NeumorphicTextField`
- `NeumorphicInput`
- `NeumorphicTypeahead`
- `NeumorphicBottomNav`

### Theme Extension

```dart
class AppColors extends ThemeExtension<AppColors> {
  final Color background;      // E0E5EC (light) / 1E1E24 (dark)
  final Color shadowLight;     // White shadow
  final Color shadowDark;      // Dark shadow
  final Color primaryAccent;   // EF8539 (orange)
  final List<BoxShadow> neumorphicShadows;
}
```

---

## 🧪 Testing Strategy

### Unit Tests

- **Services**: crypto, auth, database, backup
- **Providers**: auth state transitions
- **Models**: serialization, encryption

### Widget Tests

- **Forms**: validation, submission
- **Lists**: rendering, interactions
- **Navigation**: routing, redirects

### Integration Tests

- **Auth flow**: setup → login → logout
- **CRUD flow**: create → edit → delete
- **Premium flow**: paywall → purchase → access

---

## 🚀 Build & Deployment

### Development

```bash
flutter run \
  --dart-define=RC_GOOGLE_API_KEY=dev_key \
  --dart-define=RC_APPLE_API_KEY=dev_key
```

### Release

**Android:**
```bash
flutter build appbundle --release \
  --dart-define=RC_GOOGLE_API_KEY=prod_key
```

**iOS:**
```bash
flutter build ipa --release \
  --dart-define=RC_APPLE_API_KEY=prod_key
```

---

## 📚 Technology Stack

### Framework & Language
- **Flutter** 3.32.2
- **Dart** 3.8.1

### State Management
- **flutter_riverpod** 2.6.1 (state management)

### Database & Storage
- **hive_flutter** 1.1.0 (local database)
- **flutter_secure_storage** 10.0.0 (secrets)

### Security
- **cryptography** 2.9.0 (AES-256-GCM & PBKDF2)
- **local_auth** 2.3.0 (biometric)

### Observability
- **sentry_flutter** 9.14.0 (error tracking)

### Premium & Monetization
- **purchases_flutter** 9.12.3 (RevenueCat)

### UI/UX
- **cached_network_image** 3.4.1
- **flutter_typeahead** 5.2.0
- **flutter_staggered_animations** 1.1.1

### Services
- **http** 1.6.0 (API calls)
- **flutter_local_notifications** 20.1.0

---

## 🔮 Future Enhancements

- [ ] Cloud sync (optional, E2E encrypted)
- [ ] Biometric-only login option
- [ ] Password generator with strength meter
- [ ] Import from other password managers
- [ ] Browser extension
- [ ] Desktop apps (Windows, macOS, Linux)
- [ ] Two-factor authentication (TOTP)

---

## 📖 References

- [Flutter Architecture Best Practices](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options)
- [Riverpod Documentation](https://riverpod.dev/)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [BIP39 Specification](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki)

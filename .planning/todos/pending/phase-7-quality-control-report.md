---
title: "Phase 7 Quality Control Report"
area: resilience
priority: critical
created: 2026-03-03
updated: 2026-03-03
---

## Build and Test Gate Status
- [x] `flutter analyze` temiz (sadece 5 info, hata yok).
- [x] `flutter test` temiz (9 test geçti).

## Critical Findings (P0)

### 1) Compile blockers in `main.dart` ✅ FIXED
- [x] Undefined symbols and invalid Sentry callback signature.
- [x] Evidence:
  - `lib/main.dart:11` (`MobileAds` undefined) - FIXED
  - `lib/main.dart:23` (`beforeSend` callback type mismatch) - FIXED
  - `lib/main.dart:61-63` (localization delegates undefined) - FIXED
  - `lib/main.dart:72,82` (`AppColors` undefined) - FIXED
- [x] Impact: App can now pass analyze gate; release pipeline unblocked.

### 2) Global error handling crashes non-widget tests ✅ FIXED
- [x] `ErrorHandler.handleGlobalError` directly reads `scaffoldMessengerKey.currentState` without binding-safe guard.
- [x] Evidence:
  - `lib/widgets/error_handler.dart:36-41` - Null check eklendi
  - Trigger path: `lib/providers/auth_provider.dart:145` (recovery fail path)
- [x] Impact: provider unit tests now work correctly with widget binding guard.

### 3) Widget smoke test bootstrap is broken ✅ FIXED
- [x] `GuardenApp` is pumped without `TranslationProvider` wrapper.
- [x] Evidence:
  - `test/widget_test.dart:11` - TranslationProvider eklendi
- [x] Impact: widget smoke test now passes at startup.

## High Findings (P1)

### 4) FR3 telemetry integration incomplete/inconsistent ⚠️ PARTIAL
- [x] Telemetry exists (`telemetry_service.dart`) but phase target is only partially met.
- [x] Gaps:
  - [x] No Ghost Mode based analytics disable logic (currently dev-mode only check)
    - evidence: `lib/services/telemetry_service.dart:26,33`
  - [ ] No product event calls (onboarding/password added/premium/backup) in app flows
    - evidence: only internal method defs in `lib/services/telemetry_service.dart:33,46`
  - [ ] Firebase config files missing locally
    - `android/app/google-services.json: MISSING`
    - `ios/Runner/GoogleService-Info.plist: MISSING`
  - [ ] `.env.example` lacks `SENTRY_DSN` and `FIREBASE_*` templates
    - evidence: `.env.example` contains only `RC_*` keys
  - [ ] Android google-services plugin wiring not present in Gradle
    - no `google-services` references in `android/build.gradle.kts` and `android/app/build.gradle.kts`
- [ ] Impact: FR3 success criteria cannot be considered complete.

### 5) Raw technical error text still reaches UI in multiple screens ⚠️ PARTIAL
- [ ] User-facing messages still interpolate exception details (`$e`) in screens.
- [ ] Evidence:
  - `lib/screens/security/security_audit_screen.dart:66,75`
  - `lib/screens/settings/settings_screen.dart:354,396`
  - `lib/screens/bank_accounts/bank_account_form_screen.dart:181`
  - `lib/screens/subscriptions/subscription_form_screen.dart:199`
  - `lib/screens/web_passwords/web_password_form_screen.dart:180`
- [ ] Impact: Violates Phase 7 goal of friendly, actionable error UX.

## Medium Findings (P2)

### 6) Planning artifact consistency issue in Phase 7 docs
- [ ] `07-02-SUMMARY.md` and `07-03-SUMMARY.md` are missing under phase folder.
- [ ] There is a misplaced summary file in root phases folder: `.planning/phases/07-02-SUMMARY.md`.
- [ ] Impact: weak cross-agent traceability and execution history clarity.

## Recommended Fix Order
1. [x] Fix `main.dart` compile blockers (imports + Sentry callback signature).
2. [x] Make `ErrorHandler.handleGlobalError` binding-safe for non-widget contexts.
3. [x] Fix `test/widget_test.dart` boot wrapper to include translation provider.
4. [ ] Remove raw `$e` from user-visible snackbars, route through typed error UI.
5. [ ] Complete FR3 telemetry wiring (Ghost Mode, event mapping, config templates, Gradle/Firebase setup docs).
6. [ ] Clean up Phase 7 planning file locations and missing summaries.

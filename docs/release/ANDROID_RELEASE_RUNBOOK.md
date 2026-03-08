# Android Release Runbook

## Purpose

Use this runbook to produce the Play Store Android App Bundle for Guarden from a clean, auditable release path.

## Preconditions

- `android/key.properties` exists and contains:
  - `keyAlias`
  - `keyPassword`
  - `storeFile`
  - `storePassword`
- Android SDK cmdline-tools are installed
- Android SDK licenses are accepted
- Java 17 is available
- Flutter dependencies are installed with `flutter pub get`

## Current Android Release Facts

- Package ID: `com.pwm.guarden`
- AdMob App ID: `ca-app-pub-7514989682859982~9035581401`
- Billing permission is removed from the launch manifest
- Release signing now fails closed if signing secrets are missing
- Mobile ads can be disabled with `--dart-define=DISABLE_MOBILE_ADS=true`
- Telemetry is disabled by default and must be explicitly enabled with `--dart-define=ENABLE_TELEMETRY=true`

## Verification Before Build

Run these from repo root:

```bash
dart analyze lib test
flutter test
```

Both must pass before building a store artifact.

## Release Build Command

Standard release build:

```bash
flutter build appbundle --release
```

Optional production telemetry build:

```bash
flutter build appbundle --release --dart-define=ENABLE_TELEMETRY=true --dart-define=SENTRY_DSN=YOUR_SENTRY_DSN
```

Optional ads-disabled review build:

```bash
flutter build appbundle --release --dart-define=DISABLE_MOBILE_ADS=true
```

## Expected Failure Mode

If signing secrets are missing, the build must fail with:

`Release signing is not configured. Missing: android/key.properties, ...`

This is expected and safer than falling back to debug signing.

## Artifact Checks

After a successful build:

1. Confirm `.aab` exists in `build/app/outputs/bundle/release/`
2. Confirm the build was produced by a release task, not a debug fallback
3. Confirm no Google demo AdMob App ID remains in:
   - `android/app/src/main/AndroidManifest.xml`
   - `lib/services/ad_service.dart`
4. Confirm `dart analyze lib test` and `flutter test` were green in the same release session

## Play Console Checklist

Before uploading:

1. Verify package name is `com.pwm.guarden`
2. Verify Data safety answers match `docs/release/PRIVACY_DISCLOSURE_MATRIX.md`
3. Verify ad declarations match the shipped build
4. Verify content rating and app category
5. Verify store listing copy, privacy policy, and support URL

## Stop-Ship Conditions

Do not upload if any of these are true:

- `android/key.properties` is missing
- `flutter test` is red
- `dart analyze lib test` is red
- Manifest or ad service still contain demo/test launch config
- Data safety answers are incomplete or do not match the shipped SDK surface

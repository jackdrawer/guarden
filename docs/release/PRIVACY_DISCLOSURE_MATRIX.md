# Privacy Disclosure Matrix

## Scope

This matrix maps the shipped Guarden codebase to Play Console Data Safety and App Store privacy label review.

## Build Notes

- Telemetry is disabled by default unless the build explicitly sets `ENABLE_TELEMETRY=true`
- Mobile ads are enabled unless the build explicitly sets `DISABLE_MOBILE_ADS=true`
- Store answers must match the actual build variant being uploaded

| Surface | SDK / Feature | Trigger | Data / Behavior | Disclosure Notes | Launch Status |
|---|---|---|---|---|---|
| Ads | `google_mobile_ads` | Automatic when ad widgets are shown | Ad requests, device/app ad metadata | Must disclose ads; verify exact data categories in console forms against shipped build | Enabled in release by default |
| Crash reporting | `sentry_flutter` | Only when `ENABLE_TELEMETRY=true` and DSN is set | Crash diagnostics, scrubbed exception context | If telemetry disabled in release build, do not claim crash collection for that artifact | Disabled by default |
| Analytics | `firebase_analytics` | Only when `ENABLE_TELEMETRY=true` and Firebase is configured | Event names and scrubbed non-PII params | Console answers must follow the actual telemetry flag used for the uploaded binary | Disabled by default |
| Google account auth | `google_sign_in` | User taps Google Drive backup/restore flow | Google account sign-in and auth token exchange | Must explain Google account use for personal Drive backup | Enabled on user action |
| Cloud backup | Google Drive `appDataFolder` via `googleapis` | User backup / auto-backup | Encrypted backup payload stored in user's Drive app data area | Backup contents are encrypted before upload; disclose cloud storage / account linkage appropriately | Enabled |
| Biometrics | `local_auth` | User enables biometric unlock or confirm flows | Biometric gate only; no biometric templates stored by app | Must disclose Face ID / Touch ID usage purpose in app metadata | Enabled |
| Notifications | `flutter_local_notifications` | User enables reminders | Local reminders on device | No remote push SDK present in repo | Enabled on user action |
| Autofill | `flutter_autofill_service` | User enables autofill | Credential fill into other apps/web forms | Review platform autofill declarations and user-facing explanation | Enabled on user action |
| Local encrypted vault | Hive + secure storage | Core app behavior | Sensitive vault data stored locally and encrypted | Primary product behavior; ensure privacy policy explains on-device encrypted storage | Enabled |
| File export/share | `file_picker`, `file_saver`, `share_plus` | User exports or imports backup | User-selected backup files | Backup payload remains encrypted; disclose file export/import behavior if asked | Enabled on user action |

## Console Decision Rules

Use these rules while completing console forms:

1. If telemetry stays disabled for the submitted build, answer telemetry questions for the shipped binary, not for dormant code paths.
2. If ads stay enabled, disclose ads and related data collection appropriately.
3. Google Drive backup means account-linked cloud storage behavior exists and should not be omitted.
4. Biometrics are used for device-side authentication convenience, not identity verification beyond device APIs.

## Manual Review Items

- Confirm privacy policy text matches encrypted local storage + Google Drive backup behavior
- Confirm Play Console Data Safety answers reflect the exact release build flags
- Confirm App Store privacy labels reflect whether telemetry is enabled in the submitted iOS build

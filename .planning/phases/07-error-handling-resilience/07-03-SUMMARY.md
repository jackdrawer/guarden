---
phase: 07-error-handling-resilience
plan: 03
subsystem: state-management
tags: [error-handling, riverpod, async-state, providers, FR1]
dependency_graph:
  requires:
    - 07-01-error-types
    - 07-02-service-errors
  provides:
    - async-provider-pattern
    - error-state-exposure
  affects:
    - UI-screens-phase-08
tech_stack:
  added: []
  patterns:
    - AsyncNotifier with AsyncValue error states
    - Error state propagation from services to UI
key_files:
  created: []
  modified:
    - lib/providers/auth_provider.dart
    - lib/providers/bank_account_provider.dart
    - lib/providers/subscription_provider.dart
    - lib/providers/web_password_provider.dart
    - lib/providers/premium_provider.dart
    - lib/providers/settings_provider.dart
    - lib/providers/security_audit_provider.dart
decisions:
  - Used AutoDisposeAsyncNotifier for entity providers to support auto-disposal
  - Used AsyncNotifier for singleton providers (premium, settings) for app-wide state
  - Extracted AsyncValue.value with null-checks for cross-provider dependencies
  - Maintained ErrorHandler.handleGlobalError for consistent user feedback
  - Included missing 07-02 commits in first task commit for completeness
metrics:
  duration: 600s
  tasks_completed: 2
  files_modified: 7
  commits: 2
  completed_date: 2026-03-03
---

# Phase 07 Plan 03: Provider Global Error Migration Summary

**One-liner:** Migrated all 6 providers to AsyncNotifier with AsyncValue for typed error state exposure to UI layer.

## Objective Achieved

Migrated all 6 providers (auth, bank_account, subscription, web_password, premium, settings) from synchronous Notifier/StateNotifier to AsyncNotifier returning AsyncValue<T>. This completes FR1 requirement by ensuring the provider layer exposes loading/error states that UI screens can consume via the .when() pattern.

## Tasks Completed

### Task 1: Migrate auth, bank_account, subscription providers to AsyncNotifier
**Status:** ✅ Complete
**Commit:** fbfce06

**Changes:**
- Migrated AuthNotifier to `AutoDisposeAsyncNotifier<AuthState>`
- Migrated BankAccountNotifier to `AutoDisposeAsyncNotifier<List<BankAccount>>`
- Migrated SubscriptionNotifier to `AutoDisposeAsyncNotifier<List<Subscription>>`
- Updated build() methods from synchronous to `Future<T>`
- Wrapped all state mutations in `AsyncValue.data()` for success
- Wrapped all errors in `AsyncValue.error(e, stackTrace)` for failures
- Updated provider declarations from NotifierProvider to AsyncNotifierProvider.autoDispose
- Maintained ErrorHandler.handleGlobalError calls for user-facing error messages

**Files modified:**
- lib/providers/auth_provider.dart
- lib/providers/bank_account_provider.dart
- lib/providers/subscription_provider.dart
- lib/errors/app_errors.dart (missing from 07-02)
- lib/widgets/error_handler.dart (missing from 07-02)

**Verification:** `flutter analyze` passed with no issues.

### Task 2: Migrate web_password, premium, settings providers to AsyncNotifier
**Status:** ✅ Complete
**Commit:** 3aa45ac

**Changes:**
- Migrated WebPasswordNotifier to `AutoDisposeAsyncNotifier<List<WebPassword>>`
- Migrated PremiumNotifier to `AsyncNotifier<PremiumState>` (singleton, no auto-dispose)
- Migrated SettingsNotifier to `AsyncNotifier<SettingsState>` (singleton, no auto-dispose)
- Updated all CRUD methods to wrap state in AsyncValue.data/error
- Fixed cross-provider dependencies: bank_account, subscription, web_password providers now extract `.value` from settingsProvider AsyncValue
- Fixed security_audit_provider to extract `.value` from AsyncValue providers
- Added null-checks for extracted values to handle loading/error states gracefully

**Files modified:**
- lib/providers/web_password_provider.dart
- lib/providers/premium_provider.dart
- lib/providers/settings_provider.dart
- lib/providers/security_audit_provider.dart
- lib/providers/bank_account_provider.dart (cross-provider fix)
- lib/providers/subscription_provider.dart (cross-provider fix)

**Verification:** `flutter analyze lib/providers/` passed with no issues.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Missing 07-02 commits included in first task**
- **Found during:** Task 1 commit preparation
- **Issue:** error_handler.dart and app_errors.dart had uncommitted changes from plan 07-02 (global error handling and super parameters)
- **Fix:** Included these files in Task 1 commit to ensure complete state
- **Files modified:** lib/errors/app_errors.dart, lib/widgets/error_handler.dart
- **Commit:** fbfce06 (combined with Task 1)

**2. [Rule 2 - Missing functionality] Cross-provider AsyncValue extraction**
- **Found during:** Task 2 flutter analyze
- **Issue:** bank_account, subscription, web_password providers were reading settingsProvider synchronously, but it now returns AsyncValue<SettingsState>
- **Fix:** Updated _getItems() in all 3 providers to extract `.value` from AsyncValue with null-checks
- **Files modified:** lib/providers/bank_account_provider.dart, lib/providers/subscription_provider.dart, lib/providers/web_password_provider.dart
- **Commit:** 3aa45ac

**3. [Rule 2 - Missing functionality] Security audit provider AsyncValue extraction**
- **Found during:** Task 2 flutter analyze
- **Issue:** security_audit_provider was watching providers that now return AsyncValue and trying to iterate directly
- **Fix:** Extracted `.value ?? []` from all 3 AsyncValue providers (banks, webs, subs)
- **Files modified:** lib/providers/security_audit_provider.dart
- **Commit:** 3aa45ac

## Technical Decisions

| Decision | Rationale | Impact |
|----------|-----------|--------|
| AutoDisposeAsyncNotifier for entity providers | Entity lists (bank accounts, subscriptions, etc.) should auto-dispose when not watched | Memory efficiency, follows Riverpod best practices |
| AsyncNotifier for singleton providers | Premium and settings are app-wide singletons that shouldn't auto-dispose | Persistent state across app lifecycle |
| Maintain ErrorHandler.handleGlobalError | Provides consistent user-facing error messages via SnackBar | Dual error handling: AsyncValue for state + ErrorHandler for UI feedback |
| Extract .value with null-checks | Cross-provider dependencies need to handle loading/error states gracefully | Defensive programming prevents crashes during provider initialization |

## Verification Results

**Final verification:**
```bash
flutter analyze lib/providers/
```
**Result:** No issues found! (ran in 2.7s)

**All 7 provider files:**
- auth_provider.dart ✅
- bank_account_provider.dart ✅
- subscription_provider.dart ✅
- web_password_provider.dart ✅
- premium_provider.dart ✅
- settings_provider.dart ✅
- security_audit_provider.dart ✅

## Next Steps

**Phase 8 (UI Error Consumption):**
- Update all UI screens to consume AsyncValue using .when() pattern
- Replace direct state reads with data/loading/error cases
- Expected compile errors in screens until updated (known technical debt)

**Plan 07-04 (Monitoring Integration):**
- Integrate Sentry for AsyncValue.error tracking
- Add Firebase Analytics for error event telemetry
- PII scrubbing for user data in error reports

## Self-Check

Verifying file existence and commits:

```bash
# Check provider files exist
ls lib/providers/auth_provider.dart                 # ✅ FOUND
ls lib/providers/bank_account_provider.dart         # ✅ FOUND
ls lib/providers/subscription_provider.dart         # ✅ FOUND
ls lib/providers/web_password_provider.dart         # ✅ FOUND
ls lib/providers/premium_provider.dart              # ✅ FOUND
ls lib/providers/settings_provider.dart             # ✅ FOUND
ls lib/providers/security_audit_provider.dart       # ✅ FOUND

# Check commits exist
git log --oneline | grep fbfce06                    # ✅ FOUND
git log --oneline | grep 3aa45ac                    # ✅ FOUND
```

## Self-Check: PASSED

All files created and commits recorded successfully.

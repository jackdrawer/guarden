---
phase: 07-error-handling-resilience
plan: 02
subsystem: error-handling
tags: [dart, flutter, error-handling, retry-logic, typed-errors, resilience, exponential-backoff]

# Dependency graph
requires:
  - phase: 07-01
    provides: Typed error hierarchy (AppError, CryptoError, DatabaseError, NetworkError, StorageError, BiometricError, ValidationError)
provides:
  - All 12 services with comprehensive error handling using typed AppError exceptions
  - Network retry logic with exponential backoff (3 attempts: 1s, 2s, 4s delays)
  - Graceful degradation for non-critical services (notifications, clipboard, lifecycle)
  - Critical services throw typed errors for proper UI feedback
affects: [07-03-provider-error-handling, 07-04-monitoring, 08-testing]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - Service-level error handling with typed exceptions
    - Network retry with exponential backoff pattern
    - Graceful degradation for non-critical services
    - Error mapping strategy (PlatformException → typed AppError)

key-files:
  created: []
  modified:
    - lib/services/crypto_service.dart
    - lib/services/database_service.dart
    - lib/services/secure_storage_service.dart
    - lib/services/biometric_service.dart
    - lib/services/pwned_password_service.dart
    - lib/services/purchase_service.dart
    - lib/services/logo_service.dart
    - lib/services/backup_service.dart
    - lib/services/notification_service.dart
    - lib/services/clipboard_service.dart
    - lib/services/settings_service.dart
    - lib/services/app_lifecycle_service.dart

key-decisions:
  - "Network retry uses exponential backoff: 1s, 2s, 4s delays for 3 total attempts"
  - "Non-critical services (notifications, clipboard, lifecycle) log errors but don't throw"
  - "Critical services (crypto, database, storage, biometric) throw typed errors for UI feedback"
  - "Logo service returns fallback icon on network errors (graceful degradation)"
  - "Settings service returns defaults on read failures, throws on save failures"

patterns-established:
  - "Service error handling pattern: wrap operations in try-catch, convert to typed AppError with user-friendly messages"
  - "Network retry pattern: _retryWithBackoff helper with configurable attempts and exponential delays"
  - "Graceful degradation pattern: non-critical services catch and log errors without throwing"
  - "Error rethrow pattern: if exception is already typed AppError, rethrow; otherwise wrap in appropriate error type"

requirements-completed: [FR1]

# Metrics
duration: 84s
completed: 2026-03-03
---

# Phase 7 Plan 2: Service Error Handling Summary

**All 12 services instrumented with typed error handling, network retry with exponential backoff, and graceful degradation for non-critical operations**

## Performance

- **Duration:** 1min 24s
- **Started:** 2026-03-03T18:13:22Z
- **Completed:** 2026-03-03T18:14:46Z
- **Tasks:** 3
- **Files modified:** 12

## Accomplishments

- Added comprehensive error handling to all 12 services with typed AppError exceptions
- Implemented exponential backoff retry (1s, 2s, 4s delays) for network services
- Established graceful degradation pattern for non-critical services (notifications, clipboard, lifecycle)
- Migrated secure_storage_service to use centralized StorageError from app_errors.dart
- All services now provide clear user-facing error messages with retry/action guidance

## Task Commits

Each task was committed atomically:

1. **Task 1: Add error handling to critical services** - `4534f35` (feat)
   - crypto_service: CryptoError on encrypt/decrypt/deriveKey failures
   - database_service: DatabaseError on Hive operations and uninitialized access
   - secure_storage_service: migrated to centralized StorageError, handle PlatformException
   - biometric_service: BiometricError on auth failures

2. **Task 2: Add network retry logic and error handling** - `69a4aa3` (feat)
   - pwned_password_service: exponential backoff retry with NetworkError
   - purchase_service: NetworkError on RevenueCat failures
   - logo_service: graceful degradation with fallback icon

3. **Task 3: Add error handling to remaining services** - `b3e6ba5` (feat)
   - backup_service: DatabaseError on export/restore failures
   - notification_service: log PlatformException, don't throw (non-critical)
   - clipboard_service: log PlatformException, don't throw (non-critical)
   - settings_service: DatabaseError on save, defaults on read
   - app_lifecycle_service: log errors (observational)

## Files Created/Modified

- `lib/services/crypto_service.dart` - CryptoError handling for encryption/decryption operations
- `lib/services/database_service.dart` - DatabaseError for Hive operations, uninitialized state checks
- `lib/services/secure_storage_service.dart` - Migrated to centralized StorageError, PlatformException handling
- `lib/services/biometric_service.dart` - BiometricError for authentication failures
- `lib/services/pwned_password_service.dart` - Exponential backoff retry with NetworkError
- `lib/services/purchase_service.dart` - NetworkError for RevenueCat operations
- `lib/services/logo_service.dart` - Graceful degradation with fallback icon
- `lib/services/backup_service.dart` - DatabaseError for backup export/restore failures
- `lib/services/notification_service.dart` - Graceful degradation (log, don't throw)
- `lib/services/clipboard_service.dart` - Graceful degradation (log, don't throw)
- `lib/services/settings_service.dart` - DatabaseError on save, defaults on read failures
- `lib/services/app_lifecycle_service.dart` - Log errors without throwing

## Decisions Made

1. **Network retry strategy**: Implemented exponential backoff with 3 attempts (delays: 1s, 2s, 4s) for pwned_password_service. This balances user experience (quick response on transient failures) with API rate limiting concerns.

2. **Graceful degradation for non-critical services**: Notifications, clipboard, and lifecycle services log errors but don't throw. Rationale: these are convenience features that shouldn't block core app functionality.

3. **Error rethrow pattern**: Services check if caught exception is already a typed AppError and rethrow; otherwise wrap in appropriate error type. This prevents double-wrapping errors.

4. **Settings service hybrid approach**: Returns defaults on read failures (graceful), throws DatabaseError on save failures (critical). Rationale: failed reads shouldn't block app startup, but failed saves must notify user.

5. **Secure storage migration**: Migrated secure_storage_service from inline StorageError definition to centralized app_errors.dart. All 12 services now use the same error types.

## Deviations from Plan

None - plan executed exactly as written. All services were updated according to their criticality (critical services throw, non-critical services degrade gracefully).

## Issues Encountered

None - all services passed flutter analyze with no issues.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- All 12 services have comprehensive error handling
- Services ready for provider-level error interception (Plan 07-03)
- Error types ready for monitoring integration (Plan 07-04)
- Clear user messages ready for localization (Phase 09)
- No blockers for next phase

---
*Phase: 07-error-handling-resilience*
*Completed: 2026-03-03*

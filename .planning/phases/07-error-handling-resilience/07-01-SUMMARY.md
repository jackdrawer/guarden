---
phase: 07-error-handling-resilience
plan: 01
subsystem: error-handling
tags: [foundation, error-handling, ui-components, neumorphic]
dependency_graph:
  requires: []
  provides: [error-types, error-ui, error-utilities]
  affects: [all-future-services, all-future-screens]
tech_stack:
  added: []
  patterns: [typed-errors, user-friendly-messaging, neumorphic-ui]
key_files:
  created:
    - lib/errors/app_errors.dart
    - lib/widgets/error_snackbar.dart
    - lib/widgets/error_handler.dart
  modified: []
decisions:
  - Use super parameters for cleaner error constructors (Dart 2.17+ feature)
  - Auto-dismiss timing: 4s for info, 6s for errors with actions
  - Map common exception types automatically to typed AppError subclasses
metrics:
  duration: 156s
  tasks_completed: 3
  files_created: 3
  commits: 3
  completed_at: 2026-03-03T07:05:33Z
---

# Phase 07 Plan 01: Error Type System and UI Components Summary

**Comprehensive error handling foundation with typed errors and Neumorphic-styled user feedback**

## Overview

Established the error handling foundation for Guarden Password Manager by creating a typed error hierarchy, Neumorphic-styled error display components, and centralized error handling utilities. All error types provide both technical messages (for logging) and user-friendly messages (for display), with retry capabilities where appropriate.

## Tasks Completed

### Task 1: Create typed error hierarchy with user messages
**Status:** ✅ Complete
**Commit:** 14fc8ba
**Files:** lib/errors/app_errors.dart

Created comprehensive error type system with:
- AppError base class implementing Exception
- 6 concrete error types: StorageError, CryptoError, NetworkError, DatabaseError, BiometricError, ValidationError
- Each error contains: technical message, user-friendly message, canRetry flag, optional action string
- Used super parameters for cleaner, more modern Dart code

**Key exports:** AppError, StorageError, CryptoError, NetworkError, DatabaseError, BiometricError, ValidationError

### Task 2: Create Neumorphic error SnackBar widget
**Status:** ✅ Complete
**Commit:** 2aad083
**Files:** lib/widgets/error_snackbar.dart

Implemented Neumorphic-styled error display:
- ErrorSnackBar widget with soft shadows and depth matching app design language
- Displays error.userMessage (not technical details)
- Shows action button when error.action is present
- Auto-dismiss: 4s for info, 6s for errors with actions
- Includes dismiss button for manual dismissal
- Helper function showErrorSnackBar for easy integration

**Key exports:** ErrorSnackBar, showErrorSnackBar

### Task 3: Create error handling utilities
**Status:** ✅ Complete
**Commit:** d72a18d
**Files:** lib/widgets/error_handler.dart

Built centralized error handling utilities:
- ErrorHandler static utility class
- handleError: converts exceptions to AppError and displays via SnackBar
- withErrorHandling: wraps async operations in try-catch with automatic error display
- convertToAppError: maps common exception types to appropriate AppError subclasses
  - SocketException → NetworkError
  - FormatException → ValidationError
  - HiveError → DatabaseError
  - PlatformException → BiometricError or StorageError (based on code)
  - Default: Generic AppError

**Key exports:** ErrorHandler

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Code Quality] Applied super parameters to error constructors**
- **Found during:** Task 1 verification
- **Issue:** Flutter analyzer suggested using super parameters for cleaner code
- **Fix:** Updated all 6 error class constructors to use `super.message` instead of passing message explicitly
- **Files modified:** lib/errors/app_errors.dart
- **Commit:** 14fc8ba (included in initial commit)
- **Rationale:** Modern Dart feature (2.17+) that reduces boilerplate and improves code readability. No behavior change.

## Verification

### Automated Tests
```bash
flutter analyze lib/errors/ lib/widgets/error_handler.dart lib/widgets/error_snackbar.dart
Result: No issues found!
```

### Manual Inspection
- [x] All 6 error types extend AppError
- [x] ErrorSnackBar uses Neumorphic styling
- [x] showErrorSnackBar helper accepts AppError parameter
- [x] ErrorHandler utilities handle common exception types

## Success Criteria

- [x] Error type system established with 6 concrete error classes
- [x] Each error contains technical message, user-friendly message, retry flag, and optional action
- [x] Neumorphic-styled SnackBar widget created matching app's design language
- [x] Centralized error handling utilities ready for integration
- [x] All files pass flutter analyze with no errors
- [x] Foundation ready for service/provider error handling implementation (Plan 02)

## Impact

**Immediate:**
- Typed error system enables catching specific error types and applying appropriate recovery strategies
- Centralized utilities ensure consistent error handling across all screens
- User-friendly error messages improve UX by avoiding technical jargon and stack traces

**Future:**
- Ready for integration in all services and providers (Plan 02)
- Easy to add logging, analytics, or monitoring hooks to ErrorHandler
- Neumorphic error design maintains app's visual consistency

## Next Steps

1. Integrate error handling into existing services (secure_storage, password_repository, etc.)
2. Add error handling to providers (PasswordProvider, AuthProvider, etc.)
3. Update screens to use ErrorHandler.withErrorHandling for all async operations
4. Test error flows with simulated failures
5. Consider adding error analytics tracking to ErrorHandler

## Technical Debt

None identified. Code is clean, well-structured, and follows Flutter/Dart best practices.

## Notes

- All files passed static analysis with zero issues
- Super parameters feature used for modern Dart code style
- Error system is extensible - new error types can be added easily by extending AppError
- ValidationError accepts optional userMessage parameter for custom validation messages

## Self-Check: PASSED

Verified all claims:
- ✅ lib/errors/app_errors.dart exists
- ✅ lib/widgets/error_snackbar.dart exists
- ✅ lib/widgets/error_handler.dart exists
- ✅ Commit 14fc8ba exists
- ✅ Commit 2aad083 exists
- ✅ Commit d72a18d exists

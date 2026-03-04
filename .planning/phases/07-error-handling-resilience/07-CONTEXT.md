# Phase 7: Error Handling & Resilience - Context

**Gathered:** 2026-03-03
**Status:** Ready for planning

<domain>
## Phase Boundary

Comprehensive error handling across all 12 services and 6 providers. Production monitoring via Sentry (crash reporting) and Firebase Analytics (user behavior tracking). Users see clear, actionable error messages. Network failures retry automatically. Storage errors prompt password re-entry. No raw stack traces exposed.

</domain>

<decisions>
## Implementation Decisions

### Error Message Presentation
- **Display method**: Toast/SnackBar notifications (non-blocking, bottom of screen)
- **Visual style**: Neumorphic styled to match app's design system (subtle shadows and depth)
- **Message tone**: Friendly & helpful (e.g., "Couldn't save your password. Check your internet and try again.")
- **Action buttons**: Yes, contextual actions ("Retry" for network errors, "Review" for validation, "Dismiss" for info)
- **Auto-dismiss**: 4 seconds for info, 6 seconds for errors (unless action required)

### Recovery Mechanisms
- **Network failures**: Auto-retry with exponential backoff (3 attempts: 1s, 2s, 4s delay). Show "Retrying... (attempt X of 3)" to user.
- **Storage errors**: Prompt master password re-entry when keychain/keystore fails. Re-derive encryption key from password.
- **Database/crypto errors**: Graceful degradation - allow read-only mode. User can view data but not save changes until error resolved.
- **Progress visibility**: Always show retry attempts and recovery status. User knows what's happening.

### Monitoring and Analytics Setup
- **Sentry environment**: Debug builds → 'development', Release builds → 'production'. Clear separation for testing vs production crashes.
- **PII scrubbing**: Aggressive filtering. Remove ALL user data from crash reports: passwords, seed phrases, encryption keys, master password, account numbers, usernames. Only send stack traces and app state.
- **Firebase Analytics events**: Track only critical milestones:
  - `onboarding_complete` - User finishes first-time setup
  - `password_added` - User creates bank/subscription/web password entry
  - `premium_purchased` - RevenueCat purchase successful
  - `backup_created` - User exports encrypted backup
  - `app_open` - App launched
  - `screen_view` - Screen navigation (automatic)
- **Ghost Mode integration**: When Ghost Mode (premium privacy feature) is active, disable ALL Firebase Analytics. Crash reports (Sentry) still sent (different system).
- **Performance monitoring**: Track encryption/decryption operation times. Log if >500ms to identify slowdowns.
- **Alert thresholds**: Conservative - alert dev team if >10 crashes/hour OR >5% of active users affected.
- **Dashboard access**: Development team only. Engineers see Sentry and Firebase dashboards.
- **Cost control**: Use Sentry and Firebase free tiers. Monitor limits, adjust if needed at scale.

### Error Type System
- **Custom error classes**: Yes, typed error hierarchy:
  - `StorageError` - Keychain/Keystore failures
  - `CryptoError` - Encryption/decryption failures
  - `NetworkError` - API call failures (RevenueCat, Pwned API)
  - `DatabaseError` - Hive operations failures
  - `BiometricError` - Face ID/Touch ID failures
  - `ValidationError` - User input validation failures
- **Error object structure**: Each error includes:
  - `message` - Technical description for logging
  - `userMessage` - Friendly message for SnackBar ("Please re-enter master password")
  - `canRetry` - Boolean flag indicating if retry is possible
  - `action` - Optional recovery action (e.g., "re-enter password", "retry")
- **Provider error handling**: Migrate all providers from synchronous `Notifier<T>` to `AsyncNotifier<T>` returning `AsyncValue<T>`. UI uses `.when(data:, error:, loading:)` pattern for error states.
- **Logging strategy**: Log only critical errors to console (development) and Sentry (production). Don't log validation failures or expected errors. Keep noise low.

### Claude's Discretion
- Exact SnackBar animation timing and transitions
- Sentry release tagging strategy
- Error code numbering scheme
- Stack trace formatting for logs
- Exact retry backoff curve (can adjust 1s/2s/4s if needed)

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- **Riverpod providers** (6 total): auth, bank_account, subscription, web_password, settings, premium
  - Currently use `AutoDisposeNotifier<T>` (synchronous)
  - Need migration to `AsyncNotifier<AsyncValue<T>>` for error states
- **Services** (7 total): crypto, database, secure_storage, backup, purchase, biometric, pwned_password
  - Some have try-catch (backup_service, purchase_service, secure_storage_service)
  - Most have NO error handling (crypto_service, database_service)
- **Existing try-catch patterns**: 17 files have try-catch, mostly in UI screens
  - Pattern: Generic `catch (_)` with no error message or recovery
  - Example: `auth_provider.dart` catches all errors silently

### Established Patterns
- **State management**: Riverpod with providers - need to add `AsyncValue` error boundary pattern
- **No custom exceptions**: Code uses generic `Exception` and `Error` classes
- **No monitoring**: Zero Sentry or Firebase Analytics setup exists
- **No error UI components**: No reusable error SnackBar widget exists yet

### Integration Points
- **main.dart**: Add Sentry initialization before `runApp()`
- **All providers**: Wrap state mutations in try-catch, return `AsyncValue.error()` on failure
- **All services**: Add try-catch blocks, throw custom error types
- **UI screens**: Replace hardcoded error handling with centralized error display widget
- **RevenueCat callbacks**: Add error handling to purchase flows
- **Pwned API calls**: Add network error handling with retry logic

</code_context>

<specifics>
## Specific Ideas

- "Error messages should feel like the app is helping you, not blaming you" - friendly tone is key
- Neumorphic SnackBars should match the app's design language (subtle shadows, soft colors)
- Success criteria explicitly requires: "User sees clear, actionable error messages when operations fail (never raw stack traces)"
- Success criteria requires: "Development team receives crash reports in Sentry dashboard within minutes of occurrence"
- Success criteria requires: "Network failures show retry options and user can recover without restarting app"
- Success criteria requires: "Storage errors prompt for master password re-entry and user can continue working"
- Success criteria requires: "Firebase Analytics tracks key user behaviors without exposing PII"
- Requirements document (FR1) emphasizes: "Crypto errors are logged securely without exposing sensitive data"
- Requirements document (FR3) emphasizes: "PII data is scrubbed from all crash reports and analytics"

</specifics>

<deferred>
## Deferred Ideas

None - discussion stayed within phase scope. Error handling and monitoring for v1.1 production hardening.

</deferred>

---

*Phase: 07-error-handling-resilience*
*Context gathered: 2026-03-03*

# UI AsyncValue Migration - DEFERRED TO PHASE 8

**Phase:** 07-error-handling-resilience
**Status:** Deferred to Phase 8 (UI/UX updates)
**Date:** 2026-03-03

## What Was Deferred

After Plan 07-03 migrates all 6 providers to AsyncNotifier<T> returning AsyncValue<T>, UI screens will need updates to consume the new error/loading states.

## Why Deferred

1. **Phase boundary discipline:** Phase 7 focuses on error handling infrastructure (types, services, providers, monitoring). UI screen updates belong in Phase 8 (UI/UX).

2. **Scope control:** Plan 07-03 already touches 6 provider files. Adding 20+ UI screen updates would create a massive plan (>80% context).

3. **Compile errors are acceptable:** Provider files will compile correctly. UI screens will show compile errors ("The getter 'X' isn't defined for the type 'AsyncValue<T>'") but these are non-blocking for completing Phase 7.

4. **Clear handoff:** Phase 8 will update all screens to use `.when(data:, error:, loading:)` pattern consistently.

## What Needs To Happen (Phase 8)

**Files requiring updates (estimated 15-20 screens):**
- lib/screens/auth/login_screen.dart
- lib/screens/auth/setup_screen.dart
- lib/screens/bank_accounts/bank_account_list_screen.dart
- lib/screens/bank_accounts/bank_account_form_screen.dart
- lib/screens/subscriptions/subscription_list_screen.dart
- lib/screens/subscriptions/subscription_form_screen.dart
- lib/screens/web_passwords/web_password_list_screen.dart
- lib/screens/web_passwords/web_password_form_screen.dart
- lib/screens/settings/settings_screen.dart
- lib/screens/premium/premium_screen.dart
- ...and others

**Pattern to apply:**

FROM (current synchronous consumption):
```dart
final bankAccounts = ref.watch(bankAccountProvider);
return ListView.builder(
  itemCount: bankAccounts.length,
  itemBuilder: (context, index) => BankAccountTile(bankAccounts[index]),
);
```

TO (AsyncValue consumption):
```dart
final bankAccountsAsync = ref.watch(bankAccountProvider);
return bankAccountsAsync.when(
  data: (bankAccounts) => ListView.builder(
    itemCount: bankAccounts.length,
    itemBuilder: (context, index) => BankAccountTile(bankAccounts[index]),
  ),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorHandler.handleError(context, error),
);
```

## Verification That Deferral Is Safe

- [ ] Provider files (Plan 07-03) compile without errors
- [ ] Services (Plan 07-02) compile without errors
- [ ] Error types (Plan 07-01) compile without errors
- [ ] Monitoring (Plan 07-04) compiles without errors
- [ ] Only UI screen files show compile errors (expected)
- [ ] Compile errors are all AsyncValue-related (not logic errors)

## Phase 8 Task

Phase 8 will include a dedicated plan:
- **Plan 08-XX: Migrate UI screens to AsyncValue consumption**
- Type: execute
- Wave: depends on other Phase 8 plans
- Files: 15-20 screen files
- Tasks: 2-3 tasks (grouped by feature area)
- Estimated context: 40-50%

## Note to Future Planners

When creating Phase 8 plans, prioritize UI AsyncValue migration early in the phase. The longer screens remain broken, the harder it is to test other UI changes.

---

*Deferred: 2026-03-03*
*Reason: Phase boundary discipline, scope control*
*Resolution: Phase 8*

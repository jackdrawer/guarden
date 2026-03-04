---
phase: 10-optimization
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/router.dart
  - lib/providers/bank_account_provider.dart
  - lib/providers/subscription_provider.dart
  - lib/providers/web_password_provider.dart
autonomous: true
requirements: ["NFR1", "NFR2", "NFR3"]
user_setup: []

must_haves:
  truths:
    - "GoRouter instance is stable across auth state changes"
    - "Legacy text repair runs only once per app version"
    - "Entity providers rebuild only when relevant settings change"
    - "No jank during login/logout transitions"
  artifacts:
    - path: "lib/router.dart"
      provides: "Stable GoRouter with refreshListenable"
    - path: "lib/providers/bank_account_provider.dart"
      provides: "Migration-flag protected legacy repair"
    - path: "lib/providers/subscription_provider.dart"
      provides: "Migration-flag protected legacy repair"
    - path: "lib/providers/web_password_provider.dart"
      provides: "Granular settings watching with select"
  key_links:
    - from: "routerProvider"
      to: "authProvider"
      via: "refreshListenable stream"
    - from: "entityProviders"
      to: "settingsProvider"
      via: "selectAsync for specific fields"
---

<objective>
Fix three critical performance issues causing unnecessary widget rebuilds and jank during auth transitions:
1. GoRouter recreation on every auth state change
2. Legacy text repair running repeatedly on app start
3. SettingsProvider watch causing cascade rebuilds in entity providers

Purpose: Eliminate UI jank, reduce unnecessary rebuilds, and improve app responsiveness.
Output: Stable router instance, migration-protected repairs, and granular settings watching.
</objective>

<execution_context>
@C:/Users/turga/.claude/get-shit-done/workflows/execute-plan.md
@C:/Users/turga/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/ROADMAP.md
@.planning/STATE.md
@.planning/REQUIREMENTS.md

<interfaces>
<!-- Key existing code patterns from codebase -->

From lib/router.dart:
```dart
// Current problematic pattern - router recreated on every auth change
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider); // This causes recreation!
  // ... router config
});
```

From lib/providers/bank_account_provider.dart:
```dart
// Current problematic pattern - full settings watch
final bankAccountProvider = AsyncNotifierProvider<BankAccountNotifier, List<BankAccount>>(() {
  return BankAccountNotifier();
});

// _repairLegacyText runs on every initialization without migration flag
```

From lib/providers/settings_provider.dart:
```dart
// Settings that entity providers need to watch selectively
class UserSettings {
  final String? defaultPasswordLength;
  final bool? autoFillEnabled;
  final String? defaultCardType;
  // ... other settings
}
```
</interfaces>
</context>

---

## Task 1: Fix GoRouter Recreation

<name>
Stabilize GoRouter with refreshListenable
</name>

<files>
- lib/router.dart
</files>

<action>
1. Create a `GoRouterRefreshStream` class that listens to auth state changes
2. Replace `ref.watch(authStateProvider)` in router provider body with `refreshListenable`
3. The router instance will persist, but GoRouter will listen to the stream for navigation changes

Implementation pattern:
```dart
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription _subscription;
  @override void dispose() { _subscription.cancel(); super.dispose(); }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authStateAsync = ref.read(authStateProvider); // Read once, not watch
  
  return GoRouter(
    refreshListenable: GoRouterRefreshStream(
      ref.read(authProvider.notifier).stream, // Listen to auth changes
    ),
    redirect: (context, state) {
      // Check auth state from the stream, not from watched provider
      final authState = ref.read(authStateProvider);
      // ... redirect logic
    },
    // ... routes
  );
});
```
</action>

<verify>
- Add print statement in routerProvider - should only print once on app start
- Login/logout - router should not recreate, only redirect logic runs
- Check DevTools performance overlay - no jank during auth transitions
</verify>

<done>
- [ ] GoRouterRefreshStream class created in router.dart
- [ ] routerProvider uses `ref.read` instead of `ref.watch` for authStateProvider
- [ ] refreshListenable is configured with auth state stream
- [ ] Login/logout transitions are smooth without router recreation
- [ ] Print/logging confirms single router instance
</done>

---

## Task 2: Fix Legacy Text Repair

<name>
Add Migration Flags to Legacy Text Repair
</name>

<files>
- lib/providers/bank_account_provider.dart
- lib/providers/subscription_provider.dart
</files>

<action>
1. Add migration flag check at the start of `_repairLegacyText()` method in both providers
2. Use SecureStorage or SharedPreferences to store flags like `'legacy_text_repair_v1_done'`
3. Skip repair if flag is already set
4. Set flag after successful repair

Implementation pattern for bank_account_provider.dart:
```dart
Future<void> _repairLegacyText() async {
  // Check migration flag first
  final storage = ref.read(secureStorageProvider);
  final repairDone = await storage.getValue('legacy_text_repair_v1_done');
  if (repairDone == 'true') return;
  
  // ... existing repair logic
  
  // Set flag after successful repair
  await storage.saveValue('legacy_text_repair_v1_done', 'true');
}
```

Repeat same pattern in subscription_provider.dart with same or separate flag.
</action>

<verify>
- Add logging to _repairLegacyText - should only log once per app install
- Restart app multiple times - repair should skip after first run
- Check secure storage - flag should be set to 'true'
</verify>

<done>
- [ ] Migration flag check added to bank_account_provider.dart `_repairLegacyText()`
- [ ] Migration flag check added to subscription_provider.dart `_repairLegacyText()`
- [ ] Flag is set after successful repair in both providers
- [ ] Repair only runs once per app version/install
- [ ] App startup time improves (no repeated repairs)
</done>

---

## Task 3: Fix Settings Watch Cascade

<name>
Replace Full Settings Watch with Granular Select
</name>

<files>
- lib/providers/bank_account_provider.dart
- lib/providers/subscription_provider.dart
- lib/providers/web_password_provider.dart
</files>

<action>
1. Replace `ref.watch(settingsProvider)` with `ref.watch(settingsProvider.selectAsync(...))`
2. Each provider should only watch the specific settings fields it needs
3. This prevents rebuilds when unrelated settings change

Implementation pattern for web_password_provider.dart (needs password-related settings):
```dart
// Instead of watching all settings:
// final settings = await ref.watch(settingsProvider.future);

// Watch only specific fields:
final defaultPasswordLength = await ref.watch(
  settingsProvider.selectAsync((s) => s.defaultPasswordLength)
);
final autoFillEnabled = await ref.watch(
  settingsProvider.selectAsync((s) => s.autoFillEnabled)
);
```

For bank_account_provider.dart (needs card-related settings):
```dart
final defaultCardType = await ref.watch(
  settingsProvider.selectAsync((s) => s.defaultCardType)
);
```

For subscription_provider.dart (needs subscription-related settings):
```dart
final defaultCurrency = await ref.watch(
  settingsProvider.selectAsync((s) => s.defaultCurrency)
);
```
</action>

<verify>
- Change an unrelated setting (e.g., theme) - entity providers should NOT rebuild
- Change a relevant setting (e.g., default password length) - only web_password_provider should rebuild
- Use Riverpod DevTools to verify provider dependencies
</verify>

<done>
- [ ] bank_account_provider.dart uses `selectAsync` for card-related settings only
- [ ] subscription_provider.dart uses `selectAsync` for subscription-related settings only
- [ ] web_password_provider.dart uses `selectAsync` for password-related settings only
- [ ] Entity providers don't rebuild when unrelated settings change
- [ ] Riverpod DevTools shows granular dependencies
</done>

---

## Summary

These three fixes address the most critical performance issues:

1. **GoRouter Stability**: Router instance persists across auth changes, eliminating navigation jank
2. **Migration Protection**: Legacy repair runs once, improving startup performance
3. **Granular Watching**: Settings changes only affect relevant providers, reducing rebuild cascade

After implementation, the app should have:
- Smooth login/logout transitions
- Faster app startup
- Fewer unnecessary widget rebuilds
- Better overall responsiveness

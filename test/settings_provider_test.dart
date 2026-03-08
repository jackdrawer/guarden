import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guarden/providers/settings_provider.dart';
import 'package:guarden/services/settings_service.dart';

class _FakeSettingsService extends SettingsService {
  bool travelMode = false;
  List<String> protectedIds = [];
  bool notifications = true;
  bool bankNotif = true;
  bool subscriptionNotifValue = true;
  bool securityNotifValue = true;
  bool cleared = false;

  @override
  Future<void> init() async {}

  @override
  bool get isTravelModeActive => travelMode;

  @override
  Future<void> setTravelModeActive(bool value) async {
    travelMode = value;
  }

  @override
  List<String> get travelProtectedIds => List<String>.from(protectedIds);

  @override
  Future<void> addTravelProtectedId(String id) async {
    if (!protectedIds.contains(id)) {
      protectedIds.add(id);
    }
  }

  @override
  Future<void> removeTravelProtectedId(String id) async {
    protectedIds.remove(id);
  }

  @override
  bool get notificationsEnabled => notifications;

  @override
  Future<void> setNotificationsEnabled(bool value) async {
    notifications = value;
  }

  @override
  bool get bankRotationNotif => bankNotif;

  @override
  Future<void> setBankRotationNotif(bool value) async {
    bankNotif = value;
  }

  @override
  bool get subscriptionNotif => subscriptionNotifValue;

  @override
  Future<void> setSubscriptionNotif(bool value) async {
    subscriptionNotifValue = value;
  }

  @override
  bool get securityNotif => securityNotifValue;

  @override
  Future<void> setSecurityNotif(bool value) async {
    securityNotifValue = value;
  }

  @override
  Future<void> clearSettings() async {
    cleared = true;
    travelMode = false;
    protectedIds = [];
    notifications = true;
    bankNotif = true;
    subscriptionNotifValue = true;
    securityNotifValue = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  SettingsState readSettingsState(ProviderContainer container) {
    return container.read(settingsProvider).valueOrNull ??
        SettingsState.initial();
  }

  group('SettingsNotifier', () {
    test('initializes and toggles all settings', () async {
      final fakeService = _FakeSettingsService();
      final container = ProviderContainer(
        overrides: [settingsServiceProvider.overrideWithValue(fakeService)],
      );
      addTearDown(container.dispose);
      final sub = container.listen(settingsProvider, (_, __) {});
      addTearDown(sub.close);

      final initializedState = await container.read(settingsProvider.future);
      expect(initializedState.isInitialized, isTrue);

      final notifier = container.read(settingsProvider.notifier);
      await notifier.toggleTravelMode();
      expect(readSettingsState(container).isTravelModeActive, isTrue);

      await notifier.toggleTravelProtection('abc', true);
      expect(readSettingsState(container).travelProtectedIds, contains('abc'));
      expect(notifier.isProtected('abc'), isTrue);

      await notifier.toggleNotificationsEnabled(false);
      await notifier.toggleBankRotationNotif(false);
      await notifier.toggleSubscriptionNotif(false);
      await notifier.toggleSecurityNotif(false);

      final state = readSettingsState(container);
      expect(state.notificationsEnabled, isFalse);
      expect(state.bankRotationNotif, isFalse);
      expect(state.subscriptionNotif, isFalse);
      expect(state.securityNotif, isFalse);
    });

    test('resetSettings clears state via service', () async {
      final fakeService = _FakeSettingsService()..travelMode = true;
      final container = ProviderContainer(
        overrides: [settingsServiceProvider.overrideWithValue(fakeService)],
      );
      addTearDown(container.dispose);
      final sub = container.listen(settingsProvider, (_, __) {});
      addTearDown(sub.close);

      await container.read(settingsProvider.future);
      final notifier = container.read(settingsProvider.notifier);
      await notifier.resetSettings();

      expect(fakeService.cleared, isTrue);
      final state = readSettingsState(container);
      expect(state.isTravelModeActive, isFalse);
      expect(state.isInitialized, isTrue);
    });
  });
}

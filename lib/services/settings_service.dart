import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../errors/app_errors.dart';
import '../i18n/strings.g.dart';
import '../models/theme_mode.dart';

class SettingsService {
  static const String _boxName = 'settings_box';
  static const String _travelModeKey = 'isTravelModeActive';
  static const String _travelProtectedIdsKey = 'travelProtectedIds';
  static const String _notificationsEnabledKey = 'notificationsEnabled';
  static const String _bankRotationNotifKey = 'bankRotationNotif';
  static const String _subscriptionNotifKey = 'subscriptionNotif';
  static const String _securityNotifKey = 'securityNotif';
  static const String _biometricLoginKey = 'biometricLogin';
  static const String _biometricConfirmKey = 'biometricConfirm';
  static const String _themeModeKey = 'themeMode';
  static const String _lastMasterPasswordEntryKey = 'lastMasterPasswordEntry';

  late Box _box;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized && _box.isOpen) return;
    try {
      _box = await Hive.openBox(_boxName);
      _initialized = true;
    } catch (e) {
      _initialized = false;
      throw DatabaseError(
        'Settings box init failed: $e',
        userMessage: t.settings.errors.db_open_failed,
        canRetry: true,
      );
    }
  }

  DateTime? get lastMasterPasswordEntry {
    try {
      final isoString = _box.get(_lastMasterPasswordEntryKey);
      if (isoString == null) return null;
      return DateTime.parse(isoString);
    } catch (_) {
      return null;
    }
  }

  Future<void> setLastMasterPasswordEntry(DateTime date) async {
    try {
      await _box.put(_lastMasterPasswordEntryKey, date.toIso8601String());
    } catch (e) {
      throw DatabaseError(
        'Could not save last password entry date',
        userMessage: t.settings.errors.setting_update_failed,
      );
    }
  }

  bool get isTravelModeActive {
    try {
      return _box.get(_travelModeKey, defaultValue: false);
    } catch (_) {
      return false;
    }
  }

  Future<void> setTravelModeActive(bool value) async {
    try {
      await _box.put(_travelModeKey, value);
    } catch (e) {
      throw DatabaseError(
        'Could not save setting',
        userMessage: t.settings.errors.setting_update_failed,
      );
    }
  }

  List<String> get travelProtectedIds {
    try {
      final list = _box.get(_travelProtectedIdsKey, defaultValue: <String>[]);
      if (list is List) {
        return list.cast<String>();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> addTravelProtectedId(String id) async {
    try {
      final ids = travelProtectedIds;
      if (!ids.contains(id)) {
        ids.add(id);
        await _box.put(_travelProtectedIdsKey, ids);
      }
    } catch (e) {
      throw DatabaseError(
        'Could not save setting',
        userMessage: t.settings.errors.setting_update_failed,
      );
    }
  }

  Future<void> removeTravelProtectedId(String id) async {
    try {
      final ids = travelProtectedIds;
      if (ids.contains(id)) {
        ids.remove(id);
        await _box.put(_travelProtectedIdsKey, ids);
      }
    } catch (e) {
      throw DatabaseError(
        'Could not save setting',
        userMessage: t.settings.errors.setting_update_failed,
      );
    }
  }

  // Notification settings
  bool get notificationsEnabled {
    try {
      return _box.get(_notificationsEnabledKey, defaultValue: true);
    } catch (_) {
      return true;
    }
  }

  Future<void> setNotificationsEnabled(bool value) async {
    try {
      await _box.put(_notificationsEnabledKey, value);
    } catch (e) {
      throw DatabaseError(
        'Could not save setting',
        userMessage: t.settings.errors.setting_update_failed,
      );
    }
  }

  bool get bankRotationNotif {
    try {
      return _box.get(_bankRotationNotifKey, defaultValue: true);
    } catch (_) {
      return true;
    }
  }

  Future<void> setBankRotationNotif(bool value) async {
    try {
      await _box.put(_bankRotationNotifKey, value);
    } catch (e) {
      throw DatabaseError(
        'Could not save setting',
        userMessage: t.settings.errors.setting_update_failed,
      );
    }
  }

  bool get subscriptionNotif {
    try {
      return _box.get(_subscriptionNotifKey, defaultValue: true);
    } catch (_) {
      return true;
    }
  }

  Future<void> setSubscriptionNotif(bool value) async {
    try {
      await _box.put(_subscriptionNotifKey, value);
    } catch (e) {
      throw DatabaseError(
        'Could not save setting',
        userMessage: t.settings.errors.setting_update_failed,
      );
    }
  }

  bool get securityNotif {
    try {
      return _box.get(_securityNotifKey, defaultValue: true);
    } catch (_) {
      return true;
    }
  }

  Future<void> setSecurityNotif(bool value) async {
    try {
      await _box.put(_securityNotifKey, value);
    } catch (e) {
      throw DatabaseError(
        'Could not save setting',
        userMessage: t.settings.errors.setting_update_failed,
      );
    }
  }

  bool get biometricLogin {
    try {
      return _box.get(_biometricLoginKey, defaultValue: false);
    } catch (_) {
      return false;
    }
  }

  Future<void> setBiometricLogin(bool value) async {
    try {
      await _box.put(_biometricLoginKey, value);
    } catch (e) {
      throw DatabaseError(
        'Could not save setting',
        userMessage: t.settings.errors.setting_update_failed,
      );
    }
  }

  bool get biometricConfirm {
    try {
      return _box.get(_biometricConfirmKey, defaultValue: false);
    } catch (_) {
      return false;
    }
  }

  Future<void> setBiometricConfirm(bool value) async {
    try {
      await _box.put(_biometricConfirmKey, value);
    } catch (e) {
      throw DatabaseError(
        'Could not save setting',
        userMessage: t.settings.errors.setting_update_failed,
      );
    }
  }

  // Theme mode settings
  AppThemeMode get themeMode {
    try {
      final value = _box.get(_themeModeKey, defaultValue: 'system');
      return AppThemeModeExtension.fromString(value as String?);
    } catch (_) {
      return AppThemeMode.system;
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    try {
      await _box.put(_themeModeKey, mode.name);
    } catch (e) {
      throw DatabaseError(
        'Could not save theme setting',
        userMessage: t.settings.errors.setting_update_failed,
      );
    }
  }

  Future<void> clearSettings() async {
    try {
      await _box.clear();
    } catch (e) {
      throw DatabaseError(
        'Could not clear settings',
        userMessage: t.settings.errors.setting_update_failed,
      );
    }
  }
}

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

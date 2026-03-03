import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../errors/app_errors.dart';

class SettingsService {
  static const String _boxName = 'settings_box';
  static const String _travelModeKey = 'isTravelModeActive';
  static const String _travelProtectedIdsKey = 'travelProtectedIds';
  static const String _notificationsEnabledKey = 'notificationsEnabled';
  static const String _bankRotationNotifKey = 'bankRotationNotif';
  static const String _subscriptionNotifKey = 'subscriptionNotif';
  static const String _securityNotifKey = 'securityNotif';

  late Box _box;

  Future<void> init() async {
    try {
      _box = await Hive.openBox(_boxName);
    } catch (e) {
      throw DatabaseError(
        'Settings box init failed: $e',
        userMessage: "Couldn't load settings.",
        canRetry: true,
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
        userMessage: "Couldn't save settings.",
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
        userMessage: "Couldn't save settings.",
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
        userMessage: "Couldn't save settings.",
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
        userMessage: "Couldn't save settings.",
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
        userMessage: "Couldn't save settings.",
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
        userMessage: "Couldn't save settings.",
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
        userMessage: "Couldn't save settings.",
      );
    }
  }

  Future<void> clearSettings() async {
    try {
      await _box.clear();
    } catch (e) {
      throw DatabaseError(
        'Could not clear settings',
        userMessage: "Couldn't save settings.",
      );
    }
  }
}

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

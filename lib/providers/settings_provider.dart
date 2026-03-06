import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/settings_service.dart';
import '../services/backup_task_runner.dart';
import '../widgets/error_handler.dart';
import '../errors/app_errors.dart';
import '../i18n/strings.g.dart';
import '../models/theme_mode.dart';

class SettingsState {
  final bool isTravelModeActive;
  final List<String> travelProtectedIds;
  final bool isInitialized;
  final bool notificationsEnabled;
  final bool bankRotationNotif;
  final bool subscriptionNotif;
  final bool securityNotif;
  final bool biometricLogin;
  final bool biometricConfirm;
  final AppThemeMode themeMode;
  final DateTime? lastMasterPasswordEntry;
  // Phase 12: Locale & Currency preferences
  final String? languageCode; // null = system locale
  final String? defaultCurrency; // null = locale-derived
  // Phase 13: Auto-Backup
  final String autoBackupFrequency; // 'off', 'daily', 'weekly', 'monthly'
  final DateTime? lastSyncTimestamp;
  final bool backupOnlyOnWifi;
  final bool backupOnlyWhileCharging;

  SettingsState({
    required this.isTravelModeActive,
    required this.travelProtectedIds,
    this.isInitialized = false,
    this.notificationsEnabled = true,
    this.bankRotationNotif = true,
    this.subscriptionNotif = true,
    this.securityNotif = true,
    this.biometricLogin = false,
    this.biometricConfirm = false,
    this.themeMode = AppThemeMode.system,
    this.lastMasterPasswordEntry,
    this.languageCode,
    this.defaultCurrency,
    this.autoBackupFrequency = 'off',
    this.lastSyncTimestamp,
    this.backupOnlyOnWifi = true,
    this.backupOnlyWhileCharging = false,
  });

  factory SettingsState.initial() => SettingsState(
    isTravelModeActive: false,
    travelProtectedIds: [],
    isInitialized: false,
    themeMode: AppThemeMode.system,
  );

  SettingsState copyWith({
    bool? isTravelModeActive,
    List<String>? travelProtectedIds,
    bool? isInitialized,
    bool? notificationsEnabled,
    bool? bankRotationNotif,
    bool? subscriptionNotif,
    bool? securityNotif,
    bool? biometricLogin,
    bool? biometricConfirm,
    AppThemeMode? themeMode,
    DateTime? lastMasterPasswordEntry,
    Object? languageCode = _sentinel,
    Object? defaultCurrency = _sentinel,
    String? autoBackupFrequency,
    DateTime? lastSyncTimestamp,
    bool? backupOnlyOnWifi,
    bool? backupOnlyWhileCharging,
  }) {
    return SettingsState(
      isTravelModeActive: isTravelModeActive ?? this.isTravelModeActive,
      travelProtectedIds: travelProtectedIds ?? this.travelProtectedIds,
      isInitialized: isInitialized ?? this.isInitialized,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      bankRotationNotif: bankRotationNotif ?? this.bankRotationNotif,
      subscriptionNotif: subscriptionNotif ?? this.subscriptionNotif,
      securityNotif: securityNotif ?? this.securityNotif,
      biometricLogin: biometricLogin ?? this.biometricLogin,
      biometricConfirm: biometricConfirm ?? this.biometricConfirm,
      themeMode: themeMode ?? this.themeMode,
      lastMasterPasswordEntry:
          lastMasterPasswordEntry ?? this.lastMasterPasswordEntry,
      languageCode: languageCode == _sentinel
          ? this.languageCode
          : languageCode as String?,
      defaultCurrency: defaultCurrency == _sentinel
          ? this.defaultCurrency
          : defaultCurrency as String?,
      autoBackupFrequency: autoBackupFrequency ?? this.autoBackupFrequency,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
      backupOnlyOnWifi: backupOnlyOnWifi ?? this.backupOnlyOnWifi,
      backupOnlyWhileCharging:
          backupOnlyWhileCharging ?? this.backupOnlyWhileCharging,
    );
  }
}

/// Sentinel for nullable copyWith fields.
const _sentinel = Object();

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  late final SettingsService _settingsService;

  @override
  Future<SettingsState> build() async {
    _settingsService = ref.read(settingsServiceProvider);
    return await _init();
  }

  Future<SettingsState> _init() async {
    try {
      await _settingsService.init();
      final lang = _settingsService.languageCode;
      if (lang != null) {
        LocaleSettings.setLocaleRaw(lang);
      }
      return SettingsState(
        isTravelModeActive: _settingsService.isTravelModeActive,
        travelProtectedIds: _settingsService.travelProtectedIds,
        notificationsEnabled: _settingsService.notificationsEnabled,
        bankRotationNotif: _settingsService.bankRotationNotif,
        subscriptionNotif: _settingsService.subscriptionNotif,
        securityNotif: _settingsService.securityNotif,
        biometricLogin: _settingsService.biometricLogin,
        biometricConfirm: _settingsService.biometricConfirm,
        themeMode: _settingsService.themeMode,
        lastMasterPasswordEntry: _settingsService.lastMasterPasswordEntry,
        languageCode: _settingsService.languageCode,
        defaultCurrency: _settingsService.defaultCurrency,
        autoBackupFrequency: _settingsService.autoBackupFrequency,
        lastSyncTimestamp: _settingsService.lastSyncTimestamp,
        backupOnlyOnWifi: _settingsService.backupOnlyOnWifi,
        backupOnlyWhileCharging: _settingsService.backupOnlyWhileCharging,
        isInitialized: true,
      );
    } catch (e, stackTrace) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        state = AsyncValue.error(e, stackTrace);
        ErrorHandler.handleGlobalError(
          DatabaseError(
            'Failed to load settings: $e',
            userMessage: t.settings.errors.setting_update_failed,
          ),
        );
      });
      return SettingsState.initial().copyWith(isInitialized: true);
    }
  }

  Future<void> setTravelModeActive(bool value) async {
    try {
      await _settingsService.init();
      final currentValue = state.value;
      if (currentValue == null) return;

      await _settingsService.setTravelModeActive(value);
      state = AsyncValue.data(currentValue.copyWith(isTravelModeActive: value));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to set travel mode: $e',
          userMessage: t.settings.errors.travel_mode_failed,
        ),
      );
    }
  }

  Future<void> toggleTravelMode() async {
    final cur = state.value;
    if (cur != null) {
      await setTravelModeActive(!cur.isTravelModeActive);
    }
  }

  Future<void> toggleTravelProtection(String id, bool protect) async {
    try {
      await _settingsService.init();
      if (protect) {
        await _settingsService.addTravelProtectedId(id);
      } else {
        await _settingsService.removeTravelProtectedId(id);
      }
      final currentValue = state.value;
      if (currentValue != null) {
        state = AsyncValue.data(
          currentValue.copyWith(
            travelProtectedIds: _settingsService.travelProtectedIds,
          ),
        );
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to update travel protection: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
    }
  }

  bool isProtected(String id) {
    return state.value?.travelProtectedIds.contains(id) ?? false;
  }

  Future<void> _toggleSetting({
    required Future<void> Function(bool) setter,
    required SettingsState Function(SettingsState, bool) updater,
    required bool value,
    required String errorContext,
  }) async {
    try {
      await _settingsService.init();
      await setter(value);
      final currentValue = state.value;
      if (currentValue != null) {
        state = AsyncValue.data(updater(currentValue, value));
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to update $errorContext: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
    }
  }

  Future<void> toggleNotificationsEnabled(bool value) => _toggleSetting(
    setter: _settingsService.setNotificationsEnabled,
    updater: (s, v) => s.copyWith(notificationsEnabled: v),
    value: value,
    errorContext: 'notifications',
  );

  Future<void> toggleBankRotationNotif(bool value) => _toggleSetting(
    setter: _settingsService.setBankRotationNotif,
    updater: (s, v) => s.copyWith(bankRotationNotif: v),
    value: value,
    errorContext: 'bank rotation notifications',
  );

  Future<void> toggleSubscriptionNotif(bool value) => _toggleSetting(
    setter: _settingsService.setSubscriptionNotif,
    updater: (s, v) => s.copyWith(subscriptionNotif: v),
    value: value,
    errorContext: 'subscription notifications',
  );

  Future<void> toggleSecurityNotif(bool value) => _toggleSetting(
    setter: _settingsService.setSecurityNotif,
    updater: (s, v) => s.copyWith(securityNotif: v),
    value: value,
    errorContext: 'security notifications',
  );

  Future<void> toggleBiometricLogin(bool value) => _toggleSetting(
    setter: _settingsService.setBiometricLogin,
    updater: (s, v) => s.copyWith(biometricLogin: v),
    value: value,
    errorContext: 'biometric login',
  );

  Future<void> toggleBiometricConfirm(bool value) => _toggleSetting(
    setter: _settingsService.setBiometricConfirm,
    updater: (s, v) => s.copyWith(biometricConfirm: v),
    value: value,
    errorContext: 'biometric confirmation',
  );

  Future<void> setThemeMode(AppThemeMode mode) async {
    try {
      await _settingsService.init();
      await _settingsService.setThemeMode(mode);
      final currentValue = state.value;
      if (currentValue != null) {
        state = AsyncValue.data(currentValue.copyWith(themeMode: mode));
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to update theme mode: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
    }
  }

  Future<void> setLastMasterPasswordEntry(DateTime date) async {
    try {
      await _settingsService.init();
      await _settingsService.setLastMasterPasswordEntry(date);
      final currentValue = state.value;
      if (currentValue != null) {
        state = AsyncValue.data(
          currentValue.copyWith(lastMasterPasswordEntry: date),
        );
      }
    } catch (e) {
      debugPrint('Failed to update lastMasterPasswordEntry: $e');
    }
  }

  Future<void> resetSettings() async {
    try {
      await _settingsService.init();
      await _settingsService.clearSettings();
      state = AsyncValue.data(
        SettingsState.initial().copyWith(isInitialized: true),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to reset settings: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
    }
  }

  Future<void> setLanguageCode(String? code) async {
    try {
      await _settingsService.init();
      await _settingsService.setLanguageCode(code);
      if (code != null) {
        LocaleSettings.setLocaleRaw(code);
      } else {
        LocaleSettings.useDeviceLocale();
      }
      final currentValue = state.value;
      if (currentValue != null) {
        state = AsyncValue.data(currentValue.copyWith(languageCode: code));
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to set language: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
    }
  }

  Future<void> setDefaultCurrency(String? code) async {
    try {
      await _settingsService.init();
      await _settingsService.setDefaultCurrency(code);
      final currentValue = state.value;
      if (currentValue != null) {
        state = AsyncValue.data(currentValue.copyWith(defaultCurrency: code));
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to set default currency: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
    }
  }

  Future<void> setAutoBackupFrequency(String frequency) async {
    await _settingsService.init();
    await _settingsService.setAutoBackupFrequency(frequency);
    final currentValue = state.value;
    if (currentValue != null) {
      state = AsyncValue.data(
        currentValue.copyWith(autoBackupFrequency: frequency),
      );
      await _rescheduleBackup();
    }
  }

  Future<void> setLastSyncTimestamp(DateTime dt) async {
    try {
      await _settingsService.init();
      await _settingsService.setLastSyncTimestamp(dt);
      final currentValue = state.value;
      if (currentValue != null) {
        state = AsyncValue.data(currentValue.copyWith(lastSyncTimestamp: dt));
      }
    } catch (e) {
      debugPrint('Failed to set lastSyncTimestamp: $e');
    }
  }

  Future<void> toggleBackupOnlyOnWifi(bool value) async {
    await _settingsService.init();
    await _settingsService.setBackupOnlyOnWifi(value);
    final currentValue = state.value;
    if (currentValue != null) {
      state = AsyncValue.data(currentValue.copyWith(backupOnlyOnWifi: value));
      await _rescheduleBackup();
    }
  }

  Future<void> toggleBackupOnlyWhileCharging(bool value) async {
    await _settingsService.init();
    await _settingsService.setBackupOnlyWhileCharging(value);
    final currentValue = state.value;
    if (currentValue != null) {
      state = AsyncValue.data(
        currentValue.copyWith(backupOnlyWhileCharging: value),
      );
      await _rescheduleBackup();
    }
  }

  Future<void> _rescheduleBackup() async {
    final s = state.value;
    if (s != null && !kIsWeb) {
      await BackupTaskRunner.schedulePeriodicBackup(
        s.autoBackupFrequency,
        wifiOnly: s.backupOnlyOnWifi,
        chargingOnly: s.backupOnlyWhileCharging,
      );
    }
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, SettingsState>(
  () => SettingsNotifier(),
);

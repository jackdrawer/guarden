import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/settings_service.dart';
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
    );
  }
}

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
        isInitialized: true,
      );
    } catch (e, stackTrace) {
      // Defer state update to avoid modifying provider during build phase
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

  Future<void> toggleTravelMode() async {
    try {
      await _settingsService.init();
      final currentValue = state.value;
      if (currentValue == null) return;

      final newValue = !currentValue.isTravelModeActive;
      await _settingsService.setTravelModeActive(newValue);
      state = AsyncValue.data(
        currentValue.copyWith(isTravelModeActive: newValue),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to toggle travel mode: $e',
          userMessage: t.settings.errors.travel_mode_failed,
        ),
      );
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

  /// Generic toggle helper — DRY wrapper for all boolean settings.
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
      // Sadece arka plan logu tut, kullanıcıya göstermeye gerek yok (kritik değil)
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
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

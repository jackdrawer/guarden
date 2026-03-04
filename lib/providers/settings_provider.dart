import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/settings_service.dart';
import '../widgets/error_handler.dart';
import '../errors/app_errors.dart';
import '../i18n/strings.g.dart';

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
  });

  factory SettingsState.initial() => SettingsState(
    isTravelModeActive: false,
    travelProtectedIds: [],
    isInitialized: false,
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
        isInitialized: true,
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to load settings: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
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

  Future<void> toggleNotificationsEnabled(bool value) async {
    try {
      await _settingsService.init();
      await _settingsService.setNotificationsEnabled(value);
      final currentValue = state.value;
      if (currentValue != null) {
        state = AsyncValue.data(
          currentValue.copyWith(notificationsEnabled: value),
        );
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to update notifications: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
    }
  }

  Future<void> toggleBankRotationNotif(bool value) async {
    try {
      await _settingsService.init();
      await _settingsService.setBankRotationNotif(value);
      final currentValue = state.value;
      if (currentValue != null) {
        state = AsyncValue.data(
          currentValue.copyWith(bankRotationNotif: value),
        );
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to update bank rotation notifications: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
    }
  }

  Future<void> toggleSubscriptionNotif(bool value) async {
    try {
      await _settingsService.init();
      await _settingsService.setSubscriptionNotif(value);
      final currentValue = state.value;
      if (currentValue != null) {
        state = AsyncValue.data(
          currentValue.copyWith(subscriptionNotif: value),
        );
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to update subscription notifications: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
    }
  }

  Future<void> toggleSecurityNotif(bool value) async {
    try {
      await _settingsService.init();
      await _settingsService.setSecurityNotif(value);
      final currentValue = state.value;
      if (currentValue != null) {
        state = AsyncValue.data(currentValue.copyWith(securityNotif: value));
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to update security notifications: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
    }
  }

  Future<void> toggleBiometricLogin(bool value) async {
    try {
      await _settingsService.init();
      await _settingsService.setBiometricLogin(value);
      final currentValue = state.value;
      if (currentValue != null) {
        state = AsyncValue.data(currentValue.copyWith(biometricLogin: value));
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to update biometric login: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
    }
  }

  Future<void> toggleBiometricConfirm(bool value) async {
    try {
      await _settingsService.init();
      await _settingsService.setBiometricConfirm(value);
      final currentValue = state.value;
      if (currentValue != null) {
        state = AsyncValue.data(currentValue.copyWith(biometricConfirm: value));
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to update biometric confirmation: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
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

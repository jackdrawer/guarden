import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/strings.g.dart';
import '../services/crypto_service.dart';
import '../services/database_service.dart';
import '../services/secure_storage_service.dart';
import '../services/biometric_service.dart';
import '../theme/app_colors.dart';
import '../utils/crypto_utils.dart';
import '../widgets/error_handler.dart';
import '../services/app_lifecycle_service.dart';
import 'settings_provider.dart';

enum AuthState { initial, firstTime, unauthenticated, authenticated }

class AuthNotifier extends AsyncNotifier<AuthState> {
  late SecureStorageService _secureStorage;
  late DatabaseService _databaseService;
  late CryptoService _cryptoService;

  int _failedLoginAttempts = 0;

  @override
  Future<AuthState> build() async {
    _secureStorage = ref.read(secureStorageProvider);
    _databaseService = ref.read(databaseProvider);
    _cryptoService = ref.read(cryptoProvider);
    return await _checkInitialState();
  }

  Future<AuthState> _checkInitialState() async {
    try {
      final key = await _secureStorage.getEncryptionKey();
      if (key == null || key.isEmpty) {
        return AuthState.firstTime;
      } else {
        return AuthState.unauthenticated;
      }
    } catch (e, stackTrace) {
      // Defer state update to avoid modifying provider during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        state = AsyncValue.error(e, stackTrace);
      });
      return AuthState.unauthenticated;
    }
  }

  Future<void> setupVault(String masterPassword) async {
    try {
      final dbKey = generateSecureKey();
      await _secureStorage.saveEncryptionKey(dbKey);
      await _persistMasterPasswordVerifier(masterPassword);

      await _databaseService.initDatabase();

      // Setup successful, update last usage
      await ref
          .read(settingsProvider.notifier)
          .setLastMasterPasswordEntry(DateTime.now());

      state = AsyncValue.data(AuthState.authenticated);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(e);
    }
  }

  Future<bool> login(String masterPassword) async {
    try {
      final isValid = await verifyMasterPassword(masterPassword);
      if (!isValid) {
        _failedLoginAttempts++;
        int delaySeconds = 0;
        if (_failedLoginAttempts >= 5) {
          delaySeconds = 30;
        } else if (_failedLoginAttempts >= 3) {
          delaySeconds = 4;
        } else if (_failedLoginAttempts >= 2) {
          delaySeconds = 2;
        } else {
          delaySeconds = 1;
        }
        await Future.delayed(Duration(seconds: delaySeconds));
        return false;
      }

      _failedLoginAttempts = 0;

      await _databaseService.initDatabase();

      // Login with password successful, update last usage
      await ref
          .read(settingsProvider.notifier)
          .setLastMasterPasswordEntry(DateTime.now());

      state = AsyncValue.data(AuthState.authenticated);
      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(e);
      return false;
    }
  }

  Future<bool> verifyMasterPassword(String masterPassword) async {
    try {
      final salt = await _secureStorage.getSalt();
      if (salt == null) return false;

      final derivedKey = await _cryptoService.deriveKey(masterPassword, salt);
      final derivedBytes = await derivedKey.extractBytes();
      final derivedBase64 = base64Encode(derivedBytes);

      final verifier = await _secureStorage.getMasterPasswordVerifier();
      if (verifier != null && verifier.isNotEmpty) {
        return constantTimeEquals(derivedBase64, verifier);
      }

      // Legacy fallback: previous versions compared password-derived key with
      // the DB encryption key directly. This block auto-migrates to
      // verifier-based auth and will be removed in a future release.
      final storedBase64 = await _secureStorage.getEncryptionKey();
      if (storedBase64 == null) return false;

      final isLegacyMatch = constantTimeEquals(derivedBase64, storedBase64);
      if (isLegacyMatch) {
        debugPrint(
          '⚠️ Legacy master password verification detected — '
          'migrating to verifier-based auth.',
        );
        await _secureStorage.saveMasterPasswordVerifier(derivedBase64);
      }

      return isLegacyMatch;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(e);
      return false;
    }
  }

  Future<String?> requestVerifiedMasterPassword(
    BuildContext context, {
    String? dialogTitle,
    String? wrongPasswordMessage,
  }) async {
    final controller = TextEditingController();

    try {
      var obscure = true;
      final password = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: AppColors.of(ctx).surface,
                title: Text(
                  dialogTitle ?? t.general.authentication,
                  style: TextStyle(color: AppColors.of(ctx).textPrimary),
                ),
                content: TextField(
                  controller: controller,
                  autofocus: false,
                  obscureText: obscure,
                  style: TextStyle(color: AppColors.of(ctx).textPrimary),
                  decoration: InputDecoration(
                    labelText: t.general.master_password_hint,
                    labelStyle: TextStyle(
                      color: AppColors.of(ctx).textSecondary,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => obscure = !obscure),
                      icon: Icon(
                        obscure ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.of(ctx).textSecondary,
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      t.general.cancel,
                      style: TextStyle(color: AppColors.of(ctx).textSecondary),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(controller.text),
                    child: Text(t.general.confirm),
                  ),
                ],
              );
            },
          );
        },
      );

      if (password == null || password.isEmpty) {
        return null;
      }

      final isValid = await verifyMasterPassword(password);
      if (!isValid) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                wrongPasswordMessage ?? t.settings.master_password_wrong,
              ),
            ),
          );
        }
        return null;
      }

      return password;
    } finally {
      Future.delayed(const Duration(milliseconds: 200), () {
        controller.dispose();
      });
    }
  }

  Future<bool> authenticateForSensitiveAction(
    BuildContext context, {
    String? biometricReason,
    String? passwordDialogTitle,
    String? wrongPasswordMessage,
  }) async {
    final settings = ref.read(settingsProvider).valueOrNull;
    final isConfirmEnabled = settings?.biometricConfirm ?? false;

    if (!isConfirmEnabled) {
      return true;
    }

    final canUse = await canUseBiometrics();
    if (canUse) {
      final unlocked = await biometricUnlock(
        reason: biometricReason ?? t.settings.secure_action_reason,
      );
      if (unlocked) {
        return true;
      }
    }

    if (!context.mounted) {
      return false;
    }

    final password = await requestVerifiedMasterPassword(
      context,
      dialogTitle: passwordDialogTitle,
      wrongPasswordMessage: wrongPasswordMessage,
    );
    return password != null;
  }

  Future<void> lock() async {
    try {
      await _databaseService.closeDatabase();
      state = AsyncValue.data(AuthState.unauthenticated);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(e);
    }
  }

  /// Resets the vault after panic mode activation.
  ///
  /// WARNING: This permanently DELETES all vault data including bank accounts,
  /// subscriptions, and web passwords. This is a destructive operation intended
  /// for emergency situations (e.g., duress/compromised device).
  Future<void> resetAfterPanic() async {
    try {
      await _databaseService.deleteDatabase();
      // Clear auth & lock flags so lifecycle service stops locking
      ref.read(isUserAuthenticatedProvider.notifier).state = false;
      ref.read(isLockedProvider.notifier).state = false;
      // Reset all settings (biometric, theme, etc.)
      await ref.read(settingsProvider.notifier).resetSettings();
      state = AsyncValue.data(AuthState.firstTime);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(e);
    }
  }

  Future<void> _persistMasterPasswordVerifier(String masterPassword) async {
    final salt = generateSecureSalt();
    await _secureStorage.saveSalt(salt);

    final derivedKey = await _cryptoService.deriveKey(masterPassword, salt);
    final keyBytes = await derivedKey.extractBytes();
    final verifier = base64Encode(keyBytes);

    await _secureStorage.saveMasterPasswordVerifier(verifier);
  }

  Future<bool> canUseBiometrics() async {
    final service = BiometricService();
    return await service.canCheckBiometrics();
  }

  Future<bool> biometricUnlock({String? reason}) async {
    final service = BiometricService();
    try {
      final success = await service.authenticate(reason: reason);
      if (success) {
        await _databaseService.initDatabase();
        state = AsyncValue.data(AuthState.authenticated);
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(e);
      return false;
    }
  }
}

final splashCompleterProvider = StateProvider<bool>((ref) => false);

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

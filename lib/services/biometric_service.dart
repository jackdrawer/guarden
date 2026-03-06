import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

import '../errors/app_errors.dart';
import '../i18n/strings.g.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Returns whether biometric auth is available on this device.
  Future<bool> canCheckBiometrics() async {
    if (kIsWeb) return false;

    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck || isDeviceSupported;
    } on MissingPluginException catch (_) {
      return false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Returns enrolled biometric types (face, fingerprint, etc).
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (kIsWeb) return <BiometricType>[];

    try {
      return await _auth.getAvailableBiometrics();
    } on MissingPluginException catch (_) {
      return <BiometricType>[];
    } on PlatformException catch (_) {
      return <BiometricType>[];
    }
  }

  Future<bool> authenticate({String? reason}) async {
    if (kIsWeb) return false;

    try {
      return await _auth.authenticate(
        localizedReason: reason ?? t.auth_login.biometric_tooltip,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on MissingPluginException catch (_) {
      return false;
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        if (kDebugMode) {
          debugPrint('Biometric auth failed: hardware not available');
        }
        return false;
      }

      if (e.code == auth_error.notEnrolled) {
        if (kDebugMode) {
          debugPrint('Biometric auth failed: not enrolled');
        }
        return false;
      }

      throw BiometricError(
        'Biometric authentication failed: ${e.message}',
        userMessage:
            'Biometric authentication failed. Try again or use master password.',
        canRetry: true,
        action: 'retry',
      );
    }
  }
}

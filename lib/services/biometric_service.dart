import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import '../errors/app_errors.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Cihazda biyometrik donanımın desteklenip desteklenmediğini kontrol eder
  Future<bool> canCheckBiometrics() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck || isDeviceSupported;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Hangi biyometrik türlerin var olduğunu (Face, Fingerprint vb) liste halinde döner
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (_) {
      return <BiometricType>[];
    }
  }

  /// Kullanıcıyı biyometrik doğrulama ile onaylar
  /// [reason] : "Lütfen kasanızı açmak için onay verin" gibi işletim sisteminde görünen yazı
  Future<bool> authenticate({
    String reason = 'Parola kasanıza erişmek için lütfen doğrulama yapın',
  }) async {
    bool authenticated = false;
    try {
      authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true, // Uygulama arkaplanda iken auth isteğini tutar
          biometricOnly: false, // Eğer pin kodu vb. fallback olacaksa false
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        // cihazda hardware yok - log but don't throw
        if (kDebugMode) {
          print('Biometric auth failed: hardware not available');
        }
      } else if (e.code == auth_error.notEnrolled) {
        // şifre veya yüz kaydedilmemiş - log but don't throw
        if (kDebugMode) {
          print('Biometric auth failed: not enrolled');
        }
      } else {
        // Other platform errors - throw BiometricError
        throw BiometricError(
          'Biometric authentication failed: ${e.message}',
          userMessage:
              "Biometric authentication failed. Try again or use master password.",
          canRetry: true,
          action: "retry",
        );
      }
      return false;
    }
    return authenticated;
  }
}

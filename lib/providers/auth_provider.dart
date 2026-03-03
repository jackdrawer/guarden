import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/crypto_service.dart';
import '../services/database_service.dart';
import '../services/secure_storage_service.dart';
import '../widgets/error_handler.dart';

enum AuthState { initial, firstTime, unauthenticated, authenticated }

class AuthNotifier extends AutoDisposeAsyncNotifier<AuthState> {
  late SecureStorageService _secureStorage;
  late DatabaseService _databaseService;

  @override
  Future<AuthState> build() async {
    _secureStorage = ref.read(secureStorageProvider);
    _databaseService = ref.read(databaseProvider);
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
      state = AsyncValue.error(e, stackTrace);
      return AuthState.unauthenticated;
    }
  }

  Future<void> setupVault(String masterPassword, {String? seedPhrase}) async {
    try {
      final dbKey = _generateVaultKey();
      await _secureStorage.saveEncryptionKey(dbKey);
      await _persistMasterPasswordVerifier(masterPassword);

      final normalizedSeed = _normalizeSeedPhrase(seedPhrase ?? '');
      if (normalizedSeed.isNotEmpty) {
        final recoveryBundle = await _buildRecoveryBundle(
          normalizedSeed,
          dbKey,
        );
        await _secureStorage.saveRecoveryBundle(recoveryBundle);
      }

      await _databaseService.initDatabase();
      state = AsyncValue.data(AuthState.authenticated);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(e);
    }
  }

  Future<bool> login(String masterPassword) async {
    try {
      final isValid = await verifyMasterPassword(masterPassword);
      if (!isValid) return false;

      await _databaseService.initDatabase();
      state = AsyncValue.data(AuthState.authenticated);
      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(e);
      return false;
    }
  }

  Future<bool> verifyMasterPassword(String masterPassword) async {
    final crypto = CryptoService();

    try {
      final salt = await _secureStorage.getSalt();
      if (salt == null) return false;

      final derivedKey = await crypto.deriveKey(masterPassword, salt);
      final derivedBytes = await derivedKey.extractBytes();
      final derivedBase64 = base64Encode(derivedBytes);

      final verifier = await _secureStorage.getMasterPasswordVerifier();
      if (verifier != null && verifier.isNotEmpty) {
        return _constantTimeEquals(derivedBase64, verifier);
      }

      // Legacy fallback: previous versions compared password-derived key with
      // the DB encryption key directly.
      final storedBase64 = await _secureStorage.getEncryptionKey();
      if (storedBase64 == null) return false;

      final isLegacyMatch = _constantTimeEquals(derivedBase64, storedBase64);
      if (isLegacyMatch) {
        await _secureStorage.saveMasterPasswordVerifier(derivedBase64);
      }

      return isLegacyMatch;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(e);
      return false;
    }
  }

  Future<bool> recoverWithSeedPhrase(
    String seedPhrase,
    String newMasterPassword,
  ) async {
    if (newMasterPassword.length < 8) {
      return false;
    }

    final normalizedSeed = _normalizeSeedPhrase(seedPhrase);
    if (normalizedSeed.isEmpty) {
      return false;
    }

    try {
      final bundle = await _secureStorage.getRecoveryBundle();
      if (bundle == null || bundle.isEmpty) {
        return false;
      }

      final recoveredDbKey = await _extractVaultKeyFromBundle(
        bundle: bundle,
        normalizedSeed: normalizedSeed,
      );
      if (recoveredDbKey == null || recoveredDbKey.isEmpty) {
        return false;
      }

      try {
        await _databaseService.closeDatabase();
      } catch (_) {}

      await _secureStorage.saveEncryptionKey(recoveredDbKey);
      await _persistMasterPasswordVerifier(newMasterPassword);

      await _databaseService.initDatabase();
      state = AsyncValue.data(AuthState.authenticated);
      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(e);
      return false;
    }
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

  Future<void> resetAfterPanic() async {
    try {
      await _databaseService.closeDatabase();
      state = AsyncValue.data(AuthState.firstTime);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(e);
    }
  }

  Future<void> _persistMasterPasswordVerifier(String masterPassword) async {
    final crypto = CryptoService();
    final salt = _generateSalt();
    await _secureStorage.saveSalt(salt);

    final derivedKey = await crypto.deriveKey(masterPassword, salt);
    final keyBytes = await derivedKey.extractBytes();
    final verifier = base64Encode(keyBytes);

    await _secureStorage.saveMasterPasswordVerifier(verifier);
  }

  Future<String> _buildRecoveryBundle(
    String normalizedSeed,
    String dbKey,
  ) async {
    final crypto = CryptoService();
    final recoverySalt = _generateSalt();
    final recoveryKey = await crypto.deriveKey(normalizedSeed, recoverySalt);

    final payload = jsonEncode({'dbKey': dbKey});
    final encryptedPayload = await crypto.encryptText(payload, recoveryKey);

    return jsonEncode({
      'v': 1,
      'salt': recoverySalt,
      'cipher': encryptedPayload,
    });
  }

  Future<String?> _extractVaultKeyFromBundle({
    required String bundle,
    required String normalizedSeed,
  }) async {
    final crypto = CryptoService();
    final decodedBundle = jsonDecode(bundle);
    if (decodedBundle is! Map<String, dynamic>) return null;

    final salt = decodedBundle['salt'];
    final cipher = decodedBundle['cipher'];
    if (salt is! String || cipher is! String) return null;

    final recoveryKey = await crypto.deriveKey(normalizedSeed, salt);
    final payload = await crypto.decryptText(cipher, recoveryKey);

    final decodedPayload = jsonDecode(payload);
    if (decodedPayload is! Map<String, dynamic>) return null;

    final dbKey = decodedPayload['dbKey'];
    if (dbKey is! String || dbKey.isEmpty) return null;

    return dbKey;
  }

  String _normalizeSeedPhrase(String seedPhrase) {
    return seedPhrase.trim().toLowerCase().split(RegExp(r'\s+')).join(' ');
  }

  String _generateSalt({int length = 32}) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _generateVaultKey({int length = 32}) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  bool _constantTimeEquals(String a, String b) {
    final maxLength = a.length > b.length ? a.length : b.length;
    var diff = a.length ^ b.length;

    for (var i = 0; i < maxLength; i++) {
      final aCode = i < a.length ? a.codeUnitAt(i) : 0;
      final bCode = i < b.length ? b.codeUnitAt(i) : 0;
      diff |= aCode ^ bCode;
    }

    return diff == 0;
  }
}

final splashCompleterProvider = StateProvider<bool>((ref) => false);

final authProvider = AsyncNotifierProvider.autoDispose<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../errors/app_errors.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  static const String _dbKeyPrefix = 'guarden_db_encryption_key';
  static const String _saltKey = 'guarden_crypto_salt';
  static const String _masterPasswordVerifierKey =
      'guarden_master_password_verifier';
  static const String _recoveryBundleKey = 'guarden_recovery_bundle_v1';

  /// Writes the DB encryption key used for Hive boxes.
  Future<void> saveEncryptionKey(String base64Key) async {
    try {
      await _storage.write(key: _dbKeyPrefix, value: base64Key);
    } on PlatformException catch (e) {
      throw StorageError(
        'Platform error saving key: $e',
        userMessage:
            "Couldn't access secure storage. Please re-enter master password.",
        canRetry: true,
        action: "re-enter password",
      );
    } catch (e) {
      throw StorageError(
        'Key could not be saved: $e',
        userMessage: "Couldn't save key to storage.",
      );
    }
  }

  /// Reads the DB encryption key.
  Future<String?> getEncryptionKey() async {
    try {
      return await _storage.read(key: _dbKeyPrefix);
    } on PlatformException catch (e) {
      throw StorageError(
        'Platform error reading key: $e',
        userMessage:
            "Couldn't access secure storage. Please re-enter master password.",
        canRetry: true,
        action: "re-enter password",
      );
    } catch (e) {
      throw StorageError(
        'Secure storage is not accessible: $e',
        userMessage: "Couldn't access secure storage.",
      );
    }
  }

  /// Persists the salt used for password verification derivation.
  Future<void> saveSalt(String salt) async {
    try {
      await _storage.write(key: _saltKey, value: salt);
    } on PlatformException catch (e) {
      throw StorageError(
        'Platform error saving salt: $e',
        userMessage:
            "Couldn't access secure storage. Please re-enter master password.",
        canRetry: true,
        action: "re-enter password",
      );
    } catch (e) {
      throw StorageError('Salt could not be saved: $e');
    }
  }

  Future<String?> getSalt() async {
    try {
      return await _storage.read(key: _saltKey);
    } on PlatformException catch (e) {
      throw StorageError(
        'Platform error reading salt: $e',
        userMessage:
            "Couldn't access secure storage. Please re-enter master password.",
        canRetry: true,
        action: "re-enter password",
      );
    } catch (e) {
      throw StorageError('Salt could not be read: $e');
    }
  }

  Future<void> saveMasterPasswordVerifier(String verifier) async {
    try {
      await _storage.write(key: _masterPasswordVerifierKey, value: verifier);
    } on PlatformException catch (e) {
      throw StorageError(
        'Platform error saving verifier: $e',
        userMessage:
            "Couldn't access secure storage. Please re-enter master password.",
        canRetry: true,
        action: "re-enter password",
      );
    } catch (e) {
      throw StorageError('Master password verifier could not be saved: $e');
    }
  }

  Future<String?> getMasterPasswordVerifier() async {
    try {
      return await _storage.read(key: _masterPasswordVerifierKey);
    } on PlatformException catch (e) {
      throw StorageError(
        'Platform error reading verifier: $e',
        userMessage:
            "Couldn't access secure storage. Please re-enter master password.",
        canRetry: true,
        action: "re-enter password",
      );
    } catch (e) {
      throw StorageError('Master password verifier could not be read: $e');
    }
  }

  Future<void> saveRecoveryBundle(String bundle) async {
    try {
      await _storage.write(key: _recoveryBundleKey, value: bundle);
    } on PlatformException catch (e) {
      throw StorageError(
        'Platform error saving recovery bundle: $e',
        userMessage:
            "Couldn't access secure storage. Please re-enter master password.",
        canRetry: true,
        action: "re-enter password",
      );
    } catch (e) {
      throw StorageError('Recovery bundle could not be saved: $e');
    }
  }

  Future<String?> getRecoveryBundle() async {
    try {
      return await _storage.read(key: _recoveryBundleKey);
    } on PlatformException catch (e) {
      throw StorageError(
        'Platform error reading recovery bundle: $e',
        userMessage:
            "Couldn't access secure storage. Please re-enter master password.",
        canRetry: true,
        action: "re-enter password",
      );
    } catch (e) {
      throw StorageError('Recovery bundle could not be read: $e');
    }
  }

  /// Deletes login material but keeps recovery bundle for later restore.
  Future<void> deleteVaultAccessData() async {
    try {
      await _storage.delete(key: _dbKeyPrefix);
      await _storage.delete(key: _saltKey);
      await _storage.delete(key: _masterPasswordVerifierKey);
    } on PlatformException catch (e) {
      throw StorageError(
        'Platform error deleting vault keys: $e',
        userMessage:
            "Couldn't access secure storage. Please re-enter master password.",
        canRetry: true,
        action: "re-enter password",
      );
    } catch (e) {
      throw StorageError('Vault access keys could not be deleted: $e');
    }
  }

  /// Deletes every secure storage key.
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } on PlatformException catch (e) {
      throw StorageError(
        'Platform error deleting all keys: $e',
        userMessage:
            "Couldn't access secure storage. Please re-enter master password.",
        canRetry: true,
        action: "re-enter password",
      );
    } catch (e) {
      throw StorageError('Could not delete all keys: $e');
    }
  }
}

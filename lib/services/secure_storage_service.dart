import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../errors/app_errors.dart';
import '../i18n/strings.g.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _dbKey = 'guarden_db_encryption_key';
  static const String _saltKey = 'guarden_crypto_salt';
  static const String _masterPasswordVerifierKey =
      'guarden_master_password_verifier';
  static const String _recoveryBundleKey = 'guarden_recovery_bundle_v1';

  Future<void> saveEncryptionKey(String base64Key) async {
    try {
      await _storage.write(key: _dbKey, value: base64Key);
    } on PlatformException catch (e) {
      throw _platformStorageError('saving key', e);
    } catch (e) {
      throw StorageError(
        'Key could not be saved: $e',
        userMessage: t.settings.errors.storage_access_failed,
      );
    }
  }

  Future<String?> getEncryptionKey() async {
    try {
      return await _storage.read(key: _dbKey);
    } on PlatformException catch (e) {
      throw _platformStorageError('reading key', e);
    } catch (e) {
      throw StorageError(
        'Secure storage is not accessible: $e',
        userMessage: t.settings.errors.storage_access_failed,
      );
    }
  }

  Future<void> saveSalt(String salt) async {
    try {
      await _storage.write(key: _saltKey, value: salt);
    } on PlatformException catch (e) {
      throw _platformStorageError('saving salt', e);
    } catch (e) {
      throw StorageError('Salt could not be saved: $e');
    }
  }

  Future<String?> getSalt() async {
    try {
      return await _storage.read(key: _saltKey);
    } on PlatformException catch (e) {
      throw _platformStorageError('reading salt', e);
    } catch (e) {
      throw StorageError('Salt could not be read: $e');
    }
  }

  Future<void> saveMasterPasswordVerifier(String verifier) async {
    try {
      await _storage.write(key: _masterPasswordVerifierKey, value: verifier);
    } on PlatformException catch (e) {
      throw _platformStorageError('saving verifier', e);
    } catch (e) {
      throw StorageError('Master password verifier could not be saved: $e');
    }
  }

  Future<String?> getMasterPasswordVerifier() async {
    try {
      return await _storage.read(key: _masterPasswordVerifierKey);
    } on PlatformException catch (e) {
      throw _platformStorageError('reading verifier', e);
    } catch (e) {
      throw StorageError('Master password verifier could not be read: $e');
    }
  }

  Future<void> saveRecoveryBundle(String bundle) async {
    try {
      await _storage.write(key: _recoveryBundleKey, value: bundle);
    } on PlatformException catch (e) {
      throw _platformStorageError('saving recovery bundle', e);
    } catch (e) {
      throw StorageError('Recovery bundle could not be saved: $e');
    }
  }

  Future<String?> getRecoveryBundle() async {
    try {
      return await _storage.read(key: _recoveryBundleKey);
    } on PlatformException catch (e) {
      throw _platformStorageError('reading recovery bundle', e);
    } catch (e) {
      throw StorageError('Recovery bundle could not be read: $e');
    }
  }

  /// Deletes login material but keeps recovery bundle for later restore.
  Future<void> deleteVaultAccessData() async {
    try {
      await _storage.delete(key: _dbKey);
      await _storage.delete(key: _saltKey);
      await _storage.delete(key: _masterPasswordVerifierKey);
    } on PlatformException catch (e) {
      throw _platformStorageError('deleting vault keys', e);
    } catch (e) {
      throw StorageError('Vault access keys could not be deleted: $e');
    }
  }

  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } on PlatformException catch (e) {
      throw _platformStorageError('deleting all keys', e);
    } catch (e) {
      throw StorageError('Could not delete all keys: $e');
    }
  }

  /// Generic method to save a value with any key
  Future<void> writeValue(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on PlatformException catch (e) {
      throw _platformStorageError('writing value', e);
    } catch (e) {
      throw StorageError('Value could not be saved: $e');
    }
  }

  /// Generic method to read a value by key
  Future<String?> readValue(String key) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException catch (e) {
      throw _platformStorageError('reading value', e);
    } catch (e) {
      throw StorageError('Value could not be read: $e');
    }
  }

  /// Generic method to delete a value by key
  Future<void> deleteValue(String key) async {
    try {
      await _storage.delete(key: key);
    } on PlatformException catch (e) {
      throw _platformStorageError('deleting value', e);
    } catch (e) {
      throw StorageError('Value could not be deleted: $e');
    }
  }

  StorageError _platformStorageError(String action, PlatformException e) {
    return StorageError(
      'Platform error $action: $e',
      userMessage: t.settings.errors.storage_access_failed,
      canRetry: true,
      action: 're-enter password',
    );
  }
}

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'secure_storage_service.dart';
import '../models/bank_account.dart';
import '../models/subscription.dart';
import '../models/web_password.dart';
import '../errors/app_errors.dart';
import '../i18n/strings.g.dart';

final databaseProvider = Provider<DatabaseService>((ref) {
  final secureStorage = ref.read(secureStorageProvider);
  return DatabaseService(secureStorage);
});

class DatabaseService {
  final SecureStorageService _secureStorage;
  bool _isInitialized = false;

  DatabaseService(this._secureStorage);

  static const String bankAccountsBoxName = 'bank_accounts';
  static const String subscriptionsBoxName = 'subscriptions';
  static const String webPasswordsBoxName = 'web_passwords';

  /// Hive'Ä± baÅŸlatÄ±r ve gÃ¼venli kutularÄ± (Boxes) aÃ§ar.
  ///
  /// Not: Hive.initFlutter() main.dart'ta Ã§aÄŸrÄ±lÄ±r, burada tekrar Ã§aÄŸrÄ±lmaz.
  Future<void> initDatabase() async {
    if (_isInitialized) return;

    try {
      // Hive.initFlutter() main.dart'ta zaten Ã§aÄŸrÄ±ldÄ±
      // await Hive.initFlutter(); // KALDIRILDI - redundant

      // Type Adapter kayÄ±tlarÄ± (Daha Ã¶nce kaydedilmemiÅŸse)
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(BankAccountAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(SubscriptionAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(WebPasswordAdapter());
      }

      // 1. Storage'dan ÅŸifreleme key'ini al
      String? encryptionKeyBase64 = await _secureStorage.getEncryptionKey();

      if (encryptionKeyBase64 == null) {
        throw StorageError(
          'DB encryption key was not found. Please set a master password.',
        );
      }

      final encryptionKey = base64Decode(
        encryptionKeyBase64,
      ); // base64Decode kullanÄ±lmalÄ±

      // 3. AES ÅŸifreli olarak kutularÄ± aÃ§
      final cipher = HiveAesCipher(encryptionKey);
      await Hive.openBox<BankAccount>(
        bankAccountsBoxName,
        encryptionCipher: cipher,
      );
      await Hive.openBox<Subscription>(
        subscriptionsBoxName,
        encryptionCipher: cipher,
      );
      await Hive.openBox<WebPassword>(
        webPasswordsBoxName,
        encryptionCipher: cipher,
      );

      _isInitialized = true;
    } on HiveError catch (e) {
      throw DatabaseError(
        'Hive init failed: $e',
        userMessage: t.settings.errors.db_open_failed,
        canRetry: true,
        action: 'retry',
      );
    } on StorageError {
      rethrow;
    } catch (e) {
      throw DatabaseError(
        'Database initialization failed: $e',
        userMessage: t.settings.errors.db_open_failed,
      );
    }
  }

  Box<BankAccount> get bankAccountsBox {
    if (!_isInitialized) {
      throw DatabaseError(
        'Database not initialized',
        userMessage: t.settings.errors.db_not_ready,
      );
    }
    return Hive.box<BankAccount>(bankAccountsBoxName);
  }

  Box<Subscription> get subscriptionsBox {
    if (!_isInitialized) {
      throw DatabaseError(
        'Database not initialized',
        userMessage: t.settings.errors.db_not_ready,
      );
    }
    return Hive.box<Subscription>(subscriptionsBoxName);
  }

  Box<WebPassword> get webPasswordsBox {
    if (!_isInitialized) {
      throw DatabaseError(
        'Database not initialized',
        userMessage: t.settings.errors.db_not_ready,
      );
    }
    return Hive.box<WebPassword>(webPasswordsBoxName);
  }

  /// Tüm kutuları kapatır (Lock Vault)
  Future<void> closeDatabase() async {
    try {
      await Hive.close(); // Kapatılan tüm kutuları kapatır
      _isInitialized = false;
    } catch (e) {
      throw DatabaseError(
        'Failed to close database: $e',
        userMessage: t.settings.errors.generic,
      );
    }
  }

  /// Bütün verileri siler (Panic Mode / Reset)
  Future<void> deleteDatabase() async {
    try {
      await Hive.close(); // Boxes must be closed before deletion
      await Hive.deleteBoxFromDisk(bankAccountsBoxName);
      await Hive.deleteBoxFromDisk(subscriptionsBoxName);
      await Hive.deleteBoxFromDisk(webPasswordsBoxName);
      await Hive.deleteBoxFromDisk('settings_box');
      _isInitialized = false;
    } catch (e) {
      throw DatabaseError(
        'Failed to delete database: $e',
        userMessage: t.settings.errors.generic,
      );
    }
  }
}

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'secure_storage_service.dart';
import '../models/bank_account.dart';
import '../models/subscription.dart';
import '../models/web_password.dart';
import '../models/activity.dart';
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
  static const String activitiesBoxName = 'activities';

  /// Hive'ı başlatır ve güvenli kutuları (Boxes) açar.
  ///
  /// Not: Hive.initFlutter() main.dart'ta çağrılır, burada tekrar çağrılmaz.
  Future<void> initDatabase() async {
    if (_isInitialized) return;

    try {
      if (_areVaultBoxesOpen()) {
        _isInitialized = true;
        return;
      }

      // Type Adapter kayıtları (Daha önce kaydedilmemişse)
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(BankAccountAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(SubscriptionAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(WebPasswordAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(ActivityAdapter());
      }

      // 1. Storage'dan şifreleme key'ini al
      String? encryptionKeyBase64 = await _secureStorage.getEncryptionKey();

      if (encryptionKeyBase64 == null) {
        throw StorageError(
          'DB encryption key was not found. Please set a master password.',
        );
      }

      final encryptionKey = base64Decode(encryptionKeyBase64);

      final cipher = HiveAesCipher(encryptionKey);
      await Future.wait([
        Hive.openBox<BankAccount>(
          bankAccountsBoxName,
          encryptionCipher: cipher,
        ),
        Hive.openBox<Subscription>(
          subscriptionsBoxName,
          encryptionCipher: cipher,
        ),
        Hive.openBox<WebPassword>(
          webPasswordsBoxName,
          encryptionCipher: cipher,
        ),
        Hive.openBox<Activity>(activitiesBoxName, encryptionCipher: cipher),
      ]);

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
    _restoreInitializationFromOpenBoxes();
    if (!_isInitialized) {
      throw DatabaseError(
        'Database not initialized',
        userMessage: t.settings.errors.db_not_ready,
      );
    }
    return Hive.box<BankAccount>(bankAccountsBoxName);
  }

  Box<Subscription> get subscriptionsBox {
    _restoreInitializationFromOpenBoxes();
    if (!_isInitialized) {
      throw DatabaseError(
        'Database not initialized',
        userMessage: t.settings.errors.db_not_ready,
      );
    }
    return Hive.box<Subscription>(subscriptionsBoxName);
  }

  Box<WebPassword> get webPasswordsBox {
    _restoreInitializationFromOpenBoxes();
    if (!_isInitialized) {
      throw DatabaseError(
        'Database not initialized',
        userMessage: t.settings.errors.db_not_ready,
      );
    }
    return Hive.box<WebPassword>(webPasswordsBoxName);
  }

  Box<Activity> get activitiesBox {
    _restoreInitializationFromOpenBoxes();
    if (!_isInitialized) {
      throw DatabaseError(
        'Database not initialized',
        userMessage: t.settings.errors.db_not_ready,
      );
    }
    return Hive.box<Activity>(activitiesBoxName);
  }

  /// Settings box for migration flags and general settings
  Box get settingsBox {
    if (!Hive.isBoxOpen('settings_box')) {
      throw DatabaseError(
        'Settings box not initialized',
        userMessage: t.settings.errors.db_not_ready,
      );
    }
    return Hive.box('settings_box');
  }

  /// Tüm kutuları kapatır (Lock Vault)
  Future<void> closeDatabase() async {
    try {
      await Hive.close();
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
      await Hive.close();
      await Hive.deleteBoxFromDisk(bankAccountsBoxName);
      await Hive.deleteBoxFromDisk(subscriptionsBoxName);
      await Hive.deleteBoxFromDisk(webPasswordsBoxName);
      await Hive.deleteBoxFromDisk(activitiesBoxName);
      await Hive.deleteBoxFromDisk('settings_box');
      _isInitialized = false;
    } catch (e) {
      throw DatabaseError(
        'Failed to delete database: $e',
        userMessage: t.settings.errors.generic,
      );
    }
  }

  void _restoreInitializationFromOpenBoxes() {
    if (_isInitialized) {
      return;
    }

    if (_areVaultBoxesOpen()) {
      _isInitialized = true;
    }
  }

  bool _areVaultBoxesOpen() {
    return Hive.isBoxOpen(bankAccountsBoxName) &&
        Hive.isBoxOpen(subscriptionsBoxName) &&
        Hive.isBoxOpen(webPasswordsBoxName) &&
        Hive.isBoxOpen(activitiesBoxName);
  }
}

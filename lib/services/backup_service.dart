import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bank_account.dart';
import '../models/subscription.dart';
import '../models/web_password.dart';
import 'crypto_service.dart';
import 'database_service.dart';
import '../errors/app_errors.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  final database = ref.read(databaseProvider);
  final crypto = ref.read(cryptoProvider);
  return BackupService(databaseService: database, cryptoService: crypto);
});

class BackupException implements Exception {
  final String message;
  BackupException(this.message);

  @override
  String toString() => 'BackupException: $message';
}

class BackupDecodedPayload {
  final int version;
  final DateTime createdAt;
  final Map<String, dynamic> data;

  BackupDecodedPayload({
    required this.version,
    required this.createdAt,
    required this.data,
  });
}

class BackupDryRunReport {
  final int bankIncoming;
  final int bankConflicts;
  final int subscriptionIncoming;
  final int subscriptionConflicts;
  final int webIncoming;
  final int webConflicts;

  BackupDryRunReport({
    required this.bankIncoming,
    required this.bankConflicts,
    required this.subscriptionIncoming,
    required this.subscriptionConflicts,
    required this.webIncoming,
    required this.webConflicts,
  });

  int get totalIncoming => bankIncoming + subscriptionIncoming + webIncoming;
  int get totalConflicts =>
      bankConflicts + subscriptionConflicts + webConflicts;
  int get totalNew => totalIncoming - totalConflicts;
}

class BackupApplyResult {
  final int created;
  final int overwritten;
  final int skipped;

  BackupApplyResult({
    required this.created,
    required this.overwritten,
    required this.skipped,
  });

  int get processed => created + overwritten + skipped;
}

class BackupService {
  final DatabaseService? _databaseService;
  final CryptoService _cryptoService;

  BackupService({
    DatabaseService? databaseService,
    CryptoService? cryptoService,
  }) : _databaseService = databaseService,
       _cryptoService = cryptoService ?? CryptoService();

  Future<String> encryptBackupData({
    required String passphrase,
    required Map<String, dynamic> data,
  }) async {
    _validatePassphrase(passphrase);

    final payload = <String, dynamic>{
      'version': 1,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'data': data,
      'checksum': _sha256Hex(jsonEncode(data)),
    };

    final salt = _generateSalt();
    final key = await _cryptoService.deriveKey(passphrase, salt);
    final cipher = await _cryptoService.encryptText(jsonEncode(payload), key);

    final envelope = <String, dynamic>{
      'format': 'guarden-backup-v1',
      'kdf': 'pbkdf2-sha256-100000',
      'salt': salt,
      'cipher': cipher,
    };

    return jsonEncode(envelope);
  }

  Future<BackupDecodedPayload> decryptBackupData({
    required String encryptedBackup,
    required String passphrase,
  }) async {
    _validatePassphrase(passphrase);

    late final Map<String, dynamic> envelope;
    try {
      final decoded = jsonDecode(encryptedBackup);
      if (decoded is! Map<String, dynamic>) {
        throw BackupException('Backup formati gecersiz.');
      }
      envelope = decoded;
    } on FormatException {
      throw BackupException('Backup JSON formati gecersiz.');
    }

    final format = envelope['format'];
    final salt = envelope['salt'];
    final cipher = envelope['cipher'];
    if (format != 'guarden-backup-v1' || salt is! String || cipher is! String) {
      throw BackupException('Backup envelope alanlari eksik veya hatali.');
    }

    late final String payloadJson;
    try {
      final key = await _cryptoService.deriveKey(passphrase, salt);
      payloadJson = await _cryptoService.decryptText(cipher, key);
    } catch (_) {
      throw BackupException('Backup sifresi hatali veya dosya bozuk.');
    }

    late final Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(payloadJson);
      if (decoded is! Map<String, dynamic>) {
        throw BackupException('Payload formati gecersiz.');
      }
      payload = decoded;
    } on FormatException {
      throw BackupException('Payload JSON formati gecersiz.');
    }

    final version = payload['version'];
    final createdAtRaw = payload['created_at'];
    final dataRaw = payload['data'];
    final checksum = payload['checksum'];

    if (version is! int ||
        dataRaw is! Map<String, dynamic> ||
        checksum is! String) {
      throw BackupException('Payload alanlari eksik veya hatali.');
    }

    final expectedChecksum = _sha256Hex(jsonEncode(dataRaw));
    if (!_constantTimeEquals(checksum, expectedChecksum)) {
      throw BackupException('Checksum dogrulamasi basarisiz.');
    }

    DateTime createdAt;
    if (createdAtRaw is String) {
      createdAt =
          DateTime.tryParse(createdAtRaw)?.toUtc() ?? DateTime.now().toUtc();
    } else {
      createdAt = DateTime.now().toUtc();
    }

    return BackupDecodedPayload(
      version: version,
      createdAt: createdAt,
      data: dataRaw,
    );
  }

  Future<String> exportEncryptedBackup({required String passphrase}) async {
    try {
      final database = _databaseService;
      if (database == null) {
        throw BackupException('Veritabani servisi bagli degil.');
      }

      final data = <String, dynamic>{
        'bank_accounts': database.bankAccountsBox.values
            .map(_bankToJson)
            .toList(growable: false),
        'subscriptions': database.subscriptionsBox.values
            .map(_subscriptionToJson)
            .toList(growable: false),
        'web_passwords': database.webPasswordsBox.values
            .map(_webPasswordToJson)
            .toList(growable: false),
      };

      return await encryptBackupData(passphrase: passphrase, data: data);
    } catch (e) {
      if (e is BackupException || e is CryptoError) {
        rethrow; // Allow direct failures to surface
      }
      throw DatabaseError(
        'Backup export failed: $e',
        userMessage: "Couldn't export backup. Check storage space.",
      );
    }
  }

  Future<BackupDryRunReport> dryRunRestore({
    required String encryptedBackup,
    required String passphrase,
  }) async {
    try {
      final database = _databaseService;
      if (database == null) {
        throw BackupException('Veritabani servisi bagli degil.');
      }

      final decoded = await decryptBackupData(
        encryptedBackup: encryptedBackup,
        passphrase: passphrase,
      );

      final banks = _parseBankAccounts(decoded.data);
      final subscriptions = _parseSubscriptions(decoded.data);
      final webPasswords = _parseWebPasswords(decoded.data);

      final bankConflicts = banks
          .where((item) => database.bankAccountsBox.containsKey(item.id))
          .length;
      final subscriptionConflicts = subscriptions
          .where((item) => database.subscriptionsBox.containsKey(item.id))
          .length;
      final webConflicts = webPasswords
          .where((item) => database.webPasswordsBox.containsKey(item.id))
          .length;

      return BackupDryRunReport(
        bankIncoming: banks.length,
        bankConflicts: bankConflicts,
        subscriptionIncoming: subscriptions.length,
        subscriptionConflicts: subscriptionConflicts,
        webIncoming: webPasswords.length,
        webConflicts: webConflicts,
      );
    } catch (e) {
      if (e is BackupException || e is CryptoError) rethrow;
      throw DatabaseError(
        'Backup dry run failed: $e',
        userMessage: "Couldn't read backup data.",
      );
    }
  }

  Future<BackupApplyResult> applyRestore({
    required String encryptedBackup,
    required String passphrase,
    required bool overwriteConflicts,
  }) async {
    try {
      final database = _databaseService;
      if (database == null) {
        throw BackupException('Veritabani servisi bagli degil.');
      }

      final decoded = await decryptBackupData(
        encryptedBackup: encryptedBackup,
        passphrase: passphrase,
      );

      final banks = _parseBankAccounts(decoded.data);
      final subscriptions = _parseSubscriptions(decoded.data);
      final webPasswords = _parseWebPasswords(decoded.data);

      var created = 0;
      var overwritten = 0;
      var skipped = 0;

      for (final item in banks) {
        final exists = database.bankAccountsBox.containsKey(item.id);
        if (exists && !overwriteConflicts) {
          skipped++;
          continue;
        }
        await database.bankAccountsBox.put(item.id, item);
        if (exists) {
          overwritten++;
        } else {
          created++;
        }
      }

      for (final item in subscriptions) {
        final exists = database.subscriptionsBox.containsKey(item.id);
        if (exists && !overwriteConflicts) {
          skipped++;
          continue;
        }
        await database.subscriptionsBox.put(item.id, item);
        if (exists) {
          overwritten++;
        } else {
          created++;
        }
      }

      for (final item in webPasswords) {
        final exists = database.webPasswordsBox.containsKey(item.id);
        if (exists && !overwriteConflicts) {
          skipped++;
          continue;
        }
        await database.webPasswordsBox.put(item.id, item);
        if (exists) {
          overwritten++;
        } else {
          created++;
        }
      }

      return BackupApplyResult(
        created: created,
        overwritten: overwritten,
        skipped: skipped,
      );
    } catch (e) {
      if (e is BackupException || e is CryptoError) rethrow;
      throw DatabaseError(
        'Backup restore failed: $e',
        userMessage: "Couldn't restore backup. File may be corrupted.",
      );
    }
  }

  List<BankAccount> _parseBankAccounts(Map<String, dynamic> data) {
    final rawList = data['bank_accounts'];
    if (rawList is! List) return const [];

    return rawList
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(_bankFromJson)
        .toList(growable: false);
  }

  List<Subscription> _parseSubscriptions(Map<String, dynamic> data) {
    final rawList = data['subscriptions'];
    if (rawList is! List) return const [];

    return rawList
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(_subscriptionFromJson)
        .toList(growable: false);
  }

  List<WebPassword> _parseWebPasswords(Map<String, dynamic> data) {
    final rawList = data['web_passwords'];
    if (rawList is! List) return const [];

    return rawList
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(_webPasswordFromJson)
        .toList(growable: false);
  }

  Map<String, dynamic> _bankToJson(BankAccount item) {
    return {
      'id': item.id,
      'bank_name': item.bankName,
      'url': item.url,
      'account_name': item.accountName,
      'encrypted_password': item.encryptedPassword,
      'encrypted_notes': item.encryptedNotes,
      'period_months': item.periodMonths,
      'last_changed_at': item.lastChangedAt.toUtc().toIso8601String(),
      'created_at': item.createdAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> _subscriptionToJson(Subscription item) {
    return {
      'id': item.id,
      'service_name': item.serviceName,
      'url': item.url,
      'email_or_username': item.emailOrUsername,
      'encrypted_password': item.encryptedPassword,
      'monthly_cost': item.monthlyCost,
      'currency': item.currency,
      'next_billing_date': item.nextBillingDate.toUtc().toIso8601String(),
      'created_at': item.createdAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> _webPasswordToJson(WebPassword item) {
    return {
      'id': item.id,
      'title': item.title,
      'url': item.url,
      'username': item.username,
      'encrypted_password': item.encryptedPassword,
      'encrypted_notes': item.encryptedNotes,
      'created_at': item.createdAt.toUtc().toIso8601String(),
      'updated_at': item.updatedAt.toUtc().toIso8601String(),
    };
  }

  BankAccount _bankFromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] as String,
      bankName: json['bank_name'] as String,
      url: (json['url'] as String?) ?? '',
      accountName: (json['account_name'] as String?) ?? '',
      encryptedPassword: (json['encrypted_password'] as String?) ?? '',
      encryptedNotes: (json['encrypted_notes'] as String?) ?? '',
      periodMonths: (json['period_months'] as int?) ?? 6,
      lastChangedAt: DateTime.parse(
        json['last_changed_at'] as String,
      ).toLocal(),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  Subscription _subscriptionFromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      serviceName: json['service_name'] as String,
      url: (json['url'] as String?) ?? '',
      emailOrUsername: (json['email_or_username'] as String?) ?? '',
      encryptedPassword: (json['encrypted_password'] as String?) ?? '',
      monthlyCost: (json['monthly_cost'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] as String?) ?? 'TRY',
      nextBillingDate: DateTime.parse(
        json['next_billing_date'] as String,
      ).toLocal(),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  WebPassword _webPasswordFromJson(Map<String, dynamic> json) {
    return WebPassword(
      id: json['id'] as String,
      title: json['title'] as String,
      url: (json['url'] as String?) ?? '',
      username: (json['username'] as String?) ?? '',
      encryptedPassword: (json['encrypted_password'] as String?) ?? '',
      encryptedNotes: (json['encrypted_notes'] as String?) ?? '',
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
    );
  }

  void _validatePassphrase(String passphrase) {
    if (passphrase.trim().length < 8) {
      throw BackupException('Backup sifresi en az 8 karakter olmali.');
    }
  }

  String _generateSalt({int length = 32}) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _sha256Hex(String input) {
    return sha256.convert(utf8.encode(input)).toString();
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

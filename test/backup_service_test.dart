import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:guarden/services/backup_service.dart';
import 'package:guarden/services/crypto_service.dart';

void main() {
  group('BackupService codec', () {
    final service = BackupService();

    const passphrase = 'StrongBackup123!';
    final sampleData = <String, dynamic>{
      'bank_accounts': [
        {
          'id': 'bank-1',
          'bank_name': 'Test Bank',
          'url': '',
          'account_name': 'user-1',
          'encrypted_password': 'enc-pass',
          'encrypted_notes': 'enc-note',
          'period_months': 6,
          'last_changed_at': DateTime.utc(2026, 1, 1).toIso8601String(),
          'created_at': DateTime.utc(2026, 1, 1).toIso8601String(),
        },
      ],
      'subscriptions': [
        {
          'id': 'sub-1',
          'service_name': 'Netflix',
          'url': '',
          'email_or_username': 'mail@test.com',
          'encrypted_password': 'enc-sub-pass',
          'monthly_cost': 99.9,
          'currency': 'TRY',
          'next_billing_date': DateTime.utc(2026, 2, 1).toIso8601String(),
          'created_at': DateTime.utc(2026, 1, 1).toIso8601String(),
        },
      ],
      'web_passwords': [
        {
          'id': 'web-1',
          'title': 'Github',
          'url': 'github.com',
          'username': 'dev',
          'encrypted_password': 'enc-web-pass',
          'encrypted_notes': 'enc-web-note',
          'created_at': DateTime.utc(2026, 1, 1).toIso8601String(),
          'updated_at': DateTime.utc(2026, 2, 1).toIso8601String(),
        },
      ],
    };

    test('encrypt/decrypt roundtrip keeps payload data', () async {
      final encrypted = await service.encryptBackupData(
        passphrase: passphrase,
        data: sampleData,
      );

      final decoded = await service.decryptBackupData(
        encryptedBackup: encrypted,
        passphrase: passphrase,
      );

      expect(decoded.version, 1);
      expect(decoded.data, sampleData);
    });

    test('decrypt fails with wrong passphrase', () async {
      final encrypted = await service.encryptBackupData(
        passphrase: passphrase,
        data: sampleData,
      );

      expect(
        () => service.decryptBackupData(
          encryptedBackup: encrypted,
          passphrase: 'WrongPass123!',
        ),
        throwsA(isA<BackupException>()),
      );
    });

    test('checksum mismatch is detected', () async {
      final encrypted = await service.encryptBackupData(
        passphrase: passphrase,
        data: sampleData,
      );

      final envelope = jsonDecode(encrypted) as Map<String, dynamic>;
      final salt = envelope['salt'] as String;
      final cipher = envelope['cipher'] as String;

      final crypto = CryptoService();
      final key = await crypto.deriveKey(passphrase, salt);
      final payloadJson = await crypto.decryptText(cipher, key);
      final payload = jsonDecode(payloadJson) as Map<String, dynamic>;

      payload['checksum'] = 'invalid-checksum';
      envelope['cipher'] = await crypto.encryptText(jsonEncode(payload), key);

      final tamperedBackup = jsonEncode(envelope);

      expect(
        () => service.decryptBackupData(
          encryptedBackup: tamperedBackup,
          passphrase: passphrase,
        ),
        throwsA(isA<BackupException>()),
      );
    });
  });
}

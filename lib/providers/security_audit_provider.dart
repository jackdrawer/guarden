import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/crypto_service.dart';
import '../services/secure_storage_service.dart';
import 'bank_account_provider.dart';
import 'subscription_provider.dart';
import 'web_password_provider.dart';

class VulnerableItem {
  final String id;
  final String title;
  final String type;
  String reason;

  VulnerableItem({
    required this.id,
    required this.title,
    required this.type,
    required this.reason,
  });
}

class SecurityAuditReport {
  final int totalChecked;
  final int weakCount;
  final int duplicatedCount;
  final List<VulnerableItem> vulnerableItems;
  final int score;

  SecurityAuditReport({
    required this.totalChecked,
    required this.weakCount,
    required this.duplicatedCount,
    required this.vulnerableItems,
    required this.score,
  });
}

class _DecryptedItem {
  final String id;
  final String title;
  final String type;
  final String plaintext;

  _DecryptedItem(this.id, this.title, this.type, this.plaintext);
}

final securityAuditProvider = FutureProvider.autoDispose<SecurityAuditReport>((
  ref,
) async {
  final cryptoService = ref.read(cryptoProvider);
  final secureStorage = ref.read(secureStorageProvider);

  final banksAsync = ref.watch(bankAccountProvider);
  final websAsync = ref.watch(webPasswordProvider);
  final subsAsync = ref.watch(subscriptionProvider);

  final banks = banksAsync.valueOrNull ?? [];
  final webs = websAsync.valueOrNull ?? [];
  final subs = subsAsync.valueOrNull ?? [];

  final base64Key = await secureStorage.getEncryptionKey();
  if (base64Key == null || base64Key.isEmpty) {
    throw Exception('Encryption key not found.');
  }

  var totalChecked = 0;
  final vulnerableItems = <VulnerableItem>[];
  final passwordGroups = <String, List<_DecryptedItem>>{};

  Future<void> processItem(
    String encrypted,
    String id,
    String title,
    String type,
  ) async {
    if (encrypted.isEmpty) {
      return;
    }

    totalChecked++;

    try {
      final decrypted = await cryptoService.decryptWithBase64Key(
        encrypted,
        base64Key,
      );

      var isWeak = false;
      if (decrypted.length < 8) {
        isWeak = true;
      }
      if (!decrypted.contains(RegExp(r'[0-9]'))) {
        isWeak = true;
      }
      if (!decrypted.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
        isWeak = true;
      }

      final item = _DecryptedItem(id, title, type, decrypted);
      if (isWeak) {
        vulnerableItems.add(
          VulnerableItem(
            id: id,
            title: title,
            type: type,
            reason: 'Weak password',
          ),
        );
      }

      passwordGroups.putIfAbsent(decrypted, () => <_DecryptedItem>[]).add(item);
    } catch (_) {
      // Ignore single item decrypt failures during audit.
    }
  }

  for (final item in banks) {
    await processItem(item.encryptedPassword, item.id, item.bankName, 'bank');
  }

  for (final item in webs) {
    await processItem(item.encryptedPassword, item.id, item.title, 'web');
  }

  for (final item in subs) {
    await processItem(
      item.encryptedPassword,
      item.id,
      item.serviceName,
      'subscription',
    );
  }

  var duplicatedCount = 0;
  passwordGroups.forEach((_, items) {
    if (items.length <= 1) {
      return;
    }

    duplicatedCount += items.length;
    for (final item in items) {
      final existingIndex = vulnerableItems.indexWhere((v) => v.id == item.id);
      if (existingIndex != -1) {
        vulnerableItems[existingIndex].reason += ', reused';
      } else {
        vulnerableItems.add(
          VulnerableItem(
            id: item.id,
            title: item.title,
            type: item.type,
            reason: 'Reused password',
          ),
        );
      }
    }
  });

  final weakCount = vulnerableItems
      .where((v) => v.reason.toLowerCase().contains('weak'))
      .length;

  final penalty = (weakCount * 10) + (duplicatedCount * 5);
  var score = 100 - penalty;
  if (score < 0) {
    score = 0;
  }
  if (totalChecked == 0) {
    score = 100;
  }

  return SecurityAuditReport(
    totalChecked: totalChecked,
    weakCount: weakCount,
    duplicatedCount: duplicatedCount,
    vulnerableItems: vulnerableItems,
    score: score,
  );
});

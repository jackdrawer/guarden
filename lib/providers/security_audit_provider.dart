import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/strings.g.dart';
import '../services/crypto_service.dart';
import '../services/secure_storage_service.dart';
import 'bank_account_provider.dart';
import 'subscription_provider.dart';
import 'web_password_provider.dart';

class VulnerableItem {
  const VulnerableItem({
    required this.id,
    required this.title,
    required this.type,
    this.hasWeakPassword = false,
    this.hasReusedPassword = false,
  });

  final String id;
  final String title;
  final String type;
  final bool hasWeakPassword;
  final bool hasReusedPassword;

  String get reason {
    if (hasWeakPassword && hasReusedPassword) {
      return t.security_audit.reason_weak_and_reused;
    }
    if (hasWeakPassword) {
      return t.security_audit.reason_weak_password;
    }
    return t.security_audit.reason_reused_password;
  }

  VulnerableItem copyWith({
    bool? hasWeakPassword,
    bool? hasReusedPassword,
  }) {
    return VulnerableItem(
      id: id,
      title: title,
      type: type,
      hasWeakPassword: hasWeakPassword ?? this.hasWeakPassword,
      hasReusedPassword: hasReusedPassword ?? this.hasReusedPassword,
    );
  }
}

class SecurityAuditReport {
  const SecurityAuditReport({
    required this.totalChecked,
    required this.weakCount,
    required this.duplicatedCount,
    required this.vulnerableItems,
    required this.score,
  });

  final int totalChecked;
  final int weakCount;
  final int duplicatedCount;
  final List<VulnerableItem> vulnerableItems;
  final int score;
}

class _DecryptedItem {
  const _DecryptedItem(this.id, this.title, this.type, this.hash);

  final String id;
  final String title;
  final String type;
  final String hash;
}

class SecurityAuditNotifier extends AutoDisposeAsyncNotifier<SecurityAuditReport> {
  String? _lastVaultSignature;
  SecurityAuditReport? _cachedReport;

  @override
  Future<SecurityAuditReport> build() async {
    final cryptoService = ref.read(cryptoProvider);
    final secureStorage = ref.read(secureStorageProvider);

    final banks = ref.watch(bankAccountProvider).valueOrNull ?? [];
    final webs = ref.watch(webPasswordProvider).valueOrNull ?? [];
    final subs = ref.watch(subscriptionProvider).valueOrNull ?? [];

    final vaultSignature = _buildVaultSignature(banks, webs, subs);
    if (_cachedReport != null && _lastVaultSignature == vaultSignature) {
      return _cachedReport!;
    }

    final base64Key = await secureStorage.getEncryptionKey();
    if (base64Key == null || base64Key.isEmpty) {
      throw Exception(t.settings.errors.encryption_key_missing);
    }

    var totalChecked = 0;
    final vulnerableById = <String, VulnerableItem>{};
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

        if (_isWeakPassword(decrypted)) {
          vulnerableById[id] = VulnerableItem(
            id: id,
            title: title,
            type: type,
            hasWeakPassword: true,
            hasReusedPassword: vulnerableById[id]?.hasReusedPassword ?? false,
          );
        }

        final hashBytes = sha256.convert(utf8.encode(decrypted)).bytes;
        final hashBase64 = base64Encode(hashBytes);
        passwordGroups.putIfAbsent(hashBase64, () => <_DecryptedItem>[]).add(
          _DecryptedItem(id, title, type, hashBase64),
        );
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
    for (final items in passwordGroups.values) {
      if (items.length <= 1) {
        continue;
      }

      duplicatedCount += items.length;
      for (final item in items) {
        final existing = vulnerableById[item.id];
        vulnerableById[item.id] = (existing ??
                VulnerableItem(id: item.id, title: item.title, type: item.type))
            .copyWith(hasReusedPassword: true);
      }
    }

    final vulnerableItems = vulnerableById.values.toList()
      ..sort((a, b) => a.title.compareTo(b.title));
    final weakCount = vulnerableItems.where((item) => item.hasWeakPassword).length;

    final penalty = (weakCount * 10) + (duplicatedCount * 5);
    var score = 100 - penalty;
    if (score < 0) {
      score = 0;
    }
    if (totalChecked == 0) {
      score = 100;
    }

    final report = SecurityAuditReport(
      totalChecked: totalChecked,
      weakCount: weakCount,
      duplicatedCount: duplicatedCount,
      vulnerableItems: vulnerableItems,
      score: score,
    );

    _lastVaultSignature = vaultSignature;
    _cachedReport = report;
    return report;
  }

  String _buildVaultSignature(
    List<dynamic> banks,
    List<dynamic> webs,
    List<dynamic> subs,
  ) {
    return [
      ...banks.map((item) => 'b:${item.id}:${item.encryptedPassword}'),
      ...webs.map((item) => 'w:${item.id}:${item.encryptedPassword}'),
      ...subs.map((item) => 's:${item.id}:${item.encryptedPassword}'),
    ].join('|');
  }

  bool _isWeakPassword(String value) {
    if (value.length < 8) {
      return true;
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return true;
    }
    if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return true;
    }
    return false;
  }
}

final securityAuditProvider =
    AsyncNotifierProvider.autoDispose<SecurityAuditNotifier, SecurityAuditReport>(
      SecurityAuditNotifier.new,
    );

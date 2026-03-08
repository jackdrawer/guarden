import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guarden/i18n/strings.g.dart';
import 'package:guarden/models/bank_account.dart';
import 'package:guarden/models/subscription.dart';
import 'package:guarden/models/web_password.dart';
import 'package:guarden/providers/bank_account_provider.dart';
import 'package:guarden/providers/security_audit_provider.dart';
import 'package:guarden/providers/subscription_provider.dart';
import 'package:guarden/providers/web_password_provider.dart';
import 'package:guarden/services/crypto_service.dart';
import 'package:guarden/services/secure_storage_service.dart';

class FakeBankAccountNotifier extends BankAccountNotifier {
  FakeBankAccountNotifier(this.items);

  final List<BankAccount> items;

  @override
  Future<List<BankAccount>> build() async => items;
}

class FakeSubscriptionNotifier extends SubscriptionNotifier {
  FakeSubscriptionNotifier(this.items);

  final List<Subscription> items;

  @override
  Future<List<Subscription>> build() async => items;
}

class FakeWebPasswordNotifier extends WebPasswordNotifier {
  FakeWebPasswordNotifier(this.items);

  final List<WebPassword> items;

  @override
  Future<List<WebPassword>> build() async => items;
}

class CountingCryptoService extends CryptoService {
  CountingCryptoService(this.decryptions);

  final Map<String, String> decryptions;
  int decryptCalls = 0;

  @override
  Future<String> decryptWithBase64Key(
    String encryptedBase64,
    String base64Key,
  ) async {
    decryptCalls++;
    return decryptions[encryptedBase64] ?? encryptedBase64;
  }
}

class FakeSecureStorageService extends SecureStorageService {
  static final _key = base64Encode(List<int>.filled(32, 1));

  @override
  Future<String?> getEncryptionKey() async => _key;
}

void main() {
  test('security audit flags weak and reused passwords', () async {
    LocaleSettings.setLocale(AppLocale.en);

    final crypto = CountingCryptoService({
      'bank-enc': 'weak',
      'web-enc': 'StrongPass1!',
      'sub-enc': 'StrongPass1!',
    });

    final container = ProviderContainer(
      overrides: [
        cryptoProvider.overrideWithValue(crypto),
        secureStorageProvider.overrideWithValue(FakeSecureStorageService()),
        bankAccountProvider.overrideWith(
          () => FakeBankAccountNotifier([
            BankAccount(
              id: 'bank-1',
              bankName: 'Bank',
              url: 'bank.com',
              accountName: 'john',
              encryptedPassword: 'bank-enc',
              lastChangedAt: DateTime(2026, 3, 8),
              createdAt: DateTime(2026, 3, 8),
            ),
          ]),
        ),
        webPasswordProvider.overrideWith(
          () => FakeWebPasswordNotifier([
            WebPassword(
              id: 'web-1',
              title: 'GitHub',
              url: 'github.com',
              username: 'octocat',
              encryptedPassword: 'web-enc',
              createdAt: DateTime(2026, 3, 8),
              updatedAt: DateTime(2026, 3, 8),
            ),
          ]),
        ),
        subscriptionProvider.overrideWith(
          () => FakeSubscriptionNotifier([
            Subscription(
              id: 'sub-1',
              serviceName: 'Netflix',
              url: 'netflix.com',
              emailOrUsername: 'john@example.com',
              encryptedPassword: 'sub-enc',
              monthlyCost: 99,
              nextBillingDate: DateTime(2026, 4, 8),
              createdAt: DateTime(2026, 3, 8),
            ),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final listener = container.listen(securityAuditProvider, (_, __) {});
    addTearDown(listener.close);

    final report = await container.read(securityAuditProvider.future);

    expect(report.totalChecked, 3);
    expect(report.weakCount, 1);
    expect(report.duplicatedCount, 2);
    expect(report.vulnerableItems, hasLength(3));
    expect(
      report.vulnerableItems.firstWhere((item) => item.id == 'bank-1').reason,
      t.security_audit.reason_weak_password,
    );
    expect(
      report.vulnerableItems.firstWhere((item) => item.id == 'web-1').reason,
      t.security_audit.reason_reused_password,
    );
    expect(crypto.decryptCalls, 3);
  });

  test('security audit skips recompute when dependency refresh keeps same vault data', () async {
    final crypto = CountingCryptoService({
      'web-enc': 'StrongPass1!',
    });
    final subscriptions = FakeSubscriptionNotifier(const []);
    final container = ProviderContainer(
      overrides: [
        cryptoProvider.overrideWithValue(crypto),
        secureStorageProvider.overrideWithValue(FakeSecureStorageService()),
        bankAccountProvider.overrideWith(
          () => FakeBankAccountNotifier(const []),
        ),
        webPasswordProvider.overrideWith(
          () => FakeWebPasswordNotifier([
            WebPassword(
              id: 'web-1',
              title: 'GitHub',
              url: 'github.com',
              username: 'octocat',
              encryptedPassword: 'web-enc',
              createdAt: DateTime(2026, 3, 8),
              updatedAt: DateTime(2026, 3, 8),
            ),
          ]),
        ),
        subscriptionProvider.overrideWith(() => subscriptions),
      ],
    );
    addTearDown(container.dispose);

    final listener = container.listen(securityAuditProvider, (_, __) {});
    addTearDown(listener.close);

    await container.read(securityAuditProvider.future);
    expect(crypto.decryptCalls, 1);

    container.invalidate(subscriptionProvider);
    await container.read(subscriptionProvider.future);
    await container.read(securityAuditProvider.future);

    expect(crypto.decryptCalls, 1);
  });
}

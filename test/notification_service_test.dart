import 'package:flutter_test/flutter_test.dart';
import 'package:guarden/models/bank_account.dart';
import 'package:guarden/models/web_password.dart';
import 'package:guarden/services/notification_service.dart';

class _TestNotificationService extends NotificationService {
  final List<(int, String, String)> sent = [];

  @override
  Future<void> init() async {}

  @override
  Future<void> requestPermissions() async {}

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    sent.add((id, title, body));
  }
}

void main() {
  group('NotificationService', () {
    test(
      'sends expired and soon notifications based on bank password periods',
      () async {
        final service = _TestNotificationService();
        final now = DateTime.now();

        final banks = <BankAccount>[
          BankAccount(
            id: 'expired',
            bankName: 'Bank A',
            url: 'a.com',
            accountName: 'acc-a',
            encryptedPassword: 'enc',
            lastChangedAt: now.subtract(const Duration(days: 80)),
            periodMonths: 1,
            createdAt: now,
          ),
          BankAccount(
            id: 'soon',
            bankName: 'Bank B',
            url: 'b.com',
            accountName: 'acc-b',
            encryptedPassword: 'enc',
            lastChangedAt: now.subtract(const Duration(days: 28)),
            periodMonths: 1,
            createdAt: now,
          ),
        ];

        final webPasswords = <WebPassword>[
          WebPassword(
            id: 'wp-1',
            title: 'Mail',
            url: 'mail.com',
            username: 'u',
            encryptedPassword: 'enc',
            createdAt: now,
            updatedAt: now,
          ),
        ];

        await service.checkPasswordExpirations(banks, webPasswords);

        expect(service.sent.length, 2);
        expect(service.sent.any((entry) => entry.$1 == 100), isTrue);
        expect(service.sent.any((entry) => entry.$1 == 101), isTrue);
      },
    );
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:guarden/i18n/strings.g.dart';
import 'package:guarden/models/activity.dart';
import 'package:guarden/models/bank_account.dart';
import 'package:guarden/models/subscription.dart';
import 'package:guarden/models/web_password.dart';
import 'package:guarden/services/database_service.dart';
import 'package:guarden/services/secure_storage_service.dart';
import 'package:hive/hive.dart';

class FakeSecureStorageService extends SecureStorageService {
  @override
  Future<String?> getEncryptionKey() async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    LocaleSettings.setLocale(AppLocale.en);
    tempDir = await Directory.systemTemp.createTemp('guarden-db-test-');
    Hive.init(tempDir.path);
    _registerAdapters();

    await Future.wait([
      Hive.openBox<BankAccount>(DatabaseService.bankAccountsBoxName),
      Hive.openBox<Subscription>(DatabaseService.subscriptionsBoxName),
      Hive.openBox<WebPassword>(DatabaseService.webPasswordsBoxName),
      Hive.openBox<Activity>(DatabaseService.activitiesBoxName),
    ]);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test(
    'restores initialization state from already open vault boxes',
    () {
      final service = DatabaseService(FakeSecureStorageService());

      expect(service.bankAccountsBox.isOpen, isTrue);
      expect(service.subscriptionsBox.isOpen, isTrue);
      expect(service.webPasswordsBox.isOpen, isTrue);
      expect(service.activitiesBox.isOpen, isTrue);
    },
  );

  test(
    'initDatabase reuses already open vault boxes',
    () async {
      final service = DatabaseService(FakeSecureStorageService());

      await service.initDatabase();

      expect(service.bankAccountsBox.name, DatabaseService.bankAccountsBoxName);
      expect(
        service.subscriptionsBox.name,
        DatabaseService.subscriptionsBoxName,
      );
      expect(
        service.webPasswordsBox.name,
        DatabaseService.webPasswordsBoxName,
      );
      expect(service.activitiesBox.name, DatabaseService.activitiesBoxName);
    },
  );
}

void _registerAdapters() {
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
}

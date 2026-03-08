import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guarden/i18n/strings.g.dart';
import 'package:guarden/models/bank_account.dart';
import 'package:guarden/models/subscription.dart';
import 'package:guarden/models/web_password.dart';
import 'package:guarden/providers/bank_account_provider.dart';
import 'package:guarden/providers/settings_provider.dart';
import 'package:guarden/providers/subscription_provider.dart';
import 'package:guarden/providers/web_password_provider.dart';
import 'package:guarden/screens/bank_accounts/bank_account_form_screen.dart';
import 'package:guarden/screens/subscriptions/subscription_form_screen.dart';
import 'package:guarden/screens/web_passwords/web_password_form_screen.dart';
import 'package:guarden/services/crypto_service.dart';
import 'package:guarden/services/secure_storage_service.dart';
import 'package:guarden/theme/app_colors.dart';

class FakeSettingsNotifier extends SettingsNotifier {
  FakeSettingsNotifier(this.settingsState);

  final SettingsState settingsState;
  int toggleTravelProtectionCalls = 0;

  @override
  Future<SettingsState> build() async => settingsState;

  @override
  Future<void> toggleTravelProtection(String id, bool protect) async {
    toggleTravelProtectionCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}

class DelayedCryptoService extends CryptoService {
  DelayedCryptoService({this.delay = const Duration(milliseconds: 200)});

  final Duration delay;

  @override
  Future<String> encryptWithBase64Key(String plainText, String base64Key) async {
    await Future<void>.delayed(delay);
    return 'enc:$plainText';
  }

  @override
  Future<String> decryptWithBase64Key(
    String encryptedBase64,
    String base64Key,
  ) async {
    await Future<void>.delayed(delay);
    return encryptedBase64.replaceFirst('enc:', '');
  }
}

class FakeSecureStorageService extends SecureStorageService {
  static final _key = base64Encode(List<int>.filled(32, 1));

  @override
  Future<String?> getEncryptionKey() async => _key;
}

class FakeBankAccountNotifier extends BankAccountNotifier {
  FakeBankAccountNotifier({List<BankAccount>? seed})
    : items = List<BankAccount>.from(seed ?? const []);

  final List<BankAccount> items;
  int addCalls = 0;
  int updateCalls = 0;

  @override
  Future<List<BankAccount>> build() async => items;

  @override
  void addBankAccount(BankAccount account) {
    addCalls++;
    items.add(account);
    state = AsyncValue.data(List<BankAccount>.from(items));
  }

  @override
  void updateBankAccount(BankAccount account) {
    updateCalls++;
    final index = items.indexWhere((item) => item.id == account.id);
    if (index != -1) {
      items[index] = account;
    }
    state = AsyncValue.data(List<BankAccount>.from(items));
  }
}

class FakeSubscriptionNotifier extends SubscriptionNotifier {
  FakeSubscriptionNotifier({List<Subscription>? seed})
    : items = List<Subscription>.from(seed ?? const []);

  final List<Subscription> items;
  int addCalls = 0;

  @override
  Future<List<Subscription>> build() async => items;

  @override
  void addSubscription(Subscription item) {
    addCalls++;
    items.add(item);
    state = AsyncValue.data(List<Subscription>.from(items));
  }
}

class FakeWebPasswordNotifier extends WebPasswordNotifier {
  FakeWebPasswordNotifier({List<WebPassword>? seed})
    : items = List<WebPassword>.from(seed ?? const []);

  final List<WebPassword> items;
  int addCalls = 0;
  int updateCalls = 0;

  @override
  Future<List<WebPassword>> build() async => items;

  @override
  void addWebPassword(WebPassword item) {
    addCalls++;
    items.add(item);
    state = AsyncValue.data(List<WebPassword>.from(items));
  }

  @override
  void updateWebPassword(WebPassword item) {
    updateCalls++;
    final index = items.indexWhere((entry) => entry.id == item.id);
    if (index != -1) {
      items[index] = item;
    }
    state = AsyncValue.data(List<WebPassword>.from(items));
  }
}

Widget _buildHarness({
  required Widget child,
  required List<Override> overrides,
}) {
  final router = GoRouter(
    initialLocation: '/form',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: Text('done')),
      ),
      GoRoute(path: '/form', builder: (context, state) => child),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    child: TranslationProvider(
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(useMaterial3: true, extensions: [AppColors.light]),
      ),
    ),
  );
}

Future<void> _doubleTapSave(WidgetTester tester) async {
  final saveButton = find.text(t.general.save);
  await tester.ensureVisible(saveButton);
  await tester.tap(saveButton);
  await tester.tap(saveButton, warnIfMissed: false);
  await tester.pump();
}

void main() {
  testWidgets('bank create ignores rapid double tap while save is in flight', (
    tester,
  ) async {
    final settings = FakeSettingsNotifier(
      SettingsState.initial().copyWith(isInitialized: true),
    );
    final accounts = FakeBankAccountNotifier();

    await tester.pumpWidget(
      _buildHarness(
        child: const BankAccountFormScreen(),
        overrides: [
          settingsProvider.overrideWith(() => settings),
          bankAccountProvider.overrideWith(() => accounts),
          cryptoProvider.overrideWithValue(DelayedCryptoService()),
          secureStorageProvider.overrideWithValue(FakeSecureStorageService()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Test Bank');
    await tester.enterText(find.byType(TextFormField).at(2), 'Sup3rSecret!');

    await _doubleTapSave(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(accounts.addCalls, 1);
    expect(settings.toggleTravelProtectionCalls, 1);
    expect(find.text('done'), findsOneWidget);
  });

  testWidgets('subscription create ignores rapid double tap', (tester) async {
    final settings = FakeSettingsNotifier(
      SettingsState.initial().copyWith(isInitialized: true),
    );
    final subscriptions = FakeSubscriptionNotifier();

    await tester.pumpWidget(
      _buildHarness(
        child: const SubscriptionFormScreen(),
        overrides: [
          settingsProvider.overrideWith(() => settings),
          subscriptionProvider.overrideWith(() => subscriptions),
          cryptoProvider.overrideWithValue(DelayedCryptoService()),
          secureStorageProvider.overrideWithValue(FakeSecureStorageService()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Netflix');
    await tester.enterText(find.byType(TextFormField).at(1), '99.99');

    await _doubleTapSave(tester);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(subscriptions.addCalls, 1);
    expect(settings.toggleTravelProtectionCalls, 1);
    expect(find.text('done'), findsOneWidget);
  });

  testWidgets('web edit ignores rapid double tap on update', (tester) async {
    final settings = FakeSettingsNotifier(
      SettingsState.initial().copyWith(isInitialized: true),
    );
    final passwords = FakeWebPasswordNotifier(
      seed: [
        WebPassword(
          id: 'web-1',
          title: 'GitHub',
          url: 'github.com',
          username: 'john@example.com',
          encryptedPassword: 'enc:old-password',
          encryptedNotes: 'enc:old-notes',
          createdAt: DateTime(2026, 3, 8),
          updatedAt: DateTime(2026, 3, 8),
        ),
      ],
    );

    await tester.pumpWidget(
      _buildHarness(
        child: const WebPasswordFormScreen(webPasswordId: 'web-1'),
        overrides: [
          settingsProvider.overrideWith(() => settings),
          webPasswordProvider.overrideWith(() => passwords),
          cryptoProvider.overrideWithValue(DelayedCryptoService()),
          secureStorageProvider.overrideWithValue(FakeSecureStorageService()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'GitHub');
    await tester.enterText(find.byType(TextFormField).at(1), 'github.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'john@example.com');
    await tester.enterText(find.byType(TextFormField).at(3), 'Sup3rSecret!');

    final updateButton = find.text(t.general.update);
    await tester.ensureVisible(updateButton);
    await tester.tap(updateButton);
    await tester.tap(updateButton, warnIfMissed: false);
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(passwords.updateCalls, 1);
    expect(settings.toggleTravelProtectionCalls, 1);
    expect(find.text('done'), findsOneWidget);
  });
}

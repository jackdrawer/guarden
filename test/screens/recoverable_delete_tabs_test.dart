import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guarden/i18n/strings.g.dart';
import 'package:guarden/models/bank_account.dart';
import 'package:guarden/models/subscription.dart';
import 'package:guarden/models/web_password.dart';
import 'package:guarden/providers/bank_account_provider.dart';
import 'package:guarden/providers/subscription_provider.dart';
import 'package:guarden/providers/web_password_provider.dart';
import 'package:guarden/screens/bank_accounts/bank_accounts_tab.dart';
import 'package:guarden/screens/subscriptions/subscriptions_tab.dart';
import 'package:guarden/screens/web_passwords/web_passwords_tab.dart';
import 'package:guarden/services/logo_service.dart';
import 'package:guarden/theme/app_colors.dart';

class FakeBankAccountNotifier extends BankAccountNotifier {
  FakeBankAccountNotifier(this.accounts);

  final List<BankAccount> accounts;

  @override
  Future<List<BankAccount>> build() async => accounts;

  @override
  BankAccount? deleteBankAccount(String id) {
    final index = accounts.indexWhere((item) => item.id == id);
    if (index == -1) {
      return null;
    }

    final deleted = accounts.removeAt(index);
    state = AsyncValue.data(List<BankAccount>.from(accounts));
    return deleted;
  }

  @override
  void restoreBankAccount(BankAccount account) {
    accounts.add(account);
    state = AsyncValue.data(List<BankAccount>.from(accounts));
  }
}

class FakeSubscriptionNotifier extends SubscriptionNotifier {
  FakeSubscriptionNotifier(this.items);

  final List<Subscription> items;

  @override
  Future<List<Subscription>> build() async => items;

  @override
  Subscription? deleteSubscription(String id) {
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) {
      return null;
    }

    final deleted = items.removeAt(index);
    state = AsyncValue.data(List<Subscription>.from(items));
    return deleted;
  }

  @override
  void restoreSubscription(Subscription item) {
    items.add(item);
    state = AsyncValue.data(List<Subscription>.from(items));
  }
}

class FakeWebPasswordNotifier extends WebPasswordNotifier {
  FakeWebPasswordNotifier(this.items);

  final List<WebPassword> items;

  @override
  Future<List<WebPassword>> build() async => items;

  @override
  WebPassword? deleteWebPassword(String id) {
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) {
      return null;
    }

    final deleted = items.removeAt(index);
    state = AsyncValue.data(List<WebPassword>.from(items));
    return deleted;
  }

  @override
  void restoreWebPassword(WebPassword item) {
    items.add(item);
    state = AsyncValue.data(List<WebPassword>.from(items));
  }
}

class FakeLogoService extends LogoService {
  @override
  Widget getLogoWidget(String rawUrlOrDomain, {double size = 48.0}) {
    return SizedBox(width: size, height: size);
  }
}

Widget _buildHarness({
  required Widget child,
  required List<Override> overrides,
}) {
  return ProviderScope(
    overrides: overrides,
    child: TranslationProvider(
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true, extensions: [AppColors.light]),
        home: Scaffold(body: child),
      ),
    ),
  );
}

void _setLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1440, 2200);
  tester.view.devicePixelRatio = 1.0;
}

Future<void> _deleteFirstItem(WidgetTester tester, String itemId) async {
  await tester.drag(find.byKey(ValueKey(itemId)), const Offset(-500, 0));
  await tester.pumpAndSettle();
  await tester.tap(find.text(t.general.delete).last);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('bank tab delete shows undo snackbar and restores item', (
    tester,
  ) async {
    _setLargeViewport(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final notifier = FakeBankAccountNotifier([
      BankAccount(
        id: 'bank-1',
        bankName: 'Test Bank',
        url: 'example.com',
        accountName: 'john',
        encryptedPassword: 'enc',
        lastChangedAt: DateTime(2026, 3, 8),
        createdAt: DateTime(2026, 3, 8),
      ),
      BankAccount(
        id: 'bank-2',
        bankName: 'Backup Bank',
        url: 'backup.com',
        accountName: 'jane',
        encryptedPassword: 'enc',
        lastChangedAt: DateTime(2026, 3, 8),
        createdAt: DateTime(2026, 3, 8),
      ),
    ]);

    await tester.pumpWidget(
      _buildHarness(
        child: const BankAccountsTab(),
        overrides: [
          bankAccountProvider.overrideWith(() => notifier),
          logoServiceProvider.overrideWithValue(FakeLogoService()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await _deleteFirstItem(tester, 'bank-1');

    expect(find.byKey(const ValueKey('bank-1')), findsNothing);
    expect(
      find.text(t.general.deleted_label(label: 'Test Bank')),
      findsOneWidget,
    );

    await tester.tap(find.text(t.general.undo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('bank-1')), findsOneWidget);
  });

  testWidgets('subscription tab delete shows undo snackbar and restores item', (
    tester,
  ) async {
    _setLargeViewport(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final notifier = FakeSubscriptionNotifier([
      Subscription(
        id: 'sub-1',
        serviceName: 'Netflix',
        url: 'netflix.com',
        emailOrUsername: 'john@example.com',
        encryptedPassword: 'enc',
        monthlyCost: 99,
        nextBillingDate: DateTime(2026, 4, 8),
        createdAt: DateTime(2026, 3, 8),
      ),
      Subscription(
        id: 'sub-2',
        serviceName: 'Spotify',
        url: 'spotify.com',
        emailOrUsername: 'jane@example.com',
        encryptedPassword: 'enc',
        monthlyCost: 49,
        nextBillingDate: DateTime(2026, 4, 10),
        createdAt: DateTime(2026, 3, 8),
      ),
    ]);

    await tester.pumpWidget(
      _buildHarness(
        child: const SubscriptionsTab(),
        overrides: [
          subscriptionProvider.overrideWith(() => notifier),
          logoServiceProvider.overrideWithValue(FakeLogoService()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await _deleteFirstItem(tester, 'sub-1');

    expect(find.byKey(const ValueKey('sub-1')), findsNothing);
    expect(
      find.text(t.general.deleted_label(label: 'Netflix')),
      findsOneWidget,
    );

    await tester.tap(find.text(t.general.undo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('sub-1')), findsOneWidget);
  });

  testWidgets('web tab delete shows undo snackbar and restores item', (
    tester,
  ) async {
    _setLargeViewport(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final notifier = FakeWebPasswordNotifier([
      WebPassword(
        id: 'web-1',
        title: 'GitHub',
        url: 'github.com',
        username: 'john@example.com',
        encryptedPassword: 'enc',
        createdAt: DateTime(2026, 3, 8),
        updatedAt: DateTime(2026, 3, 8),
      ),
      WebPassword(
        id: 'web-2',
        title: 'Google',
        url: 'google.com',
        username: 'jane@example.com',
        encryptedPassword: 'enc',
        createdAt: DateTime(2026, 3, 8),
        updatedAt: DateTime(2026, 3, 8),
      ),
    ]);

    await tester.pumpWidget(
      _buildHarness(
        child: const WebPasswordsTab(),
        overrides: [
          webPasswordProvider.overrideWith(() => notifier),
          logoServiceProvider.overrideWithValue(FakeLogoService()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await _deleteFirstItem(tester, 'web-1');

    expect(find.byKey(const ValueKey('web-1')), findsNothing);
    expect(find.text(t.general.deleted_label(label: 'GitHub')), findsOneWidget);

    await tester.tap(find.text(t.general.undo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('web-1')), findsOneWidget);
  });
}

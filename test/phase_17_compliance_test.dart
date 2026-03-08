import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guarden/providers/home_provider.dart';
import 'package:guarden/widgets/dashboard/activity_feed_card.dart';
import 'package:guarden/widgets/dashboard/backup_status_card.dart';
import 'package:guarden/models/activity.dart';
import 'package:guarden/providers/settings_provider.dart';
import 'package:guarden/providers/bank_account_provider.dart';
import 'package:guarden/providers/subscription_provider.dart';
import 'package:guarden/providers/web_password_provider.dart';
import 'package:guarden/providers/activity_provider.dart';
import 'package:guarden/models/bank_account.dart';
import 'package:guarden/models/subscription.dart';
import 'package:guarden/models/web_password.dart';
import 'package:guarden/i18n/strings.g.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocale(AppLocale.en);
  });

  group('Phase 17 Compliance Tests', () {
    // 1) Activity Feed -> Tab Navigation
    testWidgets('ActivityFeedCard item tap updates homeTabProvider', (
      WidgetTester tester,
    ) async {
      final activity = Activity(
        id: '1',
        title: 'Github',
        subtitle: 'Password copied',
        type: 'web_password', // Should go to tab 3
        action: 'copied',
        itemId: 'web-1',
        timestamp: DateTime.now(),
      );

      late int currentTab;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recentActivitiesProvider.overrideWithValue([activity]),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  currentTab = ref.watch(homeTabProvider);
                  return const ActivityFeedCard();
                },
              ),
            ),
          ),
        ),
      );

      expect(currentTab, 0); // Start at Dashboard
      await tester.tap(find.text('Github'));
      await tester.pumpAndSettle();
      expect(currentTab, 3); // Switched to Web Passwords
    });

    // 2) Backup Sync -> Dashboard UI Update
    testWidgets('BackupStatusCard shows updated time after sync update', (
      WidgetTester tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          settingsProvider.overrideWith(SettingsNotifierMock.new),
          bankAccountProvider.overrideWith(BankAccountNotifierMock.new),
          subscriptionProvider.overrideWith(SubscriptionNotifierMock.new),
          webPasswordProvider.overrideWith(WebPasswordNotifierMock.new),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: BackupStatusCard())),
        ),
      );

      expect(find.textContaining('Never'), findsOneWidget);

      final now = DateTime.now();
      await container.read(settingsProvider.notifier).setLastSyncTimestamp(now);

      await tester.pumpAndSettle();

      // Should no longer show 'Never'
      expect(find.textContaining('Never'), findsNothing);
    });
  });
}

class SettingsNotifierMock extends SettingsNotifier {
  @override
  Future<SettingsState> build() async => SettingsState.initial();

  @override
  Future<void> setLastSyncTimestamp(DateTime? timestamp) async {
    state = AsyncValue.data(
      state.value!.copyWith(lastSyncTimestamp: timestamp),
    );
  }
}

class BankAccountNotifierMock extends BankAccountNotifier {
  @override
  Future<List<BankAccount>> build() async => [];
}

class SubscriptionNotifierMock extends SubscriptionNotifier {
  @override
  Future<List<Subscription>> build() async => [];
}

class WebPasswordNotifierMock extends WebPasswordNotifier {
  @override
  Future<List<WebPassword>> build() async => [];
}

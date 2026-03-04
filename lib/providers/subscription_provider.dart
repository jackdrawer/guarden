import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/app_errors.dart';
import '../models/subscription.dart';
import '../services/database_service.dart';
import '../services/text_sanitizer.dart';
import '../widgets/error_handler.dart';
import '../i18n/strings.g.dart';
import 'settings_provider.dart';

class SubscriptionNotifier
    extends AutoDisposeAsyncNotifier<List<Subscription>> {
  late final DatabaseService _dbService = ref.read(databaseProvider);

  @override
  Future<List<Subscription>> build() async {
    ref.watch(settingsProvider);
    return _getItems();
  }

  List<Subscription> _getItems() {
    try {
      final settings = ref.read(settingsProvider).valueOrNull;
      var items = _dbService.subscriptionsBox.values.toList();
      _repairLegacyText(items);
      if (settings != null && settings.isTravelModeActive) {
        items = items
            .where((item) => !settings.travelProtectedIds.contains(item.id))
            .toList();
      }
      return items;
    } catch (e) {
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to read subscriptions: $e',
          userMessage: t.settings.errors.load_failed,
        ),
      );
      return [];
    }
  }

  void _repairLegacyText(List<Subscription> items) {
    for (final item in items) {
      final repairedName = TextSanitizer.normalizeDisplayText(item.serviceName);
      final repairedUrl = TextSanitizer.normalizeDisplayText(item.url);

      if (repairedName == item.serviceName && repairedUrl == item.url) {
        continue;
      }

      item.serviceName = repairedName;
      item.url = repairedUrl;
      _dbService.subscriptionsBox.put(item.id, item);
    }
  }

  void addSubscription(Subscription item) {
    try {
      _dbService.subscriptionsBox.put(item.id, item);
      state = AsyncValue.data(_getItems());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to add subscription: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
    }
  }

  void updateSubscription(Subscription item) {
    try {
      _dbService.subscriptionsBox.put(item.id, item);
      state = AsyncValue.data(_getItems());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to update subscription: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
    }
  }

  void deleteSubscription(String id) {
    try {
      _dbService.subscriptionsBox.delete(id);
      state = AsyncValue.data(_getItems());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to delete subscription: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
    }
  }
}

final subscriptionProvider =
    AsyncNotifierProvider.autoDispose<SubscriptionNotifier, List<Subscription>>(
      SubscriptionNotifier.new,
    );

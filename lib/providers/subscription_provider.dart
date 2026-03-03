import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../services/database_service.dart';
import '../widgets/error_handler.dart';
import '../errors/app_errors.dart';

import 'settings_provider.dart';

class SubscriptionNotifier extends AutoDisposeAsyncNotifier<List<Subscription>> {
  late final _dbService = ref.read(databaseProvider);

  @override
  Future<List<Subscription>> build() async {
    ref.watch(settingsProvider);
    return _getItems();
  }

  List<Subscription> _getItems() {
    try {
      final settings = ref.read(settingsProvider);
      var items = _dbService.subscriptionsBox.values.toList();
      if (settings.isTravelModeActive) {
        items = items
            .where((i) => !settings.travelProtectedIds.contains(i.id))
            .toList();
      }
      return items;
    } catch (e) {
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to read subscriptions: $e',
          userMessage: "Could not load subscriptions.",
        ),
      );
      return [];
    }
  }

  void addSubscription(Subscription sub) {
    try {
      _dbService.subscriptionsBox.put(sub.id, sub);
      state = AsyncValue.data(_getItems());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to add subscription: $e',
          userMessage: "Could not save subscription.",
        ),
      );
    }
  }

  void updateSubscription(Subscription sub) {
    try {
      _dbService.subscriptionsBox.put(sub.id, sub);
      state = AsyncValue.data(_getItems());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to update subscription: $e',
          userMessage: "Could not update subscription.",
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
          userMessage: "Could not delete subscription.",
        ),
      );
    }
  }
}

final subscriptionProvider =
    AsyncNotifierProvider.autoDispose<SubscriptionNotifier, List<Subscription>>(
      SubscriptionNotifier.new,
    );

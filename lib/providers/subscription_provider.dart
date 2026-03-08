import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/app_errors.dart';
import '../models/subscription.dart';
import '../services/database_service.dart';
import '../services/text_sanitizer.dart';
import '../widgets/error_handler.dart';
import '../i18n/strings.g.dart';
import 'settings_provider.dart';
import 'activity_provider.dart';

class SubscriptionNotifier
    extends AutoDisposeAsyncNotifier<List<Subscription>> {
  late final DatabaseService _dbService = ref.read(databaseProvider);

  static const String _legacyTextRepairKey = 'subscription_text_repair_v1_done';
  bool _migrationChecked = false;

  // Travel mode settings cached from build() to avoid watching all settings
  late bool _isTravelModeActive;
  late List<String> _travelProtectedIds;

  @override
  Future<List<Subscription>> build() async {
    final travelModeSettings = await ref.watch(
      settingsProvider.selectAsync(
        (s) => (
          isActive: s.isTravelModeActive,
          protectedIds: s.travelProtectedIds,
        ),
      ),
    );
    // Cache travel mode settings for use in CRUD operations
    _isTravelModeActive = travelModeSettings.isActive;
    _travelProtectedIds = travelModeSettings.protectedIds;
    return _getItems();
  }

  List<Subscription> _getItems() {
    final isTravelModeActive = _isTravelModeActive;
    final travelProtectedIds = _travelProtectedIds;
    try {
      var items = _dbService.subscriptionsBox.values.toList();
      _repairLegacyText(items);
      if (isTravelModeActive) {
        items = items
            .where((item) => !travelProtectedIds.contains(item.id))
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
    if (_migrationChecked) return;

    // Check if migration already completed
    final isMigrationDone =
        _dbService.settingsBox.get(_legacyTextRepairKey) as bool?;
    if (isMigrationDone == true) {
      _migrationChecked = true;
      return;
    }

    // Perform migration only once
    for (final item in items) {
      final repairedName = TextSanitizer.normalizeDisplayText(item.serviceName);
      final repairedUrl = TextSanitizer.normalizeDisplayText(item.url);

      if (repairedName == item.serviceName && repairedUrl == item.url) {
        continue;
      }

      final newItem = item.copyWith(
        serviceName: repairedName,
        url: repairedUrl,
      );
      _dbService.subscriptionsBox.put(item.id, newItem);
    }

    // Mark migration as complete
    _dbService.settingsBox.put(_legacyTextRepairKey, true);
    _migrationChecked = true;
  }

  void addSubscription(Subscription item) {
    try {
      _dbService.subscriptionsBox.put(item.id, item);
      state = AsyncValue.data(_getItems());
      ref
          .read(activityProvider.notifier)
          .recordActivity(
            title: item.serviceName,
            subtitle: t.dashboard.activities.added_subscription,
            type: 'subscription',
            action: 'added',
            itemId: item.id,
          );
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
      ref
          .read(activityProvider.notifier)
          .recordActivity(
            title: item.serviceName,
            subtitle: t.dashboard.activities.updated_subscription,
            type: 'subscription',
            action: 'updated',
            itemId: item.id,
          );
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

  Subscription? deleteSubscription(String id) {
    try {
      final item = _dbService.subscriptionsBox.get(id);
      if (item == null) {
        return null;
      }
      final title = item.serviceName;
      _dbService.subscriptionsBox.delete(id);
      state = AsyncValue.data(_getItems());
      ref
          .read(activityProvider.notifier)
          .recordActivity(
            title: title,
            subtitle: t.dashboard.activities.deleted_subscription,
            type: 'subscription',
            action: 'deleted',
            itemId: id,
          );
      return item;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to delete subscription: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
      return null;
    }
  }

  void restoreSubscription(Subscription item) {
    try {
      _dbService.subscriptionsBox.put(item.id, item);
      state = AsyncValue.data(_getItems());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to restore subscription: $e',
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

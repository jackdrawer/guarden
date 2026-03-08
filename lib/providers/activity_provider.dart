import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/activity.dart';
import '../services/database_service.dart';

class ActivityNotifier extends AutoDisposeAsyncNotifier<List<Activity>> {
  late final DatabaseService _dbService = ref.read(databaseProvider);
  static const int _maxActivities = 50;

  @override
  Future<List<Activity>> build() async {
    return _getActivities();
  }

  List<Activity> _getActivities() {
    try {
      final items = _dbService.activitiesBox.values.toList();
      // Sort by timestamp descending
      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return items;
    } catch (e) {
      return [];
    }
  }

  Future<void> recordActivity({
    required String title,
    required String subtitle,
    required String type,
    required String action,
    required String itemId,
  }) async {
    try {
      final activity = Activity(
        id: const Uuid().v4(),
        title: title,
        subtitle: subtitle,
        type: type,
        action: action,
        itemId: itemId,
        timestamp: DateTime.now(),
      );

      await _dbService.activitiesBox.put(activity.id, activity);

      // Keep only the last _maxActivities
      final items = _getActivities();
      if (items.length > _maxActivities) {
        final toDelete = items.sublist(_maxActivities);
        for (var item in toDelete) {
          await _dbService.activitiesBox.delete(item.id);
        }
      }

      state = AsyncValue.data(_getActivities());
    } catch (e) {
      // Fail silently for activity logging to not disrupt main flow
    }
  }

  Future<void> clearAll() async {
    await _dbService.activitiesBox.clear();
    state = const AsyncValue.data([]);
  }
}

final activityProvider =
    AsyncNotifierProvider.autoDispose<ActivityNotifier, List<Activity>>(
      ActivityNotifier.new,
    );

final recentActivitiesProvider = Provider.autoDispose<List<Activity>>((ref) {
  final activities = ref.watch(activityProvider).valueOrNull ?? [];
  return activities.take(5).toList();
});

import 'package:hive/hive.dart';

part 'activity.g.dart';

@HiveType(typeId: 4)
class Activity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String subtitle;

  @HiveField(3)
  final String type; // 'web_password', 'bank_account', 'subscription', 'system'

  @HiveField(4)
  final String action; // 'added', 'updated', 'deleted', 'copied', 'revealed', 'synced'

  @HiveField(5)
  final String itemId; // Related item ID for navigation

  @HiveField(6)
  final DateTime timestamp;

  Activity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.action,
    required this.itemId,
    required this.timestamp,
  });

  Activity copyWith({
    String? title,
    String? subtitle,
    String? type,
    String? action,
    String? itemId,
    DateTime? timestamp,
  }) {
    return Activity(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      type: type ?? this.type,
      action: action ?? this.action,
      itemId: itemId ?? this.itemId,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

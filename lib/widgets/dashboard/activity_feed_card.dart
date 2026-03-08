import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/home_provider.dart';

import '../../i18n/strings.g.dart';
import '../../providers/activity_provider.dart';
import '../../theme/app_colors.dart';
import '../neumorphic/neumorphic_container.dart';

class ActivityFeedCard extends ConsumerWidget {
  const ActivityFeedCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(recentActivitiesProvider);
    final colors = AppColors.of(context);

    return NeumorphicContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.dashboard.activities.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              Icon(Icons.history, size: 18, color: colors.textSecondary),
            ],
          ),
          const SizedBox(height: 12),
          if (activities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  t.general.record_not_found,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (context, index) => Divider(
                color: colors.textSecondary.withAlpha(30),
                height: 16,
              ),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return InkWell(
                  onTap: () {
                    if (activity.type == 'web_password') {
                      ref.read(homeTabProvider.notifier).state = 3;
                    } else if (activity.type == 'bank_account') {
                      ref.read(homeTabProvider.notifier).state = 1;
                    } else if (activity.type == 'subscription') {
                      ref.read(homeTabProvider.notifier).state = 2;
                    }
                  },
                  child: Row(
                    children: [
                      _buildActivityIcon(
                        context,
                        activity.type,
                        activity.action,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activity.subtitle,
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTimestamp(activity.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActivityIcon(BuildContext context, String type, String action) {
    final colors = AppColors.of(context);
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'web_password':
        iconData = Icons.vpn_key_outlined;
        iconColor = colors.primaryAccent;
        break;
      case 'bank_account':
        iconData = Icons.account_balance_outlined;
        iconColor = Colors.green;
        break;
      case 'subscription':
        iconData = Icons.card_membership_outlined;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.notifications_none_outlined;
        iconColor = colors.textSecondary;
    }

    if (action == 'deleted') {
      iconColor = colors.error;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withAlpha(30),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, size: 16, color: iconColor),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return t.dashboard.activities.time_just_now;
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}${t.dashboard.activities.time_minute}';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}${t.dashboard.activities.time_hour}';
    } else {
      return '${difference.inDays}${t.dashboard.activities.time_day}';
    }
  }
}

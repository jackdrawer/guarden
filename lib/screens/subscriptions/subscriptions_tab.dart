import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../i18n/strings.g.dart';
import '../../providers/subscription_provider.dart';
import '../../services/logo_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_empty_state.dart';
import '../../widgets/neumorphic/neumorphic_container.dart';

class SubscriptionsTab extends ConsumerWidget {
  const SubscriptionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscriptionProvider).valueOrNull ?? [];
    final logoService = ref.watch(logoServiceProvider);
    final displayCurrency = subscriptions.isNotEmpty
        ? subscriptions.first.currency
        : 'TRY';

    double totalMonthlyCost = 0.0;
    for (var sub in subscriptions) {
      totalMonthlyCost += sub.monthlyCost;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.subscriptions.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          NeumorphicContainer(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.subscriptions.monthly_total,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.of(context).textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$displayCurrency ${totalMonthlyCost.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.of(context).primaryAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: subscriptions.isEmpty
                ? AnimatedEmptyState(
                    icon: Icons.subscriptions_outlined,
                    title: t.subscriptions.empty.title,
                    subtitle: t.subscriptions.empty.subtitle,
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      itemCount: subscriptions.length,
                      itemBuilder: (context, index) {
                        final sub = subscriptions[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Slidable(
                                  key: ValueKey(sub.id),
                                  endActionPane: ActionPane(
                                    motion: const DrawerMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) {
                                          HapticFeedback.lightImpact();
                                          context.push(
                                            '/edit-subscription/${sub.id}',
                                          );
                                        },
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: AppColors.of(
                                          context,
                                        ).primaryAccent,
                                        icon: Icons.edit,
                                        label: t.general.edit,
                                      ),
                                      SlidableAction(
                                        onPressed: (context) {
                                          HapticFeedback.mediumImpact();
                                          ref
                                              .read(
                                                subscriptionProvider.notifier,
                                              )
                                              .deleteSubscription(sub.id);
                                        },
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: AppColors.of(
                                          context,
                                        ).error,
                                        icon: Icons.delete,
                                        label: t.general.delete,
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      context.push(
                                        '/subscription-detail/${sub.id}',
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: NeumorphicContainer(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          logoService.getLogoWidget(
                                            sub.url.isNotEmpty
                                                ? sub.url
                                                : sub.serviceName,
                                            size: 50,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  sub.serviceName,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.of(
                                                      context,
                                                    ).textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${sub.currency} ${sub.monthlyCost.toStringAsFixed(2)} ${t.subscriptions.per_month}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: AppColors.of(
                                                      context,
                                                    ).textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: AppColors.of(
                                              context,
                                            ).textSecondary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

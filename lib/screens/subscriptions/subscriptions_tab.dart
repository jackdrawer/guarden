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
import '../../widgets/category/category_widgets.dart';
import '../../widgets/neumorphic/neumorphic_container.dart';
import '../../utils/currency_utils.dart';

class SubscriptionsTab extends ConsumerStatefulWidget {
  const SubscriptionsTab({super.key});

  @override
  ConsumerState<SubscriptionsTab> createState() => _SubscriptionsTabState();
}

class _SubscriptionsTabState extends ConsumerState<SubscriptionsTab> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final subscriptions = ref.watch(subscriptionProvider).valueOrNull ?? [];
    final logoService = ref.watch(logoServiceProvider);
    final displayCurrency = CurrencyUtils.getDefaultCurrency();

    // Filter by selected category
    final filtered = _selectedCategory == null || _selectedCategory!.isEmpty
        ? subscriptions
        : subscriptions.where((s) => s.category == _selectedCategory).toList();

    final Map<String, double> breakdown = {};
    for (var sub in subscriptions) {
      final monthlyCost = sub.billingCycle == 'yearly'
          ? sub.monthlyCost / 12
          : sub.monthlyCost;
      breakdown[sub.currency] = (breakdown[sub.currency] ?? 0.0) + monthlyCost;
    }

    final hasMultipleCurrencies = breakdown.length > 1;
    String breakdownString = '';
    if (hasMultipleCurrencies) {
      breakdownString = breakdown.entries
          .map((e) => CurrencyUtils.formatAmount(e.value, e.key))
          .join(' + ');
    } else {
      final key = breakdown.keys.firstOrNull ?? displayCurrency;
      final val = breakdown.values.firstOrNull ?? 0.0;
      breakdownString = CurrencyUtils.formatAmount(val, key);
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
          const SizedBox(height: 12),
          CategoryFilterChips(
            selected: _selectedCategory,
            onChanged: (cat) => setState(() => _selectedCategory = cat),
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
                    color: hasMultipleCurrencies
                        ? Colors.orange
                        : AppColors.of(context).textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (hasMultipleCurrencies)
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 16,
                    color: Colors.orange,
                  ),
                Expanded(
                  child: Text(
                    breakdownString,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: hasMultipleCurrencies ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: hasMultipleCurrencies
                          ? Colors.orange
                          : AppColors.of(context).primaryAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? AnimatedEmptyState(
                    icon: Icons.subscriptions_outlined,
                    title: t.subscriptions.empty.title,
                    subtitle: t.subscriptions.empty.subtitle,
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final sub = filtered[index];
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
                                                  '${CurrencyUtils.formatAmount(sub.monthlyCost, sub.currency)} ${sub.billingCycle == 'yearly' ? t.subscription_form.yearly : t.subscriptions.per_month}',
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../i18n/strings.g.dart';
import '../../providers/bank_account_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/currency_utils.dart';
import '../../widgets/ads/ad_banner_widget.dart';
import '../../widgets/analytics/subscription_pie_chart.dart';
import '../../widgets/neumorphic/neumorphic_container.dart';

class DashboardTab extends ConsumerStatefulWidget {
  const DashboardTab({super.key});

  @override
  ConsumerState<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<DashboardTab> {
  bool _showChart = false;

  @override
  Widget build(BuildContext context) {
    final subscriptions = ref.watch(subscriptionProvider).valueOrNull ?? [];
    final bankAccounts = ref.watch(bankAccountProvider).valueOrNull ?? [];
    final settings = ref.watch(settingsProvider).valueOrNull;
    final displayCurrency =
        settings?.defaultCurrency ?? CurrencyUtils.getDefaultCurrency();

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

    // For pie chart: group by service name for the primary currency view
    final Map<String, double> chartData = {};
    for (var sub in subscriptions) {
      final monthlyCost = sub.billingCycle == 'yearly'
          ? sub.monthlyCost / 12
          : sub.monthlyCost;
      // Only include matching display currency, or all if single currency
      if (!hasMultipleCurrencies || sub.currency == displayCurrency) {
        final label = sub.category.isNotEmpty ? sub.category : sub.serviceName;
        chartData[label] = (chartData[label] ?? 0.0) + monthlyCost;
      }
    }

    final now = DateTime.now();
    final expiredBanks = bankAccounts.where((bank) {
      final threshold = bank.lastChangedAt.add(
        Duration(days: bank.periodMonths * 30),
      );
      return now.isAfter(threshold);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.dashboard.command_center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          _buildBudgetCard(
            context,
            breakdownString,
            displayCurrency,
            hasMultipleCurrencies,
            chartData,
          ),
          const SizedBox(height: 24),
          if (expiredBanks.isNotEmpty) ...[
            _buildAlertCard(context, expiredBanks.length),
            const SizedBox(height: 16),
          ],
          _buildSecurityAuditCard(context),
          const SizedBox(height: 16),
          const AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(
    BuildContext context,
    String breakdownString,
    String displayCurrency,
    bool hasMultipleCurrencies,
    Map<String, double> chartData,
  ) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.dashboard.total_budget,
                    style: TextStyle(
                      color: AppColors.of(context).textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasMultipleCurrencies ? 'Multi-Currency' : displayCurrency,
                    style: TextStyle(
                      color: hasMultipleCurrencies
                          ? Colors.orange
                          : AppColors.of(context).primaryAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Text(
                  breakdownString,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: hasMultipleCurrencies ? 16 : 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.of(context).textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (chartData.isNotEmpty) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => setState(() => _showChart = !_showChart),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showChart
                        ? Icons.expand_less_rounded
                        : Icons.bar_chart_rounded,
                    size: 18,
                    color: AppColors.of(context).primaryAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _showChart
                        ? t.dashboard.hide_chart
                        : t.dashboard.show_chart,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.of(context).primaryAccent,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SubscriptionPieChart(
                  data: chartData,
                  currency: chartData.keys.first,
                ),
              ),
              crossFadeState: _showChart
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, int count) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.dashboard.alert_title,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.dashboard.alerts.expired_banks(count: count),
                  style: TextStyle(
                    color: AppColors.of(context).textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityAuditCard(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/security-audit'),
      borderRadius: BorderRadius.circular(16),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.of(context).background,
                shape: BoxShape.circle,
                boxShadow: AppColors.of(context).neumorphicShadows,
              ),
              child: Icon(
                Icons.security_update_warning,
                color: AppColors.of(context).primaryAccent,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.dashboard.security_audit.title,
                    style: TextStyle(
                      color: AppColors.of(context).textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.dashboard.security_audit.subtitle,
                    style: TextStyle(
                      color: AppColors.of(context).textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: AppColors.of(context).textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

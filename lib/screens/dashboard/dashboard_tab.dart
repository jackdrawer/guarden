import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../i18n/strings.g.dart';
import '../../providers/bank_account_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/ads/ad_banner_widget.dart';
import '../../widgets/neumorphic/neumorphic_container.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscriptionProvider).valueOrNull ?? [];
    final bankAccounts = ref.watch(bankAccountProvider).valueOrNull ?? [];
    final displayCurrency = subscriptions.isNotEmpty
        ? subscriptions.first.currency
        : 'TRY';

    final totalBudget = subscriptions.fold(
      0.0,
      (sum, sub) => sum + sub.monthlyCost,
    );

    final now = DateTime.now();
    final expiredBanks = bankAccounts.where((bank) {
      final threshold = bank.lastChangedAt.add(
        Duration(days: bank.periodMonths * 30),
      );
      return now.isAfter(threshold);
    }).toList();

    return Padding(
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
          _buildBudgetCard(context, totalBudget, displayCurrency),
          const SizedBox(height: 24),
          if (expiredBanks.isNotEmpty)
            _buildAlertCard(context, expiredBanks.length),
          const SizedBox(height: 16),
          _buildSecurityAuditCard(context),
          const SizedBox(height: 16),
          const AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(
    BuildContext context,
    double totalBudget,
    String displayCurrency,
  ) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(24.0),
      child: Row(
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
              const SizedBox(height: 8),
              Text(
                displayCurrency,
                style: TextStyle(
                  color: AppColors.of(context).primaryAccent,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Text(
            totalBudget.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.of(context).textPrimary,
            ),
          ),
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

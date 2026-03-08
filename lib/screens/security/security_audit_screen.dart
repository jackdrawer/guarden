import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../i18n/strings.g.dart';
import '../../providers/security_audit_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/neumorphic/neumorphic_container.dart';

class SecurityAuditScreen extends ConsumerWidget {
  const SecurityAuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditState = ref.watch(securityAuditProvider);
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: colors.textPrimary),
        title: Text(
          t.security_audit.title,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: auditState.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: colors.primaryAccent),
          ),
          error: (error, _) => Center(
            child: Text(
              t.security_audit.scan_failed,
              style: TextStyle(color: colors.error),
            ),
          ),
          data: (report) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildScoreWheel(context, report.score),
                        const SizedBox(height: 24),
                        _buildStatsRow(context, report),
                        const SizedBox(height: 24),
                        if (report.vulnerableItems.isEmpty)
                          Column(
                            children: [
                              Icon(
                                Icons.shield_rounded,
                                size: 64,
                                color: colors.primaryAccent,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                t.security_audit.great,
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                t.security_audit.safe_message,
                                style: TextStyle(color: colors.textSecondary),
                              ),
                            ],
                          )
                        else
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              t.security_audit.weak_or_risky_passwords,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (report.vulnerableItems.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = report.vulnerableItems[index];
                      final colors = AppColors.of(context);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 8.0,
                        ),
                        child: NeumorphicContainer(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              _buildTypeIcon(context, item.type),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: TextStyle(
                                        color: colors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_typeLabel(item.type)} • ${item.reason}',
                                      style: const TextStyle(
                                        color: Colors.orangeAccent,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: colors.textSecondary,
                                ),
                                onPressed: () => _goToEdit(context, item),
                              ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: report.vulnerableItems.length),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _goToEdit(BuildContext context, VulnerableItem item) {
    if (item.type == 'bank') {
      context.push('/edit-bank/${item.id}');
      return;
    }
    if (item.type == 'web') {
      context.push('/edit-web-password/${item.id}');
      return;
    }
    if (item.type == 'subscription') {
      context.push('/edit-subscription/${item.id}');
    }
  }

  Widget _buildTypeIcon(BuildContext context, String type) {
    final colors = AppColors.of(context);
    IconData icon = Icons.subscriptions;
    if (type == 'bank') {
      icon = Icons.account_balance;
    } else if (type == 'web') {
      icon = Icons.language;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.background,
        shape: BoxShape.circle,
        boxShadow: colors.neumorphicShadows,
      ),
      child: Icon(icon, color: colors.primaryAccent),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'bank':
        return t.security_audit.types.bank;
      case 'subscription':
        return t.security_audit.types.subscription;
      default:
        return t.security_audit.types.web;
    }
  }

  Widget _buildScoreWheel(BuildContext context, int score) {
    final colors = AppColors.of(context);
    var scoreColor = colors.primaryAccent;
    if (score < 50) {
      scoreColor = Colors.redAccent;
    } else if (score < 80) {
      scoreColor = Colors.orangeAccent;
    }

    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: colors.background,
        shape: BoxShape.circle,
        boxShadow: colors.neumorphicShadows,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              score.toString(),
              style: TextStyle(
                color: scoreColor,
                fontSize: 44,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              t.security_audit.security_score,
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, SecurityAuditReport report) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          t.security_audit.scanned,
          report.totalChecked.toString(),
          colors.textPrimary,
        ),
        _buildStatItem(
          t.security_audit.weak,
          report.weakCount.toString(),
          Colors.orangeAccent,
        ),
        _buildStatItem(
          t.security_audit.reused,
          report.duplicatedCount.toString(),
          Colors.redAccent,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

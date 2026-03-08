import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../i18n/strings.g.dart';
import '../../theme/app_colors.dart';
import '../../widgets/neumorphic/neumorphic_container.dart';
import '../../providers/security_audit_provider.dart';

class CompromisedAccountsScreen extends ConsumerWidget {
  const CompromisedAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditAsync = ref.watch(securityAuditProvider);

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.of(context).textSecondary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_rounded, color: AppColors.of(context).error),
            const SizedBox(width: 8),
            Text(
              t.compromised_accounts.title,
              style: TextStyle(
                color: AppColors.of(context).textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: auditAsync.when(
        data: (report) {
          final items = report.vulnerableItems;
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.security_audit.safe_message,
                    style: TextStyle(
                      color: AppColors.of(context).textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildCompromisedCard(context, item),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) =>
            Center(child: Text(t.settings.error_with_message(message: '$e'))),
      ),
    );
  }

  Widget _buildCompromisedCard(BuildContext context, VulnerableItem item) {
    final iconInitials = item.title.isNotEmpty
        ? item.title[0].toUpperCase()
        : '?';
    return NeumorphicContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Sol Baş Harf Grafiği
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.of(context).background,
              shape: BoxShape.circle,
              boxShadow: AppColors.of(context).neumorphicShadows,
            ),
            alignment: Alignment.center,
            child: Text(
              iconInitials,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.of(context).textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Bilgiler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.of(context).textPrimary,
                  ),
                ),
                Text(
                  _typeLabel(item.type),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.of(context).textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: AppColors.of(context).error,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.reason,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.of(context).error,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Fix Action
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              switch (item.type) {
                case 'bank':
                  context.push('/edit-bank/${item.id}');
                  break;
                case 'subscription':
                  context.push('/edit-subscription/${item.id}');
                  break;
                case 'web':
                  context.push('/edit-web-password/${item.id}');
                  break;
              }
            },
            child: Text(t.compromised_accounts.fix_now),
          ),
        ],
      ),
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
}

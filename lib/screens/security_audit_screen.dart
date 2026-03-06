import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../widgets/neumorphic/neumorphic_container.dart';
import '../../widgets/neumorphic/neumorphic_button.dart';
import '../../providers/security_audit_provider.dart';
import '../../i18n/strings.g.dart';

class SecurityAuditScreen extends ConsumerStatefulWidget {
  const SecurityAuditScreen({super.key});

  @override
  ConsumerState<SecurityAuditScreen> createState() =>
      _SecurityAuditScreenState();
}

class _SecurityAuditScreenState extends ConsumerState<SecurityAuditScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          t.dashboard.security_audit.title,
          style: TextStyle(
            color: AppColors.of(context).textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: auditAsync.when(
        data: (report) {
          // Update animation value if needed, or just use report.score
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Circular Score
                Center(
                  child: NeumorphicContainer(
                    padding: const EdgeInsets.all(32),
                    borderRadius: 150,
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: report.score / 100,
                            strokeWidth: 12,
                            backgroundColor: AppColors.of(
                              context,
                            ).shadowDark.withValues(alpha: 0.2),
                            color: _getScoreColor(context, report.score),
                            strokeCap: StrokeCap.round,
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${report.score}%',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: _getScoreColor(
                                      context,
                                      report.score,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Safe',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.of(context).textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Top Stats
                Row(
                  children: [
                    _buildStatCard(
                      context,
                      icon: Icons.gpp_bad_rounded,
                      title: t.security_audit.scanned,
                      count: report.totalChecked,
                      color: AppColors.of(context).primaryAccent,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push('/compromised-accounts');
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      context,
                      icon: Icons.difference_rounded,
                      title: t.security_audit.reused,
                      count: report.duplicatedCount,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      context,
                      icon: Icons.shield_moon_rounded,
                      title: t.security_audit.weak,
                      count: report.weakCount,
                      color: AppColors.of(context).error,
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                // Generate Password direct access
                SizedBox(
                  width: double.infinity,
                  child: NeumorphicButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // Call global generator
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.generating_tokens,
                            color: AppColors.of(context).primaryAccent,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            t.password_generator.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.of(context).primaryAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Color _getScoreColor(BuildContext context, int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return AppColors.of(context).error;
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int count,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: NeumorphicContainer(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.of(context).textSecondary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

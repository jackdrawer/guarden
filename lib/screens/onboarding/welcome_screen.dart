import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../i18n/strings.g.dart';
import '../../theme/app_colors.dart';
import '../../widgets/neumorphic/neumorphic_button.dart';
import '../../widgets/neumorphic/neumorphic_container.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: NeumorphicContainer(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 92,
                      height: 92,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: AppColors.of(
                        context,
                      ).primaryAccent.withValues(alpha: 0.10),
                    ),
                    child: Text(
                      t.settings.info.about.offline_title,
                      style: TextStyle(
                        color: AppColors.of(context).primaryAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    t.welcome.title,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.of(context).textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.welcome.subtitle,
                    style: TextStyle(
                      color: AppColors.of(context).textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _FeaturePill(
                        icon: Icons.shield_outlined,
                        label: t.settings.info.privacy.encryption_title,
                      ),
                      _FeaturePill(
                        icon: Icons.cloud_upload_outlined,
                        label: t.settings.info.usage.backup_title,
                      ),
                      _FeaturePill(
                        icon: Icons.fingerprint,
                        label: t.onboarding_biometric.title,
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  NeumorphicButton(
                    onPressed: () => context.go('/onboarding'),
                    child: Text(
                      t.welcome.get_started,
                      style: TextStyle(
                        color: AppColors.of(context).primaryAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.of(context).surface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.of(context).primaryAccent),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.of(context).textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

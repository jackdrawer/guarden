import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../i18n/strings.g.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/neumorphic/neumorphic_button.dart';
import '../../widgets/neumorphic/neumorphic_container.dart';
import '../../widgets/neumorphic/neumorphic_textfield.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.onboarding_setup.password_too_short)),
      );
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.onboarding_setup.passwords_do_not_match)),
      );
      return;
    }

    await ref.read(authProvider.notifier).setupVault(_passwordController.text);
    if (mounted) {
      context.go('/biometric-optin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: NeumorphicContainer(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    t.onboarding_setup.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.of(context).textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.onboarding_setup.subtitle,
                    style: TextStyle(
                      color: AppColors.of(context).textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.of(
                        context,
                      ).primaryAccent.withValues(alpha: 0.08),
                    ),
                    child: Column(
                      children: [
                        _OnboardingHintRow(
                          icon: Icons.lock_outline_rounded,
                          label: t.settings.info.privacy.encryption_title,
                          body: t.settings.info.privacy.encryption_body,
                        ),
                        const SizedBox(height: 10),
                        _OnboardingHintRow(
                          icon: Icons.phone_android_rounded,
                          label: t.settings.info.privacy.storage_title,
                          body: t.settings.info.privacy.storage_body,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  NeumorphicTextField(
                    controller: _passwordController,
                    hintText: t.general.master_password_hint,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 16),
                  NeumorphicTextField(
                    controller: _confirmController,
                    hintText: t.onboarding_setup.confirm_password_hint,
                    obscureText: true,
                    prefixIcon: Icons.lock_reset,
                  ),
                  const SizedBox(height: 24),
                  NeumorphicButton(
                    onPressed: _submit,
                    child: Text(
                      t.onboarding_setup.create_vault,
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

class _OnboardingHintRow extends StatelessWidget {
  const _OnboardingHintRow({
    required this.icon,
    required this.label,
    required this.body,
  });

  final IconData icon;
  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.of(context).primaryAccent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.of(context).textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: TextStyle(
                  color: AppColors.of(context).textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

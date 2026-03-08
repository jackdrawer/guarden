import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../i18n/strings.g.dart';
import '../../services/biometric_service.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/neumorphic/neumorphic_button.dart';
import '../../widgets/neumorphic/neumorphic_container.dart';
import '../../widgets/lottie_animation_widget.dart';

class BiometricOptInScreen extends ConsumerStatefulWidget {
  const BiometricOptInScreen({super.key});

  @override
  ConsumerState<BiometricOptInScreen> createState() =>
      _BiometricOptInScreenState();
}

class _BiometricOptInScreenState extends ConsumerState<BiometricOptInScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _isLoading = true;
  bool _hasBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final canUse = await _biometricService.canCheckBiometrics();
    setState(() {
      _hasBiometrics = canUse;
      _isLoading = false;
    });
  }

  void _finishSetup() {
    context.go('/');
  }

  void _enableBiometrics() async {
    final success = await _biometricService.authenticate();
    if (success) {
      // CRITICAL FIX: Save biometric login setting via notifier to update state
      await ref.read(settingsProvider.notifier).toggleBiometricLogin(true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.onboarding_biometric.enabled_message)),
        );
        _finishSetup();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.onboarding_biometric.failed_message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.of(context).background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasBiometrics) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _finishSetup();
      });
      return Scaffold(backgroundColor: AppColors.of(context).background);
    }

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
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.of(
                            context,
                          ).primaryAccent.withValues(alpha: 0.22),
                          AppColors.of(
                            context,
                          ).primaryAccent.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: LottieAnimationWidget(
                        animation: GuardenAnimation.fingerprintScan,
                        size: 70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    t.onboarding_biometric.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.of(context).textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.onboarding_biometric.subtitle,
                    style: TextStyle(
                      color: AppColors.of(context).textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: AppColors.of(context).surface,
                    ),
                    child: Text(
                      t.auth_login.biometric_tooltip,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.of(context).textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  NeumorphicButton(
                    onPressed: _enableBiometrics,
                    child: Text(
                      t.general.enable,
                      style: TextStyle(
                        color: AppColors.of(context).primaryAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _finishSetup,
                    child: Text(
                      t.general.later,
                      style: TextStyle(
                        color: AppColors.of(context).textSecondary,
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

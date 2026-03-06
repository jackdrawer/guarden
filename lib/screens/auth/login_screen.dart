import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/strings.g.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/secure_storage_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/lottie_animation_widget.dart';
import '../../widgets/neumorphic/neumorphic_button.dart';
import '../../widgets/neumorphic/neumorphic_container.dart';
import '../../widgets/neumorphic/neumorphic_textfield.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricsOnLoad();
    });
  }

  Future<void> _checkBiometricsOnLoad() async {
    try {
      final settings = await ref.read(settingsProvider.future);
      if (settings.biometricLogin) {
        final canUse = await ref.read(authProvider.notifier).canUseBiometrics();
        if (canUse && mounted) {
          await ref.read(authProvider.notifier).biometricUnlock();
        }
      }
    } catch (e) {
      debugPrint('Biometric load check failed: $e');
    }
  }

  Future<void> _handleBiometricLogin() async {
    final canUse = await ref.read(authProvider.notifier).canUseBiometrics();
    if (!canUse) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.auth_login.biometric_unavailable)),
        );
      }
      return;
    }

    final success = await ref.read(authProvider.notifier).biometricUnlock();
    if (!success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.auth_login.biometric_failed)));
    }
  }

  Future<void> _handleLogin() async {
    if (_passwordController.text.isEmpty) return;

    setState(() => _isLoading = true);

    final success = await ref
        .read(authProvider.notifier)
        .login(_passwordController.text);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.auth_login.wrong_master_password)),
      );
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
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
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.general.app_name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.of(context).textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.auth_login.subtitle,
                    style: TextStyle(
                      color: AppColors.of(context).textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  Tooltip(
                    message: t.auth_login.master_password_tooltip,
                    child: NeumorphicTextField(
                      controller: _passwordController,
                      hintText: t.general.master_password_hint,
                      obscureText: true,
                      prefixIcon: Icons.key,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.of(context).primaryAccent,
                          ),
                        )
                      : NeumorphicButton(
                          onPressed: _handleLogin,
                          child: Text(
                            t.auth_login.unlock_button,
                            style: TextStyle(
                              color: AppColors.of(context).primaryAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                  Tooltip(
                    message: t.auth_login.biometric_tooltip,
                    child: NeumorphicButton(
                      onPressed: _handleBiometricLogin,
                      semanticLabel: t.auth_login.use_biometrics,
                      padding: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
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
                                border: Border.all(
                                  color: AppColors.of(
                                    context,
                                  ).primaryAccent.withValues(alpha: 0.28),
                                ),
                              ),
                              child: LottieAnimationWidget(
                                animation: GuardenAnimation.fingerprintScan,
                                size: 46,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.auth_login.use_biometrics,
                                    style: TextStyle(
                                      color: AppColors.of(context).textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    t.auth_login.biometric_tooltip,
                                    style: TextStyle(
                                      color: AppColors.of(
                                        context,
                                      ).textSecondary,
                                      fontSize: 12,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 18,
                              color: AppColors.of(context).primaryAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showForgotPinDialog(context),
                    child: Text(
                      t.auth_login.forgot_master_password,
                      style: TextStyle(
                        color: AppColors.of(context).primaryAccent,
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

  void _showForgotPinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.of(ctx).surface,
        title: Text(
          t.auth_login.forgot_master_password,
          style: TextStyle(color: AppColors.of(ctx).textPrimary),
        ),
        content: Text(
          t.auth_login.forgot_dialog_body,
          style: TextStyle(color: AppColors.of(ctx).textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t.general.close),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.of(ctx).error,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final confirmed = await _showResetConfirmationDialog(context);
              if (!confirmed) return;
              await ref.read(secureStorageProvider).deleteVaultAccessData();
              await ref.read(authProvider.notifier).resetAfterPanic();
            },
            child: Text(t.auth_login.reset_device_panic),
          ),
        ],
      ),
    );
  }

  Future<bool> _showResetConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.of(ctx).surface,
            title: Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: AppColors.of(ctx).error,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.auth_login.reset_device_confirm_title,
                    style: TextStyle(color: AppColors.of(ctx).error),
                  ),
                ),
              ],
            ),
            content: Text(
              t.auth_login.reset_device_confirm_body,
              style: TextStyle(color: AppColors.of(ctx).textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(t.general.cancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.of(ctx).error,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(t.auth_login.reset_device_confirm_action),
              ),
            ],
          ),
        ) ??
        false;
  }
}

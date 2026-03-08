import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../i18n/strings.g.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/activity_provider.dart';
import '../../services/clipboard_service.dart';
import '../../services/crypto_service.dart';
import '../../services/logo_service.dart';
import '../../services/secure_storage_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/neumorphic/neumorphic_button.dart';
import '../../widgets/neumorphic/neumorphic_container.dart';
import '../../widgets/lottie_animation_widget.dart';
import '../../utils/currency_utils.dart';

class SubscriptionDetailScreen extends ConsumerStatefulWidget {
  final String subscriptionId;

  const SubscriptionDetailScreen({super.key, required this.subscriptionId});

  @override
  ConsumerState<SubscriptionDetailScreen> createState() =>
      _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState
    extends ConsumerState<SubscriptionDetailScreen> {
  static const _hiddenPassword = '********';

  bool _isPasswordRevealed = false;
  String _decryptedPassword = _hiddenPassword;

  Future<void> _revealPassword(String encryptedPassword) async {
    if (_isPasswordRevealed) {
      setState(() {
        _isPasswordRevealed = false;
        _decryptedPassword = _hiddenPassword;
      });
      return;
    }

    final authPassed = await ref
        .read(authProvider.notifier)
        .authenticateForSensitiveAction(
          context,
          wrongPasswordMessage: t.settings.master_password_wrong,
        );
    if (!authPassed) return;

    try {
      final secureStorage = ref.read(secureStorageProvider);
      final cryptoService = ref.read(cryptoProvider);
      final key = await secureStorage.getEncryptionKey();

      if (key != null && encryptedPassword.isNotEmpty) {
        final decrypted = await cryptoService.decryptWithBase64Key(
          encryptedPassword,
          key,
        );
        setState(() {
          _decryptedPassword = decrypted;
          _isPasswordRevealed = true;
        });

        Future.delayed(const Duration(seconds: 15), () {
          if (mounted && _isPasswordRevealed) {
            setState(() {
              _isPasswordRevealed = false;
              _decryptedPassword = _hiddenPassword;
            });
          }
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.general.password_decrypt_failed)),
        );
      }
    }
  }

  Future<void> _copyToClipboard(
    String label,
    String value, {
    String? activitySubtitle,
  }) async {
    if (value.isEmpty || value == _hiddenPassword) return;

    final authPassed = await ref
        .read(authProvider.notifier)
        .authenticateForSensitiveAction(
          context,
          wrongPasswordMessage: t.settings.master_password_wrong,
        );
    if (!authPassed) return;

    await ref.read(clipboardServiceProvider).copy(value);

    if (!mounted) return;

    // Record activity
    final items = ref.read(subscriptionProvider).valueOrNull ?? [];
    final matches = items.where((s) => s.id == widget.subscriptionId);
    final item = matches.isNotEmpty ? matches.first : null;

    if (item != null && activitySubtitle != null) {
      ref
          .read(activityProvider.notifier)
          .recordActivity(
            title: item.serviceName,
            subtitle: activitySubtitle,
            type: 'subscription',
            action: 'copied',
            itemId: item.id,
          );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.general.copied_label(label: label)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value, {
    bool isSensitive = false,
    VoidCallback? onReveal,
    bool isRevealed = true,
    String? activitySubtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.of(
                        context,
                      ).textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSensitive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: AppColors.of(context).textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSensitive)
              IconButton(
                icon: Icon(
                  isRevealed ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.of(context).textSecondary,
                ),
                onPressed: onReveal,
              ),
            IconButton(
              icon: Icon(
                Icons.copy,
                color: AppColors.of(context).primaryAccent,
              ),
              onPressed: () => _copyToClipboard(
                label,
                value,
                activitySubtitle: activitySubtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subs = ref.watch(subscriptionProvider).valueOrNull ?? [];
    final subIndex = subs.indexWhere((b) => b.id == widget.subscriptionId);
    final logoService = ref.watch(logoServiceProvider);

    if (subIndex == -1) {
      return Scaffold(
        backgroundColor: AppColors.of(context).background,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Text(
            t.general.record_not_found,
            style: TextStyle(color: AppColors.of(context).textPrimary),
          ),
        ),
      );
    }

    final sub = subs[subIndex];
    final costText =
        '${CurrencyUtils.formatAmount(sub.monthlyCost, sub.currency)} ${sub.billingCycle == 'yearly' ? t.subscription_form.yearly : t.subscriptions.per_month}';

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppColors.of(context).textPrimary),
        title: Text(
          t.subscription_detail.title,
          style: TextStyle(
            color: AppColors.of(context).textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.of(context).primaryAccent),
            onPressed: () => context.push('/edit-subscription/${sub.id}'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  logoService.getLogoWidget(sub.url, size: 80),
                  const SizedBox(height: 16),
                  Text(
                    sub.serviceName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.of(context).textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    costText,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.of(context).primaryAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoCard(
              t.general.username_email,
              sub.emailOrUsername,
              activitySubtitle: t.dashboard.activities.copied_username,
            ),
            if (sub.encryptedPassword.isNotEmpty)
              _buildInfoCard(
                t.general.password,
                _decryptedPassword,
                isSensitive: true,
                isRevealed: _isPasswordRevealed,
                onReveal: () => _revealPassword(sub.encryptedPassword),
                activitySubtitle: t.dashboard.activities.copied_password,
              ),
            _buildInfoCard(
              t.subscription_detail.next_billing_date_label,
              '${sub.nextBillingDate.day}/${sub.nextBillingDate.month}/${sub.nextBillingDate.year}',
            ),
            const SizedBox(height: 24),
            NeumorphicContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t.general.hide_in_travel_mode,
                    style: TextStyle(color: AppColors.of(context).textPrimary),
                  ),
                  Switch(
                    value:
                        ref
                            .watch(settingsProvider)
                            .valueOrNull
                            ?.travelProtectedIds
                            .contains(sub.id) ??
                        false,
                    activeColor: AppColors.of(context).primaryAccent,
                    onChanged: (val) {
                      ref
                          .read(settingsProvider.notifier)
                          .toggleTravelProtection(sub.id, val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            NeumorphicButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.of(context).surface,
                    title: Text(
                      t.general.confirm_delete_title,
                      style: TextStyle(
                        color: AppColors.of(context).textPrimary,
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LottieAnimationWidget(
                          animation: GuardenAnimation.deleteItem,
                          size: 100,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t.general.confirm_delete_message,
                          style: TextStyle(
                            color: AppColors.of(context).textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text(
                          t.general.cancel,
                          style: TextStyle(
                            color: AppColors.of(context).textSecondary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text(
                          t.general.delete,
                          style: TextStyle(color: AppColors.of(context).error),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  ref
                      .read(subscriptionProvider.notifier)
                      .deleteSubscription(sub.id);
                  if (context.mounted) {
                    context.pop();
                  }
                }
              },
              child: Text(
                t.general.delete_record,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.of(context).error,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

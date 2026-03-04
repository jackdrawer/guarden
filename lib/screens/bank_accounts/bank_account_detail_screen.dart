import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

import '../../i18n/strings.g.dart';
import '../../providers/bank_account_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/clipboard_service.dart';
import '../../services/crypto_service.dart';
import '../../services/logo_service.dart';
import '../../services/secure_storage_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/neumorphic/neumorphic_button.dart';
import '../../widgets/neumorphic/neumorphic_container.dart';

class BankAccountDetailScreen extends ConsumerStatefulWidget {
  final String accountId;

  const BankAccountDetailScreen({super.key, required this.accountId});

  @override
  ConsumerState<BankAccountDetailScreen> createState() =>
      _BankAccountDetailScreenState();
}

class _BankAccountDetailScreenState
    extends ConsumerState<BankAccountDetailScreen> {
  bool _isPasswordRevealed = false;
  String _decryptedPassword = '********';
  String _decryptedNotes = '';
  bool _isNotesRevealed = false;

  Future<bool> _requestMasterPassword() async {
    final controller = TextEditingController();
    try {
      var obscure = true;
      final password = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: AppColors.of(ctx).surface,
                title: Text(
                  t.general.authentication,
                  style: TextStyle(color: AppColors.of(ctx).textPrimary),
                ),
                content: TextField(
                  controller: controller,
                  autofocus: true,
                  obscureText: obscure,
                  style: TextStyle(color: AppColors.of(ctx).textPrimary),
                  decoration: InputDecoration(
                    labelText: t.general.master_password_hint,
                    labelStyle: TextStyle(
                      color: AppColors.of(ctx).textSecondary,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => obscure = !obscure),
                      icon: Icon(
                        obscure ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.of(ctx).textSecondary,
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      t.general.cancel,
                      style: TextStyle(color: AppColors.of(ctx).textSecondary),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(controller.text),
                    child: Text(t.general.confirm),
                  ),
                ],
              );
            },
          );
        },
      );

      if (password == null || password.isEmpty) return false;
      final isValid = await ref
          .read(authProvider.notifier)
          .verifyMasterPassword(password);
      if (!isValid && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.settings.master_password_wrong)),
        );
      }
      return isValid;
    } finally {
      // Small delay to ensure dialog animation completes before disposing controller
      Future.delayed(const Duration(milliseconds: 200), () {
        controller.dispose();
      });
    }
  }

  Future<bool> _authenticate() async {
    final settings = ref.read(settingsProvider).valueOrNull;
    final isConfirmEnabled = settings?.biometricConfirm ?? false;

    if (!isConfirmEnabled) return true;

    final canUse = await ref.read(authProvider.notifier).canUseBiometrics();
    if (canUse) {
      final unlocked = await ref.read(authProvider.notifier).biometricUnlock();
      if (unlocked) return true;
    }

    // Fallback: request master password if biometrics failed or not available
    return await _requestMasterPassword();
  }

  Future<void> _revealPassword(String encryptedPassword) async {
    if (_isPasswordRevealed) {
      setState(() {
        _isPasswordRevealed = false;
        _decryptedPassword = '********';
      });
      return;
    }

    final authPassed = await _authenticate();
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
              _decryptedPassword = '********';
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

  Future<void> _revealNotes(String encryptedNotes) async {
    if (_isNotesRevealed || encryptedNotes.isEmpty) return;

    try {
      final secureStorage = ref.read(secureStorageProvider);
      final cryptoService = ref.read(cryptoProvider);
      final key = await secureStorage.getEncryptionKey();

      if (key != null) {
        final decrypted = await cryptoService.decryptWithBase64Key(
          encryptedNotes,
          key,
        );
        setState(() {
          _decryptedNotes = decrypted;
          _isNotesRevealed = true;
        });
      }
    } catch (_) {
      debugPrint('Failed to load notes');
    }
  }

  void _copyToClipboard(String label, String value) {
    if (value == '********') return;
    ref.read(clipboardServiceProvider).copy(value);

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
                tooltip: isRevealed
                    ? t.general.hide_password
                    : t.general.show_password,
                icon: Icon(
                  isRevealed ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.of(context).textSecondary,
                ),
                onPressed: onReveal,
              ),
            IconButton(
              tooltip: t.general.copy,
              icon: Icon(
                Icons.copy,
                color: AppColors.of(context).primaryAccent,
              ),
              onPressed: () => _copyToClipboard(label, value),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(bankAccountProvider).valueOrNull ?? [];
    final accountIndex = accounts.indexWhere((b) => b.id == widget.accountId);
    final logoService = ref.watch(logoServiceProvider);

    if (accountIndex == -1) {
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

    final account = accounts[accountIndex];

    if (account.encryptedNotes.isNotEmpty && !_isNotesRevealed) {
      _revealNotes(account.encryptedNotes);
    }

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppColors.of(context).textPrimary),
        title: Text(
          t.bank_detail.title,
          style: TextStyle(
            color: AppColors.of(context).textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: t.general.edit,
            icon: Icon(Icons.edit, color: AppColors.of(context).primaryAccent),
            onPressed: () => context.push('/edit-bank/${account.id}'),
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
                  logoService.getLogoWidget(account.url, size: 80),
                  const SizedBox(height: 16),
                  Text(
                    account.bankName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.of(context).textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoCard(
              t.bank_detail.username_national_id_label,
              account.accountName,
            ),
            _buildInfoCard(
              t.general.password,
              _decryptedPassword,
              isSensitive: true,
              isRevealed: _isPasswordRevealed,
              onReveal: () => _revealPassword(account.encryptedPassword),
            ),
            if (account.encryptedNotes.isNotEmpty)
              _buildInfoCard(t.general.notes, _decryptedNotes),
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
                            .contains(account.id) ??
                        false,
                    activeColor: AppColors.of(context).primaryAccent,
                    onChanged: (val) {
                      ref
                          .read(settingsProvider.notifier)
                          .toggleTravelProtection(account.id, val);
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
                    content: Text(
                      t.general.confirm_delete_message,
                      style: TextStyle(
                        color: AppColors.of(context).textSecondary,
                      ),
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
                      .read(bankAccountProvider.notifier)
                      .deleteBankAccount(account.id);
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

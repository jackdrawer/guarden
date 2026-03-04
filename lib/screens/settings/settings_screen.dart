import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../i18n/strings.g.dart';
import '../../errors/app_errors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/backup_service.dart';
import '../../services/biometric_service.dart';
import '../../services/secure_storage_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/neumorphic/neumorphic_container.dart';
import '../../widgets/ads/ad_banner_widget.dart';
import '../../services/google_drive_backup_service.dart';
import '../../providers/bank_account_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/web_password_provider.dart';

class SettingsScreen extends ConsumerWidget {
  SettingsScreen({super.key});

  final BiometricService _biometricService = BiometricService();

  Future<String?> _requestPasswordConfirmation(
    BuildContext context, {
    String? title,
  }) async {
    final controller = TextEditingController();
    var obscure = true;

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: AppColors.of(ctx).surface,
              title: Text(
                title ?? t.settings.master_password_confirmation,
                style: TextStyle(color: AppColors.of(ctx).textPrimary),
              ),
              content: TextField(
                controller: controller,
                autofocus: true,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: t.settings.master_password,
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => obscure = !obscure),
                    icon: Icon(
                      obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                onSubmitted: (value) => Navigator.of(ctx).pop(value),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(t.general.cancel),
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

    controller.dispose();
    return result;
  }

  Future<bool> _authenticate(BuildContext context, WidgetRef ref) async {
    final settings =
        ref.read(settingsProvider).valueOrNull ?? SettingsState.initial();

    // Check if either biometric unlock or biometric confirmation for sensitive
    // actions is enabled. Users expect biometric to work if they enabled it
    // for app unlock, even if they didn't explicitly enable it for confirmations.
    final biometricEnabled =
        settings.biometricLogin || settings.biometricConfirm;

    if (biometricEnabled) {
      final canUseBiometric = await _biometricService.canCheckBiometrics();
      if (canUseBiometric) {
        final biometricOk = await _biometricService.authenticate(
          reason: t.settings.secure_action_reason,
        );
        if (biometricOk) return true;
      }
    }

    if (!context.mounted) return false;
    final password = await _requestPasswordConfirmation(context);
    if (password == null || password.isEmpty) return false;

    final isValid = await ref
        .read(authProvider.notifier)
        .verifyMasterPassword(password);

    if (!isValid && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.settings.master_password_wrong)));
    }
    return isValid;
  }

  Future<String?> _authenticateAndGetPassword(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (!context.mounted) return null;

    // We need raw master password text to encrypt/decrypt backup.
    // So we do not skip this with biometrics.
    final password = await _requestPasswordConfirmation(
      context,
      title: t.settings.master_password_for_security,
    );
    if (password == null || password.isEmpty) return null;

    final isValid = await ref
        .read(authProvider.notifier)
        .verifyMasterPassword(password);
    if (!isValid && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.settings.master_password_wrong)));
      return null;
    }
    return password;
  }

  Future<void> _handlePanicMode(BuildContext context, WidgetRef ref) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.of(ctx).surface,
            title: Text(
              t.settings.panic_mode_title,
              style: TextStyle(color: AppColors.of(ctx).textPrimary),
            ),
            content: Text(
              t.settings.panic_mode_confirm_message,
              style: TextStyle(color: AppColors.of(ctx).textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(t.general.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(t.settings.delete_keys),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !context.mounted) return;

    final authPassed = await _authenticate(context, ref);
    if (!authPassed) return;

    await ref.read(secureStorageProvider).deleteVaultAccessData();
    await ref.read(authProvider.notifier).resetAfterPanic();

    if (context.mounted) {
      context.go('/welcome');
    }
  }

  Future<void> _exportBackupToFile(
    BuildContext context,
    String backupText,
  ) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/guarden_vault_backup.json');
      await file.writeAsString(backupText);
      final result = await Share.shareXFiles([
        XFile(file.path),
      ], subject: 'Guarden Backup');
      if (result.status == ShareResultStatus.success && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.settings.backup_text_copied)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to export backup: $e')));
      }
    }
  }

  Future<String?> _requestRestoreInputText(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        return await file.readAsString();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to read backup file: $e')),
        );
      }
    }
    return null;
  }

  Future<bool?> _confirmRestore(
    BuildContext context,
    BackupDryRunReport report,
  ) async {
    var overwriteConflicts = false;
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: AppColors.of(ctx).surface,
              title: Text(
                t.settings.dry_run_report,
                style: TextStyle(color: AppColors.of(ctx).textPrimary),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.settings.total_incoming(count: report.totalIncoming)),
                  Text(
                    t.settings.total_conflicts(count: report.totalConflicts),
                  ),
                  Text(t.settings.new_records(count: report.totalNew)),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: overwriteConflicts,
                    onChanged: (value) =>
                        setState(() => overwriteConflicts = value ?? false),
                    title: Text(t.settings.overwrite_conflicts),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(t.general.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(overwriteConflicts),
                  child: Text(t.general.apply),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleExportBackup(BuildContext context, WidgetRef ref) async {
    final passphrase = await _authenticateAndGetPassword(context, ref);
    if (passphrase == null || !context.mounted) return;

    try {
      final backupText = await ref
          .read(backupServiceProvider)
          .exportEncryptedBackup(passphrase: passphrase);
      if (!context.mounted) return;
      await _exportBackupToFile(context, backupText);
    } on BackupException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } on AppError catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.userMessage)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.settings.backup_export_failed)),
        );
      }
    }
  }

  Future<void> _handleRestoreBackup(BuildContext context, WidgetRef ref) async {
    final passphrase = await _authenticateAndGetPassword(context, ref);
    if (passphrase == null || !context.mounted) return;

    final backupText = await _requestRestoreInputText(context);
    if (backupText == null || !context.mounted) return;

    try {
      final backupService = ref.read(backupServiceProvider);
      final report = await backupService.dryRunRestore(
        encryptedBackup: backupText,
        passphrase: passphrase,
      );
      if (!context.mounted) return;

      final overwrite = await _confirmRestore(context, report);
      if (overwrite == null || !context.mounted) return;

      final result = await backupService.applyRestore(
        encryptedBackup: backupText,
        passphrase: passphrase,
        overwriteConflicts: overwrite,
      );

      if (context.mounted) {
        // Invalidate providers so UI refreshes with restored data
        ref.invalidate(bankAccountProvider);
        ref.invalidate(subscriptionProvider);
        ref.invalidate(webPasswordProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.settings.restore_completed(
                created: result.created,
                overwritten: result.overwritten,
                skipped: result.skipped,
              ),
            ),
          ),
        );
      }
    } on BackupException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } on AppError catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.userMessage)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.settings.restore_from_backup_failed)),
        );
      }
    }
  }

  Future<void> _handleDriveExportBackup(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final passphrase = await _authenticateAndGetPassword(context, ref);
    if (passphrase == null || !context.mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final backupText = await ref
          .read(backupServiceProvider)
          .exportEncryptedBackup(passphrase: passphrase);

      await ref
          .read(googleDriveBackupServiceProvider)
          .uploadBackupToDrive(backupText);

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // close loader

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.settings.backup_uploaded_drive)));
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // close loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.settings.error_with_message(message: '$e'))),
        );
      }
    }
  }

  Future<void> _handleDriveRestoreBackup(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final passphrase = await _authenticateAndGetPassword(context, ref);
    if (passphrase == null || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final encryptedBackup = await ref
          .read(googleDriveBackupServiceProvider)
          .downloadBackupFromDrive();
      if (encryptedBackup == null) {
        if (!context.mounted) return;
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.settings.no_backup_in_drive)));
        return;
      }

      final backupService = ref.read(backupServiceProvider);
      final report = await backupService.dryRunRestore(
        encryptedBackup: encryptedBackup,
        passphrase: passphrase,
      );

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // close loader

      final overwrite = await _confirmRestore(context, report);
      if (overwrite == null || !context.mounted) return;

      final result = await backupService.applyRestore(
        encryptedBackup: encryptedBackup,
        passphrase: passphrase,
        overwriteConflicts: overwrite,
      );

      if (context.mounted) {
        // Invalidate providers so UI refreshes with restored data
        ref.invalidate(bankAccountProvider);
        ref.invalidate(subscriptionProvider);
        ref.invalidate(webPasswordProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              t.settings.restore_completed(
                created: result.created,
                overwritten: result.overwritten,
                skipped: result.skipped,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.settings.restore_failed_with_error(error: '$e')),
          ),
        );
      }
    }
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    Color? titleColor,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    Widget content = NeumorphicContainer(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              icon,
              color: titleColor ?? AppColors.of(context).textSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: titleColor ?? AppColors.of(context).textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.of(context).textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.of(context).textSecondary,
            ),
          ],
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: content);
    }
    return content;
  }

  Widget _buildNotifToggle({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? tooltip,
  }) {
    Widget content = NeumorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.of(context).textSecondary, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(label)),
          Switch(
            value: value,
            activeColor: AppColors.of(context).primaryAccent,
            onChanged: onChanged,
          ),
        ],
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: content);
    }
    return content;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsArgs =
        ref.watch(settingsProvider).valueOrNull ?? SettingsState.initial();

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.of(context).textSecondary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          t.settings.title,
          style: TextStyle(color: AppColors.of(context).textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            t.settings.sections.system_integration,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Tooltip(
            message: t.settings.tooltips.autofill,
            child: NeumorphicContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.password_rounded,
                    color: AppColors.of(context).textSecondary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Text(t.settings.labels.autofill)),
                  ElevatedButton(
                    onPressed: () async {
                      if (kIsWeb) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(t.settings.web_not_supported)),
                        );
                        return;
                      }
                      await AutofillService().requestSetAutofillService();
                    },
                    child: Text(t.settings.labels.set),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            t.settings.sections.security_privacy,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Tooltip(
            message: t.settings.tooltips.travel_mode,
            child: NeumorphicContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.flight_takeoff,
                    color: AppColors.of(context).textSecondary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Text(t.settings.labels.travel_mode)),
                  Switch(
                    value: settingsArgs.isTravelModeActive,
                    activeColor: AppColors.of(context).primaryAccent,
                    onChanged: (val) async {
                      final authOk = await _authenticate(context, ref);
                      if (authOk) {
                        ref.read(settingsProvider.notifier).toggleTravelMode();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildNotifToggle(
            context: context,
            icon: Icons.fingerprint,
            label: t.settings.labels.biometric_unlock,
            value: settingsArgs.biometricLogin,
            tooltip: t.settings.tooltips.biometric_unlock,
            onChanged: (val) =>
                ref.read(settingsProvider.notifier).toggleBiometricLogin(val),
          ),
          const SizedBox(height: 12),
          _buildNotifToggle(
            context: context,
            icon: Icons.enhanced_encryption_outlined,
            label: t.settings.labels.sensitive_action_confirmation,
            value: settingsArgs.biometricConfirm,
            tooltip: t.settings.tooltips.sensitive_action_confirmation,
            onChanged: (val) =>
                ref.read(settingsProvider.notifier).toggleBiometricConfirm(val),
          ),
          const SizedBox(height: 24),
          Text(
            t.settings.sections.drive_backup,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context: context,
            icon: Icons.cloud_upload_outlined,
            title: t.settings.labels.backup_to_drive,
            subtitle: t.settings.labels.backup_to_drive_subtitle,
            titleColor: AppColors.of(context).primaryAccent,
            tooltip: t.settings.tooltips.backup_to_drive,
            onTap: () => _handleDriveExportBackup(context, ref),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context: context,
            icon: Icons.cloud_download_outlined,
            title: t.settings.labels.restore_from_drive,
            subtitle: t.settings.labels.restore_from_drive_subtitle,
            titleColor: AppColors.of(context).primaryAccent,
            tooltip: t.settings.tooltips.restore_from_drive,
            onTap: () => _handleDriveRestoreBackup(context, ref),
          ),
          const SizedBox(height: 24),
          Text(
            t.settings.sections.manual_import_export,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context: context,
            icon: Icons.backup,
            title: t.settings.labels.copy_to_clipboard,
            subtitle: t.settings.labels.copy_to_clipboard_subtitle,
            tooltip: t.settings.tooltips.export_file,
            onTap: () => _handleExportBackup(context, ref),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context: context,
            icon: Icons.restore_page,
            title: t.settings.labels.restore_from_clipboard,
            subtitle: t.settings.labels.restore_from_clipboard_subtitle,
            tooltip: t.settings.tooltips.import_file,
            onTap: () => _handleRestoreBackup(context, ref),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context: context,
            icon: Icons.local_fire_department,
            title: t.settings.labels.panic_mode,
            subtitle: t.settings.labels.panic_mode_subtitle,
            titleColor: AppColors.of(context).error,
            tooltip: t.settings.tooltips.panic_mode,
            onTap: () async {
              await _handlePanicMode(context, ref);
            },
          ),
          const SizedBox(height: 24),
          Text(
            t.settings.sections.notifications,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          NeumorphicContainer(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: AppColors.of(context).textSecondary,
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(t.settings.labels.enable_notifications)),
                Switch(
                  value: settingsArgs.notificationsEnabled,
                  activeColor: AppColors.of(context).primaryAccent,
                  onChanged: (val) => ref
                      .read(settingsProvider.notifier)
                      .toggleNotificationsEnabled(val),
                ),
              ],
            ),
          ),
          if (settingsArgs.notificationsEnabled) ...[
            const SizedBox(height: 12),
            _buildNotifToggle(
              context: context,
              icon: Icons.lock_clock,
              label: t.settings.labels.bank_password_rotation,
              value: settingsArgs.bankRotationNotif,
              onChanged: (val) => ref
                  .read(settingsProvider.notifier)
                  .toggleBankRotationNotif(val),
            ),
            const SizedBox(height: 12),
            _buildNotifToggle(
              context: context,
              icon: Icons.autorenew,
              label: t.settings.labels.subscription_renewal,
              value: settingsArgs.subscriptionNotif,
              onChanged: (val) => ref
                  .read(settingsProvider.notifier)
                  .toggleSubscriptionNotif(val),
            ),
            const SizedBox(height: 12),
            _buildNotifToggle(
              context: context,
              icon: Icons.shield_outlined,
              label: t.settings.labels.security_alerts,
              value: settingsArgs.securityNotif,
              onChanged: (val) =>
                  ref.read(settingsProvider.notifier).toggleSecurityNotif(val),
            ),
          ],
          const SizedBox(height: 32),
          const AdBannerWidget(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../i18n/strings.g.dart';
import '../../errors/app_errors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/backup_service.dart';
import '../../services/biometric_service.dart';
import '../../services/secure_storage_service.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../widgets/neumorphic/neumorphic_container.dart';
import '../../widgets/neumorphic/neumorphic_switch.dart';
import '../../widgets/ads/ad_banner_widget.dart';
import '../../widgets/theme_selector.dart';
import '../../services/google_drive_backup_service.dart';
import '../../providers/bank_account_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/web_password_provider.dart';
import '../../utils/currency_utils.dart';
import 'info_detail_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final BiometricService _biometricService = BiometricService();
  List<BackupMetadata> _backupList = [];
  bool _isLoadingBackups = false;
  String? _appVersionLabel;

  @override
  void initState() {
    super.initState();
    _loadBackupList();
    _loadAppVersion();
  }

  Future<void> _loadBackupList() async {
    setState(() => _isLoadingBackups = true);
    try {
      final backups = await ref.read(backupServiceProvider).getBackupList();
      if (mounted) {
        setState(() => _backupList = backups);
      }
    } catch (e) {
      debugPrint('Failed to load backup list: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingBackups = false);
      }
    }
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final version = info.version.trim();
      final build = info.buildNumber.trim();
      final label = build.isEmpty
          ? 'v$version'
          : t.settings.version_format(version: version, build: build);

      if (mounted) {
        setState(() => _appVersionLabel = label);
      }
    } catch (e) {
      debugPrint('Failed to load app version: $e');
      if (mounted) {
        setState(() => _appVersionLabel = t.settings.version_unknown);
      }
    }
  }

  Future<String?> _requestPasswordConfirmation(
    BuildContext context, {
    String? title,
  }) async {
    final controller = TextEditingController();
    try {
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
      return result;
    } finally {
      // Small delay to ensure dialog animation completes before disposing controller
      Future.delayed(const Duration(milliseconds: 200), () {
        controller.dispose();
      });
    }
  }

  Future<bool> _authenticate(BuildContext context) async {
    final settings =
        ref.read(settingsProvider).valueOrNull ?? SettingsState.initial();

    // Check if either biometric unlock or biometric confirmation for sensitive
    // actions is enabled. Users expect biometric to work if they enabled it
    // for app unlock, even if they didn't explicitly enable it for confirmations.
    // Check if biometric auth is available and preferred.
    final biometricEnabled =
        settings.biometricLogin || settings.biometricConfirm;

    if (biometricEnabled) {
      try {
        final canUseBiometric = await _biometricService.canCheckBiometrics();
        final hasEnrolled =
            (await _biometricService.getAvailableBiometrics()).isNotEmpty;

        if (canUseBiometric && hasEnrolled) {
          final biometricOk = await _biometricService.authenticate(
            reason: t.settings.secure_action_reason,
          );
          if (biometricOk) return true;
        }
      } catch (e) {
        debugPrint('Biometric authentication pre-check failed: $e');
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

  Future<String?> _authenticateAndGetPassword(BuildContext context) async {
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

  Future<void> _handlePanicMode(BuildContext context) async {
    final confirmController = TextEditingController();
    final confirmKeyword = t.settings.panic_mode_confirm_keyword;

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => StatefulBuilder(
            builder: (ctx, setState) {
              final canDelete = confirmController.text == confirmKeyword;
              return AlertDialog(
                backgroundColor: AppColors.of(ctx).surface,
                title: Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: AppColors.of(ctx).error,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.settings.panic_mode_title,
                      style: TextStyle(color: AppColors.of(ctx).error),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.settings.panic_mode_confirm_message,
                      style: TextStyle(color: AppColors.of(ctx).textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t.settings.panic_mode_confirm_prompt(
                        keyword: confirmKeyword,
                      ),
                      style: TextStyle(
                        color: AppColors.of(ctx).textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: confirmController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: t.settings.panic_mode_confirm_hint(
                          keyword: confirmKeyword,
                        ),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.of(ctx).error,
                          ),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(t.general.cancel),
                  ),
                  ElevatedButton(
                    onPressed: canDelete
                        ? () => Navigator.of(ctx).pop(true)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.of(ctx).error,
                      disabledBackgroundColor: AppColors.of(
                        ctx,
                      ).error.withAlpha(80),
                    ),
                    child: Text(
                      t.settings.delete_keys,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ) ??
        false;

    confirmController.dispose();

    if (!confirmed || !context.mounted) return;

    final authPassed = await _authenticate(context);
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
      final bytes = Uint8List.fromList(backupText.codeUnits);
      final path = await FileSaver.instance.saveAs(
        name: 'guarden_vault_backup_${DateTime.now().millisecondsSinceEpoch}',
        bytes: bytes,
        fileExtension: 'json',
        mimeType: MimeType.json,
      );

      if (path != null && path.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.settings.alerts.export_success)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.settings.errors.backup_export_failed)),
        );
      }
    }
  }

  Future<String?> _requestRestoreInputText(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        if (file.bytes != null) {
          return String.fromCharCodes(file.bytes!);
        } else if (file.path != null) {
          // Fallback to IO for platforms that do not load bytes directly
          // We can use dart:io here again, so we might need dart:io import back
          // actually since we removed dart:io above, we need to leave it
          return await File(file.path!).readAsString();
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.settings.errors.backup_read_failed)),
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

  Future<void> _showBackupListDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.of(ctx).surface,
        title: Text(
          t.settings.backup_history_title,
          style: TextStyle(color: AppColors.of(ctx).textPrimary),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: _isLoadingBackups
              ? const Center(child: CircularProgressIndicator())
              : _backupList.isEmpty
              ? Text(
                  t.settings.no_backups_yet,
                  style: TextStyle(color: AppColors.of(ctx).textSecondary),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _backupList.length,
                  itemBuilder: (context, index) {
                    final backup = _backupList[index];
                    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
                    final backupService = ref.read(backupServiceProvider);
                    final isDriveBackup = backup.location == 'drive';
                    final hasDriveInfo = backup.driveFileId != null;

                    return Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Stack(
                            children: [
                              Icon(
                                Icons.backup,
                                color: isDriveBackup
                                    ? AppColors.of(context).primaryAccent
                                    : AppColors.of(context).textSecondary,
                              ),
                              if (isDriveBackup)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.of(context).success,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.of(context).surface,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            backup.name,
                            style: TextStyle(
                              color: AppColors.of(context).textPrimary,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${dateFormat.format(backup.createdAt)} • ${backupService.formatFileSize(backup.sizeInBytes)}',
                                style: TextStyle(
                                  color: AppColors.of(context).textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    isDriveBackup
                                        ? Icons.cloud_done_outlined
                                        : Icons.phone_android_outlined,
                                    size: 12,
                                    color: isDriveBackup
                                        ? AppColors.of(context).primaryAccent
                                        : AppColors.of(context).textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isDriveBackup
                                        ? t.settings.backup_location_drive
                                        : t.settings.backup_location_local,
                                    style: TextStyle(
                                      color: isDriveBackup
                                          ? AppColors.of(context).primaryAccent
                                          : AppColors.of(context).textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (backup.lastDownloadedFromDrive !=
                                      null) ...[
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.download_done_outlined,
                                      size: 12,
                                      color: AppColors.of(context).success,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${t.settings.downloaded}: ${dateFormat.format(backup.lastDownloadedFromDrive!)}',
                                      style: TextStyle(
                                        color: AppColors.of(context).success,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasDriveInfo)
                                IconButton(
                                  icon: Icon(
                                    Icons.cloud_download_outlined,
                                    color: AppColors.of(context).primaryAccent,
                                    size: 20,
                                  ),
                                  tooltip: t.settings.download_from_drive,
                                  onPressed: () async {
                                    await _handleDriveRestoreBackupById(
                                      context,
                                      backup.driveFileId!,
                                      backup.id,
                                    );
                                  },
                                ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: AppColors.of(context).error,
                                  size: 20,
                                ),
                                tooltip: t.general.delete,
                                onPressed: () async {
                                  await backupService.deleteBackupMetadata(
                                    backup.id,
                                  );
                                  await _loadBackupList();
                                },
                              ),
                            ],
                          ),
                        ),
                        if (index < _backupList.length - 1)
                          Divider(
                            color: AppColors.of(
                              context,
                            ).textSecondary.withAlpha(77),
                            height: 1,
                          ),
                      ],
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t.general.close),
          ),
          if (_backupList.isNotEmpty)
            TextButton(
              onPressed: () async {
                final backupService = ref.read(backupServiceProvider);
                for (final backup in _backupList) {
                  await backupService.deleteBackupMetadata(backup.id);
                }
                await _loadBackupList();
              },
              child: Text(
                t.settings.clear_all,
                style: TextStyle(color: AppColors.of(context).error),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleExportBackup(BuildContext context) async {
    final passphrase = await _authenticateAndGetPassword(context);
    if (passphrase == null || !context.mounted) return;

    try {
      final backupService = ref.read(backupServiceProvider);
      final backupText = await backupService.exportEncryptedBackup(
        passphrase: passphrase,
      );

      // Save backup metadata
      final metadata = BackupMetadata(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Guarden Backup',
        createdAt: DateTime.now(),
        sizeInBytes: backupText.length,
        location: 'local',
      );
      await backupService.saveBackupMetadata(metadata);
      await _loadBackupList();

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

  Future<void> _handleRestoreBackup(BuildContext context) async {
    final passphrase = await _authenticateAndGetPassword(context);
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.invalidate(bankAccountProvider);
          ref.invalidate(subscriptionProvider);
          ref.invalidate(webPasswordProvider);
        });

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

  Future<void> _handleDriveExportBackup(BuildContext context) async {
    final passphrase = await _authenticateAndGetPassword(context);
    if (passphrase == null || !context.mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final backupService = ref.read(backupServiceProvider);
      final backupText = await backupService.exportEncryptedBackup(
        passphrase: passphrase,
      );

      // Upload to Drive and get result with file ID
      final uploadResult = await ref
          .read(googleDriveBackupServiceProvider)
          .uploadBackupToDrive(backupText);

      // Save backup metadata with Drive info
      final metadata = BackupMetadata(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: uploadResult.fileName,
        createdAt: uploadResult.uploadedAt,
        sizeInBytes: backupText.length,
        location: 'drive',
        driveFileId: uploadResult.fileId,
      );
      await backupService.saveBackupMetadata(metadata);
      await _loadBackupList();

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

  Future<void> _handleDriveRestoreBackup(BuildContext context) async {
    final passphrase = await _authenticateAndGetPassword(context);
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
        // Defer to avoid modifying widget tree during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.invalidate(bankAccountProvider);
          ref.invalidate(subscriptionProvider);
          ref.invalidate(webPasswordProvider);
        });

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

  /// Restore a specific backup from Drive by file ID
  Future<void> _handleDriveRestoreBackupById(
    BuildContext context,
    String fileId,
    String metadataId,
  ) async {
    final passphrase = await _authenticateAndGetPassword(context);
    if (passphrase == null || !context.mounted) return;

    Navigator.of(context).pop(); // Close the backup list dialog

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final encryptedBackup = await ref
          .read(googleDriveBackupServiceProvider)
          .downloadBackupFromDriveById(fileId);
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

      // Update the download timestamp
      await backupService.updateBackupDownloadTimestamp(metadataId);
      await _loadBackupList();

      if (context.mounted) {
        // Invalidate providers so UI refreshes with restored data
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.invalidate(bankAccountProvider);
          ref.invalidate(subscriptionProvider);
          ref.invalidate(webPasswordProvider);
        });

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

  Widget _buildInfoTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    String? tooltip,
  }) {
    Widget content = NeumorphicContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.of(context).textSecondary),
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
                    color: AppColors.of(context).textPrimary,
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
        ],
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: content);
    }
    return content;
  }

  void _openInfoScreen(
    BuildContext context, {
    required String title,
    required List<InfoDetailSection> sections,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InfoDetailScreen(title: title, sections: sections),
      ),
    );
  }

  List<InfoDetailSection> _usageInfoSections() {
    return [
      InfoDetailSection(
        title: t.settings.info.usage.intro_title,
        body: t.settings.info.usage.intro_body,
      ),
      InfoDetailSection(
        title: t.settings.info.usage.backup_title,
        body: t.settings.info.usage.backup_body,
      ),
      InfoDetailSection(
        title: t.settings.info.usage.recovery_title,
        body: t.settings.info.usage.recovery_body,
      ),
    ];
  }

  List<InfoDetailSection> _privacyInfoSections() {
    return [
      InfoDetailSection(
        title: t.settings.info.privacy.storage_title,
        body: t.settings.info.privacy.storage_body,
      ),
      InfoDetailSection(
        title: t.settings.info.privacy.encryption_title,
        body: t.settings.info.privacy.encryption_body,
      ),
      InfoDetailSection(
        title: t.settings.info.privacy.telemetry_title,
        body: t.settings.info.privacy.telemetry_body,
      ),
    ];
  }

  List<InfoDetailSection> _aboutInfoSections() {
    return [
      InfoDetailSection(
        title: t.settings.info.about.mission_title,
        body: t.settings.info.about.mission_body,
      ),
      InfoDetailSection(
        title: t.settings.info.about.offline_title,
        body: t.settings.info.about.offline_body,
      ),
      InfoDetailSection(
        title: t.settings.info.about.recovery_title,
        body: t.settings.info.about.recovery_body,
      ),
    ];
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
          NeumorphicSwitch(
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

  Widget _buildLanguageSelector(BuildContext context, SettingsState settings) {
    return NeumorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.translate_rounded,
            color: AppColors.of(context).textSecondary,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(t.settings.labels.language)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: settings.languageCode,
              dropdownColor: AppColors.of(context).background,
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(
                    t.settings.labels.system_default,
                    style: TextStyle(
                      color: AppColors.of(context).textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                ...AppLocale.values.map(
                  (locale) => DropdownMenuItem(
                    value: locale.languageCode,
                    child: Text(
                      locale.languageCode.toUpperCase(),
                      style: TextStyle(
                        color: AppColors.of(context).textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
              onChanged: (val) {
                ref.read(settingsProvider.notifier).setLanguageCode(val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(BuildContext context, SettingsState settings) {
    return NeumorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.monetization_on_outlined,
            color: AppColors.of(context).textSecondary,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(t.settings.labels.default_currency)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: settings.defaultCurrency,
              dropdownColor: AppColors.of(context).background,
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(
                    t.settings.labels.automatic,
                    style: TextStyle(
                      color: AppColors.of(context).textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                ...CurrencyUtils.getCommonCurrencies().map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(
                      c,
                      style: TextStyle(
                        color: AppColors.of(context).textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
              onChanged: (val) {
                ref.read(settingsProvider.notifier).setDefaultCurrency(val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoBackupSection(BuildContext context, SettingsState settings) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final lastSyncText = settings.lastSyncTimestamp != null
        ? dateFormat.format(settings.lastSyncTimestamp!)
        : t.settings.no_backups_yet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.settings.sections.auto_backup,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.of(context).textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        NeumorphicContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.sync,
                    color: AppColors.of(context).textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(t.settings.labels.auto_backup_frequency),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: settings.autoBackupFrequency,
                      dropdownColor: AppColors.of(context).background,
                      items: [
                        DropdownMenuItem(
                          value: 'off',
                          child: Text(
                            t.settings.labels.never,
                            style: TextStyle(
                              color: AppColors.of(context).textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'daily',
                          child: Text(
                            t.settings.labels.daily,
                            style: TextStyle(
                              color: AppColors.of(context).textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'weekly',
                          child: Text(
                            t.settings.labels.weekly,
                            style: TextStyle(
                              color: AppColors.of(context).textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'monthly',
                          child: Text(
                            t.settings.labels.monthly,
                            style: TextStyle(
                              color: AppColors.of(context).textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          ref
                              .read(settingsProvider.notifier)
                              .setAutoBackupFrequency(val);
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (settings.autoBackupFrequency != 'off') ...[
                const Divider(height: 1),
                _buildNotifToggle(
                  context: context,
                  icon: Icons.wifi,
                  label: t.settings.labels.wifi_only,
                  value: settings.backupOnlyOnWifi,
                  onChanged: (val) => ref
                      .read(settingsProvider.notifier)
                      .toggleBackupOnlyOnWifi(val),
                ),
                _buildNotifToggle(
                  context: context,
                  icon: Icons.battery_charging_full,
                  label: t.settings.labels.charging_only,
                  value: settings.backupOnlyWhileCharging,
                  onChanged: (val) => ref
                      .read(settingsProvider.notifier)
                      .toggleBackupOnlyWhileCharging(val),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text(
                '${t.settings.labels.last_sync}: $lastSyncText',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.of(context).textSecondary,
                ),
              ),
              TextButton.icon(
                onPressed: () => _handleDriveExportBackup(context),
                icon: const Icon(Icons.sync, size: 14),
                label: Text(
                  t.settings.labels.sync_now,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
            t.settings.sections.appearance,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Tooltip(
            message: t.settings.tooltips.theme,
            child: const ThemeSelector(),
          ),
          const SizedBox(height: 24),
          Text(
            t.settings.sections.regional_settings,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildLanguageSelector(context, settingsArgs),
          const SizedBox(height: 12),
          _buildCurrencySelector(context, settingsArgs),
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
                  NeumorphicSwitch(
                    value: settingsArgs.isTravelModeActive,
                    activeColor: AppColors.of(context).primaryAccent,
                    onChanged: (val) async {
                      // val contains the intended new value (opposite of current)
                      final authOk = await _authenticate(context);
                      if (authOk && mounted) {
                        await ref
                            .read(settingsProvider.notifier)
                            .setTravelModeActive(val);
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
            onTap: () => _handleDriveExportBackup(context),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context: context,
            icon: Icons.cloud_download_outlined,
            title: t.settings.labels.restore_from_drive,
            subtitle: t.settings.labels.restore_from_drive_subtitle,
            titleColor: AppColors.of(context).primaryAccent,
            tooltip: t.settings.tooltips.restore_from_drive,
            onTap: () => _handleDriveRestoreBackup(context),
          ),
          const SizedBox(height: 24),
          _buildAutoBackupSection(context, settingsArgs),
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
            onTap: () => _handleExportBackup(context),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context: context,
            icon: Icons.restore_page,
            title: t.settings.labels.restore_from_clipboard,
            subtitle: t.settings.labels.restore_from_clipboard_subtitle,
            tooltip: t.settings.tooltips.import_file,
            onTap: () => _handleRestoreBackup(context),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context: context,
            icon: Icons.history,
            title: t.settings.backup_history_title,
            subtitle: _backupList.isEmpty
                ? t.settings.no_backups_yet
                : t.settings.backup_history_saved_count(
                    count: _backupList.length,
                  ),
            tooltip: t.settings.backup_history_tooltip,
            onTap: () => _showBackupListDialog(context),
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
              await _handlePanicMode(context);
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
          const SizedBox(height: 24),
          Text(
            t.settings.sections.help_about,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context: context,
            icon: Icons.menu_book_rounded,
            title: t.settings.labels.usage_guide,
            subtitle: t.settings.labels.usage_guide_subtitle,
            onTap: () => _openInfoScreen(
              context,
              title: t.settings.info.usage.title,
              sections: _usageInfoSections(),
            ),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context: context,
            icon: Icons.privacy_tip_outlined,
            title: t.settings.labels.privacy_overview,
            subtitle: t.settings.labels.privacy_overview_subtitle,
            onTap: () => _openInfoScreen(
              context,
              title: t.settings.info.privacy.title,
              sections: _privacyInfoSections(),
            ),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context: context,
            icon: Icons.info_outline_rounded,
            title: t.settings.labels.about_guarden,
            subtitle: t.settings.labels.about_guarden_subtitle,
            onTap: () => _openInfoScreen(
              context,
              title: t.settings.info.about.title,
              sections: _aboutInfoSections(),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoTile(
            context: context,
            icon: Icons.new_releases_outlined,
            title: t.settings.labels.app_version,
            subtitle:
                _appVersionLabel ?? t.settings.labels.app_version_subtitle,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context: context,
            icon: Icons.article_outlined,
            title: t.settings.labels.open_source_licenses,
            subtitle: t.settings.labels.open_source_licenses_subtitle,
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: t.general.app_name,
                applicationVersion:
                    _appVersionLabel ?? t.settings.version_unknown,
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context: context,
            icon: Icons.privacy_tip,
            title: t.settings.labels.privacy_policy,
            subtitle: t.settings.labels.privacy_policy_subtitle,
            onTap: () => _showLegalDocument(context, 'privacy'),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context: context,
            icon: Icons.description,
            title: t.settings.labels.terms_of_service,
            subtitle: t.settings.labels.terms_of_service_subtitle,
            onTap: () => _showLegalDocument(context, 'terms'),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            context: context,
            icon: Icons.cookie,
            title: t.settings.labels.cookie_policy,
            subtitle: t.settings.labels.cookie_policy_subtitle,
            onTap: () => _showLegalDocument(context, 'cookie'),
          ),
          const SizedBox(height: 32),
          const AdBannerWidget(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showLegalDocument(BuildContext context, String type) {
    String title;
    String content;
    final isTr = LocaleSettings.currentLocale.languageCode == 'tr';

    switch (type) {
      case 'privacy':
        title = t.settings.labels.privacy_policy;
        content = isTr
            ? 'Tüm şifre ve hassas veriler cihazınızda yerel olarak saklanır.\n\n• AES-256 şifreleme ile korunur\n• Ana şifreniz cihazınızdan asla çıkmaz\n• Biyometrik veriler sunuculara gönderilmez\n• Verileriniz satılmaz veya paylaşılmaz'
            : 'All passwords and sensitive data are stored locally on your device.\n\n• Protected with AES-256 encryption\n• Your master password never leaves your device\n• Biometric data is never sent to servers\n• Your data is not sold or shared';
        // No URL needed as button was removed by user
        break;
      case 'terms':
        title = t.settings.labels.terms_of_service;
        content = isTr
            ? 'Uygulamayı kullanarak bu şartları kabul etmiş sayılırsınız.\n\n• Tüm verilerin yedeklerini almak kullanıcının sorumluluğundadır\n• Ana şifrenin güvenliği kullanıcıya aittir\n• Yasadışı kullanım yasaktır'
            : 'By using the app, you accept these terms.\n\n• Taking regular backups is the user\'s responsibility\n• The security of the master password is the user\'s responsibility\n• Illegal use is prohibited';
        // No URL needed
        break;
      case 'cookie':
        title = t.settings.labels.cookie_policy;
        content = isTr
            ? 'Guarden PW Manager çerez kullanmaz.\n\n• Tanımlama bilgileri (cookies) kullanılmaz\n• İzleme teknolojileri kullanılmaz\n• Üçüncü taraf izleyiciler bulunmaz'
            : 'Guarden PW Manager does not use cookies.\n\n• No tracking cookies\n• No tracking technologies\n• No third-party trackers';
        // No URL needed
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(t.general.close),
          ),
        ],
      ),
    );
  }
}

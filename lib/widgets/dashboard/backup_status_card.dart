import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

import '../../i18n/strings.g.dart';
import '../../providers/settings_provider.dart';
import '../../providers/bank_account_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/web_password_provider.dart';
import '../../theme/app_colors.dart';
import '../neumorphic/neumorphic_container.dart';
import '../../services/google_drive_backup_service.dart';
import '../../services/backup_service.dart';

class BackupStatusCard extends ConsumerStatefulWidget {
  const BackupStatusCard({super.key});

  @override
  ConsumerState<BackupStatusCard> createState() => _BackupStatusCardState();
}

class _BackupStatusCardState extends ConsumerState<BackupStatusCard> {
  bool _isSyncing = false;

  Future<void> _handleSync() async {
    if (_isSyncing) return;

    final passphrase = await _requestPasswordConfirmation(context);
    if (passphrase == null || !mounted) return;

    setState(() => _isSyncing = true);

    try {
      final backupService = ref.read(backupServiceProvider);
      final backupText = await backupService.exportEncryptedBackup(
        passphrase: passphrase,
      );

      // Upload to Drive
      final uploadResult = await ref
          .read(googleDriveBackupServiceProvider)
          .uploadBackupToDrive(backupText);

      // Save backup metadata
      final metadata = BackupMetadata(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: uploadResult.fileName,
        createdAt: uploadResult.uploadedAt,
        sizeInBytes: backupText.length,
        location: 'drive',
        driveFileId: uploadResult.fileId,
      );
      await backupService.saveBackupMetadata(metadata);

      // Update last sync timestamp in settings
      await ref
          .read(settingsProvider.notifier)
          .setLastSyncTimestamp(DateTime.now());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.settings.alerts.backup_success)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.settings.errors.generic)));
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Future<String?> _requestPasswordConfirmation(BuildContext context) async {
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
                t.settings.master_password_confirmation,
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

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).valueOrNull;
    final lastSync = settings?.lastSyncTimestamp;

    final bankCount = ref.watch(bankAccountProvider).valueOrNull?.length ?? 0;
    final subCount = ref.watch(subscriptionProvider).valueOrNull?.length ?? 0;
    final pwCount = ref.watch(webPasswordProvider).valueOrNull?.length ?? 0;
    final totalCount = bankCount + subCount + pwCount;

    final colors = AppColors.of(context);

    Color statusColor = colors.error;
    if (lastSync != null) {
      final diff = DateTime.now().difference(lastSync);
      if (diff.inHours < 24) {
        statusColor = colors.success;
      } else if (diff.inDays < 7) {
        statusColor = Colors.orange;
      }
    }

    return NeumorphicContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: Lottie.asset(
                  'assets/animations/cloud_sync.json',
                  animate: _isSyncing,
                  repeat: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.dashboard.backup_status.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastSync != null
                          ? t.dashboard.backup_status.last_sync(
                              time: DateFormat('dd.MM HH:mm').format(lastSync),
                            )
                          : t.dashboard.backup_status.never,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withAlpha(100),
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.dashboard.backup_status.items_secured(count: totalCount),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              _isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : InkWell(
                      onTap: _handleSync,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primaryAccent.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colors.primaryAccent.withAlpha(100),
                          ),
                        ),
                        child: Text(
                          t.dashboard.backup_status.sync_now,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colors.primaryAccent,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

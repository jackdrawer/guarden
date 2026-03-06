import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'google_drive_backup_service.dart';
import 'backup_service.dart';
import 'settings_service.dart';
import 'secure_storage_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('Background backup task started: $task');

    try {
      // 1. Initialize mandatory services for background
      await Hive.initFlutter();
      final settingsService = SettingsService();
      await settingsService.init();

      // 2. Check if auto-backup is enabled
      final frequency = settingsService.getAutoBackupFrequency();
      if (frequency == 'off' && task != 'manual-sync') {
        debugPrint('Auto-backup is disabled.');
        return true;
      }

      // 3. Check data availability
      final secureStorage = SecureStorageService();
      final passphrase = await secureStorage.readValue(
        'guarden_master_password',
      ); // Need to ensure it's saved here
      final encryptionKey = await secureStorage.getEncryptionKey();

      if (passphrase == null || encryptionKey == null) {
        debugPrint('Authentication data missing for background sync.');
        return false;
      }

      // 4. Initialize backup services
      final backupService = BackupService(secureStorage: secureStorage);
      final gdriveService = GoogleDriveBackupService();

      // 5. Generate and upload backup
      final encryptedBackup = await backupService.exportEncryptedBackup(
        passphrase: passphrase,
      );

      final result = await gdriveService.autoBackup(encryptedBackup);

      // 6. Update last sync timestamp
      await settingsService.setLastSyncTimestamp(result.uploadedAt);

      debugPrint('Background backup successful: ${result.fileName}');
      return true;
    } catch (e) {
      debugPrint('Background backup failed: $e');
      return false;
    }
  });
}

class BackupTaskRunner {
  static const String periodicTaskName = 'com.guarden.backup.periodic';
  static const String syncTaskName = 'com.guarden.backup.manual';

  static Future<void> init() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
  }

  static Future<void> schedulePeriodicBackup(
    String frequency, {
    bool wifiOnly = false,
    bool chargingOnly = false,
  }) async {
    if (frequency == 'off') {
      await Workmanager().cancelByUniqueName(periodicTaskName);
      return;
    }

    Duration interval;
    switch (frequency) {
      case 'daily':
        interval = const Duration(hours: 24);
        break;
      case 'weekly':
        interval = const Duration(days: 7);
        break;
      case 'monthly':
        interval = const Duration(days: 30);
        break;
      default:
        interval = const Duration(hours: 24);
    }

    await Workmanager().registerPeriodicTask(
      periodicTaskName,
      'periodic-backup',
      frequency: interval,
      constraints: Constraints(
        networkType: wifiOnly ? NetworkType.unmetered : NetworkType.connected,
        requiresCharging: chargingOnly,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  static Future<void> triggerOneTimeSync() async {
    await Workmanager().registerOneOffTask(
      syncTaskName,
      'manual-sync',
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }
}

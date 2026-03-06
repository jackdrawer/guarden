import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import '../errors/app_errors.dart';
import '../i18n/strings.g.dart';
import 'backup_service.dart';

final googleDriveBackupServiceProvider = Provider<GoogleDriveBackupService>((
  ref,
) {
  return GoogleDriveBackupService();
});

/// Represents a backup file stored in Google Drive
class DriveBackupInfo {
  final String id;
  final String name;
  final DateTime? modifiedTime;
  final int sizeInBytes;
  final String? revisionId;

  DriveBackupInfo({
    required this.id,
    required this.name,
    this.modifiedTime,
    required this.sizeInBytes,
    this.revisionId,
  });
}

/// Represents a revision of a backup file
class DriveBackupRevision {
  final String id;
  final DateTime? modifiedTime;
  final int sizeInBytes;

  DriveBackupRevision({
    required this.id,
    this.modifiedTime,
    required this.sizeInBytes,
  });
}

/// Result of an upload operation
class DriveUploadResult {
  final String fileId;
  final String fileName;
  final DateTime uploadedAt;

  DriveUploadResult({
    required this.fileId,
    required this.fileName,
    required this.uploadedAt,
  });
}

class GoogleDriveBackupService {
  final gsi.GoogleSignIn _googleSignIn = gsi.GoogleSignIn(
    clientId: kIsWeb
        ? const String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: '')
        : null,
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  Future<drive.DriveApi?> _getDriveApi() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return null;
      }

      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) {
        throw AppError(
          'Google session could not be authorized.',
          userMessage: t.settings.errors.gdrive_permission_denied,
        );
      }

      return drive.DriveApi(httpClient);
    } catch (e) {
      debugPrint('Google Drive authentication error: $e');
      throw AppError(
        'An error occurred while connecting to Google account: $e',
        userMessage: t.settings.errors.gdrive_auth_failed,
      );
    }
  }

  /// Generates a timestamp-based backup filename
  String _generateBackupFileName() {
    final now = DateTime.now();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    return 'guarden_vault_$timestamp.backup';
  }

  /// Generates a timestamp-based auto-backup filename
  String _generateAutoBackupFileName() {
    final now = DateTime.now();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    return 'guarden_auto_$timestamp.backup';
  }

  /// Uploads backup to Google Drive with timestamp-based filename
  /// Returns DriveUploadResult with file ID and metadata
  Future<DriveUploadResult> uploadBackupToDrive(String encryptedBackup) async {
    final api = await _getDriveApi();
    if (api == null) {
      throw AppError(
        'Google Drive access was denied.',
        userMessage: t.settings.errors.gdrive_permission_denied,
      );
    }

    try {
      final fileName = _generateBackupFileName();

      // Check if a backup with similar name pattern already exists
      // We'll keep the main latest backup with timestamp naming
      final queryList = await api.files.list(
        spaces: 'appDataFolder',
        q: "name contains 'guarden_vault_' and name contains '.backup'",
      );

      // Delete old timestamped backups if more than 10 exist to keep storage clean
      if (queryList.files != null && queryList.files!.length >= 10) {
        // Sort by modified time and delete oldest
        final fileList = queryList.files!.where((f) => f.id != null).toList();
        fileList.sort(
          (a, b) => (a.modifiedTime ?? DateTime.now()).compareTo(
            b.modifiedTime ?? DateTime.now(),
          ),
        );
        final filesToDelete = fileList.take(fileList.length - 9);
        for (final file in filesToDelete) {
          try {
            await api.files.delete(file.id!);
          } catch (e) {
            debugPrint('Failed to delete old backup: $e');
          }
        }
      }

      final driveFile = drive.File()
        ..name = fileName
        ..parents = ['appDataFolder'];

      final bytes = utf8.encode(encryptedBackup);
      final media = drive.Media(Stream.value(bytes), bytes.length);

      final createdFile = await api.files.create(driveFile, uploadMedia: media);

      return DriveUploadResult(
        fileId: createdFile.id!,
        fileName: fileName,
        uploadedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Upload backup error: $e');
      throw BackupException('Error uploading backup to Google Drive: $e');
    }
  }

  /// Performs an automatic backup to Google Drive.
  /// Uses 'guarden_auto_' prefix and keeps only the last 5 auto-backups.
  Future<DriveUploadResult> autoBackup(String encryptedBackup) async {
    final api = await _getDriveApi();
    if (api == null) {
      throw AppError(
        'Google Drive access was denied.',
        userMessage: t.settings.errors.gdrive_permission_denied,
      );
    }

    try {
      final fileName = _generateAutoBackupFileName();

      // List existing auto-backups
      final queryList = await api.files.list(
        spaces: 'appDataFolder',
        q: "name contains 'guarden_auto_' and name contains '.backup'",
        orderBy: 'modifiedTime desc',
      );

      // Keep only 4 most recent (to make room for the new one, keeping total 5)
      if (queryList.files != null && queryList.files!.length >= 5) {
        final filesToDelete = queryList.files!.sublist(4);
        for (final file in filesToDelete) {
          if (file.id != null) {
            try {
              await api.files.delete(file.id!);
            } catch (e) {
              debugPrint('Failed to delete old auto-backup: $e');
            }
          }
        }
      }

      final driveFile = drive.File()
        ..name = fileName
        ..parents = ['appDataFolder'];

      final bytes = utf8.encode(encryptedBackup);
      final media = drive.Media(Stream.value(bytes), bytes.length);

      final createdFile = await api.files.create(driveFile, uploadMedia: media);

      return DriveUploadResult(
        fileId: createdFile.id!,
        fileName: fileName,
        uploadedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Auto backup error: $e');
      throw BackupException('Error performing auto-backup to Google Drive: $e');
    }
  }

  /// Lists all backup files from Google Drive
  Future<List<DriveBackupInfo>> listBackupsFromDrive() async {
    final api = await _getDriveApi();
    if (api == null) {
      throw AppError(
        'Google Drive access was denied.',
        userMessage: t.settings.errors.gdrive_permission_denied,
      );
    }

    try {
      final queryList = await api.files.list(
        spaces: 'appDataFolder',
        q: "name contains 'guarden_vault_' and name contains '.backup'",
        orderBy: 'modifiedTime desc',
      );

      if (queryList.files == null || queryList.files!.isEmpty) {
        return [];
      }

      return queryList.files!.map((file) {
        return DriveBackupInfo(
          id: file.id!,
          name: file.name ?? 'Unknown',
          modifiedTime: file.modifiedTime?.toLocal(),
          sizeInBytes: int.tryParse(file.size ?? '0') ?? 0,
        );
      }).toList();
    } catch (e) {
      debugPrint('List backups error: $e');
      throw BackupException('Error listing backups from Google Drive: $e');
    }
  }

  /// Gets revision history for a specific backup file
  Future<List<DriveBackupRevision>> getDriveFileRevisions(String fileId) async {
    final api = await _getDriveApi();
    if (api == null) {
      throw AppError(
        'Google Drive access was denied.',
        userMessage: t.settings.errors.gdrive_permission_denied,
      );
    }

    try {
      final revisions = await api.revisions.list(fileId);

      if (revisions.revisions == null || revisions.revisions!.isEmpty) {
        return [];
      }

      return revisions.revisions!.map((rev) {
        return DriveBackupRevision(
          id: rev.id!,
          modifiedTime: rev.modifiedTime?.toLocal(),
          sizeInBytes: int.tryParse(rev.size ?? '0') ?? 0,
        );
      }).toList();
    } catch (e) {
      debugPrint('Get revisions error: $e');
      // Return empty list if revisions are not available
      return [];
    }
  }

  /// Downloads the latest backup from Google Drive
  Future<String?> downloadBackupFromDrive() async {
    final api = await _getDriveApi();
    if (api == null) {
      throw AppError(
        'Google Drive access was denied.',
        userMessage: t.settings.errors.gdrive_permission_denied,
      );
    }

    try {
      // Get the most recent backup file
      final queryList = await api.files.list(
        spaces: 'appDataFolder',
        q: "name contains 'guarden_vault_' and name contains '.backup'",
        orderBy: 'modifiedTime desc',
        pageSize: 1,
      );

      if (queryList.files == null || queryList.files!.isEmpty) {
        return null;
      }

      final fileId = queryList.files!.first.id!;

      final media =
          await api.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final List<int> dataStore = [];
      await for (final data in media.stream) {
        dataStore.addAll(data);
      }

      return utf8.decode(dataStore);
    } catch (e) {
      debugPrint('Download backup error: $e');
      throw BackupException('Error downloading backup from Google Drive: $e');
    }
  }

  /// Downloads a specific backup file by ID
  Future<String?> downloadBackupFromDriveById(String fileId) async {
    final api = await _getDriveApi();
    if (api == null) {
      throw AppError(
        'Google Drive access was denied.',
        userMessage: t.settings.errors.gdrive_permission_denied,
      );
    }

    try {
      final media =
          await api.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final List<int> dataStore = [];
      await for (final data in media.stream) {
        dataStore.addAll(data);
      }

      return utf8.decode(dataStore);
    } catch (e) {
      debugPrint('Download backup by ID error: $e');
      throw BackupException('Error downloading backup from Google Drive: $e');
    }
  }

  /// Downloads a specific revision of a backup file
  Future<String?> downloadBackupRevision(
    String fileId,
    String revisionId,
  ) async {
    final api = await _getDriveApi();
    if (api == null) {
      throw AppError(
        'Google Drive access was denied.',
        userMessage: t.settings.errors.gdrive_permission_denied,
      );
    }

    try {
      final media =
          await api.revisions.get(
                fileId,
                revisionId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final List<int> dataStore = [];
      await for (final data in media.stream) {
        dataStore.addAll(data);
      }

      return utf8.decode(dataStore);
    } catch (e) {
      debugPrint('Download revision error: $e');
      throw BackupException('Error downloading backup revision: $e');
    }
  }

  /// Gets the most recent backup info from Drive
  Future<DriveBackupInfo?> getLatestBackupInfo() async {
    final api = await _getDriveApi();
    if (api == null) {
      return null;
    }

    try {
      final queryList = await api.files.list(
        spaces: 'appDataFolder',
        q: "name contains 'guarden_vault_' and name contains '.backup'",
        orderBy: 'modifiedTime desc',
        pageSize: 1,
      );

      if (queryList.files == null || queryList.files!.isEmpty) {
        return null;
      }

      final file = queryList.files!.first;
      return DriveBackupInfo(
        id: file.id!,
        name: file.name ?? 'Unknown',
        modifiedTime: file.modifiedTime?.toLocal(),
        sizeInBytes: int.tryParse(file.size ?? '0') ?? 0,
      );
    } catch (e) {
      debugPrint('Get latest backup info error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

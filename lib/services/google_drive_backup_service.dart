import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import '../../errors/app_errors.dart';
import '../i18n/strings.g.dart';
import 'backup_service.dart';

final googleDriveBackupServiceProvider = Provider<GoogleDriveBackupService>((
  ref,
) {
  return GoogleDriveBackupService();
});

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

  Future<void> uploadBackupToDrive(String encryptedBackup) async {
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
        q: "name = 'guarden_vault.backup'",
      );

      final fileExists =
          (queryList.files != null && queryList.files!.isNotEmpty);

      final driveFile = drive.File()
        ..name = 'guarden_vault.backup'
        ..parents = ['appDataFolder'];

      final bytes = utf8.encode(encryptedBackup);
      final media = drive.Media(Stream.value(bytes), bytes.length);

      if (fileExists) {
        final existingFileId = queryList.files!.first.id!;
        await api.files.update(
          drive.File(),
          existingFileId,
          uploadMedia: media,
        );
      } else {
        await api.files.create(driveFile, uploadMedia: media);
      }
    } catch (e) {
      debugPrint('Upload backup error: $e');
      throw BackupException('Error uploading backup to Google Drive: $e');
    }
  }

  Future<String?> downloadBackupFromDrive() async {
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
        q: "name = 'guarden_vault.backup'",
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

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

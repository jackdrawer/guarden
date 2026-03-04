import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/app_errors.dart';
import '../models/web_password.dart';
import '../services/database_service.dart';
import '../widgets/error_handler.dart';
import '../i18n/strings.g.dart';
import 'settings_provider.dart';

class WebPasswordNotifier extends AutoDisposeAsyncNotifier<List<WebPassword>> {
  late final DatabaseService _dbService = ref.read(databaseProvider);

  @override
  Future<List<WebPassword>> build() async {
    ref.watch(settingsProvider);
    return _getItems();
  }

  List<WebPassword> _getItems() {
    try {
      final settings = ref.read(settingsProvider).valueOrNull;
      var items = _dbService.webPasswordsBox.values.toList();
      if (settings != null && settings.isTravelModeActive) {
        items = items
            .where((item) => !settings.travelProtectedIds.contains(item.id))
            .toList();
      }
      return items;
    } catch (e) {
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to read web passwords: $e',
          userMessage: t.settings.errors.load_failed,
        ),
      );
      return [];
    }
  }

  void addWebPassword(WebPassword item) {
    try {
      _dbService.webPasswordsBox.put(item.id, item);
      state = AsyncValue.data(_getItems());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to add web password: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
    }
  }

  void updateWebPassword(WebPassword item) {
    try {
      _dbService.webPasswordsBox.put(item.id, item);
      state = AsyncValue.data(_getItems());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to update web password: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
    }
  }

  void deleteWebPassword(String id) {
    try {
      _dbService.webPasswordsBox.delete(id);
      state = AsyncValue.data(_getItems());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to delete web password: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
    }
  }
}

final webPasswordProvider =
    AsyncNotifierProvider.autoDispose<WebPasswordNotifier, List<WebPassword>>(
      WebPasswordNotifier.new,
    );

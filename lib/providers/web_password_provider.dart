import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/web_password.dart';
import '../services/database_service.dart';
import '../widgets/error_handler.dart';
import '../errors/app_errors.dart';

import 'settings_provider.dart';

class WebPasswordNotifier extends AutoDisposeAsyncNotifier<List<WebPassword>> {
  late final _dbService = ref.read(databaseProvider);

  @override
  Future<List<WebPassword>> build() async {
    ref.watch(settingsProvider);
    return _getItems();
  }

  List<WebPassword> _getItems() {
    try {
      final settingsAsync = ref.read(settingsProvider);
      final settings = settingsAsync.value;
      var items = _dbService.webPasswordsBox.values.toList();
      if (settings != null && settings.isTravelModeActive) {
        items = items
            .where((i) => !settings.travelProtectedIds.contains(i.id))
            .toList();
      }
      return items;
    } catch (e) {
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to read web passwords: $e',
          userMessage: "Could not load web passwords.",
        ),
      );
      return [];
    }
  }

  void addWebPassword(WebPassword pwd) {
    try {
      _dbService.webPasswordsBox.put(pwd.id, pwd);
      state = AsyncValue.data(_getItems());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to add web password: $e',
          userMessage: "Could not save web password.",
        ),
      );
    }
  }

  void updateWebPassword(WebPassword pwd) {
    try {
      _dbService.webPasswordsBox.put(pwd.id, pwd);
      state = AsyncValue.data(_getItems());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to update web password: $e',
          userMessage: "Could not update web password.",
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
          userMessage: "Could not delete web password.",
        ),
      );
    }
  }
}

final webPasswordProvider =
    AsyncNotifierProvider.autoDispose<WebPasswordNotifier, List<WebPassword>>(
      WebPasswordNotifier.new,
    );

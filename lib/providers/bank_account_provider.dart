import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/app_errors.dart';
import '../models/bank_account.dart';
import '../services/database_service.dart';
import '../services/text_sanitizer.dart';
import '../widgets/error_handler.dart';
import '../i18n/strings.g.dart';
import 'settings_provider.dart';

class BankAccountNotifier extends AutoDisposeAsyncNotifier<List<BankAccount>> {
  late final DatabaseService _dbService = ref.read(databaseProvider);

  static const String _legacyTextRepairKey = 'legacy_text_repair_v1_done';

  // Travel mode settings cached from build() to avoid watching all settings
  late bool _isTravelModeActive;
  late List<String> _travelProtectedIds;

  @override
  Future<List<BankAccount>> build() async {
    final travelModeSettings = await ref.watch(
      settingsProvider.selectAsync(
        (s) => (
          isActive: s.isTravelModeActive,
          protectedIds: s.travelProtectedIds,
        ),
      ),
    );
    // Cache travel mode settings for use in CRUD operations
    _isTravelModeActive = travelModeSettings.isActive;
    _travelProtectedIds = travelModeSettings.protectedIds;
    return _getItems();
  }

  List<BankAccount> _getItems() {
    final isTravelModeActive = _isTravelModeActive;
    final travelProtectedIds = _travelProtectedIds;
    try {
      var items = _dbService.bankAccountsBox.values.toList();
      _repairLegacyText(items);
      if (isTravelModeActive) {
        items = items
            .where((item) => !travelProtectedIds.contains(item.id))
            .toList();
      }
      return items;
    } catch (e) {
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to read accounts: $e',
          userMessage: t.settings.errors.load_failed,
        ),
      );
      return [];
    }
  }

  void _repairLegacyText(List<BankAccount> items) {
    // Check if migration already completed
    final isMigrationDone =
        _dbService.settingsBox.get(_legacyTextRepairKey) as bool?;
    if (isMigrationDone == true) {
      return;
    }

    // Perform migration only once
    for (final item in items) {
      final repairedName = TextSanitizer.normalizeDisplayText(item.bankName);
      final repairedUrl = TextSanitizer.normalizeDisplayText(item.url);

      if (repairedName == item.bankName && repairedUrl == item.url) {
        continue;
      }

      item.bankName = repairedName;
      item.url = repairedUrl;
      _dbService.bankAccountsBox.put(item.id, item);
    }

    // Mark migration as complete
    _dbService.settingsBox.put(_legacyTextRepairKey, true);
  }

  void addBankAccount(BankAccount account) {
    try {
      _dbService.bankAccountsBox.put(account.id, account);
      state = AsyncValue.data(_getItems());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to add account: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
    }
  }

  void updateBankAccount(BankAccount account) {
    try {
      _dbService.bankAccountsBox.put(account.id, account);
      state = AsyncValue.data(_getItems());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to update account: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
    }
  }

  void deleteBankAccount(String id) {
    try {
      _dbService.bankAccountsBox.delete(id);
      state = AsyncValue.data(_getItems());
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to delete account: $e',
          userMessage: t.settings.errors.setting_update_failed,
        ),
      );
    }
  }
}

final bankAccountProvider =
    AsyncNotifierProvider.autoDispose<BankAccountNotifier, List<BankAccount>>(
      BankAccountNotifier.new,
    );

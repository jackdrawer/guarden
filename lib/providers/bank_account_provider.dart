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

  @override
  Future<List<BankAccount>> build() async {
    ref.watch(settingsProvider);
    return _getItems();
  }

  List<BankAccount> _getItems() {
    try {
      final settings = ref.read(settingsProvider).valueOrNull;
      var items = _dbService.bankAccountsBox.values.toList();
      _repairLegacyText(items);
      if (settings != null && settings.isTravelModeActive) {
        items = items
            .where((item) => !settings.travelProtectedIds.contains(item.id))
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

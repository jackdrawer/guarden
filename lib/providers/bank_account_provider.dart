import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bank_account.dart';
import '../services/database_service.dart';
import '../widgets/error_handler.dart';
import '../errors/app_errors.dart';

import 'settings_provider.dart';

class BankAccountNotifier extends AutoDisposeAsyncNotifier<List<BankAccount>> {
  late final _dbService = ref.read(databaseProvider);

  @override
  Future<List<BankAccount>> build() async {
    ref.watch(settingsProvider); // watch settings to trigger rebuild
    return _getItems();
  }

  List<BankAccount> _getItems() {
    try {
      final settings = ref.read(settingsProvider);
      var items = _dbService.bankAccountsBox.values.toList();
      if (settings.isTravelModeActive) {
        items = items
            .where((i) => !settings.travelProtectedIds.contains(i.id))
            .toList();
      }
      return items;
    } catch (e) {
      ErrorHandler.handleGlobalError(
        DatabaseError(
          'Failed to read accounts: $e',
          userMessage: "Could not load bank accounts.",
        ),
      );
      return [];
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
          userMessage:
              "Could not save bank account. Please check storage capacity.",
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
          userMessage: "Could not update bank account.",
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
          userMessage: "Could not delete bank account.",
        ),
      );
    }
  }
}

final bankAccountProvider =
    AsyncNotifierProvider.autoDispose<BankAccountNotifier, List<BankAccount>>(
      BankAccountNotifier.new,
    );

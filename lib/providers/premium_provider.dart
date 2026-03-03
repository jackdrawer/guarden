import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/purchase_service.dart';
import '../widgets/error_handler.dart';
import '../errors/app_errors.dart';

class PremiumState {
  final bool isPremium;
  final bool isLoading;

  // Freemium Limits
  static const int maxFreeBanks = 5;
  static const int maxFreeSubscriptions = 3;
  static const int maxFreeWebPasswords = 5;

  PremiumState({required this.isPremium, this.isLoading = false});

  PremiumState copyWith({bool? isPremium, bool? isLoading}) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool canAddBank(int currentCount) {
    if (isPremium) return true;
    return currentCount < maxFreeBanks;
  }

  bool canAddSubscription(int currentCount) {
    if (isPremium) return true;
    return currentCount < maxFreeSubscriptions;
  }

  bool canAddWebPassword(int currentCount) {
    if (isPremium) return true;
    return currentCount < maxFreeWebPasswords;
  }
}

class PremiumNotifier extends AsyncNotifier<PremiumState> {
  late final PurchaseService _purchaseService;

  @override
  Future<PremiumState> build() async {
    _purchaseService = ref.read(purchaseServiceProvider);
    await _purchaseService.init();
    return await _checkStatus();
  }

  Future<PremiumState> _checkStatus() async {
    try {
      final isPremium = await _purchaseService.checkPremiumStatus();
      return PremiumState(isPremium: isPremium, isLoading: false);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        NetworkError(
          'Failed to check premium status: $e',
          userMessage: "Could not verify premium status.",
        ),
        onRetry: () => checkStatus(),
      );
      return PremiumState(isPremium: false, isLoading: false);
    }
  }

  Future<void> checkStatus() async {
    try {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: true) ??
        PremiumState(isPremium: false, isLoading: true),
      );
      final isPremium = await _purchaseService.checkPremiumStatus();
      state = AsyncValue.data(PremiumState(isPremium: isPremium, isLoading: false));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      ErrorHandler.handleGlobalError(
        NetworkError(
          'Failed to check premium status: $e',
          userMessage: "Could not verify premium status.",
        ),
        onRetry: () => checkStatus(),
      );
    }
  }

  /// For testing/debugging purposes, we can force unlock premium
  void debugTogglePremium() {
    final currentValue = state.value;
    if (currentValue != null) {
      state = AsyncValue.data(currentValue.copyWith(isPremium: !currentValue.isPremium));
    }
  }
}

final premiumProvider = AsyncNotifierProvider<PremiumNotifier, PremiumState>(
  PremiumNotifier.new,
);

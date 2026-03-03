import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/services.dart';
import '../errors/app_errors.dart';

class PurchaseService {
  static const String _revenueCatAppleApiKey = String.fromEnvironment(
    'RC_APPLE_API_KEY',
    defaultValue: '',
  );
  static const String _revenueCatGoogleApiKey = String.fromEnvironment(
    'RC_GOOGLE_API_KEY',
    defaultValue: '',
  );

  Future<void> init() async {
    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      PurchasesConfiguration configuration;
      if (defaultTargetPlatform == TargetPlatform.android) {
        if (_revenueCatGoogleApiKey.isEmpty) {
          throw StateError(
            'RevenueCat Google API key missing. Pass RC_GOOGLE_API_KEY via --dart-define.',
          );
        }
        configuration = PurchasesConfiguration(_revenueCatGoogleApiKey);
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        if (_revenueCatAppleApiKey.isEmpty) {
          throw StateError(
            'RevenueCat Apple API key missing. Pass RC_APPLE_API_KEY via --dart-define.',
          );
        }
        configuration = PurchasesConfiguration(_revenueCatAppleApiKey);
      } else {
        // Not supported platform for RevenueCat right now (e.g. windows desktop testing)
        // We will mock it gracefully.
        return;
      }

      await Purchases.configure(configuration);
    } catch (e) {
      debugPrint('Purchases init error: $e');
    }
  }

  Future<Offerings?> fetchOfferings() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.windows) {
        return null; // Mock for desktop
      }
      return await Purchases.getOfferings();
    } on PlatformException catch (e) {
      throw NetworkError(
        'Failed to fetch offerings: $e',
        userMessage:
            "Couldn't connect to server. Check your internet and try again.",
        canRetry: true,
        action: "retry",
      );
    } catch (e) {
      throw NetworkError(
        'Failed to fetch offerings: $e',
        userMessage:
            "Couldn't connect to server. Check your internet and try again.",
        canRetry: true,
        action: "retry",
      );
    }
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      // ignore: deprecated_member_use
      final purchaseResult = await Purchases.purchasePackage(package);
      final isPro =
          purchaseResult.customerInfo.entitlements.all["premium"]?.isActive ??
          false;
      return isPro;
    } on PlatformException catch (e) {
      throw NetworkError(
        'Purchase failed: $e',
        userMessage: "Couldn't process purchase. Check your internet.",
        canRetry: true,
        action: "retry",
      );
    } catch (e) {
      throw NetworkError(
        'Purchase error: $e',
        userMessage: "Couldn't process purchase. Check your internet.",
        canRetry: true,
        action: "retry",
      );
    }
  }

  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isPro = customerInfo.entitlements.all["premium"]?.isActive ?? false;
      return isPro;
    } catch (e) {
      debugPrint('Restore failed: $e');
      return false;
    }
  }

  Future<bool> checkPremiumStatus() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.windows) {
        return false; // Mock default status for windows development
      }
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all["premium"]?.isActive ?? false;
    } catch (e) {
      debugPrint('Status check failed: $e');
      return false;
    }
  }
}

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  return PurchaseService();
});

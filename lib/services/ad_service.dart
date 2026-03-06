import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdService {
  static bool get isEnabled {
    if (kIsWeb) return false;
    const disableMobileAds = bool.fromEnvironment(
      'DISABLE_MOBILE_ADS',
      defaultValue: false,
    );
    return !disableMobileAds;
  }

  static bool get _useProductionAds =>
      isEnabled &&
      (kReleaseMode ||
          const bool.fromEnvironment('USE_PRODUCTION_ADS', defaultValue: false));

  static String get bannerAdUnitId {
    if (!isEnabled) return '';
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (_useProductionAds) {
        return const String.fromEnvironment(
          'ANDROID_BANNER_AD_ID',
          defaultValue: 'ca-app-pub-7514989682859982/2090899108',
        );
      }
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (_useProductionAds) {
        return const String.fromEnvironment(
          'IOS_BANNER_AD_ID',
          defaultValue: 'ca-app-pub-7514989682859982/3515096767',
        );
      }
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (!isEnabled) return '';
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (_useProductionAds) {
        return const String.fromEnvironment(
          'ANDROID_INTERSTITIAL_AD_ID',
          defaultValue: 'ca-app-pub-7514989682859982/3436314831',
        );
      }
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (_useProductionAds) {
        return const String.fromEnvironment(
          'IOS_INTERSTITIAL_AD_ID',
          defaultValue: 'ca-app-pub-7514989682859982/5007307684',
        );
      }
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return '';
  }

  static String get rewardedInterstitialAdUnitId {
    if (!isEnabled) return '';
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (_useProductionAds) {
        return const String.fromEnvironment(
          'ANDROID_REWARDED_INTERSTITIAL_AD_ID',
          defaultValue: 'ca-app-pub-7514989682859982/9907995161',
        );
      }
      return 'ca-app-pub-3940256099942544/5354046379';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (_useProductionAds) {
        return const String.fromEnvironment(
          'IOS_REWARDED_INTERSTITIAL_AD_ID',
          defaultValue: '',
        );
      }
      return '';
    }
    return '';
  }

  static String get nativeAdvancedAdUnitId {
    if (!isEnabled) return '';
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (_useProductionAds) {
        return const String.fromEnvironment(
          'ANDROID_NATIVE_AD_ID',
          defaultValue: 'ca-app-pub-7514989682859982/5674070837',
        );
      }
      return 'ca-app-pub-3940256099942544/2247696110';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (_useProductionAds) {
        return const String.fromEnvironment(
          'IOS_NATIVE_AD_ID',
          defaultValue: 'ca-app-pub-7514989682859982/9974926856',
        );
      }
      return 'ca-app-pub-3940256099942544/3986624511';
    }
    return '';
  }
}

final adServiceProvider = Provider<AdService>((ref) {
  return AdService();
});

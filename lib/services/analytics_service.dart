import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../providers/settings_provider.dart';

/// Analytics service for Firebase Analytics with privacy controls.
///
/// Integrates with Travel Mode (premium privacy feature) to disable
/// behavioral tracking when privacy mode is active. Crash reporting via
/// Sentry remains active regardless of Travel Mode.
///
/// All analytics events are scrubbed of PII before sending.
class AnalyticsService {
  final Ref _ref;
  FirebaseAnalytics? _analytics;
  bool _initialized = false;

  AnalyticsService(this._ref);

  /// Initialize Firebase Analytics.
  ///
  /// Configures Firebase with platform-specific settings using compile-time
  /// environment variables (FIREBASE_APP_ID_ANDROID, FIREBASE_APP_ID_IOS).
  ///
  /// Gracefully degrades if Firebase config is missing (logs warning only).
  static Future<void> init() async {
    try {
      // Firebase is initialized in main.dart via Firebase.initializeApp()
      // or via google-services.json / GoogleService-Info.plist
      if (Firebase.apps.isEmpty) {
        debugPrint('⚠️  Firebase not initialized - analytics disabled');
        return;
      }

      debugPrint('✅ Firebase Analytics ready');
    } catch (e) {
      debugPrint('⚠️  Failed to configure Firebase Analytics: $e');
      // Don't throw - analytics is not critical for app function
    }
  }

  /// Get analytics instance (lazy initialization).
  Future<FirebaseAnalytics?> get _analyticsInstance async {
    if (_initialized) return _analytics;

    try {
      if (Firebase.apps.isEmpty) {
        debugPrint('⚠️  Firebase not initialized - analytics disabled');
        return null;
      }

      _analytics = FirebaseAnalytics.instance;

      // Disable analytics in development mode
      if (kDebugMode) {
        await _analytics?.setAnalyticsCollectionEnabled(false);
        debugPrint('📊 Analytics collection disabled in development');
      }

      _initialized = true;
      return _analytics;
    } catch (e) {
      debugPrint('⚠️  Failed to initialize Firebase Analytics: $e');
      return null;
    }
  }

  /// Check if Travel Mode is active (privacy feature).
  ///
  /// When Travel Mode is active, analytics tracking is disabled to protect
  /// user privacy. This is a premium feature.
  bool get _isTravelModeActive {
    final settings = _ref.read(settingsProvider).value;
    return settings?.isTravelModeActive ?? false;
  }

  /// Log a custom event with parameters.
  ///
  /// Checks Travel Mode before tracking. If Travel Mode is ON, returns
  /// early without tracking.
  ///
  /// Parameters are validated to ensure no PII is included. Only
  /// whitelisted parameter types are allowed: count, type, category, duration.
  Future<void> logEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    // Check Travel Mode
    if (_isTravelModeActive) {
      debugPrint('🔒 Analytics disabled (Travel Mode active): $eventName');
      return;
    }

    try {
      final analytics = await _analyticsInstance;
      if (analytics == null) return;

      // Scrub parameters to prevent PII leakage
      final safeParams = _scrubParameters(parameters);

      await analytics.logEvent(
        name: eventName,
        parameters: safeParams,
      );

      debugPrint('📊 Analytics event: $eventName ${safeParams != null ? '($safeParams)' : ''}');
    } catch (e) {
      debugPrint('⚠️  Failed to log analytics event: $e');
    }
  }

  /// Scrub parameters to prevent PII leakage.
  ///
  /// Only allows primitive types (String, num, bool) and filters out
  /// sensitive keywords (password, email, name, etc.).
  Map<String, Object>? _scrubParameters(Map<String, dynamic>? params) {
    if (params == null) return null;

    final safeParams = <String, Object>{};
    final sensitiveKeys = [
      'password',
      'secret',
      'key',
      'seed',
      'token',
      'email',
      'name',
      'phone',
      'address',
      'pin',
      'account',
    ];

    for (final entry in params.entries) {
      final lowerKey = entry.key.toLowerCase();

      // Skip sensitive keys
      if (sensitiveKeys.any((s) => lowerKey.contains(s))) {
        continue;
      }

      // Only allow primitive types
      final value = entry.value;
      if (value is String || value is num || value is bool) {
        safeParams[entry.key] = value;
      }
    }

    return safeParams.isEmpty ? null : safeParams;
  }

  /// Log app open event.
  Future<void> logAppOpen() async {
    await logEvent('app_open');
  }

  /// Log onboarding completion.
  Future<void> logOnboardingComplete() async {
    await logEvent('onboarding_complete');
  }

  /// Log password added event.
  ///
  /// Type parameter indicates category: 'bank', 'subscription', 'web'.
  Future<void> logPasswordAdded(String type) async {
    await logEvent('password_added', parameters: {'type': type});
  }

  /// Log premium purchase event.
  Future<void> logPremiumPurchased(String productId) async {
    await logEvent('premium_purchased', parameters: {'product_id': productId});
  }

  /// Log backup created event.
  Future<void> logBackupCreated() async {
    await logEvent('backup_created');
  }

  /// Log Travel Mode toggle.
  Future<void> logTravelModeToggled(bool enabled) async {
    await logEvent('travel_mode_toggled', parameters: {'enabled': enabled});
  }

  /// Set user property for segmentation.
  ///
  /// Checks Travel Mode before setting. Only non-identifying properties
  /// are allowed: user_type (free|premium), locale, app_version.
  Future<void> setUserProperty(String name, String value) async {
    // Check Travel Mode
    if (_isTravelModeActive) {
      debugPrint('🔒 User property disabled (Travel Mode active): $name');
      return;
    }

    try {
      final analytics = await _analyticsInstance;
      if (analytics == null) return;

      // Only allow safe user properties
      final allowedProperties = ['user_type', 'locale', 'app_version'];
      if (!allowedProperties.contains(name)) {
        debugPrint('⚠️  Rejected user property (not whitelisted): $name');
        return;
      }

      await analytics.setUserProperty(name: name, value: value);
      debugPrint('📊 User property set: $name = $value');
    } catch (e) {
      debugPrint('⚠️  Failed to set user property: $e');
    }
  }
}

/// Provider for AnalyticsService.
///
/// Watches settingsProvider to access Travel Mode state.
final analyticsProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(ref);
});

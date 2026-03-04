import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TelemetryService {
  final bool isDev;

  static final TelemetryService instance = TelemetryService._internal(
    isDev: kDebugMode,
  );

  TelemetryService._internal({this.isDev = kDebugMode});

  FirebaseAnalytics? _analytics;

  Future<void> init() async {
    // Sentry init is usually handled in main.dart via SentryFlutter.init

    // Firebase init
    try {
      if (Firebase.apps.isEmpty) {
        if (kIsWeb) {
          final webOptions = _firebaseWebOptionsFromEnv();
          if (webOptions == null) {
            debugPrint(
              'Firebase init skipped on web (missing FIREBASE_WEB_* dart-defines).',
            );
            return;
          }
          await Firebase.initializeApp(options: webOptions);
        } else {
          await Firebase.initializeApp();
        }
      }
      _analytics = FirebaseAnalytics.instance;
      _analytics?.setAnalyticsCollectionEnabled(!isDev); // Disable in dev
    } catch (e) {
      debugPrint('Firebase init skip (likely no defaults provided yet): $e');
    }
  }

  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    if (isDev) {
      debugPrint('TELEMETRY EVENT: $name | $parameters');
      return;
    }

    try {
      // PII scrub: enforce event names and keys to avoid leaky data.
      final safeParams = _scrubParameters(parameters);
      await _analytics?.logEvent(name: name, parameters: safeParams);
    } catch (_) {}
  }

  Future<void> recordException(
    dynamic exception, {
    StackTrace? stackTrace,
  }) async {
    if (isDev) {
      debugPrint('TELEMETRY ERROR: $exception');
      return;
    }

    try {
      // Clean potentially sensitive bits
      final cleanException = _scrubExceptionMessage(exception.toString());
      await Sentry.captureException(
        Exception(cleanException),
        stackTrace: stackTrace,
      );
    } catch (_) {}
  }

  Map<String, Object>? _scrubParameters(Map<String, dynamic>? params) {
    if (params == null) return null;
    final safeParams = <String, Object>{};

    // Explicit blacklist of keys we never want to track
    final suspiciousKeys = [
      'password',
      'secret',
      'key',
      'seed',
      'token',
      'email',
      'name',
    ];

    for (final entry in params.entries) {
      final lowerKey = entry.key.toLowerCase();
      if (suspiciousKeys.any((s) => lowerKey.contains(s))) {
        continue;
      }

      final value = entry.value;
      if (value is String || value is num || value is bool) {
        safeParams[entry.key] = value;
      }
    }

    return safeParams;
  }

  String _scrubExceptionMessage(String message) {
    // Basic regex to strip emails and common IP patterns
    var scrubbed = message.replaceAll(
      RegExp(r'[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+'),
      '[EMAIL_REDACTED]',
    );
    scrubbed = scrubbed.replaceAll(
      RegExp(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'),
      '[IP_REDACTED]',
    );
    return scrubbed;
  }

  FirebaseOptions? _firebaseWebOptionsFromEnv() {
    const apiKey = String.fromEnvironment(
      'FIREBASE_WEB_API_KEY',
      defaultValue: '',
    );
    const appId = String.fromEnvironment(
      'FIREBASE_WEB_APP_ID',
      defaultValue: '',
    );
    const messagingSenderId = String.fromEnvironment(
      'FIREBASE_WEB_MESSAGING_SENDER_ID',
      defaultValue: '',
    );
    const projectId = String.fromEnvironment(
      'FIREBASE_WEB_PROJECT_ID',
      defaultValue: '',
    );
    const authDomain = String.fromEnvironment(
      'FIREBASE_WEB_AUTH_DOMAIN',
      defaultValue: '',
    );
    const storageBucket = String.fromEnvironment(
      'FIREBASE_WEB_STORAGE_BUCKET',
      defaultValue: '',
    );
    const measurementId = String.fromEnvironment(
      'FIREBASE_WEB_MEASUREMENT_ID',
      defaultValue: '',
    );

    if (apiKey.isEmpty ||
        appId.isEmpty ||
        messagingSenderId.isEmpty ||
        projectId.isEmpty) {
      return null;
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain: authDomain.isEmpty ? null : authDomain,
      storageBucket: storageBucket.isEmpty ? null : storageBucket,
      measurementId: measurementId.isEmpty ? null : measurementId,
    );
  }
}

final telemetryServiceProvider = Provider<TelemetryService>((ref) {
  return TelemetryService.instance;
});

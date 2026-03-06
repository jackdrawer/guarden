import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../errors/app_errors.dart';

/// Monitoring service for Sentry crash reporting with PII scrubbing.
///
/// Provides methods to capture errors with automatic scrubbing of sensitive
/// data (passwords, keys, tokens, etc.).
///
/// Note: Sentry is initialized in main.dart via SentryFlutter.init.
class MonitoringService {
  static const _sensitiveKeywords = [
    'password',
    'seed',
    'key',
    'pin',
    'secret',
    'token',
    'cipher',
    'mnemonic',
    'private',
    'credential',
  ];

  static bool _containsSensitive(String text) {
    final lower = text.toLowerCase();
    return _sensitiveKeywords.any((kw) => lower.contains(kw));
  }

  /// Initialize monitoring service.
  ///
  /// This verifies Sentry DSN is configured. Actual Sentry initialization
  /// happens in main.dart via SentryFlutter.init with beforeSend callback.
  static Future<void> init() async {
    const dsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

    if (dsn.isEmpty || dsn.contains('examplePublicKey')) {
      debugPrint('⚠️  Sentry DSN not configured - monitoring disabled');
      return;
    }

    debugPrint(
      '✅ MonitoringService ready (${kDebugMode ? 'development' : 'production'})',
    );
  }

  /// Scrub PII from Sentry events before sending.
  ///
  /// Removes fields containing sensitive keywords:
  /// - password, seed, key, pin, secret, token, cipher, mnemonic
  /// - API keys starting with sk_ or pk_
  ///
  /// Use this as beforeSend callback in Sentry.init().
  static SentryEvent? scrubPII(SentryEvent event, Hint hint) {
    var scrubbed = event;

    // Scrub exception values containing sensitive keywords
    if (event.exceptions != null) {
      final scrubbedExceptions = event.exceptions!.map((ex) {
        final value = ex.value;
        if (value != null && _containsSensitive(value)) {
          return SentryException(
            type: ex.type,
            value: '[REDACTED]',
            mechanism: ex.mechanism,
            stackTrace: ex.stackTrace,
            threadId: ex.threadId,
          );
        }
        return ex;
      }).toList();
      scrubbed.exceptions = scrubbedExceptions;
    }

    // Scrub breadcrumb data maps
    if (event.breadcrumbs != null) {
      final scrubbedBreadcrumbs = event.breadcrumbs!.map((bc) {
        return Breadcrumb(
          message: bc.message,
          category: bc.category,
          data: _scrubMap(bc.data),
          timestamp: bc.timestamp,
        );
      }).toList();
      scrubbed.breadcrumbs = scrubbedBreadcrumbs;
    }

    return scrubbed;
  }

  /// Scrub sensitive fields from a map recursively.
  static Map<String, dynamic>? _scrubMap(Map<String, dynamic>? data) {
    if (data == null) return null;

    final scrubbed = <String, dynamic>{};

    data.forEach((key, value) {
      final lowerKey = key.toLowerCase();

      // Check if key contains sensitive keywords (using shared static list)
      final containsSensitive = _sensitiveKeywords.any(
        (keyword) => lowerKey.contains(keyword),
      );

      if (containsSensitive) {
        scrubbed[key] = '[REDACTED]';
        return;
      }

      // Check if value looks like an API key
      if (value is String) {
        if (value.startsWith('sk_') || value.startsWith('pk_')) {
          scrubbed[key] = '[API_KEY_REDACTED]';
          return;
        }
      }

      // Recursively scrub nested maps
      if (value is Map<String, dynamic>) {
        scrubbed[key] = _scrubMap(value);
      } else if (value is List) {
        scrubbed[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return _scrubMap(item);
          }
          return item;
        }).toList();
      } else {
        scrubbed[key] = value;
      }
    });

    return scrubbed;
  }

  /// Capture an error and send to Sentry with context.
  ///
  /// If error is an AppError, adds both technical and user messages
  /// as context for better debugging.
  ///
  /// Extras are scrubbed before being added as context.
  static Future<void> captureError(
    dynamic error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? extras,
  }) async {
    try {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          // Add AppError-specific context
          if (error is AppError) {
            scope.setTag('error_type', error.runtimeType.toString());
            scope.setContexts('app_error', {
              'user_message': error.userMessage,
              'can_retry': error.canRetry,
              'action': error.action ?? 'none',
            });
          }

          // Add scrubbed extras as contexts
          if (extras != null) {
            final scrubbedExtras = _scrubMap(extras);
            if (scrubbedExtras != null) {
              scope.setContexts('extras', scrubbedExtras);
            }
          }
        },
      );
    } catch (e) {
      debugPrint('⚠️  Failed to capture error in Sentry: $e');
      // Don't throw - monitoring failures shouldn't crash the app
    }
  }

  /// Add a breadcrumb for error context.
  ///
  /// Breadcrumbs help trace user actions leading to errors.
  /// Common categories:
  /// - 'navigation': User navigated to a screen
  /// - 'user.action': User tapped a button
  /// - 'state.change': App state changed
  ///
  /// Data is scrubbed before adding to prevent PII leakage.
  static void addBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
  }) {
    try {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: message,
          category: category,
          data: data != null ? _scrubMap(data) : null,
          timestamp: DateTime.now().toUtc(),
        ),
      );
    } catch (e) {
      debugPrint('⚠️  Failed to add breadcrumb: $e');
    }
  }
}

/// Provider for MonitoringService.
final monitoringProvider = Provider<MonitoringService>((ref) {
  return MonitoringService();
});

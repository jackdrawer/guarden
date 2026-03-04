// dart:io kaldirildi
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../errors/app_errors.dart';
import '../services/telemetry_service.dart';
import 'error_snackbar.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class ErrorHandler {
  static void handleError(
    BuildContext context,
    Object error, {
    VoidCallback? onRetry,
  }) {
    handleGlobalError(error, onRetry: onRetry);
  }

  static void handleGlobalError(Object error, {VoidCallback? onRetry}) {
    final appError = convertToAppError(error);

    // Log technical message in debug mode and report to internal telemetry
    debugPrint('Global AppError Handled: ${appError.toString()}');
    TelemetryService.instance.recordException(error);

    // Defer SnackBar display to avoid modifying widget tree during build phase.
    // This prevents '_dependents.isEmpty' assertion failures when errors occur
    // during provider rebuilds.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if context is still valid before showing UI
      if (scaffoldMessengerKey.currentState == null) return;
      _showErrorSnackBar(appError, onRetry);
    });
  }

  static void _showErrorSnackBar(AppError appError, VoidCallback? onRetry) {
    final scaffoldMessenger = _safeScaffoldMessengerState();
    if (scaffoldMessenger == null || !scaffoldMessenger.mounted) {
      debugPrint(
        'No mounted ScaffoldMessengerState found for error: $appError',
      );
      return;
    }

    try {
      scaffoldMessenger.hideCurrentSnackBar();
    } catch (_) {
      // Ignore if snackbar already dismissed or state invalid
    }

    // Use a variable that we assign afterwards to pass to the widget
    late ScaffoldFeatureController<SnackBar, SnackBarClosedReason> controller;

    final snackBar = SnackBar(
      content: Builder(
        builder: (context) {
          return ErrorSnackBar(
            error: appError,
            onAction: appError.canRetry ? onRetry : null,
            controller: controller,
          );
        },
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      duration: Duration(
        seconds: appError.action != null && onRetry != null ? 6 : 4,
      ),
      behavior: SnackBarBehavior.floating,
    );

    controller = scaffoldMessenger.showSnackBar(snackBar);
  }

  static ScaffoldMessengerState? _safeScaffoldMessengerState() {
    try {
      WidgetsBinding.instance;
      return scaffoldMessengerKey.currentState;
    } catch (_) {
      return null;
    }
  }

  static Future<T?> withErrorHandling<T>(
    BuildContext context,
    Future<T> Function() operation, {
    VoidCallback? onRetry,
  }) async {
    try {
      return await operation();
    } on Exception catch (e) {
      if (context.mounted) {
        handleError(context, e, onRetry: onRetry);
      }
      return null;
    } catch (e) {
      if (context.mounted) {
        handleError(context, Exception(e.toString()), onRetry: onRetry);
      }
      return null;
    }
  }

  static AppError convertToAppError(Object exception) {
    if (exception is AppError) {
      return exception;
    }

    if (exception.toString().contains('SocketException')) {
      return NetworkError(exception.toString());
    }

    if (exception is FormatException) {
      return ValidationError(exception.toString());
    }

    if (exception.toString().contains('HiveError')) {
      return DatabaseError(exception.toString());
    }

    if (exception is PlatformException) {
      final code = exception.code.toLowerCase();
      if (code.contains('auth') || code.contains('biometric')) {
        return BiometricError(exception.toString());
      }
      return StorageError(exception.toString());
    }

    return AppError(
      exception.toString(),
      userMessage: 'Something went wrong. Please try again.',
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../errors/app_errors.dart';
import 'error_snackbar.dart';

class ErrorHandler {
  static void handleError(
    BuildContext context,
    Exception error, {
    VoidCallback? onRetry,
  }) {
    final appError = convertToAppError(error);

    // Log technical message in debug mode
    debugPrint('AppError Handled: ${appError.toString()}');

    showErrorSnackBar(
      context,
      appError,
      onAction: appError.canRetry ? onRetry : null,
    );
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

  static AppError convertToAppError(Exception exception) {
    if (exception is AppError) {
      return exception;
    }

    if (exception is SocketException) {
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

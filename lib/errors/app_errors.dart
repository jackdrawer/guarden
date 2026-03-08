import '../i18n/strings.g.dart';

class AppError implements Exception {
  final String message;
  final String userMessage;
  final bool canRetry;
  final String? action;

  AppError(
    this.message, {
    required this.userMessage,
    this.canRetry = false,
    this.action,
  });

  @override
  String toString() => '${runtimeType.toString()}: $message';
}

class StorageError extends AppError {
  StorageError(
    super.message, {
    String? userMessage,
    super.canRetry = true,
    super.action = 're-enter password',
  }) : super(userMessage: userMessage ?? t.settings.errors.storage_access_failed);
}

class CryptoError extends AppError {
  CryptoError(
    super.message, {
    String? userMessage,
    super.canRetry = false,
    super.action,
  }) : super(userMessage: userMessage ?? t.settings.errors.encryption_failed);
}

class NetworkError extends AppError {
  NetworkError(
    super.message, {
    String? userMessage,
    super.canRetry = true,
    super.action = 'retry',
  }) : super(userMessage: userMessage ?? t.settings.errors.network_failed);
}

class DatabaseError extends AppError {
  DatabaseError(
    super.message, {
    String? userMessage,
    super.canRetry = true,
    super.action = 'retry',
  }) : super(userMessage: userMessage ?? t.settings.errors.setting_update_failed);
}

class BiometricError extends AppError {
  BiometricError(
    super.message, {
    String? userMessage,
    super.canRetry = true,
    super.action = 'retry',
  }) : super(
         userMessage:
             userMessage ?? t.auth_login.biometric_try_master_password,
       );
}

class ValidationError extends AppError {
  ValidationError(
    super.message, {
    String? userMessage,
    super.canRetry = false,
    super.action,
  }) : super(
         userMessage:
             userMessage ??
             t.settings.errors.invalid_input,
       );
}

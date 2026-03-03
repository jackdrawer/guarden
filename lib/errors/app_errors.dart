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
    super.userMessage =
        'Couldn\'t access secure storage. Please re-enter your master password.',
    super.canRetry = true,
    super.action = 're-enter password',
  });
}

class CryptoError extends AppError {
  CryptoError(
    super.message, {
    super.userMessage =
        'Couldn\'t encrypt data. Your information is safe but wasn\'t saved.',
    super.canRetry = false,
    super.action,
  });
}

class NetworkError extends AppError {
  NetworkError(
    super.message, {
    super.userMessage =
        'Couldn\'t connect to server. Check your internet and try again.',
    super.canRetry = true,
    super.action = 'retry',
  });
}

class DatabaseError extends AppError {
  DatabaseError(
    super.message, {
    super.userMessage =
        'Couldn\'t save your data. Please check available storage.',
    super.canRetry = true,
    super.action = 'retry',
  });
}

class BiometricError extends AppError {
  BiometricError(
    super.message, {
    super.userMessage =
        'Biometric authentication failed. Try again or use master password.',
    super.canRetry = true,
    super.action = 'retry',
  });
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
             'Invalid input provided. Please check your details.',
       );
}

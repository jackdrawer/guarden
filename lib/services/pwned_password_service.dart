import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../errors/app_errors.dart';
import '../i18n/strings.g.dart';

final pwnedPasswordProvider = Provider<PwnedPasswordService>((ref) {
  return PwnedPasswordService();
});

class PwnedResult {
  final bool isBreached;
  final int count;

  PwnedResult({required this.isBreached, required this.count});
}

class PwnedPasswordService {
  static const String _baseUrl = 'https://api.pwnedpasswords.com/range';

  Future<T> _retryWithBackoff<T>(
    Future<T> Function() operation,
    int maxAttempts,
  ) async {
    const delays = [1000, 2000, 4000];
    int attempt = 0;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts) {
          rethrow;
        }
        debugPrint(
          'Retrying pwned check... (attempt $attempt of $maxAttempts)',
        );
        await Future.delayed(Duration(milliseconds: delays[attempt - 1]));
      }
    }
  }

  /// Checks if the given plain text password has been exposed in a data breach.
  /// Uses k-Anonymity by only sending the first 5 characters of the SHA-1 hash.
  Future<PwnedResult> checkPassword(String password) async {
    if (password.isEmpty) return PwnedResult(isBreached: false, count: 0);

    var bytes = utf8.encode(password);
    var digest = sha1.convert(bytes);
    String hash = digest.toString().toUpperCase();

    String prefix = hash.substring(0, 5);
    String suffix = hash.substring(5);

    try {
      final response = await _retryWithBackoff(
        () => http.get(
          Uri.parse('$_baseUrl/$prefix'),
          headers: {'User-Agent': 'Guarden-PW-Manager'},
        ),
        4, // 1 initial + 3 retries
      );

      if (response.statusCode == 200) {
        final lines = const LineSplitter().convert(response.body);
        for (var line in lines) {
          final parts = line.split(':');
          if (parts.length == 2 && parts[0] == suffix) {
            final count = int.tryParse(parts[1]) ?? 0;
            return PwnedResult(isBreached: count > 0, count: count);
          }
        }
        return PwnedResult(isBreached: false, count: 0);
      } else {
        throw NetworkError(
          'Pwned API returned status code ${response.statusCode}',
          userMessage: t.settings.errors.pwned_check_failed,
          canRetry: true,
          action: "retry",
        );
      }
    } catch (e) {
      throw NetworkError(
        'Pwned API request failed: $e',
        userMessage: t.settings.errors.pwned_check_failed,
        canRetry: true,
        action: "retry",
      );
    }
  }

  /// Checks if a password is weak based on length, complexity, and repetition.
  bool isWeakPassword(String password) {
    if (password.length < 8) return true;
    if (RegExp(r'^[0-9]+$').hasMatch(password)) return true;
    if (password.split('').toSet().length == 1) return true;

    int typesCount = 0;
    if (RegExp(r'[a-z]').hasMatch(password)) typesCount++;
    if (RegExp(r'[A-Z]').hasMatch(password)) typesCount++;
    if (RegExp(r'[0-9]').hasMatch(password)) typesCount++;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) typesCount++;
    if (typesCount < 2) return true;

    return false;
  }
}

import 'dart:convert';
import 'dart:math';

/// Constant-time string comparison to prevent timing attacks.
///
/// Used for comparing derived keys, verifiers, and checksums
/// where timing side-channels could leak information.
bool constantTimeEquals(String a, String b) {
  final maxLength = a.length > b.length ? a.length : b.length;
  var diff = a.length ^ b.length;

  for (var i = 0; i < maxLength; i++) {
    final aCode = i < a.length ? a.codeUnitAt(i) : 0;
    final bCode = i < b.length ? b.codeUnitAt(i) : 0;
    diff |= aCode ^ bCode;
  }

  return diff == 0;
}

/// Generate a cryptographically secure random salt encoded as base64url.
String generateSecureSalt({int length = 32}) {
  final random = Random.secure();
  final bytes = List<int>.generate(length, (_) => random.nextInt(256));
  return base64UrlEncode(bytes);
}

/// Generate a cryptographically secure random key encoded as base64.
String generateSecureKey({int length = 32}) {
  final random = Random.secure();
  final bytes = List<int>.generate(length, (_) => random.nextInt(256));
  return base64Encode(bytes);
}

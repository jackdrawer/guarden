import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../errors/app_errors.dart';
import '../i18n/strings.g.dart';

final cryptoProvider = Provider<CryptoService>((ref) => CryptoService());

class CryptoService {
  final _algorithm = AesGcm.with256bits();
  final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 100000,
    bits: 256,
  );

  /// Master password ve salt kullanarak PBKDF2 ile 256 bitlik AES anahtarı türetir.
  Future<SecretKey> deriveKey(String password, String salt) async {
    try {
      final secretKey = SecretKey(utf8.encode(password));
      final derivedKey = await _pbkdf2.deriveKey(
        secretKey: secretKey,
        nonce: utf8.encode(salt),
      );
      return derivedKey;
    } catch (e) {
      throw CryptoError('Failed to derive key: $e');
    }
  }

  /// Düz metni (plaintext) AES-256-GCM ile şifreler.
  /// Çıktı formatı: Base64 string.
  Future<String> encryptText(String plainText, SecretKey key) async {
    try {
      final nonce = _generateNonce(); // 12 bytes nonce for AES-GCM
      final secretBox = await _algorithm.encrypt(
        utf8.encode(plainText),
        secretKey: key,
        nonce: nonce,
      );

      // Combine nonce + mac + cipherText into a single payload
      final payload = BytesBuilder();
      payload.add(secretBox.nonce);
      payload.add(secretBox.mac.bytes);
      payload.add(secretBox.cipherText);

      return base64Encode(payload.toBytes());
    } catch (e) {
      throw CryptoError(
        'Failed to encrypt: $e',
        userMessage: t.settings.errors.encryption_failed,
      );
    }
  }

  /// Şifreli metni (Base64 string) AES-256-GCM ile çözer.
  Future<String> decryptText(String encryptedBase64, SecretKey key) async {
    try {
      final payload = base64Decode(encryptedBase64);

      // AES-GCM uses 12 bytes nonce and 16 bytes MAC
      if (payload.length < 28) {
        throw ArgumentError('Invalid encryption payload.');
      }

      final nonce = payload.sublist(0, 12);
      final macBytes = payload.sublist(12, 28);
      final cipherText = payload.sublist(28);

      final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes));

      final decryptedBytes = await _algorithm.decrypt(
        secretBox,
        secretKey: key,
      );

      return utf8.decode(decryptedBytes);
    } on ArgumentError catch (e) {
      throw CryptoError(
        'Failed to decrypt (invalid payload): $e',
        userMessage: t.settings.errors.decryption_failed,
      );
    } on FormatException catch (e) {
      throw CryptoError(
        'Failed to decrypt (format error): $e',
        userMessage: t.settings.errors.generic,
      );
    } catch (e) {
      throw CryptoError(
        'Failed to decrypt: $e',
        userMessage: t.settings.errors.generic,
      );
    }
  }

  List<int> _generateNonce() {
    final random = Random.secure();
    return List<int>.generate(12, (_) => random.nextInt(256));
  }

  /// Base64 formatındaki anahtar ile şifreleme yapan helper metot.
  Future<String> encryptWithBase64Key(
    String plainText,
    String base64Key,
  ) async {
    try {
      final keyBytes = base64Decode(base64Key);
      final secretKey = SecretKey(keyBytes);
      return encryptText(plainText, secretKey);
    } catch (e) {
      if (e is CryptoError) rethrow;
      throw CryptoError('Failed to encrypt with base64 key: $e');
    }
  }

  /// Base64 formatındaki anahtar ile şifre çözen helper metot.
  Future<String> decryptWithBase64Key(
    String encryptedBase64,
    String base64Key,
  ) async {
    try {
      final keyBytes = base64Decode(base64Key);
      final secretKey = SecretKey(keyBytes);
      return decryptText(encryptedBase64, secretKey);
    } catch (e) {
      if (e is CryptoError) rethrow;
      throw CryptoError('Failed to decrypt with base64 key: $e');
    }
  }
}

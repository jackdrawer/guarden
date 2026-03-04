import 'package:flutter_test/flutter_test.dart';
import 'package:guarden/services/crypto_service.dart';

void main() {
  group('CryptoService Tests', () {
    late CryptoService cryptoService;

    setUp(() {
      cryptoService = CryptoService();
    });

    test('Seed Phrase (Mnemonic) üretimi başarılı olmalı', () {
      final phrase = cryptoService.generateSeedPhrase();
      // Bip39 genelde 12 kelime üretir
      expect(phrase.split(' ').length, 12);
      expect(phrase.isNotEmpty, true);
    });

    test(
      'Master şifreden key üretimi, şifreleme ve çözme döngüsü uyumlu olmalı',
      () async {
        const String pw = "mySuperSecretPassword123!";
        const String salt = "randomUserSaltDataXYZ";
        const String originalText = "Test edilen gizli kasa verisi!";

        final secretKey = await cryptoService.deriveKey(pw, salt);

        final encryptedText = await cryptoService.encryptText(
          originalText,
          secretKey,
        );

        // Şifrelenmiş veri original text'e benzememeli
        expect(encryptedText, isNot(equals(originalText)));

        final decryptedText = await cryptoService.decryptText(
          encryptedText,
          secretKey,
        );

        // Çözülen veri orjinale eşit olmalı
        expect(decryptedText, equals(originalText));
      },
    );
  });
}

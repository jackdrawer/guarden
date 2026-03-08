import 'package:flutter_test/flutter_test.dart';
import 'package:guarden/services/logo_service.dart';

void main() {
  group('LogoService', () {
    test('resolves aliases to canonical domains', () {
      final service = LogoService();

      expect(service.resolveDomain('Akbank'), 'akbank.com');
      expect(service.resolveDomain('https://www.github.com/login'), 'github.com');
      expect(service.resolveDomain('YouTube Premium'), 'youtube.com');
    });

    test('prefers stable favicon providers and filters duplicates', () {
      final service = LogoService();

      final urls = service.resolveLogoUrls('akbank.com');

      expect(
        urls,
        equals([
          'https://www.google.com/s2/favicons?sz=128&domain_url=https://akbank.com',
          'https://akbank.com/favicon.ico',
          'https://www.akbank.com/favicon.ico',
        ]),
      );
      expect(service.getLogoUrl('akbank.com'), urls.first);
    });

    test('stops emitting requests for domains marked as failed', () {
      final service = LogoService();

      service.markDomainAsFailed('akbank.com');

      expect(service.resolveLogoUrls('akbank.com'), isEmpty);
      expect(service.getLogoUrl('akbank.com'), isEmpty);
    });
  });
}

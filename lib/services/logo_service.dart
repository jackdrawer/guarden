import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';

class LogoService {
  static const Map<String, String> _domainAliases = {
    'akbank': 'akbank.com',
    'is bankasi': 'isbank.com.tr',
    'isbank': 'isbank.com.tr',
    'garanti': 'garantibbva.com.tr',
    'yapi kredi': 'yapikredi.com.tr',
    'ziraat': 'ziraatbank.com.tr',
    'halkbank': 'halkbank.com.tr',
    'vakifbank': 'vakifbank.com.tr',
    'qnb finansbank': 'qnbfinansbank.com',
    'kuveyt turk': 'kuveytturk.com.tr',
    'albaraka turk': 'albaraka.com.tr',
    'youtube premium': 'youtube.com',
    'amazon prime': 'amazon.com',
    'apple music': 'apple.com',
    'chatgpt plus': 'openai.com',
    'claude pro': 'anthropic.com',
    'github copilot': 'github.com',
  };
  final Set<String> _failedLogoUrls = <String>{};
  final Set<String> _failedDomains = <String>{};

  /// Resolves raw values (domain/url/brand name) to canonical domain.
  String resolveDomain(String rawUrlOrDomain) {
    final trimmed = rawUrlOrDomain.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme) {
      final fromQuery = _extractDomainFromQuery(uri);
      if (fromQuery.isNotEmpty) {
        return fromQuery;
      }

      final fromPath = _extractDomainFromPath(uri);
      if (fromPath.isNotEmpty) {
        return fromPath;
      }

      if (_looksLikeDomain(uri.host)) {
        return _sanitizeDomain(uri.host);
      }
    }

    final sanitized = _sanitizeDomain(trimmed);
    if (_looksLikeDomain(sanitized)) {
      return sanitized;
    }

    final fromAlias = _domainAliases[_normalizeNameKey(trimmed)];
    return fromAlias ?? '';
  }

  /// Returns default logo URL (primary provider) for a resolved domain.
  String getLogoUrl(String domain) {
    final candidates = resolveLogoUrls(domain);
    return candidates.isEmpty ? '' : candidates.first;
  }

  /// Backward compatible entrypoint for codepaths expecting single URL.
  String resolveLogoUrl(String rawUrlOrDomain) {
    final candidates = resolveLogoUrls(rawUrlOrDomain);
    return candidates.isEmpty ? '' : candidates.first;
  }

  /// Ordered fallback chain for local + global brands.
  List<String> resolveLogoUrls(String rawUrlOrDomain) {
    final domain = resolveDomain(rawUrlOrDomain);
    if (domain.isEmpty || _failedDomains.contains(domain)) {
      return const [];
    }

    final candidates = kIsWeb
        ? <String>[
            'https://www.google.com/s2/favicons?sz=128&domain_url=https://$domain',
          ]
        : <String>[
            'https://www.google.com/s2/favicons?sz=128&domain_url=https://$domain',
            'https://$domain/favicon.ico',
            'https://www.$domain/favicon.ico',
          ];

    final seen = <String>{};
    final unique = <String>[];
    for (final url in candidates) {
      if (_failedLogoUrls.contains(url)) {
        continue;
      }
      if (seen.add(url)) {
        unique.add(url);
      }
    }
    return unique;
  }

  String _sanitizeDomain(String input) {
    return input
        .replaceAll(RegExp(r'^https?://'), '')
        .replaceAll('www.', '')
        .split('/')
        .first
        .split('?')
        .first
        .split(':')
        .first
        .toLowerCase()
        .trim();
  }

  String _normalizeNameKey(String value) {
    return value
        .toLowerCase()
        .replaceAll('\u0131', 'i')
        .replaceAll('\u011f', 'g')
        .replaceAll('\u00fc', 'u')
        .replaceAll('\u015f', 's')
        .replaceAll('\u00f6', 'o')
        .replaceAll('\u00e7', 'c')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }

  String _extractDomainFromQuery(Uri uri) {
    for (final value in uri.queryParameters.values) {
      if (_looksLikeDomain(value)) {
        return _sanitizeDomain(value);
      }

      final nestedUri = Uri.tryParse(value);
      if (nestedUri != null && _looksLikeDomain(nestedUri.host)) {
        return _sanitizeDomain(nestedUri.host);
      }
    }

    return '';
  }

  String _extractDomainFromPath(Uri uri) {
    for (final segment in uri.pathSegments) {
      final decoded = Uri.decodeComponent(segment).trim();
      if (_looksLikeDomain(decoded)) {
        return _sanitizeDomain(decoded);
      }
    }

    return '';
  }

  bool _looksLikeDomain(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final candidate = _sanitizeDomain(value).toLowerCase();
    if (!candidate.contains('.')) return false;

    final parts = candidate.split('.');
    if (parts.length < 2) return false;

    const invalidTlds = {'png', 'jpg', 'jpeg', 'svg', 'webp', 'gif', 'ico'};

    final tld = parts.last;
    if (tld.length < 2 || invalidTlds.contains(tld)) return false;

    final segmentPattern = RegExp(r'^[a-z0-9-]+$');
    return parts.every(
      (part) => part.isNotEmpty && segmentPattern.hasMatch(part),
    );
  }

  Widget getLogoWidget(String rawUrlOrDomain, {double size = 48.0}) {
    final resolvedDomain = resolveDomain(rawUrlOrDomain);
    final fallbackLetter = resolvedDomain.isNotEmpty
        ? resolvedDomain[0].toUpperCase()
        : '?';

    // Web engines either require cross-origin image decoding support or
    // platform-view backed HTML images. Prefer a deterministic local avatar.
    if (kIsWeb) {
      return SizedBox(
        width: size,
        height: size,
        child: Builder(
          builder: (context) =>
              _buildFallbackAvatar(context, fallbackLetter, size),
        ),
      );
    }

    final logoCandidates = resolveLogoUrls(rawUrlOrDomain);

    return SizedBox(
      width: size,
      height: size,
      child: Builder(
        builder: (context) {
          if (logoCandidates.isEmpty) {
            return _buildFallbackAvatar(context, fallbackLetter, size);
          }

          return _buildCachedLogoWithFallback(
            context,
            logoCandidates,
            0,
            resolvedDomain,
            fallbackLetter,
            size,
          );
        },
      ),
    );
  }

  Widget _buildCachedLogoWithFallback(
    BuildContext context,
    List<String> logoCandidates,
    int index,
    String domain,
    String fallbackLetter,
    double size,
  ) {
    if (index >= logoCandidates.length) {
      _markDomainFailed(domain);
      return _buildFallbackAvatar(context, fallbackLetter, size);
    }

    return CachedNetworkImage(
      imageUrl: logoCandidates[index],
      imageBuilder: (context, imageProvider) => _buildImageAvatar(
        context,
        Image(
          image: imageProvider,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
        size,
      ),
      placeholder: (context, url) =>
          _buildFallbackAvatar(context, fallbackLetter, size),
      errorWidget: (context, url, error) {
        _markLogoUrlFailed(url);
        return _buildCachedLogoWithFallback(
          context,
          logoCandidates,
          index + 1,
          domain,
          fallbackLetter,
          size,
        );
      },
    );
  }

  @visibleForTesting
  void markDomainAsFailed(String domain) {
    _markDomainFailed(_sanitizeDomain(domain));
  }

  void _markLogoUrlFailed(String url) {
    if (url.isEmpty) {
      return;
    }
    _failedLogoUrls.add(url);
  }

  void _markDomainFailed(String domain) {
    if (domain.isEmpty) {
      return;
    }
    _failedDomains.add(domain);
  }

  Widget _buildImageAvatar(BuildContext context, Widget child, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.of(context).background,
        shape: BoxShape.circle,
        boxShadow: AppColors.of(context).neumorphicShadows,
        border: Border.all(
          color: AppColors.of(context).shadowDark.withValues(alpha: 0.1),
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _buildFallbackAvatar(
    BuildContext context,
    String letter,
    double size,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.of(context).background,
        shape: BoxShape.circle,
        boxShadow: AppColors.of(context).neumorphicShadows,
        border: Border.all(
          color: AppColors.of(context).shadowDark.withValues(alpha: 0.1),
          width: 1.0,
        ),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
            color: AppColors.of(context).primaryAccent,
          ),
        ),
      ),
    );
  }
}

final logoServiceProvider = Provider<LogoService>((ref) => LogoService());

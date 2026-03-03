import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';

class LogoService {
  /// Returns the Clearbit Logo API URL for a given domain
  String getLogoUrl(String domain) {
    // Basic cleanup of the domain
    final cleanDomain = domain
        .replaceAll(RegExp(r'^https?://'), '')
        .replaceAll('www.', '')
        .split('/')
        .first;
    return 'https://logo.clearbit.com/$cleanDomain';
  }

  Widget getLogoWidget(String rawUrlOrDomain, {double size = 48.0}) {
    String finalUrl = '';
    String fallbackLetter = '?';

    // Check if it's already a full clearbit or specific image URL
    if (rawUrlOrDomain.startsWith('http')) {
      finalUrl = rawUrlOrDomain;
      // Extract a fallback letter heuristically (e.g. grabbing domain piece)
      final parts = rawUrlOrDomain.split('clearbit.com/');
      if (parts.length > 1 && parts[1].isNotEmpty) {
        fallbackLetter = parts[1][0].toUpperCase();
      } else {
        fallbackLetter = 'X';
      }
    } else {
      // It's a raw domain or name string
      final cleanDomain = rawUrlOrDomain
          .replaceAll(RegExp(r'^https?://'), '')
          .replaceAll('www.', '')
          .split('/')
          .first;
      fallbackLetter = cleanDomain.isNotEmpty
          ? cleanDomain[0].toUpperCase()
          : '?';
      finalUrl = getLogoUrl(cleanDomain);
    }

    return SizedBox(
      width: size,
      height: size,
      child: CachedNetworkImage(
        imageUrl: finalUrl,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            boxShadow: AppColors.of(context).neumorphicShadows,
            border: Border.all(
              color: AppColors.of(context).shadowDark.withValues(alpha: 0.1),
              width: 1.0,
            ),
          ),
        ),
        placeholder: (context, url) =>
            _buildFallbackAvatar(context, fallbackLetter, size),
        errorWidget: (context, url, error) =>
            _buildFallbackAvatar(context, fallbackLetter, size),
      ),
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

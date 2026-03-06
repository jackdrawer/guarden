import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color background;
  final Color shadowLight;
  final Color shadowDark;
  final Color primaryAccent;
  final Color textPrimary;
  final Color textSecondary;
  final Color error;
  final Color success;
  final Color surface;
  final List<BoxShadow> neumorphicShadows;

  const AppColorsExtension({
    required this.background,
    required this.shadowLight,
    required this.shadowDark,
    required this.primaryAccent,
    required this.textPrimary,
    required this.textSecondary,
    required this.error,
    required this.success,
    required this.surface,
    required this.neumorphicShadows,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith() {
    return this;
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      background: Color.lerp(background, other.background, t)!,
      shadowLight: Color.lerp(shadowLight, other.shadowLight, t)!,
      shadowDark: Color.lerp(shadowDark, other.shadowDark, t)!,
      primaryAccent: Color.lerp(primaryAccent, other.primaryAccent, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      neumorphicShadows: t < 0.5 ? neumorphicShadows : other.neumorphicShadows,
    );
  }
}

class AppColors {
  // Accessor for the UI
  static AppColorsExtension of(BuildContext context) {
    return Theme.of(context).extension<AppColorsExtension>() ?? light;
  }

  // Pre-defined variants
  static final AppColorsExtension light = AppColorsExtension(
    background: const Color(0xFFE0E5EC),
    shadowLight: const Color(0xFFFFFFFF),
    shadowDark: const Color(0xFFA3B1C6),
    primaryAccent: const Color(0xFFEF8539),
    textPrimary: const Color(0xFF4A5568),
    textSecondary: const Color(0xFF718096),
    error: const Color(0xFFE53E3E),
    success: const Color(0xFF48BB78),
    surface: const Color(0xFFF7FAFC),
    neumorphicShadows: [
      const BoxShadow(
        color: Color(0xFFFFFFFF),
        offset: Offset(-4, -4),
        blurRadius: 8,
        spreadRadius: 0,
      ),
      const BoxShadow(
        color: Color(0xFFA3B1C6),
        offset: Offset(4, 4),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
  );

  static final AppColorsExtension dark = AppColorsExtension(
    background: const Color(0xFF1E1E24), // Deeper Neumorphic Dark
    shadowLight: const Color(0xFF2A2A33),
    shadowDark: const Color(0xFF121215),
    primaryAccent: const Color(0xFFF19754), // Brighter peach for dark
    textPrimary: const Color(0xFFE2E8F0),
    textSecondary: const Color(0xFF94A3B8),
    error: const Color(0xFFF87171),
    success: const Color(0xFF68D391),
    surface: const Color(0xFF23232A),
    neumorphicShadows: [
      const BoxShadow(
        color: Color(0xFF2A2A33),
        offset: Offset(-4, -4),
        blurRadius: 8,
        spreadRadius: 0,
      ),
      const BoxShadow(
        color: Color(0xFF121215),
        offset: Offset(4, 4),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
  );
}

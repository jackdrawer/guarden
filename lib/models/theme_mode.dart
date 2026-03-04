import 'package:flutter/material.dart';

/// Uygulama tema modu seçenekleri
enum AppThemeMode { light, dark, system }

/// AppThemeMode extension'ları
extension AppThemeModeExtension on AppThemeMode {
  /// Tema modu ismi (i18n'den alınacak)
  String get name {
    switch (this) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
    }
  }

  /// Tema modu ikonu
  IconData get icon {
    switch (this) {
      case AppThemeMode.light:
        return Icons.light_mode_outlined;
      case AppThemeMode.dark:
        return Icons.dark_mode_outlined;
      case AppThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }

  /// String'den AppThemeMode dönüştürme
  static AppThemeMode fromString(String? value) {
    return AppThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppThemeMode.system,
    );
  }
}

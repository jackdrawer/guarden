import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/theme_mode.dart';
import 'settings_provider.dart';

/// Uygulama temasını yöneten provider
///
/// Bu provider, kullanıcının seçtiği tema moduna göre
/// [ThemeMode.light], [ThemeMode.dark] veya sistem ayarlarını döndürür.
final themeModeProvider = Provider<ThemeMode>((ref) {
  final appThemeMode =
      ref.watch(settingsProvider).valueOrNull?.themeMode ?? AppThemeMode.system;

  switch (appThemeMode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
});

/// Sistem parlaklık değişikliklerini dinleyen provider
///
/// Bu provider, sistem teması değiştiğinde (örn. gündüz/gece modu)
/// uygulamanın doğru temayı kullanmasını sağlar.
final platformBrightnessProvider = Provider<Brightness>((ref) {
  return WidgetsBinding.instance.platformDispatcher.platformBrightness;
});

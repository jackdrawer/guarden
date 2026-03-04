import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/theme_mode.dart';
import '../providers/settings_provider.dart';
import '../theme/app_colors.dart';
import '../i18n/strings.g.dart';
import 'neumorphic/neumorphic_container.dart';

/// Tema seçici widget
///
/// Light, Dark ve System tema seçeneklerini gösteren,
/// neumorphic tasarıma uygun tema seçim kartları sunar.
class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme =
        ref.watch(settingsProvider).valueOrNull?.themeMode ??
        AppThemeMode.system;
    final colors = AppColors.of(context);

    return NeumorphicContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.settings.theme.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: AppThemeMode.values.map((mode) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _ThemeOptionCard(
                    mode: mode,
                    isSelected: currentTheme == mode,
                    onTap: () =>
                        ref.read(settingsProvider.notifier).setThemeMode(mode),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Tek tema seçenek kartı
class _ThemeOptionCard extends StatelessWidget {
  final AppThemeMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionCard({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AnimatedScale(
      scale: isSelected ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: colors.primaryAccent, width: 2)
                : null,
          ),
          child: NeumorphicContainer(
            padding: const EdgeInsets.all(12),
            borderRadius: 14,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // İkon
                Icon(
                  mode.icon,
                  size: 28,
                  color: isSelected
                      ? colors.primaryAccent
                      : colors.textSecondary,
                ),
                const SizedBox(height: 8),
                // Mini tema önizlemesi
                _ThemePreview(mode: mode),
                const SizedBox(height: 8),
                // Etiket
                Text(
                  _getLabel(mode),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? colors.textPrimary
                        : colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                // Radio button
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: isSelected
                      ? Icon(
                          Icons.radio_button_checked,
                          size: 18,
                          color: colors.primaryAccent,
                          key: const ValueKey('selected'),
                        )
                      : Icon(
                          Icons.radio_button_unchecked,
                          size: 18,
                          color: colors.textSecondary,
                          key: const ValueKey('unselected'),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return t.settings.theme.light;
      case AppThemeMode.dark:
        return t.settings.theme.dark;
      case AppThemeMode.system:
        return t.settings.theme.system;
    }
  }
}

/// Mini tema önizleme widget'ı
class _ThemePreview extends StatelessWidget {
  final AppThemeMode mode;

  const _ThemePreview({required this.mode});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: _getShadowColor().withAlpha(100),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildPreviewContent(),
      ),
    );
  }

  Widget _buildPreviewContent() {
    switch (mode) {
      case AppThemeMode.light:
        return Container(
          color: const Color(0xFFE0E5EC),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFFA3B1C6),
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 24,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAFC),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        );
      case AppThemeMode.dark:
        return Container(
          color: const Color(0xFF1E1E24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A33),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF121215),
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 24,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF23232A),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        );
      case AppThemeMode.system:
        return Row(
          children: [
            // Sol yarısı light
            Expanded(
              child: Container(
                color: const Color(0xFFE0E5EC),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: 12,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAFC),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sağ yarısı dark
            Expanded(
              child: Container(
                color: const Color(0xFF1E1E24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A33),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: 12,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF23232A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
    }
  }

  Color _getShadowColor() {
    switch (mode) {
      case AppThemeMode.light:
        return const Color(0xFFA3B1C6);
      case AppThemeMode.dark:
        return const Color(0xFF000000);
      case AppThemeMode.system:
        return const Color(0xFF666666);
    }
  }
}

# Tema Seçici Mock Tasarım Planı

## 🎯 Özet
Guarden uygulamasına şık bir tema seçici (Light/Dark/System) eklenmesi planlanmaktadır. Neumorphic UI tasarım dili korunarak, kullanıcı dostu ve görsel açıdan tatmin edici bir tema seçim deneyimi sunulacaktır.

---

## 📐 UI Tasarım Spec

### Bölüm Yerleşimi
Settings screen'de **"Görünüm" / "Appearance"** bölümü şu sıralamada eklenecek:
1. System Integration
2. **Appearance (YENİ)** ← Tema seçici burada
3. Security and Privacy
4. Google Drive Backup
5. Device Backup
6. Notifications

### Tema Seçici Layout

```
┌─────────────────────────────────────────┐
│  Görünüm / Appearance                   │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────┬──────────┬──────────┐   │
│  │  [☀️]    │  [🌙]    │  [📱]    │   │
│  │          │          │          │   │
│  │ ░░░░░░░░ │ ████████ │ ░░██░░██ │   │
│  │ ░░░░░░░░ │ ██░░░░██ │ ██░░██░░ │   │
│  │ ░░░░░░░░ │ ████████ │ ░░██░░██ │   │
│  │          │          │          │   │
│  │ Aydınlık │  Karanlık│ Sistem   │   │
│  │          │          │          │   │
│  │    ●     │     ○    │    ○     │   │
│  └──────────┴──────────┴──────────┘   │
│                                         │
└─────────────────────────────────────────┘
```

### Kart Tasarım Detayları

Her tema seçeneği **NeumorphicContainer** içinde, 3'lü yatay bir düzende olacak:

| Özellik | Değer |
|---------|-------|
| Kart boyutu | 100x120 px |
| Border radius | 16px |
| İç padding | 12px |
| Kart arası boşluk | 12px |
| Seçili gösterim | Accent renk border (2px) + iç glow |
| İkon boyutu | 28px |

### Mini Tema Önizlemesi
Her kartın ortasında tema önizlemesi olacak:

**Light Mode Kart:**
- Arka plan: `#F7FAFC` (surface)
- Önizleme alanı: 40x40px rounded rectangle
- İçerik: Açık tonlar (soft shadow)

**Dark Mode Kart:**
- Arka plan: `#23232A` (surface)
- Önizleme alanı: 40x40px rounded rectangle
- İçerik: Koyu tonlar (dark shadow)

**System Mode Kart:**
- Arka plan: Gradient (light → dark)
- Önizleme alanı: 40x40px rounded rectangle
- İçerik: Yarı light / yarı dark

### Seçili Durum Gösterimi

**Seçili Kart:**
```dart
NeumorphicContainer(
  borderRadius: 16,
  // Seçili ise farklı shadow ve border
  isSelected: true,
)
```

- Dış çizgi: `primaryAccent` rengi (2px)
- Radio button: Dolu daire (accent color)
- Subtle scale animasyonu: 1.02x

**Seçilmemiş Kart:**
- Normal neumorphic shadow
- Radio button: Boş daire (textSecondary)

---

## 🏗️ Mimari Yapı

### 1. Enum Tanımı

```dart
// lib/models/theme_mode.dart
enum AppThemeMode {
  light,
  dark,
  system,
}

extension AppThemeModeExtension on AppThemeMode {
  String get label {
    return switch (this) {
      AppThemeMode.light => t.settings.theme.light,
      AppThemeMode.dark => t.settings.theme.dark,
      AppThemeMode.system => t.settings.theme.system,
    };
  }
  
  IconData get icon {
    return switch (this) {
      AppThemeMode.light => Icons.light_mode_outlined,
      AppThemeMode.dark => Icons.dark_mode_outlined,
      AppThemeMode.system => Icons.brightness_auto_outlined,
    };
  }
}
```

### 2. SettingsState Güncellemesi

```dart
class SettingsState {
  // ... mevcut alanlar ...
  final AppThemeMode themeMode;
  
  SettingsState({
    // ... mevcut alanlar ...
    this.themeMode = AppThemeMode.system, // default
  });
  
  SettingsState copyWith({
    // ... mevcut alanlar ...
    AppThemeMode? themeMode,
  }) {
    return SettingsState(
      // ... mevcut alanlar ...
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
```

### 3. SettingsService Güncellemesi

```dart
class SettingsService {
  // ... mevcut kod ...
  
  AppThemeMode get themeMode {
    final value = _prefs.getString('theme_mode');
    return AppThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppThemeMode.system,
    );
  }
  
  Future<void> setThemeMode(AppThemeMode mode) async {
    await _prefs.setString('theme_mode', mode.name);
  }
}
```

### 4. Theme Seçici Widget

```dart
// lib/widgets/settings/theme_selector.dart
class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(settingsProvider).valueOrNull?.themeMode 
        ?? AppThemeMode.system;
    
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
              color: AppColors.of(context).textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: AppThemeMode.values.map((mode) {
              return Expanded(
                child: _ThemeOptionCard(
                  mode: mode,
                  isSelected: currentTheme == mode,
                  onTap: () => ref
                      .read(settingsProvider.notifier)
                      .setThemeMode(mode),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
```

### 5. Tema Provider'ı (Global)

```dart
// lib/providers/theme_provider.dart
final themeModeProvider = Provider<ThemeMode>((ref) {
  final appThemeMode = ref.watch(settingsProvider).valueOrNull?.themeMode 
      ?? AppThemeMode.system;
  
  if (appThemeMode == AppThemeMode.system) {
    // MediaQuery platform brightness kullan
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == 
        Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  }
  
  return appThemeMode == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light;
});
```

---

## 🎨 Renk ve Stil

### Kullanılacak Renkler

| Element | Light Mode | Dark Mode |
|---------|------------|-----------|
| Seçili border | `#EF8539` | `#F19754` |
| Radio dolu | `#EF8539` | `#F19754` |
| Radio boş | `#718096` | `#94A3B8` |
| Kart bg | `#F7FAFC` | `#23232A` |
| Önizleme light | `#E0E5EC` | - |
| Önizleme dark | - | `#1E1E24` |

### Tipografi

- Bölüm başlığı: 14px, FontWeight.w600
- Kart etiketi: 12px, FontWeight.w500

---

## 📝 i18n Çevirileri

### TR (tr.i18n.json)
```json
"theme": {
  "title": "Tema",
  "light": "Aydınlık",
  "dark": "Karanlık",
  "system": "Sistem",
  "tooltip": "Uygulamanın görünüm temasını seçin"
}
```

### EN (en.i18n.json)
```json
"theme": {
  "title": "Theme",
  "light": "Light",
  "dark": "Dark",
  "system": "System",
  "tooltip": "Choose the app appearance theme"
}
```

---

## 🔄 Animasyonlar

### Kart Seçim Animasyonu

```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 200),
  curve: Curves.easeInOut,
  transform: isSelected 
      ? Matrix4.diagonal3Values(1.02, 1.02, 1.0)
      : Matrix4.identity(),
  decoration: BoxDecoration(
    border: Border.all(
      color: isSelected 
          ? AppColors.of(context).primaryAccent 
          : Colors.transparent,
      width: 2,
    ),
    borderRadius: BorderRadius.circular(16),
  ),
  child: NeumorphicContainer(...),
)
```

### Radio Button Animasyonu

```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 150),
  child: isSelected 
      ? Icon(Icons.radio_button_checked, color: accentColor)
      : Icon(Icons.radio_button_unchecked, color: textSecondary),
)
```

---

## 📱 main.dart Güncellemesi

```dart
class GuardenApp extends ConsumerWidget {
  const GuardenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      // ... mevcat kod ...
      themeMode: themeMode, // YENİ
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEF8539),
          surface: const Color(0xFFE0E5EC),
        ),
        useMaterial3: true,
        extensions: [AppColors.light],
      ),
      darkTheme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEF8539),
          brightness: Brightness.dark,
          surface: const Color(0xFF23232A),
        ),
        useMaterial3: true,
        extensions: [AppColors.dark],
      ),
      // ...
    );
  }
}
```

---

## 📋 Dosya Yapısı

```
lib/
├── models/
│   └── theme_mode.dart              # AppThemeMode enum
├── providers/
│   ├── settings_provider.dart       # Güncellenecek
│   └── theme_provider.dart          # YENİ
├── widgets/
│   └── settings/
│       ├── theme_selector.dart      # YENİ - Ana widget
│       └── theme_preview_card.dart  # YENİ - Mini önizleme
├── services/
│   └── settings_service.dart        # Güncellenecek
└── screens/
    └── settings/
        └── settings_screen.dart     # Güncellenecek
```

---

## ✨ Özellikler Özeti

| Özellik | Durum |
|---------|-------|
| Light/Dark/System seçimi | ✅ |
| Mini tema önizlemesi | ✅ |
| Neumorphic UI uyumu | ✅ |
| Seçim animasyonları | ✅ |
| Kalıcı kaydetme | ✅ |
| i18n desteği (TR/EN) | ✅ |

---

## 🚀 Uygulama Adımları

1. **Enum ve Model** → `theme_mode.dart`
2. **SettingsService** → Tema okuma/yazma
3. **SettingsState/Provider** → State yönetimi
4. **ThemeSelector Widget** → UI komponenti
5. **SettingsScreen** → Bölüm ekleme
6. **i18n** → Çeviriler
7. **main.dart** → Tema uygulama
8. **Test** → Farklı modlarda kontrol

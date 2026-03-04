# Phase 5: UX & Autofill - Context

**Gathered:** 2026-03-02
**Status:** Ready for planning (updated after codebase audit)

<domain>
## Phase Boundary

Autofill Framework (Android/iOS) ekleme, empty state illüstrasyonları, ses efektleri, form auto-save, screenshot engelleme, settings toggle'ları ve ince UX detayları. Mevcut uygulamayı profesyonel seviyeye çıkarma.

**NOT:** Aşağıdaki özellikler zaten kodda mevcut ve bu phase'de YAPILMAYACAK:
- Dark mode (ThemeExtension light/dark, tüm widget'lar AppColors.of(context) kullanıyor)
- Brand database (15 banka + 16 abonelik) + NeumorphicTypeAhead autocomplete
- Staggered list animations (flutter_staggered_animations tüm listelerde)
- Hero transitions (logo geçişleri)
- Haptic feedback (HapticFeedback.lightImpact() listelerde ve FAB'da)
- Logo service (Clearbit API + cached_network_image + fallback avatar)
- Clipboard service (45sn otomatik temizleme)
- Splash screen (animasyonlu neumorphic kabartma efekti)
- Tooltips (butonlarda)

</domain>

<decisions>
## Implementation Decisions

### Autofill Framework (ANA ÖNCELİK)
- **Kapsam:** Kullanıcı seçebilecek, web şifreleri varsayılan olarak açık. Diğer kategoriler (banka, abonelik) Settings'ten aktif edilebilir.
- **Kimlik doğrulama:** Her autofill isteğinde biyometrik onay zorunlu.
- **Premium gate:** Yok — autofill herkese açık.
- **Eşleşme stratejisi:** Claude'un takdiri — URL/domain + uygulama paketi bazlı.
- **Platform:** Android AutofillService + iOS ASCredentialProviderViewController.

### Empty State İllüstrasyonları
- Tüm boş liste ekranlarında ("Henüz banka hesabı eklemediniz.") illüstrasyon/görsel eklenmeli.
- Kullanıcıyı teşvik eden friendly tasarım.
- Bu konuda kullanıcı özellikle "hiç görsel yok, app çok sade" geri bildirimi verdi.

### Ses Efektleri
- Minimal sesler: şifre kopyalama tik sesi, başarılı kaydetme chime'i.
- Settings'ten kapatılabilir toggle.

### Form Auto-Save Draft
- Form doldurulurken taslak otomatik kaydedilecek.
- Kazayla geri çıkılınca "Taslağınız kaydedildi" mesajı.

### Screenshot Engelleme
- Settings'ten açılıp kapatılabilir toggle (varsayılan: açık).
- Android: FLAG_SECURE, iOS: hiden content on app switcher.

### Settings Yeni Toggle'lar
- Ses efektleri aç/kapa
- Haptic feedback aç/kapa (mevcut haptic var, toggle eksik)
- Screenshot engelleme aç/kapa
- Autofill kategori seçimi (web şifreleri / banka / abonelik checkboxları)

### Adaptive Icon
- Android 13+ tema ikonu desteği, iOS'ta standart ikon.

### Biyometrik UX
- Biyometrik başarısızlık durumunda master password'a düş (fallback).

### Onboarding Güncelleme
- Claude'un takdiri — yeni özellikleri tanıtan en uygun format.

### Claude's Discretion
- Autofill eşleşme stratejisi detayları
- Empty state illüstrasyon stili (SVG, Lottie, veya özel widget)
- Onboarding formatı
- Skeleton loading ekleme gerekliliği (staggered animations zaten var)
- Biyometrik fallback detayları

</decisions>

<specifics>
## Specific Ideas

- Kullanıcı geri bildirimi: "Hiç görsel yok, app çok sade" — empty state illüstrasyonları kritik
- Autofill herkesin kullanabilmesi önemli — ücretsiz kullanıcı çekme stratejisinin parçası
- Ses efektleri minimal — rahatsız etmemeli
- Form auto-save: Kullanıcı kazayla çıkınca veri kaybetmesin
- Screenshot engelleme: güvenlik bilinci olan kullanıcılar için

</specifics>

<code_context>
## Existing Code Insights

### Already Implemented (DO NOT REDO)
- `AppColors` → ThemeExtension with light/dark variants, `AppColors.of(context)` pattern
- `NeumorphicContainer/Button/Input/TypeAhead/BottomNav` → All use `AppColors.of(context)`
- `BrandDatabase` (lib/constants/brand_database.dart) → 15 banks + 16 subscriptions
- `NeumorphicTypeAhead` → TypeAhead with logo previews in dropdown
- `LogoService` → Clearbit API + cached_network_image + fallback avatar
- `ClipboardService` → 45sec auto-clear timer
- `SplashScreen` → Animated neumorphic logo rise with Hero tag
- `flutter_staggered_animations` → All list screens
- `HapticFeedback.lightImpact()` → On list taps and FABs

### Reusable Patterns
- SettingsService/SettingsProvider pattern for new toggles (haptic, sound, screenshot, autofill prefs)
- GoRouter for new routes if needed
- Riverpod providers for new services

### Integration Points
- `lib/screens/settings/settings_screen.dart` → New toggles section
- `lib/services/settings_service.dart` → New keys
- `lib/providers/settings_provider.dart` → New state fields
- Android `AndroidManifest.xml` → AutofillService registration
- iOS Runner → ASCredentialProviderViewController extension
- Empty state locations: bank_accounts_tab, subscriptions_tab, web_passwords_tab, dashboard_tab

</code_context>

<deferred>
## Deferred Ideas

- Bulut senkronizasyon (Cloud sync) — ayrı phase
- Store görselleri ve marketing materyalleri — deployment phase

</deferred>

---

*Phase: 05-ux-autofill*
*Context gathered: 2026-03-02 (updated)*

---
title: "Project Quality Control Backlog"
area: engineering
priority: high
created: 2026-03-02
updated: 2026-03-03
---

## 0) Build/Test Gate (Critical) ✅ VERIFIED
- [x] `test/widget_test.dart` dosyasini gercek uygulama akisina gore yeniden yaz (counter smoke test yerine login/splash/router smoke test).
  - Evidence: `test/widget_test.dart:11` - TranslationProvider ile sarmalanmış
- [x] CI/yerel gate ekle: `flutter analyze` + `flutter test` gecmeden merge edilmesin.
  - Evidence: 2026-03-03 - `flutter analyze` sadece 5 info, `flutter test` 9/9 geçti
- [x] `problems.json` dosyasini yeniden uret veya stale ise repodan cikar; su an analiz sonucu ile tutarsiz.

## 1) Release Hazirliklari (High) ✅ VERIFIED
- [x] `android/app/build.gradle.kts` icindeki `applicationId = "com.example.guarden"` degerini production package id ile degistir.
- [x] `android/app/build.gradle.kts` release icin debug signing kullanimini kaldir, gercek signing config tanimla.
- [x] ~~`lib/services/purchase_service.dart` RevenueCat key placeholder'larini guvenli config (env/secret manager) ile besle.~~
  - **KALDIRILDI**: Premium satın alma özelliği kaldırıldı.

## 2) Security Hardening (High) ✅ VERIFIED
- [x] `lib/providers/auth_provider.dart` salt uretimini zaman damgasi yerine kriptografik random ile degistir.
- [x] `lib/providers/auth_provider.dart` key karsilastirmasini timing-safe yaklasimla yap (sabit zamanli compare).
- [x] `lib/screens/settings/settings_screen.dart` mock double-auth yerine gercek biyometrik/master-password dogrulama akisi ekle.
- [x] `lib/services/notification_service.dart` TODO kalan izin isteme akislarini platform bazli netlestir ve uygula.
- [x] ~~Seed phrase recovery implementasyonu~~
  - **KALDIRILDI**: Seed phrase recovery özelliği kaldırıldı.

## 3) Code Health (Medium) ✅ VERIFIED
- [x] `fix_consts.dart` ve `migrate_colors.dart` gibi tek seferlik scriptleri `tool/` altina tasi veya analyzer exclude et; `avoid_print` lintleri temizle.
- [x] Gereksiz importlari temizle (`unnecessary_import`):
- [x] `lib/screens/bank_accounts/bank_account_detail_screen.dart`
- [x] `lib/screens/subscriptions/subscription_detail_screen.dart`
- [x] `lib/screens/web_passwords/web_password_detail_screen.dart`
- [x] `lib/widgets/password_generator_dialog.dart`
- [x] README'yi urun-ozel setup, guvenlik modeli ve test komutlari ile guncelle (`README.md` su an template).

## 4) Test Coverage Expansion (Medium) ✅ VERIFIED
- [x] `auth_provider` icin unit testler: first-time, basarili login, hatali login, lock.
- [x] `settings_provider` icin unit testler: toggle ve persistence senaryolari.
- [x] `notification_service` icin behavior testleri: expired/soon hesaplama ve bildirim tetikleme.
- [x] En az 1 widget integration smoke testi: uygulama shell/router boot dogrulama.

## 5) Localization & Content Expansion (High) ✅ COMPLETE
- [x] Localizasyonlar genişletildi (i18n strings)
  - Evidence: `lib/i18n/en.i18n.json` ve `lib/i18n/tr.i18n.json` güncellendi
- [x] Banka logoları genişletildi
  - Evidence: `lib/constants/brand_database.dart` güncellendi

## 6) Animation Expansion (Medium) ✅ COMPLETE
- [x] Animasyonlar genişletildi
  - Evidence: `lib/theme/motion_tokens.dart` ve neumorphic widget'lar
  - Bottom nav animations
  - FAB transitions
  - Focus/hover states

## 7) Code Quality & Bug Fixes (Critical) ✅ COMPLETE
- [x] Kod kalitesi iyileştirmeleri yapıldı
- [x] Hata gidermeleri tamamlandı
  - `flutter analyze` temiz (5 info, 0 error)
  - `flutter test` 9/9 geçiyor

---

## Dogrulama Sonuclari (2026-03-03)

| Kategori | Test Sonucu |
|----------|-------------|
| `flutter analyze` | ✅ 5 info (hata yok) |
| `flutter test` | ✅ 9/9 test geçti |
| Build | ✅ Başarılı |
| Localization | ✅ Genişletildi |
| Bank Logoları | ✅ Genişletildi |
| Animasyonlar | ✅ Genişletildi |

**Genel Durum: TAMAMLANDI** 🎉

**Kaldırılan Özellikler:**
- Premium satın alma (RevenueCat entegrasyonu)
- Seed phrase recovery

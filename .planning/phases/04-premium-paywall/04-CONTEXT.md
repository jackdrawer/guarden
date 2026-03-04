# Phase 4 Context: Premium, Paywall & Polish

## Objective
Guarden'ı monetize etmek: RevenueCat ile In-App Purchase, freemium limitleri, premium özellikler (Seyahat/Panik modu, Pwned API) ve bildirimler. Phase 3'te oluşturulan CRUD ekranlarına limit kontrolü ve premium gating eklenecek.

## Decisions

### 1. Paywall & Fiyatlandırma

| Karar | Seçim | Detay |
|-------|-------|-------|
| Paywall tetikleme | Hem limit aşımı hem premium özellik erişimi | 6. bankayı eklerken VEYA Seyahat modu gibi premium özelliğe tıklayınca paywall açılır |
| Freemium limitleri | 5 banka, 3 abonelik, 5 web şifresi | Market research önerisi |
| Fiyatlandırma | Aylık + Yıllık | ₺49.99/ay veya ₺399.99/yıl (%33 indirim). RevenueCat üzerinden. |
| Paywall tasarımı | Claude'un takdiri | Neumorphic estetik, özellik listesi, CTA butonu |
| Premium durum yönetimi | RevenueCat listener | SDK otomatik kontrol. Sunucu doğrulama yok, offline çalışır. |
| Limit aşım UX | Kalan hak göstergesi + paywall yönlendirme | Liste üstünde "2/5 kayıt" göstergesi + limit aşımında paywall |
| Grandfathering | Mevcut kayıtlar korunur | Eski veriler silinmez ama limit altına düşene kadar ekleme engellenir |
| Trial | 7 gün ücretsiz deneme | RevenueCat ile yönetilir |

### 2. Seyahat & Panik Modu

| Karar | Seçim | Detay |
|-------|-------|-------|
| Seyahat modu davranışı | Seçilen kasalar gizlenir | Kullanıcı seyahat öncesi hangi kayıtların gizleneceğini seçer. Geri kalanı görünür. |
| Panik modu davranışı | Sadece bağlantı anahtarlarını sil | SecureStorage'daki encryption key + salt silinir. Veriler şifreli kalır. Seed phrase ile kurtarma mümkün. |
| Erişim noktası | Ayarlar ekranında | Settings > Seyahat Modu toggle. Settings > Panik Modu butonu (onay ile). |
| Onay mekanizması | Çift onay: biyometrik + master password | Panik modu için çift onay (biyometrik + master password). Seyahat modu için de çift onay. |

### 3. Pwned / Zayıf Şifre Kontrolü

| Karar | Seçim | Detay |
|-------|-------|-------|
| Pwned API yaklaşımı | Claude'un takdiri | k-Anonymity önerilir (SHA-1 hash'in ilk 5 karakteri) |
| Tetikleme zamanı | Manuel + Kayıt eklerken | Yeni şifre kaydederken otomatik kontrol + Dashboard'da "Tümünü Kontrol Et" butonu |
| Zayıf şifre değerlendirmesi | Uzunluk + karmaşıklık + tekrar | 8 karakterden kısa, sadece rakam, tekrarlanan şifreler zayıf işaretlenir |
| Sonuç gösterimi | Dashboard'da güvenlik kartı | "Güvenlik Durumu" kartı: X zayıf, Y ifşa şifre. Tıklayınca detay. |

### 4. Bildirimler & Hatırlatıcılar

| Karar | Seçim | Detay |
|-------|-------|-------|
| Bildirim olayları | Rotasyon + Abonelik yenileme + Güvenlik | Banka şifre rotasyonu, abonelik ödeme tarihi, zayıf/ifşa şifre bulunduğunda |
| Zamanlama | 7 gün + 1 gün önce | Son tarihe 7 gün kala ilk hatırlatma, 1 gün kala son uyarı |
| Ayar yönetimi | Ayarlar ekranında toggle | Settings > Bildirimler bölümü. Global aç/kapa + kategori bazlı toggle. |

## Code Context

### Mevcut Entegrasyon Noktaları
- **SecureStorageService** (`lib/services/secure_storage_service.dart`): `deleteAll()` metodu Panik modu için hazır
- **AuthProvider** (`lib/providers/auth_provider.dart`): `lock()` metodu + AuthState enum mevcut
- **CRUD Providers** (`lib/providers/`): `bankAccountProvider`, `subscriptionProvider`, `webPasswordProvider` — limit kontrolü buraya eklenecek
- **GoRouter** (`lib/router.dart`): Paywall ve Settings route'ları eklenecek
- **DashboardTab** (`lib/screens/dashboard/dashboard_tab.dart`): Güvenlik kartı + bildirim gösterimi buraya eklenir
- **BiometricService** (`lib/services/biometric_service.dart`): Seyahat/Panik onayı için mevcut
- **Neumorphic widgets** (`lib/widgets/neumorphic/`): Paywall ve Settings ekranlarında kullanılacak

### Yeni Dosyalar (Beklenen)
- `lib/services/purchase_service.dart` — RevenueCat entegrasyonu
- `lib/services/notification_service.dart` — flutter_local_notifications
- `lib/services/pwned_service.dart` — Have I Been Pwned API
- `lib/services/password_strength_service.dart` — Zayıf şifre değerlendirmesi
- `lib/providers/premium_provider.dart` — Premium durum yönetimi + limit kontrolü
- `lib/screens/settings/settings_screen.dart` — Ayarlar ekranı
- `lib/screens/paywall/paywall_screen.dart` — Paywall UI
- `lib/screens/security/security_report_screen.dart` — Güvenlik detay ekranı

### Paket Gereksinimleri
- `purchases_flutter` — RevenueCat SDK (pubspec'te mevcut)
- `flutter_local_notifications` — Bildirimler (pubspec'te mevcut)
- `crypto` veya `sha1` — Pwned API için SHA-1 hash

## Deferred Ideas
- Periyodik arka plan Pwned kontrolü (pil/veri tüketimi riski — Phase 5+ için düşünülebilir)
- Kayıt bazlı bildirim toggle'ı (global yeterli, kayıt bazlı override Phase 5+ için)
- Sahte/decoy kasa özelliği (Panik modunun ileri versiyonu — çok karmaşık, şimdilik kapsam dışı)

## Current Status
Ready for planning.

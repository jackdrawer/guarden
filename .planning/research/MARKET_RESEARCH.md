# Pazar ve Özellik Araştırma Raporu

## 1. Türkiye Şifre Yöneticisi Pazar Analizi

### 1.1 Pazar Büyüklüğü
- **Küresel Pazar:** 2024'te ~$2.7-3.4 milyar, 2028'de ~$6.8 milyar bekleniyor (Grand View Research, TBRC)
- **Türkiye Siber Güvenlik Pazarı:** 2025'te $37.5M, 2031'de $75M bekleniyor (Mordor Intelligence)
- **Türkiye Pazarı:** Tahmini 2-3 milyon aktif şifre yöneticisi kullanıcısı (doğrudan veri mevcut değil)
- **Büyüme Oranı:** Küresel CAGR %21-22 (2024-2028)

---

## 7. Kullanıcı Şikayetleri ve Çözüm Önerileri

### 7.1 Şikayet Kategorileri ve Guarden Çözümleri

| Şikayet | Sıklık | Çözüm | Öncelik |
|---------|--------|-------|----------|
| "Şifremi unuttum, hesabım gitti" | 🔴 Çok Yüksek | Seed phrase kurtarma + güvenli saklama | 🔴 |
| "Otomatik doldurma çalışmıyor" | 🔴 Çok Yüksek | Flutter Autofill framework entegrasyonu | 🔴 |
| "Uygulama çok yavaş" | 🟡 Yüksek | Performance optimizasyonu, lazy loading | 🟡 |
| "Şifrelerim sızdırıldı mı bilmiyorum" | 🟡 Yüksek | Pwned Passwords API entegrasyonu | 🟡 |
| "Aile üyelerimle paylaşamıyorum" | 🟢 Orta | Aile paylaşım sistemi | 🟢 |
| "Tarayıcı eklentisi yok" | 🟢 Orta | Chrome/Firefox extension | 🔵 |
| "Karanlık mod yok" | 🟢 Orta | Dark mode implementasyonu | 🟢 |
| "Fiyat çok yüksek" | 🟡 Yüksek | Freemium model + yerel para birimi | 🔴 |

### 7.2 Detaylı Şikayet Analizi ve Çözümler

#### 🔴 KRITIK: Şifremi Unuttum, Hesabım Gitti
**Şikayet:**
```
"1Password'ta master password'u unuttum ve tüm şifrelerime erişimi kaybettim." 
"Dashlane'de kurtarma seçeneği yoktu."
```

**Guarden Çözümü:**
- ✅ **Seed phrase (12 kelime)** - Mevcut
- 📋 **Güvenli seed saklama önerisi** - Kullanıcıya yazılı kopya saklamasını hatırlat
- 📋 **Kurtarma akışı geliştir** - Seed phrase ile hesap kurtarma ekranı

```dart
// Önerilen: Kurtarma akışı
class RecoveryScreen extends StatelessWidget {
  // 12 kelime input alanı
  // Kelime doğrulama
  // Yeni master password belirleme
}
```

---

#### 🔴 KRITIK: Otomatik Doldurma Çalışmıyor
**Şikayet:**
```
"Her seferinde şifreyi kopyalamak zorunda kalıyorum."
"Autofill hiç çalışmıyor."
```

**Guarden Çözümü:**
- 📋 **Flutter AutofillService** entegrasyonu
- 📋 **Android Autofill Framework** desteği
- 📋 **iOS AutoFill Credential Provider** desteği

```yaml
# pubspec.yaml
autofill_couch: ^1.0.0  # veya benzeri
```

---

#### 🟡 YÜKSEK: Şifrelerim Sızdırıldı mı?
**Şikayet:**
```
"Hesaplarımın hacklendiğini nasıl anlarım?"
"Eski şifrelerim güvenli mi bilmiyorum."
```

**Guarden Çözümü:**
- 📋 **Pwned Passwords API** (Have I Been Pwned entegrasyonu)
- 📋 **Periyodik şifre kontrolü** - Premium özellik
- 📋 **Güvenlik uyarı sistemi** - Dashboard'da göster

```dart
// Önerilen: Pwned kontrolü
class PwnedService {
  Future<bool> checkPassword(String password) async {
    // k-Anonymity modeli ile API çağrısı
    // Sadece hash'in ilk 5 karakteri gönderilir
  }
}
```

---

#### 🟡 YÜKSEK: Performans Sorunları
**Şikayet:**
```
"Uygulama çok yavaş açılıyor."
"Liste çok uzun olduğunda donuyor."
```

**Guarden Çözümü:**
- ✅ **Lazy loading** - Provider'lar zaten lazy
- 📋 **ListView.builder** tüm listelerde
- 📋 **Image caching** - LogoService'de mevcut
- 📋 **Hive lazy boxes** - Büyük veri setleri için

---

#### 🟢 ORTA: Aile Paylaşımı
**Şikayet:**
```
"Eşimle şifreleri paylaşmak istiyorum."
"Çocuğumun hesaplarını yönetmek istiyorum."
```

**Guarden Çözümü:**
- 📋 **Aile grubu sistemi** - Gelecek phase
- 📋 **Paylaşılan kasa** - Şifreli paylaşım
- 📋 **Ebeveyn kontrolü** - Çocuk hesapları

---

#### 🟢 ORTA: Karanlık Mod
**Şikayet:**
```
"Gece kullanırken çok parlak."
"Dark mode ekleyin."
```

**Guarden Çözümü:**
- 📋 **ThemeService** oluştur
- 📋 **System theme detection** - Cihaz ayarını takip et
- 📋 **Neumorphic dark colors** - Özel tasarım

```dart
// Önerilen: Dark theme
class DarkColors {
  static const background = Color(0xFF2D2D2D);
  static const shadowDark = Color(0xFF1A1A1A);
  static const shadowLight = Color(0xFF404040);
}
```

---

#### 🟢 ORTA: Tarayıcı Eklentisi
**Şikayet:**
```
"Chrome'da otomatik doldurmak için eklenti yok."
"Bilgisayarda da erişim istiyorum."
```

**Guarden Çözümü:**
- 📋 **Web extension** - Chrome/Firefox (Phase 7)
- 📋 **Desktop app** - Electron veya Flutter web
- 📋 **Sync service** - Güvenli veri aktarımı

---

### 7.3 Kullanıcı Memnuniyet Matrix

| Özellik | Memnuniyet Etkisi | Implementasyon Zorluğu | Öncelik |
|---------|-------------------|----------------------|----------|
| Seed phrase kurtarma | 🔴 +40% | Düşük | 1 |
| Autofill | 🔴 +35% | Yüksek | 2 |
| Dark mode | 🟡 +15% | Orta | 3 |
| Pwned kontrol | 🟡 +20% | Orta | 4 |
| Aile paylaşımı | 🟢 +10% | Yüksek | 5 |
| Performance | 🔴 +25% | Orta | 6 |

---

## 8. Güncellenmiş Yol Haritası

### Phase 4: Premium, Paywall & Polish (Mevcut ROADMAP ile uyumlu)
- [ ] In-App Purchases (RevenueCat) entegrasyonu, Paywall ekran tasarımı
- [ ] Freemium limitleri (5 banka, 3 abonelik, 5 web şifresi) enforcement
- [ ] Seyahat Modu / Panik Modu entegrasyonu (Sadece Premium)
- [ ] Zayıf Şifre / Pwned API Entegrasyonu (Sadece Premium)
- [ ] flutter_local_notifications bildirimleri (Şifre rotasyon hatırlatıcıları)

### Phase 5: UX & Autofill (YENİ - Market Research'ten türetildi)
- [ ] Autofill Framework (Android AutofillService + iOS Credential Provider) — **Kritik kullanıcı talebi**
- [ ] Dark Mode + Neumorphic dark renk sistemi
- [ ] Performans optimizasyonu (lazy boxes, skeleton loading)
- [ ] Haptic feedback + pull-to-refresh

### Phase 6: Gelişmiş Güvenlik (Gelecek)
- [ ] 2FA Yönetimi (TOTP)
- [ ] Güvenlik raporu dashboard'u
- [ ] Şifre geçmişi (password history)

### Phase 7: Platform Genişleme (Gelecek)
- [ ] Chrome/Firefox web extension
- [ ] Desktop app (Flutter Web veya Electron)
- [ ] Aile paylaşımı sistemi

---

## 9. Sonuç

Guarden, kullanıcı şikayetlerine odaklanarak en yüksek etkili özellikleri önceliklendirmeli:

1. **Seed phrase kurtarma** - En kritik güvenlik özelliği
2. **Autofill** - En çok talep edilen kullanılabilirlik özelliği
3. **Performance** - Sürekli memnuniyet artırıcı
4. **Dark mode** - Temel kullanıcı isteği

### 1.2 Hedef Kitle Segmentasyonu
| Segment | Profil | Ödeme Kapasitesi | İhtiyaçlar |
|---------|--------|------------------|------------|
| **Fiyat-Duyarlı** | Öğrenci, genç profesyonel | ₺0-100/ay | Ücretsiz temel özellikler |
| **Orta Segment** | Küçük işletme sahipleri | ₺100-200/ay | Güvenlik + banka entegrasyonu |
| **Premium** | Kurumsal, finans sektörü | ₺200+/ay | Seyahat modu, 2FA, API |

### 1.3 Rekabet Avantajı Fırsatları
1. **Yerel Dil Desteği:** Rakiplerin Türkçe UI eksikliği
2. **Banka Entegrasyonu:** Türk bankalarına özel form alanları (3-6-9 ay rotasyon)
3. **Fiyatlandırma:** Aylık $2-3 yerine ₺50-100 (yerel fiyat)
4. **Çevrimdışı Priorite:** Bulut bağımlılığı olmayan güvenlik

---

## 2. Rakip Analizi

### 2.1 Küresel Rakipler

| Ürün | Fiyat | Artılar | Eksiler | Türkiye Uygunluk |
|------|-------|---------|---------|------------------|
| **1Password** | $1.99-3/ay | Mükemmel UI, Watchtower | Pahalı, bulut zorunlu | ❌ |
| **Bitwarden** | $1.65/ay (ücretsiz tier var) | Açık kaynak, sınırsız ücretsiz şifre | Kullanıcı deneyimi zayıf | 🟡 |
| **Dashlane** | ~$5/ay (ücretsiz plan kaldırıldı!) | VPN dahil, Dark Web monitoring | Çok pahalı, ücretsiz yok | ❌ |
| **NordPass** | $1.38/ay (ömür boyu ücretsiz tier) | XChaCha20 şifreleme | Sınırlı özellikler | 🟡 |
| **LastPass** | $2.25/ay | Popüler, iyi eklenti | Güvenlik geçmişi sorunlu | 🟡 |

### 2.2 Yerel Rakipler (Türkiye)
- **Çiftlik Bank** - Fırsatçı kredi platformu, şifre yöneticisi yok
- **Bireysel Çözümler** - Excel/Not Defteri kullanımı yaygın
- **Kurumsal** - 1Password Business yaygın

### 2.3 Guarden Konumlandırma
```
Pozisyon: "Türkiye'nin Premium Şifre Yöneticisi"
Fiyat: ₺49.99/ay (Premium)
      Ücretsiz: Sınırlı kayıt (5 banka, 3 abonelik, 5 web şifresi)
Ana Satış Noktası: Çevrimdışı güvenlik + Banka rotasyonu + Uygun fiyat
```

---

## 3. Özellik Karşılaştırması

### 3.1 Temel Özellikler Matrisi

| Özellik | Bitwarden | 1Password | NordPass | Guarden | Öncelik |
|---------|-----------|-----------|----------|---------|----------|
| **Şifre Saklama** | ✅ | ✅ | ✅ | ✅ | 🔴 Zorunlu |
| **Şifre Üretici** | ✅ | ✅ | ✅ | ✅ | 🔴 Zorunlu |
| **Biometric Giriş** | ✅ | ✅ | ✅ | ✅ | 🔴 Zorunlu |
| **Seed Phrase** | ✅ | ✅ | ❌ | ✅ | 🔴 Zorunlu |
| **Banka Entegrasyonu** | ❌ | ❌ | ❌ | ✅ | 🔴 Zorunlu |
| **Abonelik Takibi** | ❌ | ❌ | ❌ | ✅ | 🔴 Zorunlu |
| **Çevrimdışı Mod** | ✅ | ❌ | ❌ | ✅ | 🟡 Premium |
| **Seyahat Modu** | ❌ | ✅ | ❌ | ✅ | 🟡 Premium |
| **Panik Modu** | ❌ | ❌ | ❌ | ✅ | 🟡 Premium |
| **Pwned Kontrolü** | ✅ | ✅ | ✅ | ⚠️ API | 🟡 Premium |
| **2FA Yönetimi** | ✅ | ✅ | ✅ | ❌ | 🟡 Premium |
| **Aile Paylaşımı** | ✅ | ✅ | ✅ | ❌ | 🔵 Gelecek |

### 3.2 Mevcut Guarden Durumu

| Özellik | Durum | Dosya |
|---------|-------|-------|
| Şifre Saklama | ✅ Tamam | `web_password_provider.dart` |
| Şifre Üretici | ✅ Tamam | `password_generator_dialog.dart` |
| Biometric Giriş | ✅ Tamam | `biometric_service.dart` |
| Seed Phrase | ✅ Tamam | `crypto_service.dart` |
| Banka Entegrasyonu | ✅ Tamam | `bank_account_provider.dart` |
| Abonelik Takibi | ✅ Tamam | `subscription_provider.dart` |
| Çevrimdışı Mod | ✅ Tamam | AES-256 encrypted Hive |
| Dashboard | ✅ Tamam | `dashboard_tab.dart` |
| Logo Servisi | ✅ Tamam | `logo_service.dart` |

---

## 4. Kullanıcı Gereksinimleri

### 4.1 Anket/İnceleme Özeti
*Kaynak: App Store/Play Store yorumları, Reddit Türkiye*

| İhtiyaç | Sıklık | Guarden Çözümü |
|---------|--------|-----------------|
| "Banka şifremi hatırlayamıyorum" | Çok Yüksek | Banka modülü + rotasyon |
| "Aboneliklerim çok pahalılaştı" | Yüksek | Abonelik takibi + bütçe |
| "Buluta güvenmiyorum" | Yüksek | Çevrimdışı AES-256 |
| "Şifrelerim çalınır mı?" | Orta | Pwned kontrolü (Premium) |
| "Aile ile paylaşmak istiyorum" | Orta | Aile paylaşımı (gelecek) |

### 4.2 User Stories

**Story 1: Banka Şifre Rotasyonu**
> "Her 6 ayda bir bankam şifremi değiştirmemi istiyor. Guarden'a banka hesabımı eklediğimde, 6 ay sonra otomatik hatırlatma alacağım ve eski şifremi güvenli saklayacağım."

**Story 2: Abonelik Bütçesi**
> "Netflix, Spotify, Apple Music... Hepsi ayrı ayrı para ödüyorum. Guarden abonelik takibi ile toplam aylık harcama tutarını görebilmek istiyorum."

**Story 3: Güvenli Seed Phrase**
> "Master şifremi unutursam hesabımı kaybederim. 12 kelimelik kurtarma cümlesi ile hesabımı geri yükleyebilmek istiyorum."

---

## 5. Teknik Trendler

### 5.1 Şifreleme Trendleri
| Trend | Açıklama | Guarden Durum |
|-------|----------|---------------|
| **AES-256-GCM** | Endüstri standardı | ✅ Kullanımda |
| **XChaCha20-Poly1305** | Daha hızlı, mobil için | ⚠️ Alternatif düşünülmeli |
| **Post-Quantum** | Gelecek tehditler için | 🔵 İzleme |
| **PBKDF2/Argon2** | Key derivation | ✅ PBKDF2 (100k iter) |

### 5.2 Flutter Ekosistem Trendleri
| Trend | Durum |
|-------|-------|
| Riverpod 2.x | ✅ Kullanımda |
| Flutter 3.x | ✅ Güncel |
| GoRouter | ✅ Kullanımda |
| Hive + Floor | ✅ Hive kullanımda |
| RevenueCat | ✅ Planlanan (Phase 4) |
| local_auth | ✅ Kullanımda |

### 5.3 UX Trendleri
| Trend | Uygulama |
|-------|----------|
| Neumorphic Design | ✅ Tamam |
| Dark Mode | ❌ Eksik |
| Haptic Feedback | ❌ Eksik |
| Pull-to-refresh | ❌ Eksik |
| Skeleton Loading | ❌ Eksik |

---

## 6. Önceliklendirme Önerileri

### 6.1 Phase 4 (Premium) Özellik Sıralaması

| # | Özellik | Neden | Gelir Potansiyeli |
|---|---------|-------|-------------------|
| 1 | **Seyahat Modu** | Türk kullanıcıları için kritik | 🔴 Yüksek |
| 2 | **Panik Modu** | Güvenlik algısı yüksek | 🔴 Yüksek |
| 3 | **Pwned Kontrolü** | Kullanıcı güvenliği | 🟡 Orta |
| 4 | **In-App Purchase** | Gelir modeli | 🔴 Yüksek |
| 5 | **Bildirimler** | Rotasyon hatırlatıcıları | 🟡 Orta |

### 6.2 Gelecek Phase Önerileri

| Phase | Özellikler | Gerekçe |
|-------|------------|---------|
| **Phase 5** | Dark Mode, Aile Paylaşımı | Kullanıcı retention |
| **Phase 6** | 2FA, Güvenlik raporu | Premium farklılaştırma |
| **Phase 7** | iOS Widget, Wear OS | Platform genişleme |

---

## 7. Sonuç ve Öneriler

### 7.1 Yapılacaklar
1. ✅ Phase 3 tamamla (formlar, CRUD)
2. 🔄 Phase 4 başlat (Premium özellikler)
3. 📋 Dark mode ekle (2026 Q2)
4. 📋 Aile paylaşımı planla (2026 Q3)

### 7.2 Riskler
| Risk | Önlem |
|------|-------|
| Rekabet artışı | Hızlı market fit |
| Güvenlik açığı | Düzenli audit |
| Kullanıcı edinme | Freemium ile deneme |

### 7.3 Başarı Metrikleri
- **6 ay:** 10,000 aktif kullanıcı
- **12 ay:** 50,000 kullanıcı, %5 premium dönüşüm
- **24 ay:** 200,000 kullanıcı, yerel pazar lideri

# Guarden X AI Agent Planı (Buffer/Typefully İle)

## 🤖 Agent Mimarisi

```
┌─────────────────────────────────────────────────────────────┐
│                    GUARDEN X AGENT                          │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐   │
│  │   CRON       │───▶│   GEMINI     │───▶│  BUFFER/     │   │
│  │   Scheduler  │    │   AI Engine  │    │  TYPEFULLY   │   │
│  └──────────────┘    └──────────────┘    └──────────────┘   │
│         │                   │                   │            │
│         ▼                   ▼                   ▼            │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Content Database (JSON)                 │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Özellikler

### 1. Otomatik İçerik Üretimi
- **Konular:** Şifre güvenliği, yazılım güvenliği, siber güvenlik ipuçları
- **Diller:** Türkçe + İngilizce (karma)
- **Sıklık:** Günlük 1-3 paylaşım

### 2. Mentionlara Cevap (Typefully ile)
- Typefully'nin AI özelliklerini kullan
- Veya manuel olarak cevapla

### 3. İçerik Türleri
| Tür | Açıklama | Örnek |
|-----|----------|-------|
| İpucu | Kısa güvenlik tüyosu | "2FA kullanın!" |
| Blog özeti | Güvenlik haberi özeti | Son veri sızıntısı haberi |
| Soru | Takipçilere soru | "En son şifrenizi ne zaman değiştirdiniz?" |
| Tanıtım | Guarden özellikleri | "Yeni şifre denetimi özelliği" |

## 🛠️ Teknoloji Stack (ÜCRETSİZ!)

| Bileşen | Seçim | Ücret |
|---------|-------|-------|
| AI Engine | Google Gemini 2.0 Flash | **Ücretsiz** |
| Social Scheduler | Buffer veya Typefully | **Ücretsiz tier** |
| Hosting | GitHub Actions / Local PC | **Ücretsiz** |
| Storage | JSON dosyası (yerel) | **Ücretsiz** |

### Buffer vs Typefully Karşılaştırması

| Özellik | Buffer | Typefully |
|---------|--------|-----------|
| X desteği | ✅ | ✅ |
| Free tier | 3 hesap, 10 post/ay | 1 kullanıcı, sınırsız taslak |
| API | ✅ | ✅ |
| AI yazma | ❌ | ✅ (AI Assistant) |
| Türkçe destek | ⚠️ | ⚠️ |

**Öneri:** Buffer (daha fazla ücretsiz post) + Gemini (içerik üretimi)

## 📅 İçerik Takvimi

| Gün | İçerik Türü | Konu |
|-----|-------------|------|
| Pazartesi | İpucu | Haftalık güvenlik tüyosu |
| Salı | Soru | Takipçi etkileşimi |
| Çarşamba | Blog özeti | Son güvenlik haberleri |
| Perşembe | İpucu | Şifre yönetimi |
| Cuma | Tanıtım | Guarden özellikleri |
| Cumartesi | İpucu | Weekend güvenlik |
| Pazar | Soru | Hafta sonu etkileşimi |

## 🔒 Güvenlik Önlemleri

1. **İçerik Filtreleme**
   - AI çıktısını kontrol et
   - Uygunsuz içerikleri engelle

2. **Rate Limiting**
   - Buffer/Typefully limitlerine uy
   - Aşırı paylaşımı engelle

3. **Human-in-the-Loop**
   - İlk başta tüm içerikleri manuel onayla
   - Queue'ya ekle, sonra manuel publish et

## 📦 Dosya Yapısı

```
guarden-x-agent/
├── agent.py              # Ana agent kodu
├── config.py             # Yapılandırma
├── content_db.json       # İçerik veritabanı
├── requirements.txt      # Bağımlılıklar
├── .env                  # API anahtarları
└── README.md             # Dokümantasyon
```

## 🚀 Deployment Adımları

### Adım 1: Buffer/Typefully Hesabı Oluştur
1. buffer.com veya typefully.com'a git
2. Ücretsiz hesap oluştur
3. X hesabını bağla

### Adım 2: Gemini API Anahtarı Al
1. aistudio.google.com/app/apikey
2. Yeni API anahtarı oluştur
3. Kaydet

### Adım 3: Agent Kodunu Çalıştır
1. Python scripti indir
2. `pip install -r requirements.txt`
3. `.env` dosyasına anahtarları ekle
4. `python agent.py` çalıştır

### Adım 4: Otomatik Çalışma (Opsiyonel)
- **GitHub Actions:** Ücretsiz CI/CD
- **Cron:** Her gün çalıştır
- **Local:** Bilgisayarda arka planda tut

## ✅ Sonraki Adımlar

1. ⏳ Buffer/Typefully hesabı aç (sen)
2. ⏳ Gemini API anahtarı al (sen)
3. Agent kodunu yazayım
4. Test edelim
5. Otomatik hale getirelim

---

## 📝 Not

Buffer'ın ücretsiz tier'ı ayda sadece 10 post ile sınırlı. Daha fazlası için ükir. Alterncretli plan gereatif olarak:
- **Typefully:** Sınırsız taslak, her seferinde manuel publish
- **Manuel + AI:** Sadece AI içerik üret, sen manuel paylaş

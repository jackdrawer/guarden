# Phase 1: Foundation (Altyapı & Kriptografi) - Context

**Gathered:** 2026-03-02
**Status:** Ready for planning

<domain>
## Phase Boundary

Veritabanı (Hive/Isar) ve Kriptografi (AES-256 + PBKDF2) altyapısının kurulması. Kullanıcı arayüzü (UI) öncesinde, uygulamanın şifreleme ve veri katmanının testlenebilir şekilde hazırlanması.

</domain>

<decisions>
## Implementation Decisions

### Kasa Bekleme Süresi (App Lifecycle)
- Uygulama arka plana düştükten sonra anında kilitlenmeyecek, kullanıcıya **1 dakika** bekleme süresi tanınacak. Süre aşımında kasa kilitlenecek.

### Master Şifre Kurtarma (Recovery)
- Kullanıcıya kayıt esnasında Master Şifreyi unutmasına karşın bir **Seed Phrase (Kurtarma Kelimeleri)** üretilecek ve gösterilecek. Seed Phrase ile kasa kurtarılabilecek.

### Hata Yaklaşımı (Secure Storage Fallback)
- Cihazın şifre depolama alanına (Keystore/Keychain) erişimde işletim sistemi engeli veya hatası oluşursa, uygulama doğrudan **Master Şifre** ekranına (fallback) yönlendirecek.
</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- Henüz sıfır proje, oluşturulacak CryptoService ve DatabaseService sınıfları Riverpod provider'ları üzerinden sunulacaktır.

### Established Patterns
- Sıklıkla DI (Dependency Injection) için `Riverpod` yapıları kullanılacaktır. Uygulama veritabanı (database modeli) modellerle bağımsız tutulacaktır.

### Integration Points
- Geliştirilecek şifreleme fonksiyonları (encrypt/decrypt) doğrudan Data Katmanına entegre edilecektir.

</code_context>

<specifics>
## Specific Ideas
- Seed phrase üretimi için `bip39` paketi veya güvenli bir standart kelime havuzu kütüphanesi kullanılacaktır. Ek olarak gereklilik olursa eklenecek.
</specifics>

<deferred>
## Deferred Ideas
None — discussion stayed within phase scope
</deferred>

---

*Phase: 01-foundation*
*Context gathered: 2026-03-02*

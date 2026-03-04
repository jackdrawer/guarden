# Phase 2: Auth & Security - Context

**Gathered:** 2026-03-02
**Status:** Ready for planning

<domain>
## Phase Boundary

Uygulamanın şifre kurulumunu (Onboarding) ve sisteme giriş ekranlarını (Login) içerir. Bu evrede, 1. Evrede yazılan CryptoService ve DatabaseService sınıflarıyla entegrasyon yapılarak UI/UX katmanına başlangıç yapılır. Neumorphism / Soft UI tasarım dili ilk kez bu aşamanın mocklarında uygulanacaktır.

</domain>

<decisions>
## Implementation Decisions

### Master Password Zorluk Derecesi (Restrictions)
- En az 8 karakter, 1 büyük harf, 1 sayı zorunluluğu aranacak. Bu, aes-256 PBKDF2 mantığını daha güçlü tutmak içindir.

### Biometric Auth (local_auth)
- Biometric (FaceID / Fingerprint) tamamen "Opsiyonel" olarak sunulacak. Kullanıcı atlayabilir veya etkinleştirebilir.
- Cihazda biometrik kilit başarısız olursa her zaman Master Password ile Fallback yapılacak (Neumorphic numpad veya klavye kullanılabilir, şimdilik native klavye olacak).

### Onboarding Flow (Kurulum Akışı)
1. Welcome Screen
2. Create Master Password
3. Show Backup / Seed Phrase 
4. Enable Biometric (Optional)
5. Go to Vault (Dashboard)

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `app_colors.dart` (Neumorphism renk paleti)
- `crypto_service.dart` (deriveKey, generateSeedPhrase)
- `secure_storage_service.dart` (saveEncryptionKey)
- `database_service.dart` (initDatabase ile key'i okuyup kasayı açma)

### Integration Points
- Riverpod state management ile "AuthState" (Unauthenticated, Authenticated, FirstTime) yönetimi yapılacak.

</code_context>

<specifics>
## Specific Ideas
- Login ekranı Neumorphism (Soft UI) konseptine uygun, dışa vuruk şifre inputlarına sahip sakin bir krem renginde tasarlanacaktır.
</specifics>

<deferred>
## Deferred Ideas
None
</deferred>

---

*Phase: 02-auth-security*
*Context gathered: 2026-03-02 (Agent Autopilot)*

---
title: "Recovery, Backup ve Duzenleme Akislari"
area: security/data
priority: critical
created: 2026-03-02
updated: 2026-03-03
---

## GSD Discuss Snapshot

### Phase Boundary
- [x] Bu calisma sadece 2 capability kapsar (Seed phrase kaldirip):
- [x] Sifreli backup/export + restore/import
- [x] Var olan kayitlar icin edit akisi
- [ ] Kapsam disi: cloud sync, multi-device merge, account sharing, remote key escrow, seed phrase recovery.

### Mevcut Durum (Code Reality)

#### Seed Phrase ❌ KALDIRILDI
- [x] Seed phrase recovery ozelligi projeden kaldirildi.
- [x] Onboarding'de artik seed phrase uretilmiyor/gosterilmiyor.

#### Backup/Restore ✅ MOSTLY COMPLETE
- [x] Export/import servisi mevcut (`BackupService`).
- [x] Versiyonlu yedek formati mevcut.
- [x] Restore conflict strategy mevcut.
- [x] Google Drive backup integration mevcut.
- [x] Test coverage mevcut (backup_service_test.dart).

#### Edit Ekranlari ✅ COMPLETE
- [x] 3 detail ekranda `Duzenle` butonu aktif.
- [x] 3 form ekrani create/edit modunda calisiyor.
- [x] Edit icin route/model prefill/decrypt/update zinciri mevcut:
  - `/edit-bank/:id` ✅
  - `/edit-subscription/:id` ✅
  - `/edit-web-password/:id` ✅

## Karar Alanlari (GSD-style)

### 1) Backup Encryption Key
- [x] Secenek A: Master password ile export sifrele.
- [ ] Secenek B: Export icin ayri backup passphrase iste (onerilen).
- [ ] Oneri: B (guvenlik ve master password rotation'dan bagimsizlik).

### 2) Restore Strategy
- [x] Secenek A: Full overwrite.
- [ ] Secenek B: Dry-run + conflict report + user confirm + apply (onerilen).
- [ ] Oneri: B.

### 3) Edit UX Pattern
- [ ] Secenek A: Ayrı edit ekranlari.
- [x] Secenek B: Form ekranlarinda `mode=create|edit` (onerilen).
- [x] Oneri kabul edildi: B (tekrar kodu azaltir, testi kolaylastirir).

## Fazlandirilmis Uygulama Plani

### Phase R1 - Recovery Foundation (KALDIRILDI) ❌
- [x] Seed phrase recovery ozelligi kaldirildi.

### Phase R2 - Backup/Restore MVP (High) ✅ COMPLETE
- [x] `BackupService` olustur:
- [x] Export payload: `version`, `created_at`, `data` (bank/sub/web), `checksum`.
- [x] Encrypt format: `AES-GCM + PBKDF2(passphrase, random_salt)`.
- [x] Import flow:
- [x] Dosya sec -> passphrase -> decrypt -> schema validate -> dry-run report -> apply.
- [x] Settings ekranina 2 aksiyon:
- [x] `Yedek Al`
- [x] `Yedekten Geri Yukle`
- [x] Google Drive backup integration.

Definition of Done:
- [x] Export edilen dosya sifresiz acilamiyor.
- [x] Corrupted file/yanlis passphrase dogru hata mesaji veriyor.
- [x] Dry-run raporu conflict sayisini gosteriyor.

### Phase R3 - Edit Akislarini Tamamlama (High) ✅ COMPLETE
- [x] Router:
- [x] `/edit-bank/:id`
- [x] `/edit-subscription/:id`
- [x] `/edit-web-password/:id`
- [x] Form ekranlari:
- [x] `itemId` parametresi al, init'te decrypt+prefill yap.
- [x] `save` action create/update switch yapsin.
- [x] Detail ekranlari:
- [x] `Duzenle` butonu aktif, form ekranina yonlendiriyor.

Definition of Done:
- [x] Edit akisi sonunda kayit guncelleniyor.
- [x] Edit sirasinda decrypt/encrypt dogru calisiyor.
- [x] Cancel edince state temizleniyor.

## Son Durum Ozeti (2026-03-03)

| Bilesen | Durum | Notlar |
|---------|-------|--------|
| Seed Phrase Recovery | ❌ KALDIRILDI | Artik desteklenmiyor |
| Backup/Restore | ✅ TAMAMLANDI | Testler geçiyor |
| Edit Akislari | ✅ TAMAMLANDI | Tum routelar aktif |
| Google Drive Backup | ✅ TAMAMLANDI | Settings ekraninda mevcut |

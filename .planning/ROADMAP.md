# Roadmap: Guarden Password Manager

## Milestones

- ✅ **v1.0 MVP** - Phases 1-6 (shipped)
- ✅ **v1.1 Production Hardening** - Phases 7-11 (complete)
- ✅ **v1.2 Advanced Analytics & Experience** - Phases 12-13 (shipped)

## Phases

<details>
<summary>✅ v1.0 MVP (Phases 1-6) - SHIPPED</summary>

### Phase 1: Foundation (Altyapi ve Kriptografi)
**Goal**: Flutter project structure with cryptography service
**Plans**: Complete

Plans:
- [x] Flutter projesinin (Riverpod, Hive, Secure Storage) yapilandirilmasi
- [x] Kriptografi servisinin (PBKDF2/AES) yazilmasi

### Phase 2: Auth and Security
**Goal**: Working master password authentication with biometric unlock and seed phrase recovery
**Plans**: 2 plans

Plans:
- [x] 02-01-PLAN.md - Auth service layer (auth state, biometric, secure storage wiring)
- [x] 02-02-PLAN.md - Auth UI screens and router bootstrap (setup/login/recovery)

**Requirements:**
- [x] Master password kurulum ekrani ve mantigi
- [x] local_auth biyometrik dogrulama (Face ID/Fingerprint)

### Phase 3: Core UI and Moduller
**Goal**: Complete core UI with Dashboard, Bank Accounts, Subscriptions, and Web Passwords CRUD screens using Neumorphic design and encrypted Hive storage
**Plans**: 5 plans

Plans:
- [x] 03-01-PLAN.md - Domain models + LogoService
- [x] 03-02-PLAN.md - DatabaseService + CRUD providers
- [x] 03-03-PLAN.md - Neumorphic widget library + Home shell + Dashboard
- [x] 03-04-PLAN.md - Bank and Subscription CRUD screens
- [x] 03-05-PLAN.md - Web Password CRUD screens + visual checkpoint

**Requirements:**
- [x] Dashboard tasarimi ve verilerin baglanmasi
- [x] Dinamik logo servisi (cache destekli)
- [x] Banka modulu CRUD
- [x] Abonelik ve butce modulu CRUD
- [x] Standart web sifre modulu CRUD

### Phase 4: Premium, Paywall and Polish
**Goal**: Monetize with RevenueCat, enforce freemium limits, and add premium features (travel/panic mode, pwned checks, notifications)
**Plans**: 4 plans

Plans:
- [x] 04-01-PLAN.md - RevenueCat + Paywall + freemium limits
- [x] 04-02-PLAN.md - Travel mode + Panic mode + Settings
- [x] 04-03-PLAN.md - Detail screens + Security audit + UX polish
- [x] 04-04-PLAN.md - Notification service + reminder toggles

**Requirements:**
- [x] In-app purchases ve paywall
- [x] Freemium limit enforcement
- [x] Travel/Panic mode (premium)
- [x] Pwned password kontrolu (premium)
- [x] Local notification entegrasyonu

### Phase 5: UX and Autofill
**Goal**: Professionalize UX with autofill framework, draft autosave, accessibility, screenshot protection, haptic/sound polish
**Plans**: 4 plans

Plans:
- [x] 05-01-PLAN.md - Settings infrastructure + UX/security toggles
- [x] 05-02-PLAN.md - Empty states + Draft service
- [x] 05-03-PLAN.md - Android/iOS autofill framework wiring
- [x] 05-04-PLAN.md - Adaptive icon + biometric fallback UX + onboarding update

**Requirements:**
- [x] R1: Autofill framework
- [x] R2: Theme continuity (already implemented)
- [x] R3: Performance polish
- [x] R4: Haptic and sound feedback
- [x] R5: Draft, clipboard, screenshot protection
- [x] R6: Adaptive icon and onboarding polish

### Phase 6: Recovery, Backup and Edit Flows
**Goal**: Make panic/recovery reliable, add encrypted backup/restore, and complete edit flows for all credential modules.
**Plans**: 4 plans

Plans:
- [x] 06-01-PLAN.md - Recovery foundation (seed persistence, recovery route/screen, panic consistency)
- [x] 06-02-PLAN.md - Edit flows (bank/sub/web detail->edit->update)
- [x] 06-03-PLAN.md - Encrypted backup/restore MVP (export/import, schema check, dry-run)
- [x] 06-04-PLAN.md - Hardening, integration tests, final UX alignment

**Requirements:**
- [x] R7: Seed phrase persistence and master password recovery flow
- [x] R8: Encrypted local backup export/import with integrity checks
- [x] R9: Full edit capability for bank/subscription/web credentials

</details>

---

<details>
<summary>✅ v1.1 Production Hardening - SHIPPED</summary>

### Phase 7: Error Handling & Resilience
- [x] Error type system and Neumorphic error UI components
- [x] Service error handling with typed errors and network retry
- [x] Provider migration
- [x] Sentry and Firebase Analytics integration

### Phase 8: Testing Infrastructure
- [x] Core unit tests for crypto and domain models
- [x] Widget tests for Neumorphic components

### Phase 9: Localization & i18n
- [x] i18n framework (Slang) integration
- [x] Turkish and English language files

### Phase 10: Performance & Optimization
- [x] Hive box lazy loading and encryption indexing
- [x] Asset optimization

### Phase 11: Security & Migration
- [x] Database schema versioning and migration logic
- [x] Root/Jailbreak detection

</details>

---

<details>
<summary>✅ v1.2 Advanced Analytics & Experience - SHIPPED</summary>

### Phase 12: Visual Analytics & Categorization
- [x] Category field for all credential models
- [x] Dashboard Pie Chart for expense breakdown
- [x] Category-based filtering across all modules
- [x] Manual Language and Currency selection in Settings

### Phase 13: Auto Backup & Restore
- [x] Workmanager-based periodic background sync
- [x] Google Drive AppData folder integration
- [x] 5-file retention policy for cloud backups
- [x] Enhanced integrity and conflict checks during restore

</details>

### Phase 14: Store Launch Readiness & Submission Hardening

**Goal:** Close Android and iOS launch blockers so Guarden can be submitted to Play Store and App Store with production-safe configuration, passing tests, and policy-aligned metadata.
**Requirements**:
- Production ad and telemetry configuration with correct store disclosures
- Android release signing and reproducible clean release builds
- iOS bundle identity, biometric metadata, Google Sign-In wiring, and archive readiness
- Green automated test baseline for launch-critical flows
- Store submission checklist and evidence for console/app review
**Depends on:** Phase 13
**Plans:** 4 plans

Plans:
- [ ] 14-01 Android Release Hardening
- [ ] 14-02 iOS Submission Readiness
- [ ] 14-03 Launch Gate Test Stabilization
- [ ] 14-04 Store Submission Pack & Evidence

---

## Progress

**Execution Order:** Phases execute in numeric order (7 → 8 → 9 → 10 → 11 → 12 → 13 → 14)

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 1. Foundation | v1.0 | Complete | Complete | - |
| 2. Auth and Security | v1.0 | 2/2 | Complete | - |
| 3. Core UI and Moduller | v1.0 | 5/5 | Complete | - |
| 4. Premium, Paywall and Polish | v1.0 | 4/4 | Complete | - |
| 5. UX and Autofill | v1.0 | 4/4 | Complete | - |
| 6. Recovery, Backup and Edit Flows | v1.0 | 4/4 | Complete | - |
| 7. Error Handling & Resilience | v1.1 | 4/4 | Complete | 2026-03-03 |
| 8. Testing Infrastructure | v1.1 | Complete | Complete | 2026-03-04 |
| 9. Localization & i18n | v1.1 | Complete | Complete | 2026-03-05 |
| 10. Performance & Optimization | v1.1 | Complete | Complete | 2026-03-05 |
| 11. Security & Migration | v1.1 | Complete | Complete | 2026-03-05 |
| 12. Visual Analytics & Categorization | v1.2 | Complete | Complete | 2026-03-06 |
| 13. Auto Backup & Restore | v1.2 | Complete | Complete | 2026-03-06 |
| 14. Store Launch Readiness & Submission Hardening | v1.2 | 0/4 | Planned | - |

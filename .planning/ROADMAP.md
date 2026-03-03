# Roadmap: Guarden Password Manager

## Milestones

- ✅ **v1.0 MVP** - Phases 1-6 (shipped)
- 🚧 **v1.1 Production Hardening** - Phases 7-11 (in progress)

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

## 🚧 v1.1 Production Hardening (In Progress)

**Milestone Goal:** Make Guarden production-ready for App Store and Play Store release

### Phase 7: Error Handling & Resilience
**Goal**: Comprehensive error handling across all services and production monitoring for crash detection
**Depends on**: Phase 6 (v1.0 complete)
**Requirements**: FR1, FR3
**Success Criteria** (what must be TRUE):
  1. User sees clear, actionable error messages when operations fail (never raw stack traces)
  2. Network failures show retry options and user can recover without restarting app
  3. Storage errors prompt for master password re-entry and user can continue working
  4. Development team receives crash reports in Sentry dashboard within minutes of occurrence
  5. Firebase Analytics tracks key user behaviors (onboarding complete, password added, premium purchased) without exposing PII
**Plans**: 4 plans

Plans:
- [x] 07-01-PLAN.md — Error type system and Neumorphic error UI components
- [ ] 07-02-PLAN.md — Service error handling with typed errors and network retry
- [ ] 07-03-PLAN.md — Provider migration to AsyncNotifier with AsyncValue (UI migration deferred to Phase 8)
- [ ] 07-04-PLAN.md — Sentry and Firebase Analytics integration with PII scrubbing

### Phase 8: Testing Infrastructure
**Goal**: Automated test coverage for critical user flows and CRUD operations
**Depends on**: Phase 7
**Requirements**: FR2
**Success Criteria** (what must be TRUE):
  1. User can complete authentication flow (onboarding to home screen) verified by automated E2E tests
  2. All CRUD operations (bank accounts, subscriptions, web passwords) work correctly verified by integration tests
  3. Premium features (paywall, purchase flow, unlock) function properly verified by integration tests with mocked RevenueCat
  4. Seed phrase backup and recovery restore user access verified by integration tests
  5. Test coverage report shows 70%+ coverage for critical paths
**Plans**: TBD

Plans:
- [ ] TBD

### Phase 9: Localization & i18n
**Goal**: Full multi-language support for English and Turkish with locale-aware formatting
**Depends on**: Phase 7
**Requirements**: FR4
**Success Criteria** (what must be TRUE):
  1. User can switch language between English and Turkish in app settings
  2. App displays all UI text, error messages, and help content in user's selected language
  3. App respects device locale by default without user configuration
  4. Dates, numbers, and currency display correctly for Turkish and English locales
  5. No hardcoded Turkish strings remain in codebase (all extracted to ARB files)
**Plans**: TBD

Plans:
- [ ] TBD

### Phase 10: Performance & Optimization
**Goal**: Optimized app size, memory usage, and build configuration for store submission
**Depends on**: Phase 8, Phase 9
**Requirements**: FR5, FR6
**Success Criteria** (what must be TRUE):
  1. Release APK/IPA size is under 50MB (target: 20-30MB)
  2. App runs smoothly without memory leaks during 1-hour stress test
  3. App memory usage stays under 150MB during normal operation verified by profiling
  4. Code is obfuscated in release builds protecting intellectual property
  5. All controllers and streams properly dispose preventing resource leaks
**Plans**: TBD

Plans:
- [ ] TBD

### Phase 11: Security & Migration
**Goal**: Security hardening with device compromise detection and database migration strategy
**Depends on**: Phase 10
**Requirements**: NFR1, NFR2
**Success Criteria** (what must be TRUE):
  1. User receives dismissible warning if device is jailbroken/rooted
  2. Database schema changes can be applied without losing user data
  3. Backup is automatically created before migration executes
  4. Migration rollback restores previous state if upgrade fails
  5. v1.0 to v1.1 schema migration tested with production-like data
**Plans**: TBD

Plans:
- [ ] TBD

---

## Progress

**Execution Order:** Phases execute in numeric order (7 → 8 → 9 → 10 → 11)

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 1. Foundation | v1.0 | Complete | Complete | - |
| 2. Auth and Security | v1.0 | 2/2 | Complete | - |
| 3. Core UI and Moduller | v1.0 | 5/5 | Complete | - |
| 4. Premium, Paywall and Polish | v1.0 | 4/4 | Complete | - |
| 5. UX and Autofill | v1.0 | 4/4 | Complete | - |
| 6. Recovery, Backup and Edit Flows | v1.0 | 4/4 | Complete | - |
| 7. Error Handling & Resilience | v1.1 | 1/4 | In progress | - |
| 8. Testing Infrastructure | v1.1 | 0/? | Not started | - |
| 9. Localization & i18n | v1.1 | 0/? | Not started | - |
| 10. Performance & Optimization | v1.1 | 0/? | Not started | - |
| 11. Security & Migration | v1.1 | 0/? | Not started | - |

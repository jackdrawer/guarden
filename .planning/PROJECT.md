# Project: Guarden PW Manager

## Current Milestone: v1.1 Production Hardening

**Goal:** Make Guarden production-ready for App Store and Play Store release

**Target features:**
- Comprehensive error handling and resilience
- Integration and E2E test coverage
- Production monitoring (crash reporting, analytics)
- Multi-language support (English, Turkish)
- App size and security optimization

## Context
Banka hesapları, dijital abonelikler ve web şifrelerini bir arada tutan, gizlilik (privacy-first) odaklı yerel bir şifre yöneticisi. 
Pazarlama stratejisi olarak "Freemium" modeli uygulanacak. Rakip ürünlerin (1Password, Dashlane) Türkiye pazarına uzak ve pahalı kalmasını avantaja çeviriyoruz.

## Key Decisions
| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Çevrimdışı AES-256 | Veriler cihazda güvende. Bulut korkusu olan kitleyi çekmek için. | Onaylandı |
| Freemium Ödeme Modeli | Gelişmiş özelliklerin (Seyahat Modu, Sınırsız kayıt, Pwned Kontrolü) In-App Purchase ile satışı. | Onaylandı |
| Dinamik Logo Kullanımı | Uygulama premium hissettirmeli. Fetch API + Local Fallback logoları kullanılacak. | Onaylandı |
| Esnek Şifre Periyotları | Her banka 6 ay değil, 3/6/9 ay seçenekleri formda dropdown olarak sorulmalı. | Onaylandı |

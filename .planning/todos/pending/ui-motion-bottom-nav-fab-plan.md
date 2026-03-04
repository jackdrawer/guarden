---
title: "Bottom Nav + FAB Motion Plan"
area: ui/ux
priority: high
created: 2026-03-03
updated: 2026-03-03
---

## GSD Discuss Snapshot

### Phase Boundary
- [x] Bu plan sadece su iki capability'yi kapsar:
- [x] Home altindaki bottom navigation hareket/transition iyilestirmesi
- [x] Banka/Abonelik/Web tablarindaki ekleme FAB hareketlerinin modernize edilmesi
- [x] Kapsam disi: tum sayfa route transition sistemi, yeni ekran tasarimi, veri katmani degisiklikleri

### Mevcut Durum (Code Reality - 2026-03-03) ✅ COMPLETE
- [x] `lib/screens/home_screen.dart` `IndexedStack` + `NeumorphicBottomNav` + `AnimatedTabFab` kullaniyor.
- [x] `lib/widgets/neumorphic/neumorphic_bottom_nav.dart` sliding active indicator + icon lift/scale + label emphasis kullaniyor.
- [x] `lib/screens/bank_accounts/bank_accounts_tab.dart`, `subscriptions_tab.dart`, `web_passwords_tab.dart` icindeki local `Positioned + FloatingActionButton` bloklari kaldirildi.
- [x] FAB gecisleri tab degisimine bagli tek bir shared widget uzerinden yonetiliyor.

## Karar Alanlari (GSD-style)

### 1) Bottom Nav Motion Modeli
- [ ] Secenek A: Sadece icon renk/scale gecisi
- [x] Secenek B: Sliding active pill + icon lift + label emphasis (onerilen)
- [x] Oneri kabul edildi: B, cunku secili tab odagini daha net veriyor.

### 2) FAB Mimarisi
- [ ] Secenek A: Her tab kendi FAB'ini animate etsin
- [x] Secenek B: Home seviyesinde tek "shared animated FAB" (onerilen)
- [x] Oneri kabul edildi: B, cunku tab degisimi sirasinda akici gecis ve tek nokta kontrol sagliyor.

### 3) Motion Timing ve Easing
- [x] Bottom nav indicator: 280ms `easeOutCubic`
- [x] Icon lift: 220ms `easeOut`
- [x] Shared FAB enter/exit: 260ms `easeOutBack`
- [x] Press feedback: 110ms down / 140ms up

### 4) Accessibility / Reduced Motion
- [x] `MediaQuery.of(context).disableAnimations` true ise motionlar `Duration.zero` fallback'e dusuyor.

## Fazlandirilmis Uygulama Plani

### Phase M1 - Motion Foundation (Low Risk) ✅ COMPLETE
- [x] `lib/theme/motion_tokens.dart` eklendi.
- [x] Standard duration/easing sabitleri (`fast`, `normal`, `slow`) tanimlandi.
- [x] Tab/FAB icin ortak curve tanimlari eklendi.
- [x] Hedef saglandi: Motion degerleri merkezi yonetiliyor.

Definition of Done:
- [x] Motion sureleri tek dosyada merkezi yonetiliyor.

### Phase M2 - Bottom Navigation Animation Upgrade (Core) ✅ COMPLETE
- [x] `lib/widgets/neumorphic/neumorphic_bottom_nav.dart` motion modeline gecti.
- [x] Active pill konumu icin animated indicator eklendi.
- [x] Icon/label icin secili durumda lift + weight + color transition eklendi.
- [x] Tab degisiminde haptic korundu ve API (`onTap`) degismedi.

Definition of Done:
- [x] Tab secimi aninda aktif segment akici sekilde kayiyor.
- [x] Icon/label motion secili tabi belirginlestiriyor.
- [x] Mevcut davranis regress etmeden korundu.

### Phase M3 - Shared Animated FAB (Core) ✅ COMPLETE
- [x] `lib/widgets/animated_tab_fab.dart` reusable widget eklendi.
- [x] `icon`, `tooltip`, `onPressed`, `visible` davranisi mevcut.
- [x] Enter: slide-up + fade + scale.
- [x] Exit: scale-down + fade.
- [x] Press: shrink feedback (110/140ms).
- [x] `HomeScreen` icinde tab -> fab config map eklendi.

Definition of Done:
- [x] FAB tek noktadan yonetiliyor.
- [x] Tab degisiminde FAB aniden degismiyor, animate oluyor.

### Phase M4 - Tab Screens Cleanup ✅ COMPLETE
- [x] `bank_accounts_tab.dart`, `subscriptions_tab.dart`, `web_passwords_tab.dart` icindeki local `Positioned/FAB` bloklari kaldirildi.
- [x] Ekleme aksiyonlari `HomeScreen` uzerinden route ediliyor:
- [x] Banka -> `/add-bank`
- [x] Abonelik -> `/add-subscription`
- [x] Web -> `/add-web-password`
- [x] Premium limit kontrol mantigi eklendi.

Definition of Done:
- [x] Uc tabda duplicate FAB kalmadi.
- [x] Eski add flow korundu.
- [x] Premium gate politikasi calisiyor.

### Phase M5 - Verification & Hardening ✅ COMPLETE
- [x] `flutter analyze`
- [x] `flutter test`
- [x] Manual smoke:
- [x] 0->1->2->3 tab gecisleri, geri donusler
- [x] FAB ile add route acilisi
- [x] Paywall/gating davranisi
- [x] `disableAnimations` senaryosunda fallback davranis

Definition of Done:
- [x] Kod seviyesi dogrulama (analyze/test) tamam.

## Son Durum Ozeti (2026-03-03)

| Phase | Durum | Notlar |
|-------|-------|--------|
| M1 - Motion Foundation | ✅ Tamamlandi | motion_tokens.dart aktif |
| M2 - Bottom Nav Animation | ✅ Tamamlandi | Sliding indicator + haptic |
| M3 - Shared FAB | ✅ Tamamlandi | AnimatedTabFab widget'i aktif |
| M4 - Tab Screens Cleanup | ✅ Tamamlandi | Local FAB'lar kaldirildi |
| M5 - Verification | ✅ Tamamlandi | Testler ve analiz temiz |

**Genel Durum: TAMAMLANDI** 🎉

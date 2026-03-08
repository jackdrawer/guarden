# Closed Test 02 Release Notes

Date: 2026-03-08
Target: Google Play Closed Test 2

## Play Console TR

```text
Bu surumde hassas veri akislari guclendirildi. Notlar artik otomatik acilmiyor; gosterme ve kopyalama islemleri daha tutarli guvenlik dogrulamasiyla calisiyor. Yanlis silmeleri azaltmak icin geri alma eklendi. Kaydet butonlari hizli cift tiklamaya karsi korundu. Autofill eslesmeleri iyilestirildi ve guvenlik denetimi akisi sadeleştirildi.
```

## Play Console EN

```text
This build improves security-sensitive flows. Notes no longer reveal automatically, and copy/reveal actions now follow a more consistent verification flow. Undo was added for destructive deletes. Save buttons are protected against rapid double taps. Autofill matching was improved and the security audit flow was streamlined.
```

## Internal Summary

- Sensitive notes no longer open automatically on detail screens
- Copy, reveal, and export actions now follow a more consistent auth flow
- Swipe delete actions now support undo recovery
- Save buttons are protected against duplicate rapid taps
- Autofill now ranks matching accounts first
- Security Audit flow was consolidated and localized

## Notes

- Web logo behavior is temporarily simplified and can be handled in a later web-specific pass
- Closed Test 02 notes are based primarily on Phase 16 security and UX hardening work

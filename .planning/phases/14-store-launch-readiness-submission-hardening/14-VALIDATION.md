---
phase: 14
slug: store-launch-readiness-submission-hardening
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-06
---

# Phase 14 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter test / dart analyze / flutter build |
| **Config file** | `pubspec.yaml` |
| **Quick run command** | `dart analyze lib test` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~120 seconds |

---

## Sampling Rate

- **After every task commit:** Run `dart analyze lib test`
- **After every plan wave:** Run `flutter test`
- **Before `$gsd-verify-work`:** `flutter test` plus platform release checks must be green
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 14-01-01 | 01 | 1 | launch-android | static + build | `flutter build appbundle --release` | OK | pending |
| 14-01-02 | 01 | 1 | launch-android | static | `dart analyze lib test` | OK | pending |
| 14-02-01 | 02 | 1 | launch-ios | config audit | `rg -n "PRODUCT_BUNDLE_IDENTIFIER|NSFaceIDUsageDescription|CFBundleURLTypes" ios` | OK | pending |
| 14-02-02 | 02 | 1 | launch-ios | manual checklist | `xcode archive/manual verification` | W0 manual | pending |
| 14-03-01 | 03 | 2 | launch-tests | unit/widget | `flutter test` | OK | pending |
| 14-04-01 | 04 | 2 | launch-store-docs | lint + docs audit | `dart analyze lib test` | OK | pending |

*Status: pending / green / red / flaky*

---

## Wave 0 Requirements

- [ ] Confirm Android cmdline-tools and SDK licenses are installed on the release machine.
- [ ] Confirm iOS signing team, bundle ID, and required Apple credentials outside this Windows workspace.
- [ ] Add any missing test harness cleanup needed for lifecycle timers and boot smoke tests.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| iOS archive and signing | launch-ios | Cannot be fully executed from this Windows workspace | Open Xcode on macOS, archive Runner, verify signing, Info.plist metadata, and Google Sign-In callback handling |
| Store console disclosures | launch-store-docs | Console forms are outside repo | Compare shipped SDKs/permissions against App Store privacy labels and Play Console Data Safety answers before submission |
| AdMob production readiness | launch-android | Requires external console values | Verify release build uses production app IDs and ad unit IDs from secure launch configuration |

---

## Validation Sign-Off

- [ ] All tasks have automated verify or explicit Wave 0 manual dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all missing external prerequisites
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s for local checks
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending

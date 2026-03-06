# Phase 14: Store Launch Readiness & Submission Hardening - Context

**Gathered:** 2026-03-06
**Status:** Ready for planning
**Source:** Local launch-readiness review

<domain>
## Phase Boundary

This phase closes the concrete blockers preventing Guarden from being safely submitted to Play Store and App Store.

In scope:
1. Android release hygiene: production signing, reproducible release build, clean store-facing manifest/config.
2. iOS submission readiness: bundle identity, required metadata for biometrics and Google Sign-In, archive/signing prerequisites.
3. Production service configuration: replace test ad IDs, verify telemetry/analytics behavior, align privacy disclosures with actual SDK usage.
4. Launch verification: make launch-critical automated tests green and produce a final submission checklist/evidence pack.

Out of scope:
- New user-facing features unrelated to launch blockers.
- Revenue or pricing redesign.
- Post-launch growth experiments.
- Large security architecture rewrites beyond what is required for store submission and safe launch.

</domain>

<decisions>
## Implementation Decisions

### Launch bar
- Do not treat the app as store-ready until both Android and iOS have a repeatable release path.
- Phase success requires both platform config and validation evidence, not just code edits.

### Android hardening
- Release signing must fail closed. Falling back to debug signing for release builds is not acceptable.
- Manifest should declare only capabilities actually used for launch. Billing declarations must match implementation reality.
- Release build output must be reproducible from a clean machine after toolchain fixes.

### iOS hardening
- Replace placeholder iOS bundle identifiers with production identifiers.
- Add all metadata required for Face ID and Google Sign-In before archive testing.
- Treat missing iOS project files and signing setup as launch blockers, not follow-up polish.

### Ads, telemetry, and privacy
- Replace all test AdMob app IDs/unit IDs in launch configuration.
- Privacy declarations must match the real SDK surface: ads, analytics, crash reporting, Google Sign-In, and Drive backup.
- If telemetry cannot be confidently disclosed, disable it for launch rather than shipping ambiguous behavior.

### Verification strategy
- Launch-critical tests must be green, especially settings initialization, lifecycle/lock behavior, and app boot smoke tests.
- Produce a final checklist covering Android artifact, iOS archive prerequisites, privacy disclosures, console metadata, and rollback risks.

### Claude's Discretion
- Exact plan split between config work, test stabilization, and submission documentation.
- Whether ad/billing cleanup should be grouped or separated by platform risk.
- Whether to create temporary feature flags to disable non-ready launch surfaces.

</decisions>

<code_context>
## Existing Code Insights

### Confirmed blockers from review
- Android release currently allows debug signing fallback in `android/app/build.gradle.kts`.
- Android manifest still contains test AdMob app ID and billing declaration.
- iOS project still uses placeholder bundle IDs in `ios/Runner.xcodeproj/project.pbxproj`.
- `ios/Runner/Info.plist` lacks launch-critical metadata such as Face ID usage description.
- Google Sign-In/Drive flow exists in code, but iOS sign-in wiring and metadata are incomplete.
- `flutter analyze` is green, but `flutter test` is not green due to settings and lifecycle-related failures.
- `flutter build appbundle --release` currently exits with a toolchain/symbol-stripping failure even though an `.aab` artifact appears.

### Important integration points
- `lib/main.dart`
- `lib/services/ad_service.dart`
- `lib/services/telemetry_service.dart`
- `lib/services/analytics_service.dart`
- `lib/services/google_drive_backup_service.dart`
- `lib/services/biometric_service.dart`
- `lib/services/app_lifecycle_service.dart`
- `lib/providers/settings_provider.dart`
- `test/settings_provider_test.dart`
- `test/widget_test.dart`
- `android/app/build.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`
- `ios/Runner.xcodeproj/project.pbxproj`

</code_context>

<specifics>
## Specific Ideas

- Phase 14 should end with an explicit go/no-go launch checklist.
- Treat store policy and store metadata as first-class deliverables, not side notes.
- Prefer removing or disabling declarations that are not ready over trying to justify them in store review.
- iOS readiness should include documented manual checks because this workspace cannot perform a full App Store archive submission.
- Android should produce a clean release command path after cmdline-tools/licenses/toolchain issues are resolved.

</specifics>

<deferred>
## Deferred Ideas

- Beta rollout strategy after store approval.
- Marketing assets, screenshots, and app listing copy iteration.
- Longer-term security review beyond current store launch blockers.

</deferred>

---

*Phase: 14-store-launch-readiness-submission-hardening*
*Context gathered: 2026-03-06*

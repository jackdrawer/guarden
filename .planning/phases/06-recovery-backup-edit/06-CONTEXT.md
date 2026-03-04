# Phase 6: Recovery, Backup and Edit Flows - Context

**Gathered:** 2026-03-02
**Status:** Ready for planning

<domain>
## Phase Boundary

This phase delivers three capabilities:
1. Seed phrase persistence and recovery flow.
2. Encrypted local backup export/import.
3. Full edit support for bank/subscription/web records.

Out of scope:
- Cloud sync and remote account merge.
- Team/shared vault features.
- Key escrow or remote recovery services.

</domain>

<decisions>
## Implementation Decisions

### Recovery storage strategy
- Seed phrase must not be stored plaintext.
- Store only encrypted seed blob in secure storage.
- Recovery validation will be based on decryptability + exact phrase match.

### Backup encryption strategy
- Backup will use a dedicated backup passphrase (not master password).
- Backup payload will be versioned and checksummed.

### Restore behavior
- Restore must have dry-run mode before apply.
- User confirms conflict handling after dry-run report.

### Edit UX strategy
- Reuse existing form screens in `create|edit` mode.
- Detail-screen edit buttons route to edit mode forms.

### Panic flow strategy
- Panic sends user to onboarding/welcome flow.
- Recovery entry point must be visible on welcome/login path.

### Claude's Discretion
- Exact backup file schema structure.
- Exact conflict-report visual format.
- Recovery screen UX copy and validation micro-interactions.

</decisions>

<specifics>
## Specific Ideas

- Keep recovery simple and local-first.
- Keep restore safe: dry-run first, apply second.
- Deliver edit flow early because user-facing value is immediate.

</specifics>

<code_context>
## Existing Code Insights

### Reusable assets
- `CryptoService`: AES-GCM + PBKDF2 + seed generation.
- `SecureStorageService`: secure key-value storage.
- Existing form/detail/provider triads for bank/sub/web domains.

### Established patterns
- Riverpod notifiers for business state.
- GoRouter route-driven screen flow.
- `setupVault`, `login`, `lock` flow in `AuthNotifier`.

### Integration points
- Auth: `lib/providers/auth_provider.dart`
- Secure storage: `lib/services/secure_storage_service.dart`
- Router: `lib/router.dart`
- Settings actions: `lib/screens/settings/settings_screen.dart`
- Forms/details: `lib/screens/{bank_accounts|subscriptions|web_passwords}/*`

</code_context>

<deferred>
## Deferred Ideas

- Cross-device backup sync.
- Automatic scheduled backups.
- Secure cloud restore point.

</deferred>

---

*Phase: 06-recovery-backup-edit*
*Context gathered: 2026-03-02*

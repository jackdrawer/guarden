---
status: testing
phase: 03-core-ui
source: 03-04-SUMMARY.md, 03-05-SUMMARY.md
started: 2026-03-03T00:00:00Z
updated: 2026-03-03T00:00:00Z
---

## Current Test

number: 1
name: Bank Account List Screen
expected: |
  Navigate to Bank Accounts tab. Should see a list view with neumorphic styling.
  If no accounts exist, empty state should be visible. If accounts exist, they should
  be listed with bank names/logos and basic info.
awaiting: user response

## Tests

### 1. Bank Account List Screen
expected: Navigate to Bank Accounts tab. List view with neumorphic styling shows accounts or empty state.
result: [pending]

### 2. Bank Account Create Form
expected: Tap add button, form screen opens. Fields for bank name, account number, password. Neumorphic text fields with focus states. Form validation works (required fields).
result: [pending]

### 3. Bank Account Edit & Save
expected: Tap existing account, edit form opens with pre-filled data. Make changes, save button updates the account successfully.
result: [pending]

### 4. Subscription List Screen
expected: Navigate to Subscriptions tab. List view shows subscriptions with service names/logos. Empty state if none exist.
result: [pending]

### 5. Subscription Create Form
expected: Tap add button, form opens. Fields for service name, cost, billing cycle (monthly/yearly). Neumorphic styling. Form validation works.
result: [pending]

### 6. Subscription Edit & Save
expected: Tap existing subscription, edit form opens with pre-filled data. Update fields, save button persists changes.
result: [pending]

### 7. Web Passwords List Screen
expected: Navigate to Web Passwords tab. List shows saved passwords with website logos. Empty state if none exist.
result: [pending]

### 8. Web Password Create Form
expected: Tap add button, form opens. Fields for website, username, password. Logo fetching works. Neumorphic design consistent.
result: [pending]

### 9. Web Password Copy to Clipboard
expected: Tap copy icon on a password entry. Password is decrypted and copied. SnackBar shows confirmation feedback.
result: [pending]

### 10. Responsive Layout (Landscape/Tablet)
expected: Rotate device to landscape or test on tablet. All forms (Bank, Subscription, Web Password) should be centered and constrained, not stretched edge-to-edge.
result: [pending]

### 11. Neumorphic Focus States
expected: Tap into any text field in forms. Field should show focus state with border color change, maintaining neumorphic design.
result: [pending]

### 12. Accessibility Labels
expected: Enable TalkBack/VoiceOver. Neumorphic buttons, text fields, and containers should have semantic labels that are read aloud.
result: [pending]

## Summary

total: 12
passed: 0
issues: 0
pending: 12
skipped: 0

## Gaps

[none yet]

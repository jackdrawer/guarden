# Play Store Screenshot Pack

## Scope

This pack is for the four Android phone screenshots currently available from the latest Guarden launch-review flow.

## Current Best Order

1. Dashboard / command center
2. Subscriptions screen
3. Settings screen
4. Login with biometric access

## Recommended Turkish Headlines

1. `Kumanda merkeziniz hep elinizin altinda`
2. `Abonelikleri tek yerde duzenli tutun`
3. `Yedekleme ve gizlilik kontrolunuzde`
4. `Biyometri ile hizli ve net giris`

## Recommended English Alternatives

1. `Your secure command center`
2. `Keep subscriptions organized`
3. `Backup and privacy stay in your control`
4. `Unlock quickly with biometrics`

## Important Review Notes

The screenshots you shared are strong references, but two of them should be refreshed before the final Play upload:

- Login: the visible title still uses older wording and should be recaptured from the latest launch-polish build.
- Settings: the light-theme capture is usable for review, but the darker Guarden-aligned theme will make the listing feel more coherent.

The dashboard and subscriptions screens are closer to upload quality, provided the status bar and transient system UI are trimmed.

## Builder Workflow

1. Put the raw screenshots here:
   - `docs/release/raw-playstore/dashboard.png`
   - `docs/release/raw-playstore/subscriptions.png`
   - `docs/release/raw-playstore/settings.png`
   - `docs/release/raw-playstore/login.png`
2. Run:
   - `python tool/playstore_screenshot_builder.py`
3. Generated outputs will be written here:
   - `docs/release/generated-playstore/`

The builder:

- trims the Android status bar area
- places each screenshot on a branded dark Play Store card
- adds a short headline and supporting line
- exports Play-ready PNG files

## Validation

Use this command before generation if you only want to check the input files:

- `python tool/playstore_screenshot_builder.py --validate`

## Final QA Before Upload

- Ensure login and settings are captured from the latest build, not older wording.
- Avoid screenshots with keyboards, snackbars, or permission dialogs.
- Keep the same language across the whole screenshot set.
- Use the same theme across all screenshots.
- Prefer real product UI over decorative renders for phone screenshot slots.

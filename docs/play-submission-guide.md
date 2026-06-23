# Cairn - Google Play submission guide

A step-by-step checklist for submitting Cairn to the Play Console. Each step
points to the source doc or asset that has the exact content to paste.

Reference material:
- Store listing text (title, short, full, category, contact): `docs/play-store-listing.md`
- Privacy policy (host URL): https://github.com/Zansuken/cairn/blob/main/docs/privacy-policy.md
- Data Safety form answers: `docs/play-data-safety.md`
- Permission and sensitive-API justifications: `docs/play-permissions-justification.md`
- Feature graphic: `store/feature_graphic.png` (1024x500, local, gitignored)
- Screenshots: `store/screenshots/*.png` (1200x2400, local, gitignored)
- Upload artifact: `build/app/outputs/bundle/release/app-release.aab` (rebuild fresh before upload)

---

## 1. Create the app

Play Console -> Create app.
- App name: Cairn
- Default language: English (United States)
- App or game: App
- Free or paid: Free
- Declarations: accept the developer program policies and US export laws.

## 2. Main store listing

Play Console -> Grow -> Store presence -> Main store listing. All text is in
`docs/play-store-listing.md`.
- App name: `Cairn: Stay Away Streaks`
- Short description: paste the 69-character line.
- Full description: paste the full block.
- App icon: 512x512 (export from the launcher icon; the in-app icon is `assets/cairn_icon.png`).
- Feature graphic: upload `store/feature_graphic.png`.
- Phone screenshots: upload all six from `store/screenshots/` in order (01 to 06). Minimum two required.
- No promo video.

## 3. Store settings

Play Console -> Grow -> Store presence -> Store settings.
- App category: Health & Fitness (Lifestyle or Productivity also fit; your call).
- Tags: pick a couple that match (for example "Digital Wellbeing").
- Contact details: email doom.sebastien.pro@gmail.com. Website optional.

## 4. App content (Policy -> App content)

Work through every declaration here. The app cannot go live until all are done.

- Privacy policy: paste the URL above.
- Ads: No, this app does not contain ads.
- App access: All functionality is available without special access (no login). Say so.
- Content ratings: complete the IARC questionnaire. Cairn has no violence, sexual,
  or mature content, no user accounts, and shares only a short text recap through
  the OS share sheet. Expect an "Everyone" rating. Answer honestly.
- Target audience and content: target 13 and over (do not target children; that
  avoids the Designed for Families requirements). Confirm the app is not
  appealing to children.
- News app: No.
- Data safety: fill from `docs/play-data-safety.md`. The summary answer is that
  the app does not collect or share any data (no INTERNET permission in the
  release manifest; verified against the merged manifest).
- Government apps: No. Financial features: none. Health: no health declarations.
- Foreground service permissions: Cairn declares FOREGROUND_SERVICE_SPECIAL_USE.
  Play requires a declaration with a short justification and usually a demo video.
  Use the specialUse justification in `docs/play-permissions-justification.md`
  (the speed-bump watcher that shows a brief user-enabled pause when a tracked
  app is opened). Record a short screen capture of the pause if a video is asked for.

Note on sensitive permissions the user grants in-app (not Play forms):
PACKAGE_USAGE_STATS (usage access) and SYSTEM_ALERT_WINDOW (draw over other apps)
are granted by the user in system settings. If review asks, the justifications are
in `docs/play-permissions-justification.md`.

## 5. Production release

Play Console -> Release -> Production -> Create new release.
- Play App Signing: leave enabled (recommended). Your `cairn-upload.jks` is the
  upload key; Google manages the app signing key.
- Rebuild a fresh AAB right before upload:
  `flutter build appbundle`
  then upload `build/app/outputs/bundle/release/app-release.aab`.
- Release name: 1.0.0 (1).
- Release notes (en-US): a short first-release note, for example:
  "First release. Grow a streak for every day you stay away from an app you choose to track. On-device, no accounts."
- Countries and regions: select where to publish (all, or start with a few).

## 6. Review and roll out

- Resolve any warnings on the release dashboard.
- Send for review. First reviews can take a few days.
- Consider a closed or internal test track first if you want to validate the
  upload and listing before public production.

## Regenerating store assets

Screenshots and the feature graphic are not in the repo (gitignored under
`store/`). To regenerate the screenshots on a running emulator:

    flutter drive --driver=test_driver/integration_test.dart --target=integration_test/screenshot_test.dart -d <emulator-id>

They land in `store/screenshots/` at 1080x2400, then are padded to 1200x2400
(2:1) so Play accepts them.

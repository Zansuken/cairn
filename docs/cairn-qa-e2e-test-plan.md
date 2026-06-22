# Cairn — E2E QA Test Plan

Senior-QA pass over every user-facing screen, element, and UX flow. Each flow
lists the manual checks to run on device/emulator. The **Issues found & fixed**
and **Known limitations** sections at the end record this pass's outcome.

Conventions: ✅ expected pass · ⚠️ edge case to verify on device · 🔒 honesty
invariant (must never be violated).

---

## 1. First run / onboarding (`OnboardingFlow`)

1. Fresh install → **Welcome 1** (pitch) shows mascot, headline, Continue.
2. Continue → **Welcome 2** (how it works): 3 forming-day stacks, chips
   (On-device / No blocking / No accounts), dots show step 2 active.
3. Continue → **Permission primer** (`PermissionScreen`, primer variant).
4. Grant Usage Access in system settings, return → auto-advances to **Pick apps**
   (verified via `didChangeAppLifecycleState` resume). ⚠️ Confirm on device the
   resume callback fires after returning from Settings.
5. **Pick apps**: curated suggestions show as a grid; search filters all
   installed apps; selecting toggles a sage check; footer shows "N cairns
   forming" + forming-cairn previews; Continue disabled at 0 picks.
6. Confirm picks → **All set** (Day 1 begins): tracked names in the pill,
   Start → Home.
7. ⚠️ A user who refuses Usage Access cannot pass the permission step (hard wall —
   intentional, the app cannot function without it). No "explore first" path.

## 2. Permission (`PermissionScreen`)

- **Primer**: mascot + glow, headline, "This never leaves your phone", 3 trust
  bullets, expandable "Why does Cairn need this?" (3 sections), pinned Grant
  button + caption.
- **Lost** (`lost: true`, access revoked after being granted): "TRACKING PAUSED",
  unverified illustration card, reassurance that streaks are safe, "Re-enable
  access" button. 🔒 Re-enabling resumes; lost days are unverified, never clean.
- Grant button opens system Usage Access settings.

## 3. Home (`HomeScreen`)

- **Empty** (no active cairns): mascot + glow, "Your first cairn is waiting.",
  copy, "Choose an app" CTA → Manage, "Most people start with just one".
- **Content**:
  - Hero: "PERFECT-DAY RUN" + big meta number, subtitle branches on
    `allCleanToday` ("Day N, still clean today" vs "A tracked app was opened
    today"), rollover line, Best run / Lifetime clean stats.
  - "YOUR CAIRNS" list: each row = icon, name, today label, stone stack, streak
    number; tap → App detail. Sorted by current streak desc.
  - "+ Track another app" dashed button → Manage.
- Bottom nav: Home (active), Apps → Manage, Settings → Settings.
- ⚠️ 3-digit streaks (100+) in hero/rows: confirm no overflow on a 360dp screen.

## 4. App detail (`AppDetailScreen`)

- **Active view**: back row + ⋯ (stop), hero (mascot, CURRENT RUN, big number,
  today dot+label), Best record / Lifetime clean tiles, "LAST 30 DAYS" dot grid
  (today ringed), legend (Clean / Slipped / Unverified), honesty note, "Edit
  notifications & name" (→ "coming soon"), "Stop tracking X".
  - 🔒 Unverified dots render distinct from clean; never shown as clean.
- **Stop tracking**: confirm dialog ("lifetime + best kept; current run ends"),
  Stop → removeApp → pops.
- **Freed view** (uninstalled app): summit art, "SUMMITED", "You're free.",
  final run / lifetime stats, "Freed on <date>", "Share your summit"
  (→ "coming soon"), "Keep as a marker on my trail" → pops.
- App removed while screen open → provider returns null → screen auto-pops.

## 5. Manage apps (`ManageAppsScreen`)

- "TRACKING NOW" + count; each tracked row = icon, name, "Day N · <today>",
  Remove (pill). Empty → "No apps tracked yet."
- "+ Add an app" → bottom sheet picker (search, curated suggestions, Add /
  TRACKING badge, guidance card). Done closes.
- Guidance card ("Most people start with 1 to 3 apps").
- **SUMMITED** section (freed apps) — tap → Freed view. (Added this pass.)
- Remove → app leaves the active list; re-adding later resumes lifetime/best
  from the kept day records.
- Bottom nav: Home → pop, Settings → push.

## 6. Settings (`SettingsScreen`)

- **Your day**: "Day resets at" → hour picker sheet (0–23, persists, reschedules
  worker, refreshes Home/recap); "Yesterday's recap" → Daily recap.
- **Notifications**: "Daily summary" toggle (schedules/cancels + asks Android 13+
  permission); "Summary time" → time picker; "Milestone moments" toggle
  (in-app only); honest footnote ("never nags").
- **Privacy**: "About & open source" → Privacy/About; honest footnote ("no
  analytics, no servers"). 🔒 No analytics toggle (nothing to opt into).
- Footer "CAIRN · V1.0". Bottom nav works.

## 7. Daily recap (`DailyRecapScreen`)

- Reachable from notification tap (cold + warm) and Settings.
- Header "GOOD MORNING" + yesterday's date + mascot.
- Headline + subtitle reflect grew/total honestly; per-app rows with status pill
  (CLEAN / RESET / UNVERIFIED) and trailing (Day N / New stack / —); lifetime +
  perfect-run strip; "Done".
- Empty (no apps) → "No cairns tracked yet."
- 🔒 Single unverified app reads "couldn't be verified", never "reset" (fixed).
- ⚠️ Repeated notification taps must not stack multiple recap screens (`_recapOpen`
  guard).

## 8. Moments (`moment_modals`) 🔒

- **Slip**: fires only on a confirmed open (run >0 → 0 with yesterday = slipped).
  Card: "You opened X today…", trail (lifetime) + best preserved, "Start a new
  stack". 🔒 An unverified-induced break fires **no** slip (fixed).
- **Milestone**: 7 / 30 / 100 crossing → proud mascot, number, affirmation,
  "Nice". Honors the Milestone toggle. Highest threshold when several crossed.
- **Freed**: pushes the summit (App detail Freed view).
- Idempotent: a second foreground recompute (before == after) emits nothing.

## 9. Detection / reconciliation (data + native) ⚠️

- Foreground reconcile (`RootGate._onForeground`): rechecks permission, recomputes,
  syncs worker, refreshes Home + recap, shows moments.
- Native worker (~04:05) writes yesterday's clean/slipped verdict to the same
  SQLite DB; BootReceiver reschedules after reboot.
- 🔒 Days with no detection data = unverified (retention = 2 days, older gaps
  filled unverified). Never silently clean.
- 🔒 Slip = honest hard reset to 0; lifetime + best preserved (monotonic).
- Uninstall → Freed trophy (never mass-free on an empty installed-apps query).
- ⚠️ **Not yet verified on a real device**: that the native worker actually writes
  a `day_records` row at 04:05 (needs a temporary debug trigger or adb).

---

## Issues found & fixed (this pass)

1. **🔴 False "you opened it" on an unverified break.** A run broken by an
   unverified day (permission revoked) dropped to 0 and fired the slip modal
   claiming the user opened the app — violating the honesty invariant. Slip now
   fires only when the just-closed day's verdict is `slipped`; an unverified or
   unknown break stays silent. (`moment_detector.dart`, `tracking_repository.dart`;
   TDD in `moment_detector_test.dart`.)
2. **🔴 Recap called an unverified day a "reset".** A single tracked app with an
   unverified yesterday showed "Your cairn reset yesterday." while the subtitle
   said it couldn't be verified — contradictory and false. Headline now reads
   "Yesterday couldn't be verified." (`daily_recap.dart`; TDD in
   `daily_recap_test.dart`.)
3. **🟠 Freed trophies were unreachable.** Freed apps are filtered out of Home and
   Manage, so after the one-time celebration the "permanent" summit could never be
   revisited. Added a **SUMMITED** section to Manage that lists freed apps and
   navigates to the Freed view. (`manage_apps_screen.dart`; test in
   `manage_screen_test.dart`.)
4. **🟡 Stale state after settings/foreground.** Changing the reset hour didn't
   refresh Home (day windows shifted but numbers didn't recompute), and the recap
   could show a stale "unverified" after a foreground reconcile finalized
   yesterday. Added targeted provider invalidations.
   (`settings_screen.dart`, `root_gate.dart`.)

Result: `flutter analyze` clean, 97 tests green (was 93).

## Known limitations (intentional v1, not bugs)

- Milestone celebrations are in-app modals, not tray pushes.
- No manual reorder of the Home list (sorted by streak).
- Stubs show "coming soon": Edit reminders & name, Share summit, Privacy
  links/tips (F-Droid, GitHub, tip buttons).
- Permission is a hard requirement — no "explore without it" path.
- Native worker runtime write not yet confirmed on a physical device.

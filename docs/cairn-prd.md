# Cairn — v1 Build Spec (PRD)

Engineering spec for the v1 skeleton. Pairs with `cairn-design-brief.md` (visual/UX) and `cairn-screen-prompts.md` (screens). This doc owns the mechanic rules, the Android detection architecture, the data model, and release requirements.

---

## 1. Overview

Cairn is an Android app that grows a streak for the days a user does **not** open an app they've chosen to moderate. Each clean day adds a stone to a per-app cairn. Honest, on-device, free.

**v1 goal:** ship the smallest version that proves (a) reliable on-device detection of "was this app opened today?" and (b) the core streak loop, with a calm, complete UI.

**In scope (v1):** onboarding + Usage Access grant, app selection, per-app zero-open streaks, global meta-streak, lifetime total, best record, 4 AM day boundary, honest reset, "unverified" days, Freed-on-uninstall, daily summary + milestone notifications, settings, privacy/about, all v1 screens from the brief.

**Out of scope (v1):** intervention speed bump, accountability buddy, leaderboards, iOS, deep stats, time-budget mode, themes. (All on the roadmap.)

---

## 2. Mechanic rules (source of truth)

- **Clean day (per app):** zero foreground opens of that app within the day window.
- **Day window:** `[today 04:00 local, tomorrow 04:00 local)`. The 04:00 boundary is configurable in settings. Usage between midnight and 04:00 counts toward the *previous* day.
- **Streak (per app):** count of consecutive completed clean days. The current in-progress day is shown separately ("Day N — still clean") and only graduates into the streak when its window closes clean.
- **Meta-streak ("perfect days"):** consecutive days where *every* tracked app was clean.
- **Lifetime clean days (per app and global):** monotonic counter; never resets.
- **Best record (per app):** longest streak ever achieved; never decreases.
- **Slip:** any foreground open of a tracked app in its day window. On slip, that app's current streak resets to 0 immediately on detection (subject to detection latency). Lifetime total and best record are untouched. Reset is framed positively ("run ended, new stack starts").
- **Unverified day:** a day for which detection data is unavailable (e.g. permission was revoked, or the OS event log rolled off before reconciliation). Rendered distinctly; **never** counted as clean and never silently counted as a slip — it breaks the streak's "completed clean days" chain but is labeled honestly.
- **Freed:** if a tracked app is uninstalled, its tracking converts to a permanent "Freed" trophy (summit state) and it stops accruing an active streak.

---

## 3. Platform & stack

- **Platform:** Android only. Target latest stable `compileSdk`/`targetSdk`; `minSdk 26` (Android 8.0) for solid WorkManager behavior and ~high device coverage.
- **App:** Flutter (Dart) for all UI and the streak logic.
- **Native bridge:** Kotlin via `MethodChannel` for everything that touches `UsageStatsManager` and the permission check.
- **Background:** WorkManager (periodic) for the daily reconciliation.
- **Local storage:** SQLite via **Drift** (recommended — typed queries, good for date-range reads; Isar is the NoSQL alternative). All data on-device; no backend, no accounts.
- **Suggested key plugins:** `workmanager` (or a native Kotlin Worker), `drift` + `sqlite3`, `flutter_local_notifications`, `device_apps`/`installed_apps` (to list installed apps + icons), `permission_handler` is **not** sufficient for Usage Access (special permission) — handle via the native channel.

---

## 4. Detection architecture (the heart of v1)

Android cannot block or be notified in real time that an app opened (without an AccessibilityService, which is out of scope and Play-risky). Instead Cairn **reconstructs** usage from the OS's retained event log.

### 4.1 Permission
- Requires the special **`PACKAGE_USAGE_STATS`** access ("Usage access"), granted in system settings, not a runtime dialog.
- Open settings via `Settings.ACTION_USAGE_ACCESS_SETTINGS`.
- Check grant state natively via `AppOpsManager` (`OPSTR_GET_USAGE_STATS` → `MODE_ALLOWED`), exposed to Dart over the channel as `isUsageAccessGranted()`.

### 4.2 Reading opens
- Use `UsageStatsManager.queryEvents(beginMillis, endMillis)`.
- Iterate `UsageEvents.Event`; an **open** = an event of type `ACTIVITY_RESUMED` (value `1`, aka the legacy `MOVE_TO_FOREGROUND`) whose `packageName` is in the tracked set.
- Notification peeks and background services are *not* `ACTIVITY_RESUMED`, so they correctly don't count.
- Native channel method: `getOpenedPackages(List<String> packages, long startMillis, long endMillis) → List<String>` (the subset that had ≥1 qualifying event in the window).

### 4.3 Reconstruction (lazy, no always-on service)
For a given app and day window `[start, end)`: it's **clean** iff `getOpenedPackages` returns it `false` for that window. This is computed:
- **On app foreground** (recompute the current and any not-yet-finalized days), and
- **Once daily** by the reconciliation worker just after the 04:00 boundary.

No persistent foreground service is needed for a once-a-day streak.

### 4.4 Daily reconciliation worker
- WorkManager periodic task targeted to run shortly after the day boundary (~04:05). WorkManager timing is approximate under Doze — that's fine; the worker is idempotent and also re-runs on next app open.
- For each tracked app, finalize the just-closed day: query its window, write a `DayRecord` (clean / slipped). Update streak, meta-streak, lifetime, best.
- **Persist verdicts immediately** so we never depend on OS event retention beyond ~24h.

### 4.5 Retention & unverified days
- The OS event log is retained only for a limited window (treat as not guaranteed beyond ~24–48h; often up to ~7 days). Because we finalize daily, normal use never hits this.
- If a gap is detected (no reconciliation ran and the window is older than retention, e.g. device off / battery-saver killed the worker for days), mark those days **`unverified`**, never clean. The streak chain breaks honestly; the UI explains it (ties to the "permission lost / re-grant" screen pattern).

### 4.6 Edge cases
- **Uninstall:** detect that a tracked package is no longer installed → set app state `Freed`, stop active tracking, show the trophy. (Check on app launch + during reconciliation.)
- **Timezone/DST:** day windows computed in the device's current local time at evaluation. Rare dateline anomalies accepted.
- **Reboot:** no impact — reconstruction reads the retained log; reschedule the worker on `BOOT_COMPLETED`.
- **Incidental opens** (a link opening the app): counts as an open in v1. A "grace for opens under N seconds" is a v2 consideration.
- **Multi-user / work profile:** out of scope v1 (UsageStats is per-profile); documented limitation.

---

## 5. Data model (Drift / SQLite)

- **TrackedApp**: `packageId` (PK), `displayName`, `addedAt`, `status` (`active` | `freed`), `freedAt?`.
- **DayRecord**: (`packageId`, `dayStartUtcMillis`) composite PK, `state` (`clean` | `slipped` | `unverified`), `finalizedAt`.
- **AppStreakState** (derived but cached): `packageId`, `currentStreak`, `bestStreak`, `lifetimeCleanDays`, `lastFinalizedDay`.
- **MetaState**: `currentMetaStreak`, `bestMetaStreak`, `lifetimePerfectDays`.
- **Settings**: `dayResetHour` (default 4), `notificationsEnabled`, `dailySummaryTime`, `milestonesEnabled`, `analyticsOptIn` (default per consent UX).

Streaks are recomputable from `DayRecord` history, so `AppStreakState` is a cache that can be rebuilt if needed.

---

## 6. Build-step-zero: the detection spike

**Do this before any UI.** A throwaway spike that proves the riskiest unknown.

Scope: a one-screen app that (1) requests Usage Access, (2) lets you pick a package, (3) calls `getOpenedPackages([pkg], todayWindowStart, now)` and prints whether it was opened today, plus the raw event timestamps.

**Acceptance criteria:**
1. With Usage Access granted, opening the target app then returning to the spike reflects the open within one foreground recompute.
2. The same query, run the morning after, correctly classifies *yesterday's* full window (test the 04:00 boundary with a late-night open).
3. After the spike app is force-killed and the device sits overnight with battery-saver on, the next-morning result is still correct (reconstruction from the retained log, not a live service).
4. After ~2 days offline, reopening still reconstructs the missed days; simulate/observe the retention ceiling and confirm older-than-retention windows return *no data* (→ would be marked `unverified`), never a false "clean."

If 1–4 pass, the project is technically green-lit and the rest is Flutter you already know.

---

## 7. App architecture

- **UI layer (Flutter):** screens from the brief; stateless where possible, driven by view-models.
- **Domain layer (Dart):** the mechanic rules (day windows, streak/meta computation, reset, unverified). Pure functions — unit-testable without Android.
- **Data layer (Dart):** Drift DAOs; settings.
- **Platform layer (Kotlin):** `UsageStatsManager` queries, permission check/open, installed-apps list, the reconciliation Worker, boot receiver. Exposed via `MethodChannel`.

Keep the mechanic rules in Dart (one language for the logic, fully unit-tested) and keep Kotlin to thin data access. This also leaves a clean seam for the future intervention module (which *will* need real-time native work).

---

## 8. Screen → data mapping

- **Home:** meta-streak, today's in-progress status, per-app rows (current streak + stone-stack height), lifetime + best. Reads `AppStreakState` + `MetaState` + live recompute of today.
- **App detail:** one `AppStreakState` + recent `DayRecord` history (clean/slipped/unverified dots); Freed state.
- **Manage/add apps:** installed-apps list (native) + curated suggestions; writes `TrackedApp`.
- **Onboarding:** permission grant (native check), app picker.
- **Slip / milestone / Freed modals:** triggered off reconciliation/recompute results.
- **Permission-lost state:** native `isUsageAccessGranted()` false → recovery flow; surfaces `unverified` days.
- **Settings/Privacy:** `Settings` table; static privacy content + repo/F-Droid links.

---

## 9. Notifications

- **Daily summary:** one local notification at the user's chosen time reporting the just-finalized day(s). Scheduled via `flutter_local_notifications`. Default on, easily disabled.
- **Milestones:** local notification on hitting 7 / 30 / 100 (and beyond) for any app.
- **Hard rule:** no re-engagement / FOMO / "come back" notifications, ever. Single notification channel, honest content only.

---

## 10. Analytics

- Minimal, anonymous, transparent, ideally opt-in. Collect only coarse app-health: onboarding completion, retention buckets, crash reports.
- **Never** collect which apps are tracked, usage data, or streak content. That data never leaves the device.
- Disclose plainly in onboarding + Privacy screen. Provide a real opt-out.
- For F-Droid friendliness, prefer a privacy-respecting/self-hostable analytics SDK or none; avoid Google/Firebase Analytics (also keeps the build free of proprietary blobs).

---

## 11. Privacy & open-source

- Promise (must hold absolutely): usage data and which apps you track **never leave the device**.
- Public GitHub repo; permissive or copyleft license (your call — GPL/AGPL signals "stays free," MIT is friendlier to reuse).
- For **F-Droid**: no proprietary dependencies, no non-free SDKs, reproducible-build-friendly. This constrains analytics/notification/library choices — keep deps FOSS.
- Play Store: file the **permissions declaration** justifying `PACKAGE_USAGE_STATS` (core feature) and ship a clear privacy policy.

---

## 12. Release

- **Channels:** Play Store (primary) + F-Droid + GitHub releases (APK).
- **Versioning:** semver; tag releases in the repo.
- **Pre-launch checklist:** permission declaration, privacy policy URL, store listing built on the locked positioning ("a streak for the days you don't open the app you can't quit — no blocking, no subscriptions, nothing leaves your phone"), the `cairn_icon` asset.

---

## 13. Roadmap (post-v1)

1. **Intervention speed bump** — real-time detection (AccessibilityService and/or overlay) → non-blocking pause + honest reminder + real "Open anyway." Expect Play review friction; F-Droid/APK as fallback.
2. **Stats / history + themes.**
3. **Accountability buddy** — privacy-first (share streak *status* only), its own backend + accounts; a separate project, designed deliberately.

---

## 14. Risks & open questions

- **OEM battery killers** (Samsung/Xiaomi/etc.) deferring the worker → mitigated by lazy recompute on open + honest `unverified` days. Validate on a real Samsung/Xiaomi device.
- **Event retention variance** across OEMs/versions → spike criterion #4 measures the real ceiling on target devices.
- **Play policy** on `PACKAGE_USAGE_STATS` → permitted with declaration; confirm current policy at submission.
- **Local DB choice** (Drift vs Isar) — pick during the spike; not load-bearing.
- **Icon-scale face readability** — already handled with the 2-stone icon variant; validate at 48px.

---

## 15. Definition of done (v1)

- Detection spike criteria 1–4 pass on at least two physical devices (one stock Pixel-like, one aggressive-OEM).
- A user can: grant Usage Access, pick 1–3 apps, see per-app + meta streaks, accrue a clean day across the 04:00 boundary, experience an honest reset on a real open, and see lifetime/best persist.
- Uninstalling a tracked app yields the Freed trophy.
- Daily summary + a milestone fire correctly; no re-engagement notifications exist.
- All data verified to stay on-device; repo public; Play permission declaration drafted.
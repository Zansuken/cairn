# Cairn Intervention Speed Bump — Final Implementation Plan

Status: implementation-ready. This revision incorporates every valid defect from the
adversarial review. The biggest changes from the draft: native no longer opens SQLite on
the hot path (it writes an append-only journal that Dart drains); the reconcile finalizes
any day that has interception data regardless of `retentionDays`; the match key is the real
OS event timestamp, not the detection time; day bucketing is done only in Dart; `allowed`
dominates at the day level (per-open "nearest" matching is dropped); the whole feature lives
behind a build flavor so the Play APK never ships the overlay/FGS permissions; and several
copy fixes.

---

## 0. Decisions made up front (conflicts + critique resolutions)

These are locked for this plan. Each cites the defect(s) it closes.

1. **Bump is a native overlay, not an Activity.** `TYPE_APPLICATION_OVERLAY` via
   `WindowManager.addView`. No `onSpeedBump` native→Dart channel, no Flutter bump route, no
   `SpeedBumpEvent` stream. The bump UI is a native `res/layout/speed_bump.xml`.

2. **Native NEVER opens SQLite on the hot path. (Fixes C1, C2, C3, G4.)** The draft had the
   service open the Drift SQLite file with `android.database.sqlite.SQLiteDatabase` while the
   Flutter process holds the same file open in WAL mode with a *different* bundled SQLite
   build — a real cross-process / mixed-library WAL corruption vector, made worse because the
   service writes on a hot path while a foreground reconcile may be writing too. Instead:
   - The service writes interception records to a **single append-only JSONL journal file**
     (`<filesDir>/cairn_interceptions.jsonl`), one JSON object per line, via a serialized
     `HandlerThread` (the only writer). Append is atomic enough for our needs; we never
     rewrite earlier lines.
   - The service still needs the **streak number + app display name** for the bump copy. It
     reads those the same way, from the **same journal mechanism in reverse is not possible**,
     so instead it reads a tiny **read-only snapshot** that Dart maintains in SharedPreferences
     (`WorkerConfig`): a `streaks` map (packageId→current streak) and a `labels` map
     (packageId→display name). This is a read-only prefs read on the hot path, never SQLite.
     Dart refreshes this snapshot on every reconcile (cheap, already iterating apps). The
     snapshot can be stale by at most one reconcile cycle; see G3 handling in §6/§7.
   - On the Dart side, `reconcile()` first **drains** the journal into the Drift
     `InterceptionEvents` table (inside one transaction), then deletes/truncates the drained
     lines. Drift is the *only* writer to the SQLite file. This removes the second SQLite
     writer entirely.
   - The existing `ReconciliationWorker` keeps writing `day_records` via raw `SQLiteDatabase`
     exactly as today (unchanged risk profile: once/day, app almost always backgrounded). We
     do **not** add a second hot-path raw writer.

3. **Match key is the real OS event timestamp. (Fixes A2, C3.)** `UsageQuery` returns the
   actual `MOVE_TO_FOREGROUND` `timeStamp` that triggered the bump (not the poll-loop
   observation time). The service writes *that* as `foregroundAtMillis` into the journal, and
   reuses the exact same value when it appends the outcome line. The reconcile matches OS
   opens to interceptions on this value with a small tolerance (`matchToleranceMillis = 2000`)
   only as a safety net for the OS reporting the same event with a slightly different stamp
   across two queries.

4. **`allowed` dominates at the day level; per-open "nearest" matching is dropped.
   (Fixes A3.)** Day classification is a simple set rule (see §4 `classifyDay`), not a
   per-open nearest-neighbour match. Nearest matching produced both false-clean (a later
   resisted bump "stealing" an earlier real Open-anyway) and false-unverified, and made the
   verdict brittle against the tolerance. The new rule:
   - If any `allowed` interception exists for the day → `slipped`.
   - Else if there is any OS open that is **not** matched by a `resisted` interception (i.e.
     unmatched, or matched only by a `shown`-without-outcome row) → `unverified`.
   - Else (every OS open is covered by a `resisted`, or there are no OS opens) → `clean`.

5. **Any day with interception data is finalizable regardless of `retentionDays`.
   (Fixes A4, A5.)** The reconcile's finalize loop is extended: in addition to the last
   `retentionDays` completed days, it finalizes **every completed day that has interception
   rows but no finalized `DayRecord` yet, OR whose `DayRecord` was previously finalized only
   from the OS-log path and now has interception rows** — independent of age. This is the
   feature's own happy path on a device that killed the worker for days: perfect `resisted`
   records must still be honoured even if the day is older than 2 days. Interception-bearing
   days are reconcilable from **journal/table + prefs snapshot alone**, without re-querying
   the OS log.

6. **Day bucketing is done ONLY in Dart. (Fixes C2, mitigates risk in §8.)** The journal line
   carries `foregroundAtMillis` (the OS event time). The reconcile derives each interception's
   day with the *same* `DayWindow.forNow(eventTime, resetHour:)` used for OS opens. We do
   **not** trust any native-computed day boundary for bucketing, eliminating native/Dart
   reset-hour and DST skew. (We do not even write a native `dayStartMillis`; the column is
   computed in Dart at drain time.)

7. **Legacy-vs-interception gate uses a never-cleared `speedBumpEnabledAt`. (Fixes E2, refines
   draft decision 3.)** `WorkerConfig.speedBumpEnabledAt` is set **once, on first-ever enable,
   and never cleared** (toggling off does not reset it). It means "the earliest day Cairn is
   responsible for vouching." The boolean `speedBumpEnabled` separately means "is it on right
   now." For a completed day:
   - If the day has interception rows → interception-aware verdict (`classifyDay`), always.
   - Else if the day's window-end is **before** `speedBumpEnabledAt` (or the feature was never
     enabled) → legacy set-query path (`opened ⇒ slipped`, else `clean`).
   - Else (at/after `speedBumpEnabledAt`, no interception rows) → interception-aware path with
     `interceptions = []`: an unmatched OS open is `unverified` (honest "we were supposed to
     be watching and saw an open we cannot vouch for"), no OS open is `clean`.

8. **`openTimestamps` and `openedPackages` share one event-filter predicate. (Fixes G1.)**
   Both use the single private `isOpenEvent(e)` in `UsageQuery` (currently
   `e.eventType == MOVE_TO_FOREGROUND`). PRD §4.2 calls an open `ACTIVITY_RESUMED` /
   legacy `MOVE_TO_FOREGROUND` (same int value `1`); keeping one predicate guarantees the two
   reconcile paths never disagree about what counts as an open.

9. **"Stay strong" leaving the app is validated on-device FIRST. (Addresses B1.)** Launching a
   HOME intent from a service is a background-activity-launch (BAL) operation that Android
   14/15 + HONOR may drop, which would leave the user inside the tracked app — the opposite of
   the primary button's promise. Step 6 of the build order is a **spike gate**: prove on the
   HONOR device that, from a `specialUse` FGS holding `SYSTEM_ALERT_WINDOW`, a
   `startActivity(HOME, FLAG_ACTIVITY_NEW_TASK)` actually backgrounds the tracked app. If it
   does not, fall back to the documented alternatives in §7-B1 before building anything on top.

10. **Whole feature behind a build flavor. (Fixes D1.)** A `speedbump` product flavor gates the
    extra permissions (`SYSTEM_ALERT_WINDOW`, `FOREGROUND_SERVICE`,
    `FOREGROUND_SERVICE_SPECIAL_USE`), the `<service>` block, and the Kotlin/Dart feature code.
    The Play track builds the `base` flavor with none of these. The `speedbump` flavor ships via
    F-Droid / direct APK. This is a requirement, added in step 0, not an afterthought.

11. **Persist edge state + an allow-grace on kill-restart. (Fixes B3.)** `lastForegroundPackage`
    and the last `allowed` `(package, foregroundAtMillis)` are persisted in prefs. On a
    START_STICKY restart, the service suppresses an immediate re-fire if the same package was
    `allowed` within `restartGraceMillis = 8000` and is still foreground. This is a narrow,
    documented exception to "no grace period," needed only for the kill→restart loop, not for
    normal cadence (normal re-foreground after backgrounding still re-shows the bump).

12. **Copy fixes. (Fixes F1, F2, D2; notes F3.)** No em dashes / unicode punctuation anywhere
    (F1 — the spec source line 153 has an em dash; do not copy it). FGS notification drops the
    word "watching" (F2). The primer adds a plain "Cairn checks which app you just opened" line
    (D2). "Stay strong" is a LOCKED label; the brand tension with "no willpower battles" is
    noted for product but kept (F3).

---

## 1. Architecture overview (data flow)

```
                       on-device only, no network, speedbump build flavor only
  user opens a
  tracked app
        |
        v
 OS UsageStatsManager  ── logs MOVE_TO_FOREGROUND(pkg, eventTs) ──┐
                                                                  |
  SpeedBumpService (specialUse FGS, default process)             |
   - poll loop (~1000ms, screen-on only, HandlerThread)          |
   - UsageQuery.latestForegroundOpen(now-3000, now)  <-----------+
       returns (pkg, eventTs) of most-recent open
   - tracked? AND rising edge vs persisted lastForegroundPackage?
   - NOT inside restart allow-grace?
        | yes
        v
   OverlayController.show(pkg, eventTs)
   - reads streak + label from WorkerConfig prefs snapshot (read-only, no SQLite)
   - Journal.append({pkg, foregroundAtMillis=eventTs, outcome=shown(2), recordedAt})
   - WindowManager.addView(speed_bump.xml)   (over the tracked app)
        |
   +----+--------------------+
   v                         v
 "Stay strong"            "Open anyway"
  removeView               removeView only (tracked app revealed behind)
  + startActivity(HOME,    Journal.append({pkg, foregroundAtMillis=eventTs,
    NEW_TASK)  [B1 gate]      outcome=allowed(1), recordedAt})
  Journal.append({... outcome=resisted(0) ...})
        |                         |
        +-----------+-------------+
                    v
   <filesDir>/cairn_interceptions.jsonl   (append-only, native = only writer)
                    |
   next app foreground / daily worker
                    v
  ReconciliationService.reconcile(now):
   1. drainJournal(): read JSONL -> InterceptionDao.upsert (in one Drift txn) -> truncate file
        (Drift is the ONLY SQLite writer)
   2. refreshSpeedBumpSnapshot(): write streaks{} + labels{} to WorkerConfig prefs
   3. per app, per completed day to finalize:
        - day has interception rows                  -> classifyDay(osOpens, interceptions)
        - else day < speedBumpEnabledAt / never on   -> legacy set query (opened => slipped)
        - else (>= speedBumpEnabledAt, no rows)       -> classifyDay(osOpens, [])
      finalize loop covers max(retentionDays days, ALL days with interception rows)
   4. fill unverified gaps, recompute caches (unchanged)
   5. pruneInterceptions(): drop rows strictly older than the oldest still-unfinalized day
                    v
  day_records -> StreakCalculator -> app_streak_states / meta_states -> UI
```

Source of truth for streaks stays the retroactive reconcile. The bump is best-effort real
time. The interception log only *reclassifies* OS-logged opens so "Stay strong" does not
break the run, and lets us honestly mark `unverified` when our own service could not vouch.

---

## 2. File-by-file change list

### Build config

- `android/app/build.gradle.kts` — add `flavorDimensions += "features"` and two product
  flavors: `base` (default, Play track, no extra permissions) and `speedbump` (F-Droid /
  sideload). Source sets: feature Kotlin/Dart-bridge manifest entries live under
  `src/speedbump/`. Keep `isMinifyEnabled = false` for now (note D1: flip on with keep rules
  before any Play release; unrelated to correctness).

### Native (Kotlin / Android) — all under `src/speedbump/kotlin/...` unless noted

**New files**
- `SpeedBumpService.kt` — the `specialUse` foreground service. Poll loop on a `HandlerThread`
  (~1000ms), `SCREEN_ON`/`SCREEN_OFF` `BroadcastReceiver` to hard-stop the loop when the
  screen is off, `ACTION_USER_PRESENT` not required. Ongoing `IMPORTANCE_LOW` notification.
  Edge-trigger using persisted `lastForegroundPackage`. Calls `OverlayController`. START_STICKY.
  On `addView` failure (overlay revoked) it disables itself (see D3): sets
  `WorkerConfig.setSpeedBumpEnabled(false)` and `stopSelf()`.
- `OverlayController.kt` — inflates `speed_bump.xml`, `addView`/`removeView` with
  `TYPE_APPLICATION_OVERLAY`. Reads streak + label from `WorkerConfig` prefs snapshot (no
  SQLite). Wires the two buttons: "Stay strong" → `removeView` + HOME intent (NEW_TASK);
  "Open anyway" → `removeView` only. Writes `shown` on show and `resisted`/`allowed` on tap via
  `Journal`, reusing the identical `foregroundAtMillis`.
- `Journal.kt` — `appendShown/appendResisted/appendAllowed(pkg, foregroundAtMillis)` and the
  raw `append(line)`; serialized on the service's `HandlerThread`. One JSON object per line:
  `{"pkg":"...","fg":<eventMillis>,"outcome":0|1|2,"rec":<recordedMillis>}`. Path =
  `<context.filesDir>/cairn_interceptions.jsonl`.
- `SpeedBumpController.kt` (small helper object) — `start(context)`, `stop(context)`,
  `isRunning(context)`, `isOverlayGranted(context)`, `openOverlaySettings(context)` (the
  `Settings.ACTION_MANAGE_OVERLAY_PERMISSION` intent). Used by `MainActivity` and
  `BootReceiver`.

**Edited files**
- `UsageQuery.kt` (main source set; the predicate must be shared by both builds) — extract the
  open test into `private fun isOpenEvent(e: UsageEvents.Event)` and route the existing
  `openedPackages` through it (no behaviour change). Add:
  - `fun latestForegroundOpen(context, start, end): Pair<String, Long>?` — most-recent open
    event in the window, returning `(packageName, timeStamp)`; null if none.
  - `fun openTimestamps(context, pkg, start, end): List<Long>` — per-open `timeStamp`s for one
    package, using the same `isOpenEvent` predicate (NOT collapsed to a set).
- `MainActivity.kt` (main source set; methods are harmless no-ops/false in `base`) — add channel
  methods: `getOpenTimestamps` (pkg,start,end → `List<Long>`), `isOverlayGranted`,
  `openOverlaySettings`, `startSpeedBump`, `stopSpeedBump`, `isSpeedBumpRunning`. In the `base`
  flavor these return `false`/empty/no-op so the Dart contract is uniform; in `speedbump` they
  delegate to `SpeedBumpController`. (Use a thin `SpeedBumpBridge` interface with a base no-op
  impl and a speedbump real impl, selected by source set, to avoid `#ifdef`-style branching.)
  Add `import android.net.Uri` only where the overlay-settings intent needs it.
- `WorkerConfig.kt` (main source set) — add:
  - `speedBumpEnabled` flag + `setSpeedBumpEnabled(context, bool)`.
  - `speedBumpEnabledAt(context): Long?` and internal set-once logic (set on first enable,
    never cleared).
  - `lastForegroundPackage` + `lastAllowed(pkg, foregroundAtMillis)` getters/setters (edge +
    restart-grace persistence, B3/§11).
  - `streaks(context): Map<String,Int>` and `labels(context): Map<String,String>` read-only
    getters, plus `saveSpeedBumpSnapshot(context, streaks, labels)` (the prefs snapshot the
    overlay reads; written by Dart via channel).
- `BootReceiver.kt` (main source set) — when `speedBumpEnabled`, attempt
  `SpeedBumpController.start(context)`. Catch `ForegroundServiceStartNotAllowedException`
  (E3) — if it throws, do nothing (the daily worker self-heal + next-foreground are the
  backstop). Add `MY_PACKAGE_REPLACED` + `QUICKBOOT_POWERON` to its intent filter (the existing
  `flutter_local_notifications` receiver already declares those; we add them to `BootReceiver`).
- `ReconciliationWorker.kt` (main source set) — refactor `yesterdayWindow` into a shared
  `DayWindowNative.windowEndingToday(resetHour, now)` object so future native callers reuse it
  (the service itself no longer needs day math — bucketing is Dart-only — but extracting it
  keeps the worker honest and testable). Self-heal: if `speedBumpEnabled` and service not
  running, `SpeedBumpController.start(ctx)` (guarded by the same E3 try/catch).
- `AndroidManifest.xml`: the **base** manifest is unchanged. A **`src/speedbump/AndroidManifest.xml`**
  adds the 3 permissions and the `<service android:name=".SpeedBumpService"
  android:foregroundServiceType="specialUse" android:exported="false">` block with the
  `<property android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE" .../>` honest
  justification, and adds `MY_PACKAGE_REPLACED`/`QUICKBOOT_POWERON` actions to `BootReceiver`'s
  filter (manifest-merge augments the base receiver).

**New native resources (speedbump source set)**
- `res/layout/speed_bump.xml` — calm full-screen bump (mascot PNG asset reused, headline, body,
  two buttons, dim background scrim).
- `res/values/strings.xml` — all native bump + notification copy (single reviewable COPY-RULE
  enforcement point; see §6).

### Dart / Flutter

**New files**
- `lib/domain/model/interception_outcome.dart` — `enum InterceptionOutcome { resisted, allowed, shown }`
  with LOCKED int indices 0/1/2 (native writes these as integers in the journal). Include a
  `static InterceptionOutcome fromIndex(int)` for the drain step.
- `lib/domain/model/interception_event.dart` — `InterceptionEvent { packageId, foregroundAt,
  outcome, recordedAt }` (DateTimes in domain; raw millis at the DB/journal edge).
- `lib/domain/interception_reconciler.dart` — pure `InterceptionReconciler.classifyDay({
  required List<int> osOpens, required List<InterceptionEvent> interceptions,
  int matchToleranceMillis = 2000 })` returning `DayState`. The heart; TDD target (§4). Plus a
  pure `InterceptionJournalLine` parse helper is NOT here (parsing lives in the DAO/drain).
- `lib/data/db/daos/interception_dao.dart` — `upsertAll(rows)`, `interceptionsForDay(pkg,
  dayStartMillis, dayEndMillis)` (range query on `foregroundAtMillis`), `daysWithInterceptions(pkg)`
  (distinct day starts with rows, for the extended finalize loop), `pruneBefore(millis)`.
- `lib/data/interception_journal.dart` — Dart side of the journal: `drainInto(InterceptionDao)`
  reads the JSONL file, parses lines, derives `dayStartMillis` in Dart via `DayWindow`, upserts
  in one transaction, then truncates the file. Robust to a partial last line (ignore unpar? no —
  keep it: only truncate up to the last fully-parsed newline, so a half-written final line is
  retained for the next drain).
- `lib/ui/speedbump/speed_bump_primer_screen.dart` — overlay-permission primer, styled like
  `permission_screen.dart`.
- `test/domain/interception_reconciler_test.dart` — pure-logic tests (§4).
- `test/data/interception_journal_test.dart` — drain/parse/truncate tests (§4).

**Edited files**
- `lib/data/db/tables.dart` — add `InterceptionEvents` table (raw integer-millis columns); add
  `speedBumpEnabled` BoolColumn to `AppSettings`.
- `lib/data/db/database.dart` — register `InterceptionEvents` + `InterceptionDao`;
  `schemaVersion => 3`; migration `from < 3` (§3).
- `lib/data/db/mappers.dart` — `InterceptionEventRow.toDomain()` /
  `InterceptionEvent.toCompanion()` via `DateTime.fromMillisecondsSinceEpoch` (NOT Drift
  `dateTime`, to avoid the seconds trap that `finalized_at` has).
- `lib/data/reconciliation_service.dart` — drain journal first; refresh prefs snapshot;
  extended finalize loop (retentionDays days ∪ all days-with-interceptions, per §0.5); the
  per-day verdict gate (§0.7); prune call (§0; G2 horizon). Add `openTimestamps` use.
- `lib/platform/usage_service.dart` — add `openTimestamps` to `UsageGateway` + impl; add a new
  `SpeedBumpController` Dart interface (`isOverlayGranted`, `openOverlaySettings`,
  `startSpeedBump`, `stopSpeedBump`, `isSpeedBumpRunning`) implemented on `UsageService`; add
  `saveSpeedBumpSnapshot(streaks, labels)` to `WorkerController` (so the reconcile can push the
  prefs snapshot through the existing channel).
- `lib/providers/providers.dart` — `overlayGrantedProvider` (FutureProvider over
  `isOverlayGranted`); `speedBumpEnabledProvider` (derived from `settingsProvider`).
- `lib/ui/root_gate.dart` — in `_onForeground`, after the existing reconcile: invalidate
  `overlayGrantedProvider`; if `speedBumpEnabled && overlayGranted && usageGranted`,
  idempotently `startSpeedBump()` (covers OEM kill + the BAL/E3 case where boot could not
  start it); if `speedBumpEnabled && !overlayGranted`, `stopSpeedBump()` and flip the setting
  off (reconciles the native self-disable from D3). All inside the existing best-effort
  try/catch.
- `lib/ui/settings/settings_screen.dart` — new "Gentle pauses" section: the toggle + handler
  (on → primer → overlay grant → persist + `saveSpeedBumpSnapshot` + `startSpeedBump`; off →
  persist + `stopSpeedBump`). Footer + honesty line (§6).
- `test/data/reconciliation_service_test.dart` — extend `FakeUsageGateway` with
  `openTimestamps`; add a fake/seeded journal + interception DAO; integration tests #12-18 (§4).
- `test/domain/streak_calculator_test.dart` — guard test #19.

---

## 3. Drift schema change + migration

`lib/data/db/tables.dart`:

```dart
@DataClassName('InterceptionEventRow')
class InterceptionEvents extends Table {
  TextColumn get packageId => text()();
  // OS MOVE_TO_FOREGROUND event timestamp — the match key (NOT detection time).
  IntColumn get foregroundAtMillis => integer()();
  // Reset-hour window start, computed in DART at drain time (never trusted from native).
  IntColumn get dayStartMillis => integer()();
  IntColumn get outcome => intEnum<InterceptionOutcome>()(); // resisted0 allowed1 shown2
  IntColumn get recordedAtMillis => integer()();

  @override
  Set<Column<Object>> get primaryKey => {packageId, foregroundAtMillis};
}
```

Add to `AppSettings`:
```dart
BoolColumn get speedBumpEnabled => boolean().withDefault(const Constant(false))();
```

`lib/data/db/database.dart`:
```dart
@DriftDatabase(
  tables: [TrackedApps, DayRecords, AppStreakStates, MetaStates, AppSettings, InterceptionEvents],
  daos: [TrackedAppsDao, DayRecordsDao, StreakCacheDao, SettingsDao, InterceptionDao],
)
...
@override
int get schemaVersion => 3;

// in MigrationStrategy.onUpgrade:
if (from < 2) {
  await m.addColumn(appSettings, appSettings.onboardingComplete);
}
if (from < 3) {
  await m.createTable(interceptionEvents);
  await m.addColumn(appSettings, appSettings.speedBumpEnabled);
}
```

Use `createTable`/`addColumn` (not `createAll`). No backfill: pre-feature days had no bumps,
their stored verdict is correct and is gated to the legacy path by `speedBumpEnabledAt`.

**Seconds vs millis (deliberate divergence, fixes the C2 trap at the schema level):**
`day_records.finalized_at` is Drift `dateTime()` which Drift stores as **seconds**. The new
table uses raw **integer millis** for `foregroundAtMillis`, `dayStartMillis`, `recordedAtMillis`
to keep millisecond precision for timestamp matching and to sidestep the seconds/millis
mismatch. Mappers use `DateTime.fromMillisecondsSinceEpoch`.

**LOCKED int indices** (native writes them directly into the JSONL journal):
`interception outcome` resisted=0, allowed=1, shown=2; `day_records.state` clean=0, slipped=1,
unverified=2 (matches the existing `DayState` enum order and `ReconciliationWorker.writeVerdicts`).

---

## 4. TDD test list (pure logic first)

`test/domain/interception_reconciler_test.dart` — `InterceptionReconciler.classifyDay`
(`matchToleranceMillis = 2000`; `osOpens` are OS event millis; interceptions carry
`foregroundAt` = the same event millis the service captured):

1. `no OS opens and no interceptions returns clean`
2. `OS open exactly matched by a resisted interception returns clean`
3. `OS open exactly matched by an allowed interception returns slipped`
4. `two OS opens both matched by resisted returns clean`
5. `two OS opens one resisted one allowed returns slipped`
6. `OS open with no interception at all returns unverified`
7. `OS open matched only by a shown interception (no outcome) returns unverified`
8. `interception 5000ms away from the OS open does not match and returns unverified`
9. `interception 1500ms away (within tolerance) does match a resisted and returns clean`
10. `one resisted-matched open plus one unmatched open returns unverified`
11. `allowed anywhere in the day dominates: returns slipped even with a resisted open present`
    (this is the explicit drop of "nearest wins" — an `allowed` is never masked by a later
    `resisted`)
12. `an allowed interception with NO corresponding OS open still returns slipped`
    (the user opened via Open-anyway; the OS log may have rolled the event off — honesty: the
    user chose to open, so the day is a slip)

`test/data/interception_journal_test.dart` — `InterceptionJournal.drainInto`:

13. `drain parses well-formed JSONL lines into upserted rows with Dart-computed dayStartMillis`
14. `drain retains a half-written final line (no trailing newline) for the next drain and does
    not lose it`
15. `drain is idempotent: draining an already-drained (empty) journal is a no-op`

`test/data/reconciliation_service_test.dart` — wired path (extend `FakeUsageGateway` with
`openTimestamps`; seed an in-memory journal + `InterceptionDao`):

16. `resisted interception keeps the completed day clean end to end`
17. `allowed interception finalizes the day as slipped and breaks the current streak`
18. `OS open with no interception after speedBumpEnabledAt finalizes as unverified not slipped`
19. `legacy fast path keeps opened equals slipped for a day whose window-end is before
    speedBumpEnabledAt`
20. `a day with interception rows that is OLDER than retentionDays is still finalized from the
    table (extended finalize loop) and a resisted-only old day stays clean` (fixes A4)
21. `pruneInterceptions drops rows for finalized days but keeps rows for the oldest
    still-unfinalized day` (fixes G2)

`test/domain/streak_calculator_test.dart`:

22. `a day classified unverified by the interception path breaks the streak exactly like a slip`

---

## 5. Build order (small, independently reviewable steps)

0. **Build flavor scaffold.** Add `base` + `speedbump` flavors and the `src/speedbump/`
   source set (empty manifest + dirs). Confirm `flutter run --flavor base` and
   `--flavor speedbump` both build. No feature code yet. Review. (Fixes D1 up front.)

1. **Domain + tests (no platform).** `interception_outcome.dart`, `interception_event.dart`,
   `interception_reconciler.dart`; tests #1-12, #22. Pure, fast, no Android. Review.

2. **Schema + DAO + mappers + migration + journal.** Add the table + `speedBumpEnabled` column,
   register + bump to schema 3, add `InterceptionDao` + mappers + `InterceptionJournal`
   (Dart drain). Run `build_runner`. Tests #13-15, #21. Review.

3. **Reconcile wiring (feature still invisible).** Add `openTimestamps` to `UsageGateway` +
   `UsageService` + the Kotlin `getOpenTimestamps` + `UsageQuery.openTimestamps` (sharing
   `isOpenEvent`, fixes G1). Add `saveSpeedBumpSnapshot` channel method + `WorkerConfig`
   getters. Rewire `_reconcileApp`: drain journal → refresh snapshot → extended finalize loop
   (§0.5) → per-day gate (§0.7) → prune (§0/G2). Tests #16-20. Review.

4. **Native detection core (no service/overlay).** `UsageQuery.latestForegroundOpen`,
   `Journal.kt` (append-only JSONL), `DayWindowNative` refactor of the worker. Verify journal
   format round-trips through the Dart drain with a tiny manual harness. Review.

5. **Native overlay UI.** `res/layout/speed_bump.xml` + `strings.xml` + `OverlayController`
   (show/remove, button handlers, reads prefs snapshot, writes journal lines, reuses identical
   `foregroundAtMillis`). Add overlay permission to the speedbump manifest. Review the layout
   against the design system (mascot + tokens, §8).

6. **The foreground service + B1 spike gate.** `SpeedBumpService` (poll loop, screen receiver,
   notification, edge trigger with persisted state + restart grace per B3). Speedbump manifest:
   FGS permissions + `<service specialUse>`. `MainActivity`/`SpeedBumpController` start/stop/
   running + overlay methods. **Before going further, validate on the HONOR device (B1):**
   does "Stay strong" actually leave the tracked app? Also measure real query-event latency
   (B2). Record results; pick the B1 fallback if needed (§7). Review on-device.

7. **Dart control + consent.** `SpeedBumpController` (Dart), `overlayGrantedProvider`,
   `speed_bump_primer_screen.dart`, Settings "Gentle pauses" section + handler, `root_gate`
   foreground start/stop + revoke reconciliation (D3). Review the full opt-in flow end to end.

8. **Resilience.** `BootReceiver` restart (with E3 try/catch) + `MY_PACKAGE_REPLACED` /
   `QUICKBOOT_POWERON`; `ReconciliationWorker` self-heal restart. Review survival across
   reboot / app-update / force-stop on HONOR; confirm the daily worker is the real backstop if
   boot-start throws (E3).

---

## 6. User-facing copy (final, plain English — COPY RULE enforced)

No em dashes, no en dashes, no curly/unicode quotes or symbols. Short, calm, human. Verify
`strings.xml` and all Dart strings contain zero of: `—  –  ’  ‘  “  ”`.

**Speed bump (native `speed_bump.xml`, bound at show time from the prefs snapshot)**
- Headline: `You're on a {N}-day {app} streak.`
- Body: `Opening it ends the run. Take a breath first.`
- Primary button: `Stay strong`
- Secondary button: `Open anyway`

Rules:
- `{N}` is the cached current streak from the prefs snapshot. For `N == 1` use the literal
  `You're on a 1-day {app} streak.` (no special-casing).
- **Honesty guard (G3):** if the snapshot streak for the app is `0` (or missing), do NOT claim
  a run is at stake. Show the neutral variant instead:
  - Headline: `Opening {app}?`
  - Body: `Take a breath first. You can still walk away.`
  This prevents the bump from ever saying "ends the run" when there is no run.
- `{app}` is the tracked app's display name from the snapshot.

**Foreground-service notification** (channel `IMPORTANCE_LOW`, silent, ongoing; tap opens Cairn
Settings)
- Channel name: `Gentle pauses`
- Title: `Gentle pauses are on`
- Text: `Tap to manage in Settings.`

(F2 fix: dropped "watching"/"watching your streaks".)

**Overlay-permission primer screen** (`speed_bump_primer_screen.dart`)
- Title: `Want a gentle pause before you open an app?`
- Body: `When you open an app you're keeping a streak on, Cairn can show a short, calm
  reminder first. You decide what happens next. Stay away, or open it anyway. Cairn never
  blocks you.`
- Bullets:
  - `Shows only for apps you're already tracking.`
  - `Cairn checks which app you just opened, only to show this pause. It is never sent
    anywhere.`  (D2 fix: plain prominent-disclosure line.)
  - `Two clear choices every time, including a plain Open anyway.`
  - `Runs quietly in the background, so it needs a small status notice.`
- "What Cairn needs" sub-block:
  - `DRAW OVER OTHER APPS`
  - `This lets Cairn show the pause on top of the app you opened. It does not read what is on
    your screen and it does not touch the app itself.`
  - `A QUIET BACKGROUND NOTICE`
  - `So your phone keeps Cairn running, you will see a small ongoing notice that the pause is
    on. You can turn the whole thing off any time, right here in Settings.`
  - `NOTHING LEAVES YOUR PHONE`
  - `Same as the rest of Cairn. No account, no servers, no tracking of what you do.`
- Primary button: `Turn it on`
- Caption (default): `Opens your phone settings. Turn off anytime.`
- Caption (returned without granting): `Cairn still needs permission to show the pause.`

**Settings ("Gentle pauses" section)**
- Section label: `Gentle pauses`
- Toggle title: `Speed bump`
- Toggle subtitle: `A short pause before a tracked app opens`
- Footer: `When you open an app you are keeping a streak on, Cairn shows a calm reminder
  first. You can always open it anyway. It never blocks you.`
- Honesty line (shown under the toggle when enabled): `On some phones the system may stop
  Cairn in the background. If pauses stop appearing, open settings and allow Cairn to run.`

**Unverified-break recap (NEW string, fixes the A1 copy gap).** When a streak breaks because
our own service could not vouch (an OS open with no matching resisted interception), the recap
/ moment copy must say we could not verify, not that the user opened it:
- Recap line (unverified day): `We could not check {app} on this day. The run is paused, not
  broken by you.`
- (The existing slipped copy "you opened it" stays only for `allowed` / legacy-`slipped` days.)

`F3 note for product (not a code change):` "Stay strong" is a LOCKED label but invokes the
willpower framing the brand otherwise rejects. Flagged; kept as locked.

---

## 7. Risks + open questions (with the decision taken)

**B1 [BLOCKER until spiked] "Stay strong" leaving the app.** The HOME launch from the service
is BAL-restricted on Android 14/15 + HONOR; if dropped, "Stay strong" removes the overlay and
strands the user in the tracked app. **Decision:** step 6 is a hard spike gate. Try
`startActivity(HOME, FLAG_ACTIVITY_NEW_TASK)` from the `specialUse` FGS while holding
`SYSTEM_ALERT_WINDOW` (overlay permission sometimes grants implicit BAL allowance). If HONOR
honours it, done. Fallbacks, in order: (a) keep the overlay up and replace its content with a
"You're away. Tap to go home." panel backed by a user-tap `PendingIntent` (a tap is a fresh BAL
allowance); (b) move the user via the launcher's `PendingIntent`. Do not build steps 7-8 until
B1 is proven on-device.

**B2 [HIGH] Poll latency + battery throttling on MTK.** `queryEvents` batches commits, so a
just-happened open can take 1-10s to appear; the bump is best-effort and frequently late.
Poll at ~1000ms (not 800ms) to reduce wakeups; hard-stop on screen-off (done). **Decision:**
copy never promises "1-2s"; messaging is "a short pause," and the honesty line covers
background-kill gaps. Measure real latency in step 6.

**B3 [HIGH] Edge state resets on OEM kill → bump re-fires over a just-chosen app.** **Decision:**
persist `lastForegroundPackage` + last `allowed (pkg, fg)`; on restart suppress re-fire within
`restartGraceMillis = 8000` if the same package was `allowed` and is still foreground (§0.11).
Documented narrow exception to "no grace period."

**C1 [resolved] Cross-process SQLite/WAL corruption.** Resolved by §0.2: native writes an
append-only JSONL journal; Dart is the only SQLite writer. No second SQLite library touches the
WAL file on the hot path.

**C2/C3 [resolved] Day-boundary skew + key drift.** Resolved by §0.3 (match on the real OS
event timestamp, reuse the identical value for the outcome line) and §0.6 (day bucketing only
in Dart). The native `dayStartMillis` is not used for bucketing; it is computed in Dart at
drain time.

**A1 [accepted, honestly] "Stay strong" can still end as `unverified` if the OS log retains a
later, unwatched open while our service was dead.** This is correct and honest: the user
resisted every bump they were *shown*, but an open we could not vouch for happened. **Decision:**
ship the dedicated unverified-break recap copy (§6) so it never reads as "you slipped." Confirm
with product that breaking honestly (vs leaving the streak intact) is desired when our own
service died — current decision: break honestly, label as unverified.

**D1 [resolved] Play policy minefield.** Resolved by §0.10: build flavor; the Play APK never
contains `SYSTEM_ALERT_WINDOW` / `specialUse`. The `speedbump` flavor ships via F-Droid /
sideload with an honest `PROPERTY_SPECIAL_USE_FGS_SUBTYPE` and Console note if ever submitted.

**D2 [resolved] Prominent disclosure.** Resolved by the primer bullet "Cairn checks which app
you just opened..." (§6).

**D3 [resolved] Overlay revoked while only the service is alive.** Native catches the `addView`
failure, sets `speedBumpEnabled=false`, `stopSelf()`; Dart reconciles the setting on next
foreground (`root_gate`). No silent dead polling.

**E1 [documented, not a regression] Cross-04:00 continuous use.** A single "Open anyway"
session straddling the reset hour leaves the new day with no `MOVE_TO_FOREGROUND` inside its
window, so the new day reads `clean` even though the app was open at 04:15. This is pre-existing
v1 behaviour; the bump does not change it. Documented limit, not a fix.

**E2 [resolved] `speedBumpEnabledAt` lost on toggle.** Resolved by §0.7: set once, never
cleared.

**E3 [HIGH] FGS start from BOOT may throw on HONOR.** Starting a `specialUse` FGS from
`BOOT_COMPLETED` may raise `ForegroundServiceStartNotAllowedException`. **Decision:** wrap the
boot/self-heal start in try/catch; if it throws, the daily worker self-heal and next-foreground
start are the real backstop, and the honesty line tells the user pauses may stop until they
open Cairn. Streak accuracy is unaffected (reconcile is retroactive).

**G1 [resolved] `openTimestamps` vs `openedPackages` divergence.** Resolved by §0.8: one shared
`isOpenEvent` predicate; cross-check test asserting
`openTimestamps(pkg).isNotEmpty == openedPackages([pkg]).contains(pkg)` for the same window.

**G2 [resolved] Prune horizon.** `pruneInterceptions` deletes rows strictly older than the
oldest still-unfinalized day with interceptions (never prunes a day lacking a finalized
`DayRecord`). Test #21.

**G3 [resolved] Stale/zero cached streak in the bump.** The snapshot may lag by one reconcile;
acceptable. The zero/missing-streak honesty guard (§6) ensures the bump never claims a run when
there is none.

**A4/A5 [resolved] Happy path breaks on retention window.** Resolved by §0.5: the finalize loop
covers all days with interception rows regardless of `retentionDays`, and interception-bearing
days are reconcilable from table + snapshot alone. Test #20.

**Visual drift between native bump and Flutter design system.** The bump is the only
native-rendered screen. Reuse the mascot PNG asset and hardcode the same color/type tokens in
`speed_bump.xml`; budget a design pass in step 5.

---

Key absolute paths referenced:
`c:\Users\Zansuken\code\projects\cairn\lib\data\reconciliation_service.dart`,
`c:\Users\Zansuken\code\projects\cairn\lib\data\db\tables.dart`,
`c:\Users\Zansuken\code\projects\cairn\lib\data\db\database.dart`,
`c:\Users\Zansuken\code\projects\cairn\lib\data\db\mappers.dart`,
`c:\Users\Zansuken\code\projects\cairn\lib\platform\usage_service.dart`,
`c:\Users\Zansuken\code\projects\cairn\lib\providers\providers.dart`,
`c:\Users\Zansuken\code\projects\cairn\lib\ui\root_gate.dart`,
`c:\Users\Zansuken\code\projects\cairn\android\app\src\main\kotlin\dev\cairn\UsageQuery.kt`,
`c:\Users\Zansuken\code\projects\cairn\android\app\src\main\kotlin\dev\cairn\MainActivity.kt`,
`c:\Users\Zansuken\code\projects\cairn\android\app\src\main\kotlin\dev\cairn\ReconciliationWorker.kt`,
`c:\Users\Zansuken\code\projects\cairn\android\app\src\main\kotlin\dev\cairn\WorkerConfig.kt`,
`c:\Users\Zansuken\code\projects\cairn\android\app\src\main\kotlin\dev\cairn\BootReceiver.kt`,
`c:\Users\Zansuken\code\projects\cairn\android\app\src\main\AndroidManifest.xml`,
`c:\Users\Zansuken\code\projects\cairn\android\app\build.gradle.kts`.

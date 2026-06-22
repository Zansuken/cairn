# Cairn on iOS — feasibility spike

**Status:** research spike, 2026-06-22. No code written. Purpose: decide *whether* and *how* Cairn can ship on iOS, and surface what does **not** translate from the Android build before any investment.

**Bottom line:** The **core streak mechanic is feasible** on iOS via Apple's Screen Time APIs (Family Controls + Device Activity), but with **lower fidelity** and **different data**. The **real-time calm speed bump (Streak guard) does not translate** — iOS only offers a *blocking* shield, which directly contradicts Cairn's "no blocking, no willpower battles" promise. iOS is **not a port; it is a re-architecture of the detection layer** behind the same pure-Dart domain, gated on an **Apple entitlement approval** (days to weeks, not guaranteed). Recommended: ship Android first; treat iOS as a separate track that starts with the entitlement request.

---

## 1. The iOS capability model

iOS forbids an app from seeing which other apps you open. The only sanctioned path is the **Screen Time API** family (iOS 15+, the parts Cairn needs are iOS 16+):

| Framework | What it gives us | Where it runs |
|---|---|---|
| **FamilyControls** | Authorization + the system app picker (`FamilyActivityPicker`) returning **opaque tokens** | Main app |
| **DeviceActivity** | Schedule daily intervals; fire an event when a selected app crosses a **usage threshold** | A sandboxed **DeviceActivityMonitor** app extension |
| **ManagedSettings** | Apply restrictions — most relevantly **shield (block)** selected apps | Main app + extensions |
| **ManagedSettingsUI / ShieldConfiguration** | Customize the block screen (title/subtitle/icon/buttons) | A **ShieldConfiguration** extension |
| **ShieldAction** | Handle taps on the block screen's buttons | A **ShieldAction** extension |
| **DeviceActivityReport** | Show usage charts — but only inside a sandboxed SwiftUI extension whose data the host app **cannot read out** | A **DeviceActivityReport** extension |

**Authorization:** `AuthorizationCenter.shared.requestAuthorization(for: .individual)` (iOS 16+) lets an **adult monitor their own device** with no Family Sharing parent/child pairing — exactly Cairn's self-managed wellbeing use case. (iOS 15 only had `.child`, which would have been a blocker.) **→ iOS minimum would be 16.0.**

---

## 2. The two hard constraints that shape everything

1. **Apps are opaque tokens — no names, no icons, no bundle IDs.** The user picks apps through *Apple's* `FamilyActivityPicker`; we receive cryptographic `ApplicationToken`s and can only render them via a system `Label(token)` SwiftUI view. We **cannot** build our own "pick your apps" grid with icons + search + a curated suggestions list. (Verified: tokens are "cryptographically opaque… all information is hidden.")
2. **No real-time "app was just opened" event, and no overlay.** DeviceActivity tells us *after* usage crosses a threshold (via a background extension); it cannot present UI. The only in-the-moment mechanism is the **shield**, which **blocks** the app. There is also **no supported way for an extension to launch our app** (only fragile deep-link/notification workarounds).

---

## 3. Feature-by-feature mapping (Android → iOS)

| Cairn feature (Android today) | iOS status | Mechanism / caveat |
|---|---|---|
| **Streak for days you don't open an app** | ✅ **Feasible, lower fidelity** | One `DeviceActivityEvent` per tracked app with a small usage **threshold** over a daily interval. Event fires → that day **slipped**; interval ends without firing → **clean**. |
| Detect the *exact* moment/open | ⚠️ **Degraded** | Detection is **threshold-based** (reliable ~1 min of use), not "opened at all." A 10-second peek may not register → could read as clean. No per-open timestamps. |
| Custom day reset hour (04:00) | ✅ | `DeviceActivitySchedule` with `intervalStart`/`intervalEnd` DateComponents. |
| "Pick your apps" grid (icons, names, search, curated) | ❌ **Not possible** | Must use Apple's `FamilyActivityPicker`; no names/icons/curation. UX must change. |
| App names/icons in Home, Manage, recap | ❌ **Not as-is** | Can only show apps via system `Label(token)`. Our rows/hero that print names + monograms need rethinking. |
| **Streak guard — calm, non-blocking speed bump** | ❌ **Not as-is** | iOS has no overlay. Closest = a **blocking shield** (Apple-styled modal, limited custom copy). Contradicts the "no blocking" brand (see §4). |
| "Open anyway" / "Stay strong" honesty (resisted/allowed) | ⚠️ **Partial** | Mappable onto shield buttons (primary = stay / `resisted`, secondary = unshield + `allowed`), but it is a block screen and **can't relaunch the app** — user must re-tap the icon. |
| Daily reconciliation + verdicts in Drift | ✅ | The DAM extension writes verdicts to a shared **App Group**; the Flutter app drains them into Drift — the **same pattern** as the Android JSONL journal. |
| On-device only, no backend | ✅ | Screen Time data never leaves the device; aligns perfectly with Cairn's privacy stance. |
| Pure-Dart domain (StreakMath, reconciler, recap) | ✅ **Reused as-is** | Platform-agnostic; no change. |
| Daily summary notification | ✅ | `flutter_local_notifications` already cross-platform. |
| Foreground service / boot self-heal | ➖ **N/A** | iOS schedules the DAM extension itself; no foreground service. Different reliability profile (Apple-managed; documented callback-reliability bugs exist). |
| Launcher icon / splash | ✅ | Standard iOS app icon + launch screen. |

---

## 4. The brand conflict (the most important finding)

Cairn's onboarding literally promises: *"No blocking, no willpower battles."* On iOS, the **only** in-the-moment intervention is the **shield, which blocks**. So we must pick a stance:

- **Model A — Measure, don't intervene (recommended, on-brand).** Don't shield anything. Use DeviceActivity purely to *observe* usage and keep the **honest streak**. The only nudges are after-the-fact: the daily summary and "your streak broke" notifications. This keeps Cairn's calm, non-blocking identity intact and the streak meaningful. **Cost:** no in-the-moment guard on iOS at all.
- **Model B — Shield-based speed bump.** Shield tracked apps so opening one shows a custom block screen ("Stay strong" / "Open anyway"). **Cost:** it is *blocking* (contradicts the brand), Apple-styled with limited customization, "Open anyway" can't relaunch the app (re-tap friction), and **a shielded app reads as 0 usage → the streak becomes "did you press Open anyway," not "did you stay away."** This muddies the honesty mechanic.

**Recommendation:** ship iOS as **Model A**. It is the honest, on-brand subset. Revisit a shield-based guard later as an explicit, separately-framed feature if users ask.

---

## 5. Proposed iOS architecture (maximize reuse)

```
Flutter app (Dart)  ── unchanged ──>  pure-Dart domain + Drift  (StreakMath, reconciler, recap, UI*)
        │  MethodChannel "cairn/screentime"
        ▼
Swift platform layer (iOS)
        │  FamilyControls authorization + FamilyActivityPicker (returns tokens)
        │  DeviceActivityCenter.startMonitoring(schedule, events:[per-app threshold])
        ▼
DeviceActivityMonitor extension  ──writes verdicts──>  App Group container (shared)
                                                              │
Flutter app drains App Group  ──>  Drift  (same drain pattern as Android's JSONL journal)
```

- **Reused unchanged:** the entire `lib/domain/` layer, Drift schema/DAOs, recap logic, notifications, most providers/state. The verdict-via-shared-store→drain pattern already exists for Android — iOS slots into the same `ReconciliationService` shape behind a new gateway.
- **New (Swift):** a `ScreenTimeService` (MethodChannel peer of `UsageService`) + a **DeviceActivityMonitor** app-extension target (and, only for Model B, **ShieldConfiguration** + **ShieldAction** extensions). Extensions are pure Swift (no Flutter), share data via an **App Group**.
- **Must change in the UI:** the "pick your apps" flow → wrap `FamilyActivityPicker`; anywhere we render app names/icons → render via tokens. The streak visuals, hero, recap copy stay.
- **Entitlements:** `com.apple.developer.family-controls` (app **and** every extension) + an **App Group**. Min iOS **16.0**.

---

## 6. Distribution & entitlement risk (a gating dependency)

- The `com.apple.developer.family-controls` entitlement must be **requested from Apple** and approved **before TestFlight or App Store** (both use distribution profiles). The **same request must cover each extension** (DAM, ShieldConfiguration, ShieldAction).
- Approval timeline is **variable**: reports range from ~4 business days to ~4.5 weeks, with sometimes-unclear status. **Start this request early — it can block everything else.**
- Apple scrutinizes Screen Time apps. Self-monitoring wellbeing apps in Cairn's category (e.g. one sec, Opal, Jomo) have been approved, so Cairn has a reasonable case, but **approval is not guaranteed**.
- Known API pain points to expect (developer-reported): occasional token re-generation breaking context, shields not refreshing across stores, DAM callback delays/misses. Build for eventual-consistency, not real-time precision.

---

## 7. Effort & recommended sequencing

This is a **large** workstream, not an add-on:

1. **(Gating) Request the Family Controls entitlement** — submit immediately; it runs in the background while other work proceeds.
2. **Spike 1 — authorization + picker + detection** (Swift): `.individual` auth, `FamilyActivityPicker`, one DeviceActivityEvent, DAM extension writing a verdict to an App Group, drained into Drift. Proves the streak mechanic end-to-end on a device.
3. **Decide Model A vs B** (§4) with the verdict spike in hand.
4. **UI rework** for opaque tokens (picker + token labels) — the biggest Dart-side change.
5. **Wire the iOS gateway** into the existing `ReconciliationService`; reuse the domain + Drift untouched.
6. **(Model B only)** ShieldConfiguration + ShieldAction extensions.
7. QA on real devices (Screen Time behaves differently in Simulator).

**Recommended order overall:** finish and ship **Android → Play** first (it is close and already cross-OEM). Run the iOS entitlement request and Spike 1 in parallel so the riskiest unknowns (approval + detection fidelity) are de-risked before committing to the full iOS build.

---

## 8. Open questions to resolve in Spike 1

- What is the **smallest reliable threshold**? Confirms how close iOS "slipped" detection gets to Android's "opened at all."
- **DAM callback reliability** in practice (missed/delayed `eventDidReachThreshold` / `intervalDidEnd`) and how it affects the honest streak.
- Event/monitored-activity **count limits** vs. how many apps a user can track.
- App Group drain timing — when does the Flutter app reliably get to read the extension's writes (foreground only? background task?).
- Exact **reset-hour** modeling with `DeviceActivitySchedule` across DST.

---

## 9. Sources

- [Family Controls — Apple Developer Documentation](https://developer.apple.com/documentation/familycontrols)
- [Configuring Family Controls — Apple Developer Documentation](https://developer.apple.com/documentation/xcode/configuring-family-controls)
- [Device Activity — Apple Developer Documentation](https://developer.apple.com/documentation/deviceactivity)
- [Meet the Screen Time API — WWDC21](https://developer.apple.com/videos/play/wwdc2021/10123/)
- [A Developer's Guide to Apple's Screen Time APIs — Julius Brussee](https://medium.com/@juliusbrussee/a-developers-guide-to-apple-s-screen-time-apis-familycontrols-managedsettings-deviceactivity-e660147367d7)
- [Take Family Control to Production/Distribution — Itsuki](https://medium.com/@itsuki.enjoy/swift-ios-take-family-control-to-production-distribution-83da9b3346c6)
- [The Device Activity Monitor Extension — letvar](https://letvar.medium.com/time-after-screen-time-part-3-the-device-activity-monitor-extension-284da931391b)
- [State of the Screen Time API 2024 — Frederik Riedel](https://riedel.wtf/state-of-the-screen-time-api-2024/)
- [Monitoring App Usage using the Screen Time API — Crunchy Bagel](https://crunchybagel.com/monitoring-app-usage-using-the-screen-time-api/)
- Apple Developer Forums: [Family Controls request form](https://developer.apple.com/forums/thread/735888), [Open parent app from ShieldAction](https://developer.apple.com/forums/thread/719905)

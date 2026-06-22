# Cairn - Google Play Permissions and Sensitive API Justifications

Cairn is an on-device habit-streak app. It has no accounts, no servers, and no network transmission capability. There is no INTERNET permission in the release manifest, and the project pulls in no HTTP, networking, analytics, telemetry, or crash-reporting libraries. All personal and usage data is stored only in the app's private on-device storage (SQLite database and a local journal file). Every permission below exists to power a local feature; none of them moves data off the device.

---

## Usage Access (android.permission.PACKAGE_USAGE_STATS)

What it does: Reads the system usage event log through `UsageStatsManager.queryEvents()` to detect when a tracked app was brought to the foreground.

Why the core feature needs it: Cairn's entire purpose is to track "no-open" streaks for apps the user chooses. The only reliable way to know whether a tracked app was opened is the OS usage event log. The daily reconciliation worker reads these events to compute each day's verdict (clean, slipped, or unverified), and the in-the-moment speed-bump reads the same source to know when a tracked app just came forward. There is no alternative API that provides this signal.

User benefit: The user gets accurate daily streak verdicts and the optional pause prompt without manually logging anything. The usage data is read on-device and stored on-device; it is never transmitted.

This is special access, granted by the user in system settings.

---

## Display Over Other Apps (android.permission.SYSTEM_ALERT_WINDOW)

What it does: Draws the intervention speed-bump overlay (a brief pause modal) on top of a tracked app using a `TYPE_APPLICATION_OVERLAY` window.

Why the core feature needs it: The speed-bump is the in-the-moment intervention. When the user opens an app they are keeping a streak on, Cairn shows a calm pause over that app so the user can decide to back out or continue. Showing UI over another app is only possible with an overlay window, so this permission is required for that feature to exist.

User benefit: A short, intentional pause at the moment of opening, giving the user a real chance to reconsider before breaking a streak. The feature is opt-in, and the permission is granted by the user in system settings.

---

## Foreground Service (android.permission.FOREGROUND_SERVICE)

What it does: Runs the speed-bump watcher as a foreground service so it can observe foreground app changes while the screen is on.

Why the core feature needs it: To show the pause overlay at the right moment, the watcher must keep checking which app is in the foreground (it polls roughly once per second while the screen is on, and stops polling when the screen is off). Reliable, ongoing monitoring of this kind requires a foreground service rather than background work that the system would suspend.

User benefit: The pause appears promptly and consistently when a tracked app is opened, instead of being missed because the OS paused background work.

---

## Special-Use Foreground Service (android.permission.FOREGROUND_SERVICE_SPECIAL_USE)

What it does: Declares the speed-bump watcher with the `specialUse` foreground service type and a documented subtype property describing the behavior.

Why the core feature needs it: The watcher's job (presenting a user-enabled on-screen pause when a tracked app is opened) does not fit any of the standard predefined foreground service types such as location, media playback, or data sync. `specialUse` is the correct declaration for this intervention behavior. The manifest property documents exactly what the service does: it shows a brief, user-enabled pause when the user opens an app they are keeping a no-open streak on, then steps aside, and detection relies on the existing on-device Usage Access with nothing leaving the device.

User benefit: Truthful, scoped declaration of why the service runs. The service does only what the subtype states, and is opt-in with the speed-bump feature.

specialUse subtype summary: Shows a brief, user-enabled on-screen pause when the user opens a tracked app they are keeping a no-open streak on, then steps aside. Detection uses on-device Usage Access only; no data leaves the device.

---

## Ignore Battery Optimizations (android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)

What it does: Shows the system dialog asking the user to exempt Cairn from battery optimization.

Why the core feature needs it: On aggressive OEM battery managers, the speed-bump watcher can be killed in the background, which means the pause silently stops working. Requesting the exemption lets the watcher keep running so the intervention remains reliable on those devices.

User benefit: The pause feature keeps working on phones that would otherwise kill it, so the user is not left with a feature that quietly fails. The request is an opt-in dialog the user can decline.

---

## Run at Boot (android.permission.RECEIVE_BOOT_COMPLETED)

What it does: Receives the boot-completed broadcast so Cairn can restore its scheduled work after a reboot.

Why the core feature needs it: Streaks are evaluated by a daily reconciliation worker, and the daily summary notification is scheduled work. A device reboot clears scheduled jobs, so without this the daily verdict and summary would stop after the next restart. On boot, Cairn reschedules the daily reconciliation worker and restarts the speed-bump watcher.

User benefit: Daily streak tracking and the daily summary keep working across reboots with no action from the user.

---

## Notifications (android.permission.POST_NOTIFICATIONS)

What it does: Posts notifications: the once-a-day morning summary, and the ongoing foreground notification for the speed-bump watcher.

Why the core feature needs it: The daily summary is how Cairn reports the previous day's streak results. On Android 13 and above, posting any notification requires this runtime permission. The speed-bump foreground service also requires an ongoing notification while it runs, as mandated by the foreground service model.

User benefit: The user gets one calm daily summary of their streaks, and a required, low-importance indicator while the optional pause watcher is active. Both are local; nothing is sent anywhere.

---

## Data and network summary

- No INTERNET permission is declared in the release manifest. Network transmission is architecturally impossible.
- No HTTP clients, networking libraries, analytics, telemetry, or crash-reporting SDKs are present.
- ACCESS_NETWORK_STATE may appear via a dependency but is not used by app code to transmit anything.
- All data (tracked apps, daily records, streaks, settings, interception events, and the native journal) lives only in the app's private on-device storage.
- The `analyticsOptIn` setting is a dormant schema field defaulting to false, with no data-collection logic behind it.

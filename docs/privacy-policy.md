# Privacy Policy for Cairn

Cairn runs entirely on your device and does not collect, transmit, or share any of your data.

Last updated: 2026-06-22

## Summary

Cairn is an on-device only app. Everything Cairn records stays in the app's private storage on your phone. The app has no internet permission and contains no networking code, so it is not technically able to send your data anywhere.

## What Cairn does NOT collect or transmit

- Cairn does not have the Android INTERNET permission. It is not declared in the app's release manifest, so the app cannot transmit data off the device.
- Cairn contains no HTTP/HTTPS clients, sockets, or networking libraries. There is no code that uploads data, calls a remote API, or syncs to a server or cloud.
- Cairn has no accounts and no sign-in. You do not create an account to use the app.
- Cairn includes no analytics, no crash reporting, no telemetry, and no tracking. There are no analytics, crash-reporting, or advertising SDKs in the app.
- Cairn does not access your camera, microphone, location, contacts, calendar, or SMS. None of those permissions are requested.

Note: there is a settings field named "analyticsOptIn" stored in the local database. It defaults to false and is a leftover schema field with no data-collection logic behind it. Cairn collects no analytics regardless of its value.

## What is stored locally, and why

All of the following data is stored only in Cairn's private storage on your device (the app's files directory, for example /data/data/io.github.zansuken.cairn/files/cairn.sqlite, and the app's private SharedPreferences). None of it leaves your device.

- **Tracked apps**: the package ID and display name of each app you choose to track, when you added it, and its status (active or freed, including an uninstall timestamp). This is what you asked Cairn to watch.
- **Daily streak records**: per app, the day window and the daily verdict (clean, slipped, or unverified) and when that verdict was computed. This is how Cairn tracks your progress over time.
- **Cached streak metrics**: per app, your current streak, best streak, and lifetime clean days. These are derived from your daily records and can be recomputed from them.
- **Cross-app meta streaks**: your current and best streak across all tracked apps, and the number of days when all tracked apps stayed clean.
- **App settings**: your preferences, including the day reset hour, whether notifications are enabled, the daily summary time, whether milestones are enabled, whether the speed-bump is enabled (and when it was first enabled), and whether onboarding is complete.
- **Speed-bump interception events**: when a tracked app was opened, the day window it fell in, the outcome (you backed out, you opened it anyway, or the pause was shown with no choice recorded), and when the event was recorded. This is how Cairn measures the speed-bump intervention.
- **Native interception journal**: a local append-only file (cairn_interceptions.jsonl) in the same private directory that briefly records interception events written by the overlay. Its contents are drained into the local database and the file is truncated after each drain.
- **Worker configuration**: a private SharedPreferences entry holding the list of tracked package IDs, the reset hour, the database path, cached streaks and labels for the overlay, whether the speed-bump is on, and a short-lived note of the last app you chose to open (used to avoid re-firing the pause after a restart).

This data exists so Cairn can show you your streaks, run the daily reconciliation, and show the speed-bump pause. It is used only on your device.

## Permissions Cairn uses, and why

Cairn requests the following Android permissions. Each is used by the app for the stated purpose only.

- **PACKAGE_USAGE_STATS** (usage access): Reads the system usage event log to detect when a tracked app comes to the foreground. This is what makes the daily reconciliation and the speed-bump pause work. The usage data is read on the device and stays on the device.
- **RECEIVE_BOOT_COMPLETED**: Reschedules the daily reconciliation worker and restarts the speed-bump watcher after the device reboots.
- **POST_NOTIFICATIONS**: Sends the daily morning summary notification and the speed-bump foreground service notification (the runtime notification permission on Android 13 and newer).
- **SYSTEM_ALERT_WINDOW** (draw over other apps): Draws the speed-bump pause overlay on top of a tracked app when you open it.
- **FOREGROUND_SERVICE**: Lets the speed-bump watcher run as a foreground service while the screen is on so it can notice when the foreground app changes.
- **FOREGROUND_SERVICE_SPECIAL_USE**: Declares the speed-bump service as a special-use foreground service for the intervention pause.
- **REQUEST_IGNORE_BATTERY_OPTIMIZATIONS**: Lets you exempt Cairn from battery optimization so the speed-bump watcher is not killed in the background by aggressive battery management.

Cairn's compiled manifest also includes a few permissions that come from dependencies rather than from Cairn's own features: ACCESS_NETWORK_STATE (which only checks whether a network is available and cannot transmit data), VIBRATE, and WAKE_LOCK (added by the flutter_local_notifications library), plus a private signature-level permission whose name ends in DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION (added automatically by AndroidX to protect a broadcast receiver that Cairn registers internally; it is held only by Cairn itself and grants nothing to other apps). None of these transmit any data.

## Opening links and sharing

Cairn can open a link in your device's browser, such as the link to its source code or a page to leave an optional tip. When it does, your browser handles the connection and Cairn passes only the web address, sending none of your data.

Cairn can also hand a short text recap of a summited cairn to your device's share sheet, where you choose which app receives it. Cairn only prepares the text; the app you pick does the sending.

In both cases Cairn itself still has no internet permission, and nothing is sent unless you choose to send it.

## No third parties, no analytics, no ads

Cairn does not include any third-party data SDKs. There are no analytics, crash-reporting, telemetry, or advertising components. No data is shared with any third party, because no data leaves your device.

## Children

Cairn does not collect any data from anyone, including children. There is no account, no sign-in, and no transmission of data off the device.

## Security

Your data stays on your device. It is kept in Cairn's private app storage (the app's files directory and private SharedPreferences) and is not sent over a network. Because Cairn has no internet permission and no networking code, the app is not able to transmit your data off the device.

## Changes to this policy

If this policy changes, the updated version will be published in the app's source repository at https://github.com/Zansuken/cairn with a new "Last updated" date. Because Cairn is open source under the GPL-3.0 license, you can review the code and the history of this policy there.

## Contact

If you have questions about this policy or about Cairn, contact the developer at doom.sebastien.pro@gmail.com.

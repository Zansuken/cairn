# Cairn - Google Play Data Safety Form Answers

## Summary answer

**Does this app collect or share user data? No.**

Under Google Play's definitions, data is "collected" only when it is transmitted off the device, and "shared" only when it is transferred to a third party. Cairn does this for nothing. The app has no INTERNET permission in any manifest (only ACCESS_NETWORK_STATE, which can read network status but cannot transmit), no HTTP/networking libraries in its dependencies, and no remote API, upload, socket, or transmission code anywhere in the source. All data lives in the app's private on-device storage (a SQLite file, an append-only JSONL journal, and private SharedPreferences). On-device-only storage is not "collected" and not "shared" under Play's rules.

---

## Data collection and sharing decision

- [x] **Does your app collect or share any of the required user data types?** -> **No**
  - Reason: No INTERNET permission is declared or merged in any manifest, so network transmission is architecturally impossible. There are no networking packages in pubspec.yaml and no transmission code in lib/ or the native Android sources. Everything is stored only in the app's private directory.

---

## Per-category answers (collected = transmitted off device)

- [x] **Location** -> Collected: **No**
  - The app declares no ACCESS_FINE_LOCATION or ACCESS_COARSE_LOCATION permission, contains no location code, and has no INTERNET permission, making network transmission impossible.

- [x] **Personal info** (name, email, user IDs, address, phone, etc.) -> Collected: **No**
  - No accounts and no sign-in. The app stores user-selected tracked-app package IDs and display names, but only in the on-device SQLite database. The app has no INTERNET permission, so even if it accessed this data, it could not transmit it.

- [x] **Financial info** -> Collected: **No**
  - No payment, purchase, or financial data is handled. The app has no INTERNET permission and no networking libraries.

- [x] **Health and fitness** -> Collected: **No**
  - No health or fitness data is handled. The app has no INTERNET permission and no networking libraries.

- [x] **Messages** (emails, SMS/MMS, other in-app messages) -> Collected: **No**
  - The app declares no READ_SMS or messaging permissions and contains no message data code. The app has no INTERNET permission.

- [x] **Photos and videos** -> Collected: **No**
  - The app declares no CAMERA permission and contains no media access code. The app has no INTERNET permission.

- [x] **Audio files** (voice/sound recordings, music) -> Collected: **No**
  - The app declares no RECORD_AUDIO permission and contains no audio handling code. The app has no INTERNET permission.

- [x] **Files and docs** -> Collected: **No**
  - The app writes only to its own private app directory (/data/data/dev.cairn/files/cairn.sqlite and /data/data/dev.cairn/files/cairn_interceptions.jsonl). These are internal app storage, not user documents, and the app has no INTERNET permission to transmit them.

- [x] **Calendar** -> Collected: **No**
  - The app declares no READ_CALENDAR permission and contains no calendar code. The app has no INTERNET permission.

- [x] **Contacts** -> Collected: **No**
  - The app declares no READ_CONTACTS permission and contains no contacts code. The app has no INTERNET permission.

- [x] **App activity / App info and performance** -> Collected: **No**
  - The app uses the Android UsageStatsManager API (PACKAGE_USAGE_STATS permission) to detect when tracked apps come to the foreground, and it derives streaks and interception-event outcomes from that. All computation and storage is on-device only (SQLite tables DayRecords, AppStreakStates, MetaStates, InterceptionEvents, plus the native JSONL journal at /data/data/dev.cairn/files/cairn_interceptions.jsonl and SharedPreferences at /data/data/dev.cairn/shared_prefs/cairn_worker.xml). None of this data is transmitted off the device, so under Play's definition it is not "collected." There is no analytics, crash reporting, or telemetry SDK. The analyticsOptIn field in the database schema (default false) has no associated collection logic and is not used by the app.

- [x] **Web browsing history** -> Collected: **No**
  - No browsing data is read or accessed. The app has no INTERNET permission.

- [x] **Device or other IDs** -> Collected: **No**
  - No advertising ID, device ID, or similar identifier is read or transmitted. The app has no INTERNET permission.

---

## Data sharing

- [x] **Is any user data shared with third parties?** -> **No**
  - There are no third-party data SDKs (no analytics, ads, crash reporting, or tracking libraries), and the app has no INTERNET permission or networking libraries. There is nothing to share.

---

## Data security questions

- [x] **Is all of the user data collected by your app encrypted in transit?**
  - **Not applicable.** The app transmits no user data off the device. The app declares no INTERNET permission, includes no networking libraries, and contains no transmission code. Because no data leaves the device, there is no in-transit encryption requirement.

- [x] **Do you provide a way for users to request that their data be deleted?**
  - All user data is stored locally on the device only in /data/data/dev.cairn/files (SQLite database cairn.sqlite and JSONL journal cairn_interceptions.jsonl) and /data/data/dev.cairn/shared_prefs (Android SharedPreferences cairn_worker.xml). Users can delete all app data at any time by uninstalling the app or by clearing the app's storage in Android system settings. No server-side data exists, so there is no remote data to delete and no deletion request mechanism is needed.

---

## Supporting notes

- No account or sign-in (stated in the in-app privacy screen).
- No servers and no cloud sync.
- No analytics collection is active.
- No INTERNET permission is declared in app, build, or merged release manifests.
- No networking libraries are present in dependencies. The pubspec lists flutter_riverpod, riverpod_annotation, drift, sqlite3_flutter_libs, path_provider, path, go_router, flutter_local_notifications, timezone, flutter_timezone, package_info_plus, url_launcher, and share_plus. Neither url_launcher nor share_plus is a networking library, performs any transmission from Cairn, or adds an INTERNET permission to the merged manifest. url_launcher opens a link (the source repository or the developer's tip page) in the system browser by handing off an intent; its bundled manifest declares only a non-exported WebView activity, which Cairn does not use because it opens links in the external browser. share_plus hands a plain text recap to the OS share sheet via an ACTION_SEND intent (the user picks the receiving app); its bundled manifest declares only a non-exported file provider and broadcast receiver, neither of which Cairn's text-only share uses.
- All data lives in the app's private storage directories: /data/data/dev.cairn/files (SQLite) and /data/data/dev.cairn/shared_prefs (Android SharedPreferences).
- The only network-related permission, ACCESS_NETWORK_STATE, is read-only status checking that cannot transmit data, is not invoked by app code, and likely comes from a dependency (androidx.work) used internally.

package dev.cairn

import android.content.Context
import org.json.JSONObject

/**
 * Minimal config the background worker needs, kept in sync by the Dart side via
 * the `updateWorkerConfig` channel method (active package list, reset hour, and
 * the on-device SQLite path so the worker writes to the same DB as Drift).
 *
 * Also holds the speed-bump snapshot (per-app current streak + display name) that
 * the overlay reads to render its copy without ever touching SQLite, and the
 * on/off flag the service reads to decide whether to run.
 */
object WorkerConfig {
    private const val PREFS = "cairn_worker"
    private const val KEY_PACKAGES = "packages"
    private const val KEY_RESET_HOUR = "resetHour"
    private const val KEY_DB_PATH = "dbPath"
    private const val KEY_STREAKS = "sbStreaks" // JSON {packageId: currentStreak}
    private const val KEY_LABELS = "sbLabels"   // JSON {packageId: displayName}
    private const val KEY_SB_ENABLED = "sbEnabled"
    private const val KEY_LAST_ALLOWED_PKG = "sbLastAllowedPkg"
    private const val KEY_LAST_ALLOWED_AT = "sbLastAllowedAt"

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun save(context: Context, packages: List<String>, resetHour: Int, dbPath: String) {
        prefs(context).edit()
            .putString(KEY_PACKAGES, packages.joinToString(","))
            .putInt(KEY_RESET_HOUR, resetHour)
            .putString(KEY_DB_PATH, dbPath)
            .apply()
    }

    fun packages(context: Context): List<String> =
        prefs(context).getString(KEY_PACKAGES, "")
            ?.split(",")
            ?.filter { it.isNotBlank() }
            ?: emptyList()

    fun resetHour(context: Context): Int = prefs(context).getInt(KEY_RESET_HOUR, 4)

    fun dbPath(context: Context): String? = prefs(context).getString(KEY_DB_PATH, null)

    // ── Speed-bump snapshot (read-only on the overlay hot path) ──────────────
    fun saveSpeedBumpSnapshot(context: Context, streaks: Map<String, Int>, labels: Map<String, String>) {
        val s = JSONObject()
        for ((k, v) in streaks) s.put(k, v)
        val l = JSONObject()
        for ((k, v) in labels) l.put(k, v)
        prefs(context).edit()
            .putString(KEY_STREAKS, s.toString())
            .putString(KEY_LABELS, l.toString())
            .apply()
    }

    /** Cached current streak for [pkg]; 0 when unknown (the overlay then shows a
     *  neutral message rather than claiming a run that may not exist). */
    fun streakFor(context: Context, pkg: String): Int {
        val raw = prefs(context).getString(KEY_STREAKS, null) ?: return 0
        return try {
            JSONObject(raw).optInt(pkg, 0)
        } catch (_: Throwable) {
            0
        }
    }

    /** Cached display name for [pkg], or null to fall back to the package id. */
    fun labelFor(context: Context, pkg: String): String? {
        val raw = prefs(context).getString(KEY_LABELS, null) ?: return null
        return try {
            JSONObject(raw).optString(pkg, "").ifBlank { null }
        } catch (_: Throwable) {
            null
        }
    }

    // ── On/off flag the service reads (kept in sync with the Drift setting) ──
    fun setSpeedBumpEnabled(context: Context, enabled: Boolean) {
        prefs(context).edit().putBoolean(KEY_SB_ENABLED, enabled).apply()
    }

    fun isSpeedBumpEnabled(context: Context): Boolean =
        prefs(context).getBoolean(KEY_SB_ENABLED, false)

    // ── Restart grace: remember the last "Open anyway" so a kill→restart does not
    //    re-fire the bump over an app the user just chose to open (B3) ──────────
    fun setLastAllowed(context: Context, pkg: String) {
        prefs(context).edit()
            .putString(KEY_LAST_ALLOWED_PKG, pkg)
            .putLong(KEY_LAST_ALLOWED_AT, System.currentTimeMillis())
            .apply()
    }

    fun lastAllowedPackage(context: Context): String? =
        prefs(context).getString(KEY_LAST_ALLOWED_PKG, null)

    fun lastAllowedAt(context: Context): Long = prefs(context).getLong(KEY_LAST_ALLOWED_AT, 0L)
}

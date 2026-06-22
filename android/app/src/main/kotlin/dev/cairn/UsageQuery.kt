package dev.cairn

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context

/**
 * Shared UsageStatsManager reconstruction, used by both the foreground channel
 * (MainActivity) and the background reconciliation worker. An "open" is an
 * ACTIVITY_RESUMED / MOVE_TO_FOREGROUND event for a tracked package.
 */
object UsageQuery {
    /** What counts as an "open" — shared by both reconcile paths so they can never
     *  disagree about what an open is (PRD §4.2). */
    private fun isOpenEvent(e: UsageEvents.Event): Boolean =
        e.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND

    fun openedPackages(context: Context, packages: Set<String>, start: Long, end: Long): Set<String> {
        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val events = usm.queryEvents(start, end)
        val opened = mutableSetOf<String>()
        val e = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(e)
            if (isOpenEvent(e) && packages.contains(e.packageName)) {
                opened.add(e.packageName)
            }
        }
        return opened
    }

    /** Per-open foreground event timestamps for one package, oldest first. The
     *  match key for reconciling speed-bump interceptions against the OS log. */
    fun openTimestamps(context: Context, pkg: String, start: Long, end: Long): List<Long> {
        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val events = usm.queryEvents(start, end)
        val out = mutableListOf<Long>()
        val e = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(e)
            if (isOpenEvent(e) && e.packageName == pkg) {
                out.add(e.timeStamp)
            }
        }
        return out
    }

    /** Most-recent open of any package in [packages] within the window, or null. */
    fun latestForegroundOpen(context: Context, packages: Set<String>, start: Long, end: Long): Pair<String, Long>? {
        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val events = usm.queryEvents(start, end)
        var latest: Pair<String, Long>? = null
        val e = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(e)
            if (isOpenEvent(e) && packages.contains(e.packageName)) {
                if (latest == null || e.timeStamp > latest!!.second) {
                    latest = Pair(e.packageName, e.timeStamp)
                }
            }
        }
        return latest
    }

    /** Most-recent foreground open of ANY package within the window, or null — i.e.
     *  the current foreground app. The speed-bump service uses this to notice when
     *  the foreground changes to a tracked app. */
    fun latestForegroundPackage(context: Context, start: Long, end: Long): Pair<String, Long>? {
        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val events = usm.queryEvents(start, end)
        var latest: Pair<String, Long>? = null
        val e = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(e)
            if (isOpenEvent(e)) {
                if (latest == null || e.timeStamp > latest!!.second) {
                    latest = Pair(e.packageName, e.timeStamp)
                }
            }
        }
        return latest
    }
}

package dev.cairn

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import java.util.Calendar

/**
 * Daily (~04:05) reconciliation. Per the agreed design (the workmanager Flutter
 * isolate cannot reach our channel), this native worker does the thin native
 * work — compute the just-closed window, query UsageStatsManager, and write the
 * clean/slipped verdict for each tracked app straight into the Drift SQLite DB.
 * The Dart side recomputes the streak caches (and fills unverified gaps) on the
 * next foreground reconcile.
 */
class ReconciliationWorker(context: Context, params: WorkerParameters) :
    CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        return try {
            val ctx = applicationContext
            val packages = WorkerConfig.packages(ctx)
            val dbPath = WorkerConfig.dbPath(ctx)
            if (packages.isEmpty() || dbPath == null) return Result.success()

            val resetHour = WorkerConfig.resetHour(ctx)
            val (start, end) = yesterdayWindow(resetHour, System.currentTimeMillis())
            val opened = UsageQuery.openedPackages(ctx, packages.toSet(), start, end)
            writeVerdicts(dbPath, packages, start, opened)
            Result.success()
        } catch (t: Throwable) {
            Result.retry()
        }
    }

    /** [start, end) for the day window that just closed (yesterday). */
    private fun yesterdayWindow(resetHour: Int, now: Long): Pair<Long, Long> {
        val todayStart = Calendar.getInstance().apply {
            timeInMillis = now
            set(Calendar.HOUR_OF_DAY, resetHour)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            if (now < timeInMillis) add(Calendar.DAY_OF_MONTH, -1)
        }
        val end = todayStart.timeInMillis
        val start = (todayStart.clone() as Calendar)
            .apply { add(Calendar.DAY_OF_MONTH, -1) }
            .timeInMillis
        return Pair(start, end)
    }

    private fun writeVerdicts(
        dbPath: String,
        packages: List<String>,
        dayStartMillis: Long,
        opened: Set<String>,
    ) {
        val db = SQLiteDatabase.openDatabase(dbPath, null, SQLiteDatabase.OPEN_READWRITE)
        try {
            db.execSQL("PRAGMA busy_timeout = 3000")
            val finalizedSeconds = System.currentTimeMillis() / 1000
            for (pkg in packages) {
                // DayState index: clean = 0, slipped = 1 (matches the Dart enum).
                val state = if (opened.contains(pkg)) 1 else 0
                db.execSQL(
                    "INSERT OR REPLACE INTO day_records " +
                        "(package_id, day_start_millis, state, finalized_at) VALUES (?, ?, ?, ?)",
                    arrayOf<Any>(pkg, dayStartMillis, state, finalizedSeconds),
                )
            }
        } finally {
            db.close()
        }
    }
}

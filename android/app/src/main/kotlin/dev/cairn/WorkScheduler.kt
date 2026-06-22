package dev.cairn

import android.content.Context
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import java.util.Calendar
import java.util.concurrent.TimeUnit

object WorkScheduler {
    private const val DAILY = "cairn_daily_reconciliation"

    /** Schedule the daily reconciliation, first run ~5 min after the reset hour. */
    fun scheduleDaily(context: Context) {
        val request = PeriodicWorkRequestBuilder<ReconciliationWorker>(1, TimeUnit.DAYS)
            .setInitialDelay(initialDelayToNextReset(WorkerConfig.resetHour(context)), TimeUnit.MILLISECONDS)
            .build()
        WorkManager.getInstance(context)
            .enqueueUniquePeriodicWork(DAILY, ExistingPeriodicWorkPolicy.UPDATE, request)
    }

    /** One-off run, for testing the worker on demand. */
    fun runOnce(context: Context) {
        WorkManager.getInstance(context).enqueue(OneTimeWorkRequestBuilder<ReconciliationWorker>().build())
    }

    private fun initialDelayToNextReset(resetHour: Int): Long {
        val now = System.currentTimeMillis()
        val target = Calendar.getInstance().apply {
            timeInMillis = now
            set(Calendar.HOUR_OF_DAY, resetHour)
            set(Calendar.MINUTE, 5)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            if (timeInMillis <= now) add(Calendar.DAY_OF_MONTH, 1)
        }
        return target.timeInMillis - now
    }
}

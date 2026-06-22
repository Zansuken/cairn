package dev.cairn

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Reschedules the daily reconciliation after a reboot (PRD §4.6) and, if the
 *  speed bump is enabled, tries to restart its watcher. */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            "android.intent.action.QUICKBOOT_POWERON",
            "com.htc.intent.action.QUICKBOOT_POWERON" -> {
                WorkScheduler.scheduleDaily(context)
                if (WorkerConfig.isSpeedBumpEnabled(context)) {
                    try {
                        SpeedBumpController.start(context)
                    } catch (_: Throwable) {
                        // Starting a foreground service from boot is restricted on
                        // Android 12+; the foreground self-heal (RootGate) is the
                        // real backstop. Streak accuracy is unaffected either way.
                    }
                }
            }
        }
    }
}

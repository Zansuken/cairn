package dev.cairn

import android.annotation.SuppressLint
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings

/** Start/stop the speed-bump service and check/request the overlay permission.
 *  Called from the channel (MainActivity) and from BootReceiver / self-heal. */
object SpeedBumpController {

    fun start(context: Context) {
        val intent = Intent(context, SpeedBumpService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(intent)
        } else {
            context.startService(intent)
        }
    }

    fun stop(context: Context) {
        context.stopService(Intent(context, SpeedBumpService::class.java))
    }

    fun isRunning(): Boolean = SpeedBumpService.isRunning

    fun isOverlayGranted(context: Context): Boolean = Settings.canDrawOverlays(context)

    fun openOverlaySettings(context: Context) {
        val intent = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse("package:" + context.packageName),
        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }

    fun isIgnoringBatteryOptimizations(context: Context): Boolean {
        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(context.packageName)
    }

    @SuppressLint("BatteryLife")
    fun requestIgnoreBatteryOptimizations(context: Context) {
        val direct = Intent(
            Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
            Uri.parse("package:" + context.packageName),
        ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            context.startActivity(direct)
        } catch (_: Throwable) {
            // Fall back to the battery-optimization list if the direct dialog is unavailable.
            try {
                context.startActivity(
                    Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                )
            } catch (_: Throwable) {
                // Nothing to open; the honesty line in-app tells the user what to do.
            }
        }
    }

    /** Build.MANUFACTURER lowercased, so the UI can show OEM-specific hints only
     *  where they matter (these OEMs aggressively kill background services). */
    fun manufacturer(): String = Build.MANUFACTURER.lowercase()

    /** Best-effort: open the OEM "auto-start / protected apps" page so the user can
     *  whitelist Cairn (aggressive OEMs kill background foreground-services). Tries
     *  the known OEM screens in turn, then falls back to this app's system details
     *  page, which always exists. */
    fun openProtectedAppsSettings(context: Context) {
        val candidates = listOf(
            // Honor / Huawei
            ComponentName("com.hihonor.systemmanager", "com.hihonor.systemmanager.startupmgr.ui.StartupNormalAppListActivity"),
            ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"),
            ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.process.ProtectActivity"),
            // Xiaomi / Redmi / POCO
            ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity"),
            // Oppo / Realme
            ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity"),
            ComponentName("com.oppo.safe", "com.oppo.safe.permission.startup.StartupAppListActivity"),
            // Vivo / iQOO
            ComponentName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"),
            ComponentName("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity"),
            // Samsung (device care battery page)
            ComponentName("com.samsung.android.lool", "com.samsung.android.sm.battery.ui.BatteryActivity"),
        )
        for (cn in candidates) {
            try {
                context.startActivity(
                    Intent().setComponent(cn).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                )
                return
            } catch (_: Throwable) {
                // Not this OEM (or not visible) — try the next candidate.
            }
        }
        try {
            context.startActivity(
                Intent(
                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                    Uri.parse("package:" + context.packageName),
                ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
        } catch (_: Throwable) {
            // Nothing to open; the in-app guidance still explains what to do.
        }
    }
}

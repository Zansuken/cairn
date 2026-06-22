// MainActivity.kt
// Detection bridge for Cairn. The MethodChannel contract (`cairn/usage`) and the
// UsageStatsManager reconstruction below are reused VERBATIM from the validated spike.

package dev.cairn

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Process
import android.provider.Settings
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val channelName = "cairn/usage"

    // The MethodChannel handler runs on the Android main thread. Enumerating apps
    // (icon render + PNG encode) and UsageStats queries are heavy enough to block
    // it, which stalls Choreographer/vsync and freezes every Flutter animation
    // (loading spinners included). Run those reads here and reply on the UI thread.
    private val ioExecutor: ExecutorService = Executors.newSingleThreadExecutor()

    /** Run [work] off the main thread, then deliver to [result] back on it. */
    private fun <T> replyAsync(result: MethodChannel.Result, work: () -> T) {
        ioExecutor.execute {
            val outcome = runCatching(work)
            runOnUiThread {
                outcome
                    .onSuccess { result.success(it) }
                    .onFailure { result.error("native_error", it.message, null) }
            }
        }
    }

    override fun onDestroy() {
        ioExecutor.shutdown()
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isUsageAccessGranted" -> result.success(isUsageAccessGranted())

                    "openUsageAccessSettings" -> {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(null)
                    }

                    "getOpenedPackages" -> {
                        val pkgs = (call.argument<List<String>>("packages") ?: emptyList()).toSet()
                        val start = call.argument<Long>("startMillis") ?: 0L
                        val end = call.argument<Long>("endMillis") ?: 0L
                        replyAsync(result) { getOpenedPackages(pkgs, start, end) }
                    }

                    "getOpenTimestamps" -> {
                        val pkg = call.argument<String>("package") ?: ""
                        val start = call.argument<Long>("startMillis") ?: 0L
                        val end = call.argument<Long>("endMillis") ?: 0L
                        replyAsync(result) { UsageQuery.openTimestamps(this, pkg, start, end) }
                    }

                    "getRawEvents" -> {
                        val pkg = call.argument<String>("package") ?: ""
                        val start = call.argument<Long>("startMillis") ?: 0L
                        val end = call.argument<Long>("endMillis") ?: 0L
                        replyAsync(result) { getRawEvents(pkg, start, end) }
                    }

                    "getInstalledApps" -> {
                        val withIcons = call.argument<Boolean>("withIcons") ?: false
                        replyAsync(result) { getInstalledApps(withIcons) }
                    }

                    "updateWorkerConfig" -> {
                        val pkgs = call.argument<List<String>>("packages") ?: emptyList()
                        val resetHour = call.argument<Int>("resetHour") ?: 4
                        val dbPath = call.argument<String>("dbPath") ?: ""
                        WorkerConfig.save(applicationContext, pkgs, resetHour, dbPath)
                        result.success(null)
                    }

                    "scheduleDailyReconciliation" -> {
                        WorkScheduler.scheduleDaily(applicationContext)
                        result.success(null)
                    }

                    "runReconciliationNow" -> {
                        WorkScheduler.runOnce(applicationContext)
                        result.success(null)
                    }

                    // ── Intervention speed bump ──────────────────────────────
                    "isOverlayGranted" -> result.success(SpeedBumpController.isOverlayGranted(this))

                    "openOverlaySettings" -> {
                        SpeedBumpController.openOverlaySettings(this)
                        result.success(null)
                    }

                    "setSpeedBumpEnabled" -> {
                        WorkerConfig.setSpeedBumpEnabled(
                            applicationContext,
                            call.argument<Boolean>("enabled") ?: false,
                        )
                        result.success(null)
                    }

                    "startSpeedBump" -> {
                        SpeedBumpController.start(applicationContext)
                        result.success(null)
                    }

                    "stopSpeedBump" -> {
                        SpeedBumpController.stop(applicationContext)
                        result.success(null)
                    }

                    "isSpeedBumpRunning" -> result.success(SpeedBumpController.isRunning())

                    "isIgnoringBatteryOptimizations" ->
                        result.success(SpeedBumpController.isIgnoringBatteryOptimizations(this))

                    "requestIgnoreBatteryOptimizations" -> {
                        SpeedBumpController.requestIgnoreBatteryOptimizations(this)
                        result.success(null)
                    }

                    "getManufacturer" -> result.success(SpeedBumpController.manufacturer())

                    "openProtectedAppsSettings" -> {
                        SpeedBumpController.openProtectedAppsSettings(this)
                        result.success(null)
                    }

                    "saveSpeedBumpSnapshot" -> {
                        val streaksRaw = call.argument<Map<String, Any?>>("streaks") ?: emptyMap()
                        val labelsRaw = call.argument<Map<String, Any?>>("labels") ?: emptyMap()
                        val streaks = streaksRaw.mapValues { (it.value as? Number)?.toInt() ?: 0 }
                        val labels = labelsRaw.mapValues { it.value?.toString() ?: "" }
                        WorkerConfig.saveSpeedBumpSnapshot(applicationContext, streaks, labels)
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun isUsageAccessGranted(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    /** Packages (from the given set) that had at least one foreground event in [start, end). */
    private fun getOpenedPackages(packages: Set<String>, start: Long, end: Long): List<String> =
        UsageQuery.openedPackages(this, packages, start, end).toList()

    /** All raw events for one package in [start, end) — for debugging the boundary. */
    private fun getRawEvents(pkg: String, start: Long, end: Long): List<Map<String, Any>> {
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val events = usm.queryEvents(start, end)
        val out = mutableListOf<Map<String, Any>>()
        val e = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(e)
            if (e.packageName == pkg) {
                out.add(mapOf("type" to e.eventType, "timestamp" to e.timeStamp))
            }
        }
        return out
    }

    /** Launchable installed apps for the picker, optionally with PNG icons. */
    @Suppress("DEPRECATION", "QueryPermissionsNeeded")
    private fun getInstalledApps(withIcons: Boolean): List<Map<String, String>> {
        val pm = packageManager
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        return pm.queryIntentActivities(intent, 0)
            .distinctBy { it.activityInfo.packageName }
            .map {
                val entry = mutableMapOf(
                    "package" to it.activityInfo.packageName,
                    "label" to it.loadLabel(pm).toString(),
                )
                if (withIcons) {
                    runCatching { iconToBase64(it.loadIcon(pm)) }.getOrNull()?.let { png ->
                        entry["icon"] = png
                    }
                }
                entry
            }
            .sortedBy { it["label"] }
    }

    /** Renders an app icon Drawable to a small PNG, base64-encoded (no wrap). */
    private fun iconToBase64(drawable: Drawable, size: Int = 96): String {
        val bitmap = if (drawable is BitmapDrawable && drawable.bitmap != null) {
            Bitmap.createScaledBitmap(drawable.bitmap, size, size, true)
        } else {
            val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bmp)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            bmp
        }
        val baos = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, baos)
        return Base64.encodeToString(baos.toByteArray(), Base64.NO_WRAP)
    }
}

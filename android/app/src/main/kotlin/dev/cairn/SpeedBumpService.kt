package dev.cairn

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager

/**
 * The intervention speed bump (PRD roadmap). A `specialUse` foreground service
 * that, while the screen is on, polls UsageStatsManager (~1s) for the current
 * foreground app and shows the calm overlay when a TRACKED app comes forward.
 *
 * Detection is best-effort and may lag a second or two; the streak source of
 * truth stays the retroactive reconcile. This service only adds the in-the-moment
 * pause and writes the resisted/allowed verdict to the journal.
 */
class SpeedBumpService : Service() {

    companion object {
        @Volatile
        var isRunning: Boolean = false
            private set

        private const val NOTIF_ID = 42
        private const val CHANNEL_ID = "gentle_pauses"
        private const val POLL_MS = 1000L
        private const val LOOKBACK_MS = 2500L
        private const val RESTART_GRACE_MS = 8000L
    }

    private lateinit var thread: HandlerThread
    private lateinit var worker: Handler
    private val main = Handler(Looper.getMainLooper())
    private var screenReceiver: BroadcastReceiver? = null

    /** Last package seen at the foreground — the edge we trigger on. Touched only
     *  on the worker thread. */
    private var lastForegroundPackage: String? = null

    private val pollRunnable = object : Runnable {
        override fun run() {
            poll()
            worker.postDelayed(this, POLL_MS)
        }
    }

    override fun onCreate() {
        super.onCreate()
        createChannel()
        startInForeground()
        isRunning = true
        thread = HandlerThread("cairn-speedbump").apply { start() }
        worker = Handler(thread.looper)
        registerScreenReceiver()
        if (isScreenOn()) startPolling()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int = START_STICKY

    override fun onDestroy() {
        stopPolling()
        screenReceiver?.let { runCatching { unregisterReceiver(it) } }
        if (this::thread.isInitialized) thread.quitSafely()
        main.post { OverlayController.remove(applicationContext) }
        isRunning = false
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    // ── Polling ──────────────────────────────────────────────────────────────
    private fun poll() {
        val ctx = applicationContext
        if (!WorkerConfig.isSpeedBumpEnabled(ctx)) {
            stopSelf()
            return
        }
        val tracked = WorkerConfig.packages(ctx).toSet()
        if (tracked.isEmpty()) return

        val now = System.currentTimeMillis()
        val latest = UsageQuery.latestForegroundPackage(ctx, now - LOOKBACK_MS, now) ?: return
        val pkg = latest.first
        if (pkg == lastForegroundPackage) return // no foreground change
        lastForegroundPackage = pkg

        if (!tracked.contains(pkg)) return // moved to an untracked app: nothing to do
        if (OverlayController.isShowing()) return

        // Restart grace (B3): do not re-bump an app the user just chose to open.
        val allowedPkg = WorkerConfig.lastAllowedPackage(ctx)
        val withinGrace = allowedPkg == pkg && (now - WorkerConfig.lastAllowedAt(ctx)) < RESTART_GRACE_MS
        if (withinGrace) return

        main.post { OverlayController.show(ctx, pkg, latest.second) }
    }

    private fun startPolling() {
        worker.removeCallbacks(pollRunnable)
        worker.post(pollRunnable)
    }

    private fun stopPolling() {
        if (this::worker.isInitialized) worker.removeCallbacks(pollRunnable)
    }

    // ── Screen on/off: only poll while the screen is on (battery) ─────────────
    private fun registerScreenReceiver() {
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(Intent.ACTION_SCREEN_OFF)
        }
        screenReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                when (intent.action) {
                    Intent.ACTION_SCREEN_ON -> startPolling()
                    Intent.ACTION_SCREEN_OFF -> {
                        stopPolling()
                        lastForegroundPackage = null
                        main.post { OverlayController.remove(applicationContext) }
                    }
                }
            }
        }
        registerReceiver(screenReceiver, filter)
    }

    private fun isScreenOn(): Boolean {
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.isInteractive
    }

    // ── Foreground notification ────────────────────────────────────────────────
    private fun startInForeground() {
        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(NOTIF_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(NOTIF_ID, notification)
        }
    }

    private fun createChannel() {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(
            CHANNEL_ID,
            getString(R.string.sb_channel_name),
            NotificationManager.IMPORTANCE_LOW,
        ).apply { setShowBadge(false) }
        nm.createNotificationChannel(channel)
    }

    private fun buildNotification(): Notification {
        val launch = packageManager.getLaunchIntentForPackage(packageName)
        val pending = PendingIntent.getActivity(
            this,
            0,
            launch,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        return Notification.Builder(this, CHANNEL_ID)
            .setContentTitle(getString(R.string.sb_notif_title))
            .setContentText(getString(R.string.sb_notif_text))
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .setContentIntent(pending)
            .build()
    }
}

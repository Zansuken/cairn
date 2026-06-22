package dev.cairn

import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.TextView

/**
 * Shows / removes the speed-bump overlay (TYPE_APPLICATION_OVERLAY) over a tracked
 * app. The copy is read from the [WorkerConfig] prefs snapshot (no SQLite on the
 * hot path); the outcome is written to the append-only [Journal] reusing the exact
 * OS foreground timestamp that triggered the bump.
 *
 * "Stay strong" removes the overlay and sends the user home (a resisted open, which
 * the reconcile does not count). "Open anyway" only removes the overlay, revealing
 * the tracked app behind it (an allowed open, which counts as a slip).
 */
object OverlayController {
    private var view: View? = null

    fun isShowing(): Boolean = view != null

    fun show(context: Context, pkg: String, foregroundAtMillis: Long) {
        if (view != null) return // already up; do not stack
        val appContext = context.applicationContext
        val wm = appContext.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val root = LayoutInflater.from(appContext).inflate(R.layout.speed_bump, null)

        bindCopy(root, pkg)

        root.findViewById<View>(R.id.sb_stay).setOnClickListener {
            Journal.appendResisted(appContext, pkg, foregroundAtMillis)
            remove(appContext)
            goHome(appContext)
        }
        root.findViewById<View>(R.id.sb_open).setOnClickListener {
            Journal.appendAllowed(appContext, pkg, foregroundAtMillis)
            // Remember the choice so a kill→restart does not immediately re-bump
            // over the app the user just chose to open (B3).
            WorkerConfig.setLastAllowed(appContext, pkg)
            remove(appContext) // reveals the tracked app behind the overlay
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT,
        )

        try {
            wm.addView(root, params)
            view = root
            Journal.appendShown(appContext, pkg, foregroundAtMillis)
        } catch (_: Throwable) {
            // Overlay permission was revoked while the service ran: disable the
            // feature so we stop polling blindly. Dart reconciles the setting on
            // its next foreground.
            view = null
            WorkerConfig.setSpeedBumpEnabled(appContext, false)
        }
    }

    fun remove(context: Context) {
        val v = view ?: return
        view = null
        val wm = context.applicationContext.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        try {
            wm.removeView(v)
        } catch (_: Throwable) {
            // Already detached.
        }
    }

    private fun bindCopy(root: View, pkg: String) {
        val context = root.context
        val app = WorkerConfig.labelFor(context, pkg) ?: pkg
        val streak = WorkerConfig.streakFor(context, pkg)
        val headline = root.findViewById<TextView>(R.id.sb_headline)
        val body = root.findViewById<TextView>(R.id.sb_body)
        if (streak <= 0) {
            // Honesty guard: never claim a run that is not there.
            headline.text = "Opening $app?"
            body.text = "Take a breath first. You can still walk away."
        } else {
            headline.text = "You're on a $streak-day $app streak."
            body.text = "Opening it ends the run. Take a breath first."
        }
    }

    private fun goHome(context: Context) {
        val home = Intent(Intent.ACTION_MAIN)
            .addCategory(Intent.CATEGORY_HOME)
            .setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            context.startActivity(home)
        } catch (_: Throwable) {
            // Background-activity-launch may be blocked on some OEMs (the B1 risk);
            // the overlay is already removed, so at worst the user lands back in
            // the app and the next foreground re-shows the bump.
        }
    }
}

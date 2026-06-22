package dev.cairn

import android.content.Context
import android.os.Handler
import android.os.HandlerThread
import java.io.File

/**
 * Append-only JSONL journal for speed-bump interceptions. The native overlay is
 * the ONLY writer; the Dart reconcile drains and truncates it, so Drift stays the
 * single SQLite writer (no cross-process WAL contention).
 *
 * One JSON object per line:
 *   {"pkg":"<package>","fg":<osEventMillis>,"outcome":0|1|2,"rec":<recordedMillis>}
 * outcome indices match the Dart InterceptionOutcome enum: resisted=0, allowed=1,
 * shown=2. `fg` is the real OS MOVE_TO_FOREGROUND timestamp (the reconcile match
 * key), reused verbatim across the shown line and the outcome line.
 *
 * The file lives in the SAME directory as the Drift DB (derived from the synced
 * dbPath) so Dart and native agree on the path without a second hand-off.
 */
object Journal {
    private const val FILE_NAME = "cairn_interceptions.jsonl"

    private val thread = HandlerThread("cairn-journal").apply { start() }
    private val handler = Handler(thread.looper)

    fun appendShown(context: Context, pkg: String, foregroundAtMillis: Long) =
        append(context, pkg, foregroundAtMillis, 2)

    fun appendResisted(context: Context, pkg: String, foregroundAtMillis: Long) =
        append(context, pkg, foregroundAtMillis, 0)

    fun appendAllowed(context: Context, pkg: String, foregroundAtMillis: Long) =
        append(context, pkg, foregroundAtMillis, 1)

    private fun append(context: Context, pkg: String, fg: Long, outcome: Int) {
        val rec = System.currentTimeMillis()
        val appContext = context.applicationContext
        handler.post {
            val file = journalFile(appContext) ?: return@post
            val safePkg = pkg.replace("\\", "\\\\").replace("\"", "\\\"")
            val line = "{\"pkg\":\"$safePkg\",\"fg\":$fg,\"outcome\":$outcome,\"rec\":$rec}\n"
            try {
                file.appendText(line)
            } catch (_: Throwable) {
                // Best effort: a dropped line just leaves that open unverified, never
                // a false clean.
            }
        }
    }

    /** Next to the Drift DB. Null (drop the line) if the dbPath has not synced yet,
     *  rather than risk writing to a directory Dart does not read. */
    private fun journalFile(context: Context): File? {
        val dbPath = WorkerConfig.dbPath(context) ?: return null
        val parent = File(dbPath).parentFile ?: return null
        return File(parent, FILE_NAME)
    }
}

package de.gartenpa.kept

import android.app.Notification
import android.content.Context
import android.os.Build
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import org.json.JSONObject
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Throwaway (Phone checks, check 4): writes one JSON line per notification
 * posted by a messenger to a file in filesDir. Nothing goes to logcat.
 */
class KeptNotificationListener : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if (sbn.packageName !in PACKAGES) return
        try {
            append(this, describe(sbn).toString())
        } catch (_: Exception) {
            // Never crash the listener; never log the content.
        }
    }

    private fun describe(sbn: StatusBarNotification): JSONObject {
        val n = sbn.notification
        val extras = n.extras
        val template = extras?.getString(Notification.EXTRA_TEMPLATE)
        val time = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX", Locale.ROOT)
            .format(Date(sbn.postTime))
        return JSONObject().apply {
            put("postTime", time)
            put("package", sbn.packageName)
            put("category", n.category ?: JSONObject.NULL)
            put(
                "channel",
                if (Build.VERSION.SDK_INT >= 26) n.channelId ?: JSONObject.NULL else JSONObject.NULL,
            )
            put("title", extras?.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: JSONObject.NULL)
            put(
                "text",
                extras?.getCharSequence(Notification.EXTRA_TEXT)?.toString()?.take(40) ?: JSONObject.NULL,
            )
            put("ongoing", sbn.isOngoing)
            put("groupSummary", (n.flags and Notification.FLAG_GROUP_SUMMARY) != 0)
            put("template", template ?: JSONObject.NULL)
            put("messagingStyle", template?.contains("MessagingStyle") == true)
            put("callStyle", template?.contains("CallStyle") == true)
        }
    }

    companion object {
        val PACKAGES = setOf(
            "com.whatsapp",
            "com.whatsapp.w4b",
            "org.telegram.messenger",
            "org.thoughtcrime.securesms",
            "com.discord",
        )
        private const val FILE_NAME = "listener_log.jsonl"
        private const val MAX_LINES = 100
        private val lock = Any()

        private fun file(context: Context) = File(context.filesDir, FILE_NAME)

        fun append(context: Context, line: String) = synchronized(lock) {
            val f = file(context)
            val lines = if (f.exists()) f.readLines().filter { it.isNotEmpty() } else emptyList()
            f.writeText((lines + line).takeLast(MAX_LINES).joinToString("\n", postfix = "\n"))
        }

        fun read(context: Context): List<String> = synchronized(lock) {
            val f = file(context)
            if (f.exists()) f.readLines().filter { it.isNotEmpty() } else emptyList()
        }

        fun clear(context: Context) = synchronized(lock) {
            file(context).delete()
        }
    }
}

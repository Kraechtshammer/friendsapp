package de.gartenpa.kept

import android.app.Notification
import android.content.Context
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Incoming contact (M7, 02-design.md §2.6 and §6.9). Optional part, off by
 * default; the user grants notification access by hand in the system
 * settings. Built in only with KEPT_INCOMING=true; see IncomingRules.kt.
 *
 * When the part is on, a notification from a messenger whose title is the
 * name of a watched person is written to a small queue file as
 * {personId, kind, time}. The app reads and clears the queue when it comes
 * to the front. Read from a notification: package, post time, category,
 * flags, and the extras template, title, conversation title, group
 * conversation flag and call type. Never the text of a message. Nothing is
 * logged.
 */
class KeptNotificationListener : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        try {
            if (sbn == null || sbn.packageName !in IncomingRules.MESSENGERS) return
            if (!IncomingStore.isEnabled(this)) return
            val n = sbn.notification ?: return
            val kind = IncomingRules.classify(facts(sbn.packageName, n)) ?: return
            val title = n.extras?.getCharSequence(Notification.EXTRA_TITLE)?.toString()
            val personId = IncomingRules.match(title, IncomingStore.watchList(this)) ?: return
            IncomingStore.add(this, QueueEntry(personId, kind, sbn.postTime))
        } catch (_: Throwable) {
            // Never crash the listener, never log what was seen.
        }
    }

    private fun facts(packageName: String, n: Notification): NotificationFacts {
        val extras = n.extras
        val groupConversation =
            if (extras != null && extras.containsKey(EXTRA_IS_GROUP_CONVERSATION)) {
                extras.getBoolean(EXTRA_IS_GROUP_CONVERSATION)
            } else {
                null
            }
        return NotificationFacts(
            packageName = packageName,
            category = n.category,
            template = extras?.getString(EXTRA_TEMPLATE),
            groupSummary = (n.flags and Notification.FLAG_GROUP_SUMMARY) != 0,
            foregroundService = (n.flags and Notification.FLAG_FOREGROUND_SERVICE) != 0,
            ongoing = (n.flags and Notification.FLAG_ONGOING_EVENT) != 0,
            groupConversation = groupConversation,
            hasConversationTitle =
                !extras?.getCharSequence(EXTRA_CONVERSATION_TITLE).isNullOrBlank(),
            callType = extras?.getInt(EXTRA_CALL_TYPE, 0) ?: 0,
        )
    }

    private companion object {
        // The values of Notification.EXTRA_TEMPLATE and
        // EXTRA_CONVERSATION_TITLE (API 24), EXTRA_IS_GROUP_CONVERSATION
        // (API 28) and EXTRA_CALL_TYPE (API 31), spelled out so older phones
        // and the compat library's extras are read the same way.
        const val EXTRA_TEMPLATE = "android.template"
        const val EXTRA_CONVERSATION_TITLE = "android.conversationTitle"
        const val EXTRA_IS_GROUP_CONVERSATION = "android.isGroupConversation"
        const val EXTRA_CALL_TYPE = "android.callType"
    }
}

/**
 * What the listener and the app share: the on/off flag and the watch list in
 * SharedPreferences (written by the app), and the queue file in filesDir.
 */
object IncomingStore {
    private const val PREFS = "kept_incoming"
    private const val KEY_ENABLED = "enabled"
    private const val KEY_WATCH_LIST = "watchList"
    private const val QUEUE_FILE = "incoming_queue.json"
    private val lock = Any()

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun isEnabled(context: Context): Boolean = prefs(context).getBoolean(KEY_ENABLED, false)

    /** Off also forgets the watch list and the queue. */
    fun setEnabled(context: Context, on: Boolean) {
        prefs(context).edit().putBoolean(KEY_ENABLED, on).apply()
        if (!on) {
            setWatchList(context, "[]")
            take(context)
        }
    }

    /** [json]: `[{"id": "...", "names": ["...", ...]}, ...]`, as the app sends it. */
    fun setWatchList(context: Context, json: String) {
        JSONArray(json) // Refuses anything that is not a list.
        prefs(context).edit().putString(KEY_WATCH_LIST, json).apply()
    }

    fun watchList(context: Context): List<WatchEntry> {
        val array = JSONArray(prefs(context).getString(KEY_WATCH_LIST, "[]") ?: "[]")
        return (0 until array.length()).mapNotNull { i ->
            val o = array.optJSONObject(i) ?: return@mapNotNull null
            val id = o.optString("id")
            val names = o.optJSONArray("names") ?: return@mapNotNull null
            if (id.isEmpty()) return@mapNotNull null
            WatchEntry(id, (0 until names.length()).map { names.optString(it) })
        }
    }

    fun add(context: Context, entry: QueueEntry) = synchronized(lock) {
        val format = SimpleDateFormat("yyyy-MM-dd", Locale.ROOT)
        val next = IncomingRules.addToQueue(read(context), entry) { format.format(Date(it)) }
        write(context, next)
    }

    /** The queue, emptied. Lines that cannot be read are dropped. */
    fun take(context: Context): List<QueueEntry> = synchronized(lock) {
        val entries = read(context)
        file(context).delete()
        entries
    }

    private fun file(context: Context) = File(context.filesDir, QUEUE_FILE)

    private fun read(context: Context): List<QueueEntry> {
        val f = file(context)
        if (!f.exists()) return emptyList()
        val array = try {
            JSONArray(f.readText())
        } catch (_: Exception) {
            return emptyList()
        }
        return (0 until array.length()).mapNotNull { i ->
            val o = array.optJSONObject(i) ?: return@mapNotNull null
            val kind = IncomingKind.values().firstOrNull { it.name == o.optString("kind") }
            val id = o.optString("personId")
            val time = o.optLong("time", 0)
            if (kind == null || id.isEmpty() || time <= 0) null else QueueEntry(id, kind, time)
        }
    }

    private fun write(context: Context, entries: List<QueueEntry>) {
        val array = JSONArray()
        for (e in entries) {
            array.put(
                JSONObject()
                    .put("personId", e.personId)
                    .put("kind", e.kind.name)
                    .put("time", e.time),
            )
        }
        file(context).writeText(array.toString())
    }

    /** Maps for the method channel. */
    fun toMaps(entries: List<QueueEntry>): List<Map<String, Any>> =
        entries.map { mapOf("personId" to it.personId, "kind" to it.kind.name, "time" to it.time) }
}

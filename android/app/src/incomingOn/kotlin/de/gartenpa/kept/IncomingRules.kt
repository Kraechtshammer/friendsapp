package de.gartenpa.kept

// Incoming contact (M7, 02-design.md §2.6 and §6.9): the rules of the
// notification listener as pure functions, with no Android types, so they
// can be tested once Kotlin has a test setup. The listener
// (KeptNotificationListener.kt) only reads the fields and calls these.
//
// Optional part, built in only with --dart-define=KEPT_INCOMING=true: this
// folder (src/incomingOn) and its AndroidManifest.xml are then added by
// android/app/build.gradle.kts; otherwise src/incomingOff holds a stub
// IncomingSetup (docs/04-architecture.md).

/** What an incoming notification stands for. Stored by [name] in the queue. */
enum class IncomingKind { wrote, called }

/**
 * The fields of a notification the rules look at. Nothing else is read;
 * in particular never the text of a message.
 */
data class NotificationFacts(
    val packageName: String,
    /** `Notification.category`, e.g. "call", "msg"; null if not set. */
    val category: String?,
    /** `EXTRA_TEMPLATE`, e.g. "android.app.Notification$MessagingStyle". */
    val template: String?,
    /** `FLAG_GROUP_SUMMARY` is set. */
    val groupSummary: Boolean,
    /** `FLAG_FOREGROUND_SERVICE` is set (the app's own service notice). */
    val foregroundService: Boolean,
    /** `FLAG_ONGOING_EVENT` is set. */
    val ongoing: Boolean,
    /** `EXTRA_IS_GROUP_CONVERSATION`; null when the extra is missing. */
    val groupConversation: Boolean?,
    /** `EXTRA_CONVERSATION_TITLE` is set and not blank. */
    val hasConversationTitle: Boolean,
    /** `EXTRA_CALL_TYPE` of a CallStyle (1 incoming, 2 ongoing, 3 screening); 0 when missing. */
    val callType: Int,
)

/** One person to watch for: their id and the names a messenger may show. */
data class WatchEntry(val personId: String, val names: List<String>)

/** One line of the queue file. [time] is milliseconds since the epoch. */
data class QueueEntry(val personId: String, val kind: IncomingKind, val time: Long)

object IncomingRules {
    /** WhatsApp (and Business), Telegram, Signal, Discord. */
    val MESSENGERS = setOf(
        "com.whatsapp",
        "com.whatsapp.w4b",
        "org.telegram.messenger",
        "org.thoughtcrime.securesms",
        "com.discord",
    )

    /** At most this many entries wait in the queue; older ones are dropped. */
    const val MAX_QUEUE = 300

    private const val CALL_TYPE_INCOMING = 1

    /**
     * A call, a message or nothing. Goes by category, template and flags only,
     * never by text (the text follows the phone's language). Group summaries,
     * group conversations and service notifications are nothing. A call is
     * category "call" with the CallStyle template, and only an incoming one
     * when the call type is given (an ongoing call may be one the user
     * started); "missed_call" counts as a call too. WhatsApp's "Checking for
     * new calls" has no category and no CallStyle, so it is nothing.
     */
    fun classify(n: NotificationFacts): IncomingKind? {
        if (n.packageName !in MESSENGERS) return null
        if (n.groupSummary || n.foregroundService) return null
        if (isGroupConversation(n)) return null
        val template = n.template ?: ""
        if (n.category == "call" && template.endsWith("\$CallStyle")) {
            return if (n.callType == 0 || n.callType == CALL_TYPE_INCOMING) {
                IncomingKind.called
            } else {
                null
            }
        }
        if (n.category == "missed_call") return IncomingKind.called
        if (n.ongoing) return null
        if (n.category == "msg" || template.endsWith("\$MessagingStyle")) {
            return IncomingKind.wrote
        }
        return null
    }

    /**
     * A group chat: the MessagingStyle flag says so when present; without it,
     * a conversation title marks a group (as NotificationCompat does for
     * apps that do not set the flag).
     */
    fun isGroupConversation(n: NotificationFacts): Boolean =
        n.groupConversation ?: n.hasConversationTitle

    /** Trimmed, inner spaces collapsed, lower case. */
    fun normalize(name: String): String =
        name.trim().replace(Regex("\\s+"), " ").lowercase()

    /**
     * The person whose name is [title], or null. Compared trimmed and without
     * regard to case. A trailing count in brackets ("Jonas (2 messages)") is
     * also tried without it. If two people share the name, nobody matches.
     */
    fun match(title: String?, watchList: List<WatchEntry>): String? {
        if (title.isNullOrBlank()) return null
        val candidates = linkedSetOf(normalize(title))
        val stripped = title.replace(Regex("\\s*\\([^()]*\\d[^()]*\\)\\s*$"), "")
        if (stripped.isNotBlank()) candidates.add(normalize(stripped))
        for (candidate in candidates) {
            val ids = watchList
                .filter { e -> e.names.any { normalize(it) == candidate } }
                .map { it.personId }
                .toSet()
            if (ids.size == 1) return ids.first()
            if (ids.size > 1) return null
        }
        return null
    }

    /**
     * The queue after adding [entry]: unchanged if one with the same person,
     * kind and day (by [dayOf]) is already there; otherwise appended, and
     * only the newest [MAX_QUEUE] kept.
     */
    fun addToQueue(
        queue: List<QueueEntry>,
        entry: QueueEntry,
        dayOf: (Long) -> String,
    ): List<QueueEntry> {
        val day = dayOf(entry.time)
        val known = queue.any {
            it.personId == entry.personId && it.kind == entry.kind && dayOf(it.time) == day
        }
        if (known) return queue
        return (queue + entry).takeLast(MAX_QUEUE)
    }
}

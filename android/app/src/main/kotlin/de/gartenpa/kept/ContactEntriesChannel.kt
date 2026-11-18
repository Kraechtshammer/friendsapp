package de.gartenpa.kept

import android.app.Activity
import android.content.ContentUris
import android.content.Intent
import android.provider.ContactsContract
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * The ways to reach a person that their phone contact holds (02-design.md
 * §8, 2026-11-18, "Any messenger"): the entries messengers write into a
 * linked contact (WhatsApp, Signal, Telegram, ...) and the contact's
 * Website entries. Behind lib/platform/contact_entries.dart.
 *
 * Uses READ_CONTACTS, which the app already holds. Nothing is stored or
 * logged here; Dart looks the entries up again at every "Open chat",
 * because data row ids change when a contact syncs again.
 *
 * Methods: "entries" (contactId) lists the rows that are not one of
 * Android's own kinds, plus Website rows, as id, MIME type, value (data1)
 * and label (data3). "open" (id, mimeType) starts a VIEW on that data row,
 * which the messenger that wrote it answers with the chat.
 */
class ContactEntriesChannel(messenger: BinaryMessenger, private val activity: Activity) {
    private val channel = MethodChannel(messenger, NAME)

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "entries" -> {
                    val id = call.argument<String>("contactId")!!
                    // Off the main thread: a contacts query can take a moment.
                    Thread {
                        val rows = try {
                            entries(id)
                        } catch (e: Exception) {
                            null
                        }
                        activity.runOnUiThread {
                            if (rows == null) {
                                result.error("query", "contact entries failed", null)
                            } else {
                                result.success(rows)
                            }
                        }
                    }.start()
                }
                "open" -> result.success(
                    open(call.argument<String>("id")!!, call.argument<String>("mimeType")!!),
                )
                else -> result.notImplemented()
            }
        }
    }

    private fun entries(contactId: String): List<Map<String, String?>> {
        val out = mutableListOf<Map<String, String?>>()
        activity.contentResolver.query(
            ContactsContract.Data.CONTENT_URI,
            arrayOf(
                ContactsContract.Data._ID,
                ContactsContract.Data.MIMETYPE,
                ContactsContract.Data.DATA1,
                ContactsContract.Data.DATA3,
            ),
            "${ContactsContract.Data.CONTACT_ID} = ?",
            arrayOf(contactId),
            null,
        )?.use { c ->
            while (c.moveToNext()) {
                val mime = c.getString(1) ?: continue
                if (mime in ANDROID_KINDS) continue
                out.add(
                    mapOf(
                        "id" to c.getLong(0).toString(),
                        "mimeType" to mime,
                        "value" to c.getString(2),
                        "label" to c.getString(3),
                    ),
                )
            }
        }
        return out
    }

    private fun open(id: String, mimeType: String): Boolean = try {
        val uri = ContentUris.withAppendedId(ContactsContract.Data.CONTENT_URI, id.toLong())
        activity.startActivity(
            Intent(Intent.ACTION_VIEW)
                .setDataAndType(uri, mimeType)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
        )
        true
    } catch (e: Exception) {
        false
    }

    companion object {
        private const val NAME = "de.gartenpa.kept/contactEntries"

        /** Android's own kinds of contact data; never a messenger entry. */
        private val ANDROID_KINDS = setOf(
            ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE,
            ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE,
            ContactsContract.CommonDataKinds.Email.CONTENT_ITEM_TYPE,
            ContactsContract.CommonDataKinds.Photo.CONTENT_ITEM_TYPE,
            ContactsContract.CommonDataKinds.Organization.CONTENT_ITEM_TYPE,
            ContactsContract.CommonDataKinds.Nickname.CONTENT_ITEM_TYPE,
            ContactsContract.CommonDataKinds.Note.CONTENT_ITEM_TYPE,
            ContactsContract.CommonDataKinds.StructuredPostal.CONTENT_ITEM_TYPE,
            ContactsContract.CommonDataKinds.GroupMembership.CONTENT_ITEM_TYPE,
            ContactsContract.CommonDataKinds.Event.CONTENT_ITEM_TYPE,
            ContactsContract.CommonDataKinds.Relation.CONTENT_ITEM_TYPE,
            ContactsContract.CommonDataKinds.SipAddress.CONTENT_ITEM_TYPE,
            ContactsContract.CommonDataKinds.Identity.CONTENT_ITEM_TYPE,
            ContactsContract.CommonDataKinds.Im.CONTENT_ITEM_TYPE,
        )
    }
}

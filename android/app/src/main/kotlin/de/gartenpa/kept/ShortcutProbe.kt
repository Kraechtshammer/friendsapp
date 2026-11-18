package de.gartenpa.kept

import android.app.Activity
import android.content.ComponentName
import android.content.Intent
import android.content.pm.LauncherApps
import android.os.Build
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Experiment, debug builds only (HANDOFF.md, chat shortcut experiment):
 * can Kept. capture a chat in another messenger through the old
 * "create shortcut" picker (Intent.ACTION_CREATE_SHORTCUT) and open that
 * chat again later?
 *
 * The apps offering the picker are only visible to the debug build: the
 * <queries> entry is in src/debug/AndroidManifest.xml. The Dart side
 * (lib/ui/settings/shortcut_probe_page.dart) is only reachable in debug.
 *
 * Methods: "list" (apps with a picker), "pick" (run one picker, report what
 * came back), "launch" (start a captured intent). Nothing is logged or stored
 * here; Dart keeps the results in memory.
 */
class ShortcutProbe(messenger: BinaryMessenger, private val activity: Activity) {
    private val channel = MethodChannel(messenger, NAME)
    private var pendingPick: MethodChannel.Result? = null

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "list" -> result.success(list())
                "pick" -> pick(
                    call.argument<String>("package")!!,
                    call.argument<String>("activity")!!,
                    result,
                )
                "launch" -> result.success(launch(call.argument<String>("uri")!!))
                else -> result.notImplemented()
            }
        }
    }

    private fun list(): List<Map<String, String>> {
        val pm = activity.packageManager
        return pm.queryIntentActivities(Intent(Intent.ACTION_CREATE_SHORTCUT), 0)
            .map {
                mapOf(
                    "package" to it.activityInfo.packageName,
                    "activity" to it.activityInfo.name,
                    "label" to it.loadLabel(pm).toString(),
                    "app" to it.activityInfo.applicationInfo.loadLabel(pm).toString(),
                )
            }
            .sortedBy { it["app"]!!.lowercase() }
    }

    private fun pick(pkg: String, cls: String, result: MethodChannel.Result) {
        pendingPick?.success(mapOf("error" to "replaced by a new pick"))
        pendingPick = result
        try {
            activity.startActivityForResult(
                Intent(Intent.ACTION_CREATE_SHORTCUT).setComponent(ComponentName(pkg, cls)),
                REQUEST,
            )
        } catch (e: Exception) {
            pendingPick = null
            result.success(mapOf("error" to "start failed: ${e.javaClass.simpleName}: ${e.message}"))
        }
    }

    /** Called from MainActivity.onActivityResult; true if it was ours. */
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST) return false
        val result = pendingPick ?: return true
        pendingPick = null
        result.success(describe(resultCode, data))
        return true
    }

    @Suppress("DEPRECATION")
    private fun describe(resultCode: Int, data: Intent?): Map<String, Any?> {
        val out = mutableMapOf<String, Any?>(
            "resultCode" to when (resultCode) {
                Activity.RESULT_OK -> "OK"
                Activity.RESULT_CANCELED -> "CANCELED"
                else -> resultCode.toString()
            },
        )
        if (data == null) return out
        val extras = data.extras
        out["extras"] = extras?.keySet()?.sorted()?.joinToString(", ")
        out["name"] = data.getStringExtra(Intent.EXTRA_SHORTCUT_NAME)

        // Old format: the intent that opens the chat, right in the result.
        val legacy: Intent? = try {
            data.getParcelableExtra(Intent.EXTRA_SHORTCUT_INTENT)
        } catch (e: Exception) {
            out["legacyError"] = "${e.javaClass.simpleName}: ${e.message}"
            null
        }
        if (legacy != null) {
            out["legacyUri"] = legacy.toUri(Intent.URI_INTENT_SCHEME)
            out["legacyTarget"] = exported(legacy)
        }

        // Android 8+ format: a pin request meant for the default launcher.
        if (Build.VERSION.SDK_INT >= 26) {
            try {
                val req: LauncherApps.PinItemRequest? =
                    data.getParcelableExtra(LauncherApps.EXTRA_PIN_ITEM_REQUEST)
                if (req != null) {
                    out["pinRequest"] = "type=${req.requestType} valid=${req.isValid}"
                    val info = req.shortcutInfo
                    if (info != null) {
                        out["pinShortcut"] = "id=${info.id} label=${info.shortLabel}"
                        val intents = try {
                            info.intents
                        } catch (e: Exception) {
                            null
                        }
                        out["pinIntents"] = intents?.joinToString(" | ") {
                            it.toUri(Intent.URI_INTENT_SCHEME)
                        } ?: "not readable"
                    }
                }
            } catch (e: Exception) {
                out["pinError"] = "${e.javaClass.simpleName}: ${e.message}"
            }
        }
        return out
    }

    /** Where [intent] leads and whether another app may start it. */
    private fun exported(intent: Intent): String {
        val info = activity.packageManager.resolveActivity(intent, 0)?.activityInfo
            ?: return "no activity found (or not visible)"
        return "${info.packageName}/${info.name} exported=${info.exported}"
    }

    private fun launch(uri: String): String = try {
        val intent = Intent.parseUri(uri, Intent.URI_INTENT_SCHEME)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        activity.startActivity(intent)
        "started"
    } catch (e: Exception) {
        "failed: ${e.javaClass.simpleName}: ${e.message}"
    }

    companion object {
        private const val NAME = "de.gartenpa.kept/shortcutProbe"
        private const val REQUEST = 4711
    }
}

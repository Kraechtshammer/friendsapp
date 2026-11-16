package de.gartenpa.kept

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.webkit.MimeTypeMap
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.UUID

/**
 * Sharing into the app (M10): the method channel behind
 * lib/platform/share_receiver.dart. MainActivity hands every ACTION_SEND
 * intent to [handle], at start and in onNewIntent.
 *
 * Text (text/plain) is handed over as it is. A single image is copied into
 * the app's own files directory, folder `shared/`, under a new random name
 * with the extension of its type; Dart gets that path and the app never
 * keeps the other app's URI. Reading the URI works through the read grant
 * that comes with the share; no permission is needed.
 *
 * The share waits here until Dart takes it ("take"). When one arrives while
 * Dart is listening, "available" tells Dart to take it. Nothing is logged.
 */
class ShareChannel(messenger: BinaryMessenger, context: Context) {
    private val app = context.applicationContext
    private val channel = MethodChannel(messenger, NAME)
    private val main = Handler(Looper.getMainLooper())
    private var pending: Map<String, String>? = null
    private var dartListening = false

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "take" -> {
                    dartListening = true
                    result.success(pending)
                    pending = null
                }
                "picturesDirectory" -> result.success(picturesDir(app).path)
                else -> result.notImplemented()
            }
        }
    }

    /** Takes the share out of [intent], if it is one; else does nothing. */
    fun handle(intent: Intent?) {
        if (intent?.action != Intent.ACTION_SEND) return
        // Opened again from the recent apps: the old share, not a new one.
        if (intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0) return
        val type = intent.type ?: return
        when {
            type.startsWith("text/") -> {
                val text = intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString()
                val subject = intent.getStringExtra(Intent.EXTRA_SUBJECT)
                val joined = listOfNotNull(
                    subject?.takeIf { it.isNotBlank() && text?.contains(it) != true },
                    text?.takeIf { it.isNotBlank() },
                ).joinToString("\n")
                if (joined.isNotBlank()) deliver(mapOf("type" to "text", "text" to joined))
            }
            type.startsWith("image/") -> {
                val uri = streamOf(intent) ?: return
                // Copying can take a moment: off the main thread.
                Thread {
                    val path = try {
                        copyImage(uri, type)
                    } catch (e: Exception) {
                        null
                    }
                    if (path != null) {
                        main.post { deliver(mapOf("type" to "image", "path" to path)) }
                    }
                }.start()
            }
        }
    }

    private fun deliver(item: Map<String, String>) {
        pending = item
        if (dartListening) channel.invokeMethod("available", null)
    }

    @Suppress("DEPRECATION")
    private fun streamOf(intent: Intent): Uri? =
        if (Build.VERSION.SDK_INT >= 33) {
            intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            intent.getParcelableExtra(Intent.EXTRA_STREAM)
        }

    /** Copies the image to `files/shared/<random>.<ext>`; returns the path. */
    private fun copyImage(uri: Uri, intentType: String): String? {
        val resolver = app.contentResolver
        val type = resolver.getType(uri) ?: intentType
        if (!type.startsWith("image/")) return null
        val ext = MimeTypeMap.getSingleton().getExtensionFromMimeType(type) ?: "img"
        val dir = picturesDir(app)
        dir.mkdirs()
        val target = File(dir, "${UUID.randomUUID()}.$ext")
        try {
            resolver.openInputStream(uri)?.use { input ->
                target.outputStream().use { output -> input.copyTo(output) }
            } ?: return null
        } catch (e: Exception) {
            target.delete()
            throw e
        }
        return target.path
    }

    companion object {
        private const val NAME = "de.gartenpa.kept/share"

        fun picturesDir(context: Context) = File(context.filesDir, "shared")
    }
}

package de.gartenpa.kept

import android.app.NotificationManager
import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Incoming contact (M7): the method channel between the app and the
 * listener's store (lib/platform/incoming_listener.dart). Built in only with
 * KEPT_INCOMING=true; see IncomingRules.kt.
 */
object IncomingChannel {
    private const val NAME = "de.gartenpa.kept/incoming"

    fun register(messenger: BinaryMessenger, context: Context) {
        val app = context.applicationContext
        MethodChannel(messenger, NAME).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "setEnabled" -> {
                        IncomingStore.setEnabled(app, call.argument<Boolean>("on") == true)
                        result.success(null)
                    }
                    "setWatchList" -> {
                        IncomingStore.setWatchList(app, call.argument<String>("json") ?: "[]")
                        result.success(null)
                    }
                    "takeQueue" -> result.success(IncomingStore.toMaps(IncomingStore.take(app)))
                    "hasAccess" -> result.success(hasAccess(app))
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                // The class name only: no names or ids in the message.
                result.error("incoming", e.javaClass.simpleName, null)
            }
        }
    }

    /** Whether the user has granted notification access to the listener. */
    private fun hasAccess(context: Context): Boolean {
        val component = ComponentName(context, KeptNotificationListener::class.java)
        if (Build.VERSION.SDK_INT >= 27) {
            return context.getSystemService(NotificationManager::class.java)
                .isNotificationListenerAccessGranted(component)
        }
        val enabled = Settings.Secure.getString(context.contentResolver, "enabled_notification_listeners")
        return enabled?.split(':')?.contains(component.flattenToString()) == true
    }
}

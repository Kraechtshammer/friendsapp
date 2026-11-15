package de.gartenpa.kept

import android.app.NotificationManager
import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Throwaway: the "Phone checks" screen (lib/platform/phone_checks.dart).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "de.gartenpa.kept/checks")
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "listenerEnabled" -> result.success(listenerEnabled())
                        "openListenerSettings" -> {
                            startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
                            result.success(null)
                        }
                        "listenerLog" -> result.success(KeptNotificationListener.read(this))
                        "clearListenerLog" -> {
                            KeptNotificationListener.clear(this)
                            result.success(null)
                        }
                        "appIcon" -> result.success(appIcon(call.argument<String>("package")!!))
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    result.error("checks", e.toString(), null)
                }
            }
    }

    private fun listenerEnabled(): Boolean {
        val component = ComponentName(this, KeptNotificationListener::class.java)
        if (Build.VERSION.SDK_INT >= 27) {
            return getSystemService(NotificationManager::class.java)
                .isNotificationListenerAccessGranted(component)
        }
        val enabled = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        return enabled?.split(':')?.contains(component.flattenToString()) == true
    }

    /** The app's launcher icon drawn at 96 px as PNG, or null if not installed. */
    private fun appIcon(packageName: String): ByteArray? {
        val drawable = try {
            packageManager.getApplicationIcon(packageName)
        } catch (_: PackageManager.NameNotFoundException) {
            return null
        }
        val size = 96
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        // Works for adaptive icons too: they are drawn like any Drawable.
        drawable.setBounds(0, 0, size, size)
        drawable.draw(Canvas(bitmap))
        val out = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
        return out.toByteArray()
    }
}

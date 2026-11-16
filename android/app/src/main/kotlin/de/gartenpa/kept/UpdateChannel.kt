package de.gartenpa.kept

import android.annotation.SuppressLint
import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageInstaller
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

/**
 * In-app update (02-design.md §8): the method channel behind
 * lib/platform/app_update.dart. Reads the installed version, opens the
 * "Install unknown apps" switch and installs a downloaded APK through a
 * PackageInstaller session. No network here: Dart downloads the APK, and
 * only while the user has switched the update check on.
 *
 * Not part of a Play build (Google Play does not allow apps that update
 * themselves): delete this file, its two lines in MainActivity.kt and the
 * INTERNET and REQUEST_INSTALL_PACKAGES permissions in the manifest; see
 * lib/app/update_controller.dart for the Dart side.
 *
 * Debug and release builds are separate apps (de.gartenpa.kept.debug and
 * de.gartenpa.kept), so everything that must be unique per app uses
 * [Activity.getPackageName] at runtime.
 */
class UpdateChannel(messenger: BinaryMessenger, private val activity: Activity) {
    private val channel = MethodChannel(messenger, NAME)
    private val installExecutor = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    private val packageName: String = activity.packageName
    private val statusAction = "$packageName.INSTALL_STATUS"
    private var receiver: BroadcastReceiver? = null

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "installedVersion" -> result.success(installedVersion())
                "canInstall" -> result.success(activity.packageManager.canRequestPackageInstalls())
                "openInstallPermission" -> {
                    activity.startActivity(
                        Intent(
                            Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                            Uri.parse("package:$packageName"),
                        ),
                    )
                    result.success(null)
                }
                "install" -> {
                    val path = call.argument<String>("path")
                    if (path == null) {
                        result.error("INSTALL_ERROR", "Missing path", null)
                    } else {
                        installApk(File(path), result)
                    }
                }
                else -> result.notImplemented()
            }
        }
        registerReceiver()
    }

    /** Called from MainActivity.cleanUpFlutterEngine. */
    fun dispose() {
        unregisterReceiver()
        channel.setMethodCallHandler(null)
        installExecutor.shutdown()
    }

    /** This app's versionName, so Dart can compare it with the latest release. */
    private fun installedVersion(): String {
        val pm = activity.packageManager
        val info = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION")
            pm.getPackageInfo(packageName, 0)
        }
        return info.versionName ?: ""
    }

    /**
     * Installs [apk] through a PackageInstaller session. The copy runs off the main thread (the
     * APK is tens of MB); [result] is answered once the session is committed. The user confirms
     * in the system dialog, which [receiver] starts.
     */
    private fun installApk(apk: File, result: MethodChannel.Result) {
        installExecutor.execute {
            val installer = activity.packageManager.packageInstaller
            var sessionId = -1
            try {
                // A restarted update must not collide with an old half-finished session.
                for (old in installer.mySessions) {
                    try {
                        installer.abandonSession(old.sessionId)
                    } catch (_: Exception) {
                    }
                }
                val size = apk.length()
                val params = PackageInstaller.SessionParams(
                    PackageInstaller.SessionParams.MODE_FULL_INSTALL,
                )
                params.setAppPackageName(packageName)
                params.setSize(size)
                sessionId = installer.createSession(params)
                installer.openSession(sessionId).use { session ->
                    session.openWrite("base.apk", 0, size).use { out ->
                        apk.inputStream().use { it.copyTo(out) }
                        session.fsync(out)
                    }
                    // Mutable: the system adds the status extras to this intent.
                    val pending = PendingIntent.getBroadcast(
                        activity,
                        0,
                        Intent(statusAction).setPackage(packageName),
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE,
                    )
                    session.commit(pending.intentSender)
                }
                main.post { result.success(null) }
            } catch (e: Exception) {
                if (sessionId != -1) {
                    try {
                        installer.abandonSession(sessionId)
                    } catch (_: Exception) {
                    }
                }
                main.post { result.error("INSTALL_ERROR", e.message ?: e.toString(), null) }
            }
        }
    }

    /**
     * Receives the installer's status: opens the system confirmation when needed, passes every
     * other status on to Dart.
     */
    @SuppressLint("UnspecifiedRegisterReceiverFlag")
    private fun registerReceiver() {
        unregisterReceiver()
        val r = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                val status = intent.getIntExtra(
                    PackageInstaller.EXTRA_STATUS,
                    PackageInstaller.STATUS_FAILURE,
                )
                val message = intent.getStringExtra(PackageInstaller.EXTRA_STATUS_MESSAGE)
                if (status == PackageInstaller.STATUS_PENDING_USER_ACTION) {
                    val confirm = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        intent.getParcelableExtra(Intent.EXTRA_INTENT, Intent::class.java)
                    } else {
                        @Suppress("DEPRECATION")
                        intent.getParcelableExtra<Intent>(Intent.EXTRA_INTENT)
                    }
                    if (confirm != null) {
                        confirm.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        activity.startActivity(confirm)
                    }
                } else {
                    channel.invokeMethod(
                        "installResult",
                        mapOf("status" to status, "message" to message),
                    )
                }
            }
        }
        val filter = IntentFilter(statusAction)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            activity.registerReceiver(r, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            activity.registerReceiver(r, filter)
        }
        receiver = r
    }

    private fun unregisterReceiver() {
        val r = receiver ?: return
        receiver = null
        try {
            activity.unregisterReceiver(r)
        } catch (_: IllegalArgumentException) {
        }
    }

    companion object {
        private const val NAME = "de.gartenpa.kept/updater"
    }
}

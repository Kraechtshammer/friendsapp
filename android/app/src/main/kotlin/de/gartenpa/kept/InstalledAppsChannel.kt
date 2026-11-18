package de.gartenpa.kept

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Which of the messengers in lib/domain/chat_app.dart are installed
 * (02-design.md §8, 2026-11-18). Kept. only sees the packages named in the
 * manifest's <queries>; no permission is needed. Behind
 * lib/platform/installed_apps.dart.
 *
 * Methods: "installed" (packages) returns the installed ones of them;
 * "hasSmsApp" says whether any app answers smsto: links.
 */
class InstalledAppsChannel(messenger: BinaryMessenger, context: Context) {
    private val pm = context.applicationContext.packageManager

    init {
        MethodChannel(messenger, NAME).setMethodCallHandler { call, result ->
            when (call.method) {
                "installed" -> result.success(
                    call.argument<List<String>>("packages")!!.filter(::isInstalled),
                )
                "hasSmsApp" -> result.success(
                    Intent(Intent.ACTION_SENDTO, Uri.parse("smsto:")).resolveActivity(pm) != null,
                )
                else -> result.notImplemented()
            }
        }
    }

    private fun isInstalled(pkg: String): Boolean = try {
        pm.getPackageInfo(pkg, 0)
        true
    } catch (e: PackageManager.NameNotFoundException) {
        false
    }

    companion object {
        private const val NAME = "de.gartenpa.kept/installedApps"
    }
}

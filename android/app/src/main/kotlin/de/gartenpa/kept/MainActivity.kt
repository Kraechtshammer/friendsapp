package de.gartenpa.kept

import android.content.Intent
import android.content.pm.ApplicationInfo
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var share: ShareChannel? = null
    private var update: UpdateChannel? = null
    private var probe: ShortcutProbe? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Incoming contact (M7), optional part: a no-op unless built with
        // KEPT_INCOMING=true (src/incomingOn or src/incomingOff, build.gradle.kts).
        IncomingSetup.register(flutterEngine.dartExecutor.binaryMessenger, this)
        // Sharing into the app (M10): see ShareChannel.kt.
        share = ShareChannel(flutterEngine.dartExecutor.binaryMessenger, this)
        // In-app update, not in a Play build: see UpdateChannel.kt.
        update = UpdateChannel(flutterEngine.dartExecutor.binaryMessenger, this)
        // "Open chat" through a contact's messenger entry: see ContactEntriesChannel.kt.
        ContactEntriesChannel(flutterEngine.dartExecutor.binaryMessenger, this)
        // Which messengers are installed: see InstalledAppsChannel.kt.
        InstalledAppsChannel(flutterEngine.dartExecutor.binaryMessenger, this)
        // Chat shortcut experiment, debug builds only: see ShortcutProbe.kt.
        if (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE != 0) {
            probe = ShortcutProbe(flutterEngine.dartExecutor.binaryMessenger, this)
        }
    }

    @Deprecated("Needed for startActivityForResult in ShortcutProbe")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (probe?.onActivityResult(requestCode, resultCode, data) == true) return
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        update?.dispose()
        update = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // A share that started the app; not again when Android re-creates it.
        if (savedInstanceState == null) share?.handle(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        share?.handle(intent)
    }
}

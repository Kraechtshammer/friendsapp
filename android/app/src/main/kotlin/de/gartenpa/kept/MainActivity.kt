package de.gartenpa.kept

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var share: ShareChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Incoming contact (M7), optional part: see IncomingRules.kt.
        IncomingChannel.register(flutterEngine.dartExecutor.binaryMessenger, this)
        // Sharing into the app (M10): see ShareChannel.kt.
        share = ShareChannel(flutterEngine.dartExecutor.binaryMessenger, this)
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

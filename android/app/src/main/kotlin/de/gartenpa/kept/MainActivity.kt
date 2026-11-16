package de.gartenpa.kept

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Incoming contact (M7), optional part: see IncomingRules.kt.
        IncomingChannel.register(flutterEngine.dartExecutor.binaryMessenger, this)
    }
}

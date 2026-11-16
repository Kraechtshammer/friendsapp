package de.gartenpa.kept

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger

/**
 * Incoming contact (M7), built in (KEPT_INCOMING=true): MainActivity's one
 * entry point. src/incomingOff has the same object doing nothing.
 */
object IncomingSetup {
    fun register(messenger: BinaryMessenger, context: Context) =
        IncomingChannel.register(messenger, context)
}

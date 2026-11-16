package de.gartenpa.kept

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger

/**
 * Incoming contact (M7), not built in (no KEPT_INCOMING=true): no listener,
 * no channel. The Dart side then never calls the channel
 * (lib/app/build_flags.dart). src/incomingOn has the real one.
 */
object IncomingSetup {
    @Suppress("UNUSED_PARAMETER")
    fun register(messenger: BinaryMessenger, context: Context) = Unit
}

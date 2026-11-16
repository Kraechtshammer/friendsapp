/// Build flags, set with `--dart-define` (docs/03-dev-setup.md).
library;

/// Incoming contact (02-design.md §2.6 and §8): whether the notification
/// listener is built in. `--dart-define=KEPT_INCOMING=true`; off by default,
/// because Play Protect blocks sideloaded APKs that have a notification
/// listener. android/app/build.gradle.kts reads the same flag for the
/// Kotlin side. The UI reads [incomingBuiltInProvider] (providers.dart), so
/// tests can switch it.
const keptIncoming = bool.fromEnvironment('KEPT_INCOMING');

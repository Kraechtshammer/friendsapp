import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'platform/phone_checks.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initPhoneChecks();
  } catch (e, stack) {
    // The app must still open; it just has no notifications.
    debugPrint('Notification setup failed: $e\n$stack');
  }
  runApp(const ProviderScope(child: KeptApp()));
}

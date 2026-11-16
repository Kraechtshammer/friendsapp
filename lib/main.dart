import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';
import 'app/licences.dart';
import 'app/providers.dart';
import 'app/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerLicences();
  // create() can't throw (see there), so the app always opens.
  final services = await AppServices.create();
  runApp(
    ProviderScope(
      overrides: [servicesProvider.overrideWithValue(services)],
      child: const KeptApp(),
    ),
  );
}

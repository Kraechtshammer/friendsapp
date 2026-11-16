import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/licences.dart';
import '../../app/update_controller.dart' show installedVersionProvider;
import '../material.dart';

/// Flutter's licence page with the app's name and the installed version
/// (read from Android, [appVersion] if that fails). The Outfit font's
/// licence is added to it by [registerLicences].
Future<void> openAbout(BuildContext context, WidgetRef ref) async {
  final version = await ref.read(installedVersionProvider.future);
  if (!context.mounted) return;
  showLicensePage(
    context: context,
    applicationName: 'Kept.',
    applicationVersion: version,
  );
}

import '../../app/licences.dart';
import '../material.dart';

/// Flutter's licence page with the app's name and version. The Outfit font's
/// licence is added to it by [registerLicences].
void openAbout(BuildContext context) => showLicensePage(
  context: context,
  applicationName: 'Kept.',
  applicationVersion: appVersion,
);

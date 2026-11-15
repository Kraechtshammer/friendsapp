import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => TabPage(
    title: context.l10n.appTitle,
    actions: [
      IconButton(
        tooltip: context.l10n.settings,
        icon: const KeptIcon(KeptIcons.gear, size: 28),
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
      ),
    ],
    child: const EmptyHint(),
  );
}

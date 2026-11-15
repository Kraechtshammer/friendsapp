import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../checks/phone_checks_screen.dart';
import '../common.dart';
import '../material.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.settingsTheme.toUpperCase(),
            style: context.text.labelMedium,
          ),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text(l10n.themeSystem),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text(l10n.themeLight),
              ),
              ButtonSegment(value: ThemeMode.dark, label: Text(l10n.themeDark)),
            ],
            selected: {ref.watch(themeModeProvider)},
            onSelectionChanged: (chosen) =>
                ref.read(themeModeProvider.notifier).set(chosen.single),
          ),
          const SizedBox(height: 24),
          // Throwaway: remove together with lib/ui/checks/.
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Phone checks'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PhoneChecksScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

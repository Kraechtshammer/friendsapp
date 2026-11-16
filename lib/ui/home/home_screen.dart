import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/greeting.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../settings/settings_screen.dart';
import 'capture_card.dart';
import 'congratulated_screen.dart';
import 'open_thoughts.dart';
import 'tonights_pick.dart';

/// Home: a greeting, quick capture, tonight's pick and the open thoughts. The whole tab
/// scrolls. See 02-design.md §2.1 and the concept V6b · Capturing
/// (docs/concepts/gen_v6.py).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.onAddPeople});

  /// Switches to the People tab (the shell owns the tab).
  final VoidCallback onAddPeople;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = greetingLabel(
      greetingAt(ref.watch(clockProvider)()),
      context.l10n,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
      children: [
        Row(
          children: [
            Expanded(child: Text(greeting, style: context.text.headlineLarge)),
            IconButton(
              tooltip: context.l10n.settings,
              icon: const KeptIcon(KeptIcons.gear, size: 28),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        CaptureCard(onAddPeople: onAddPeople),
        const OwnBirthdayCard(),
        const TonightsPick(),
        const OpenThoughts(),
      ],
    );
  }
}

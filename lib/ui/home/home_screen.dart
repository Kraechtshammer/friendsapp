import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/greeting.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../settings/settings_screen.dart';
import 'back_in_touch_card.dart';
import 'capture_card.dart';
import 'coming_up.dart';
import 'congratulated_screen.dart';
import 'did_it_happen.dart';
import 'open_thoughts.dart';
import 'tonights_pick.dart';
import 'update_ask_card.dart';

/// Home: a greeting, quick capture, "Did it happen?", tonight's pick, what is
/// coming up and the open thoughts. The whole tab scrolls. See 02-design.md §2.1 and the concept V6b · Capturing
/// (docs/concepts/gen_v6.py).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
    required this.onAddPeople,
    required this.onShowUpcoming,
  });

  /// Switches to the People tab (the shell owns the tab).
  final VoidCallback onAddPeople;

  /// Switches to the Upcoming tab ("See all").
  final VoidCallback onShowUpcoming;

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
        // In-app update, not in a Play build (update_controller.dart).
        const UpdateAskCard(),
        const OwnBirthdayCard(),
        const DidItHappen(),
        const BackInTouchCard(),
        const TonightsPick(),
        ComingUp(onSeeAll: onShowUpcoming),
        const OpenThoughts(),
      ],
    );
  }
}

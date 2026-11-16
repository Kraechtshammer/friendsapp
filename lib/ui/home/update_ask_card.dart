import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/update_controller.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/main_button.dart';

/// "Check GitHub for new versions?" (02-design.md §8, in-app update): for
/// an install that finished the first start without being asked (older
/// installs, or a skipped flow), Home asks once. Yes switches the check on,
/// Not now leaves it off; either way the card does not come back. Not part
/// of a Play build (see update_controller.dart).
class UpdateAskCard extends ConsumerWidget {
  const UpdateAskCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    if (settings == null ||
        !settings.firstStartDone ||
        settings.updateCheckAsked) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final controller = ref.read(updateProvider.notifier);
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: KeptCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Row(
              spacing: 14,
              children: [
                const KeptIcon(KeptIcons.gear, size: 40),
                Expanded(
                  child: Text(
                    l10n.updateAskTitle,
                    style: context.text.titleLarge,
                  ),
                ),
              ],
            ),
            Text(l10n.updateAskBody, style: context.text.bodyMedium),
            GreyButton(
              label: l10n.fsNotNow,
              onPressed: () => unawaited(controller.setEnabled(false)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: MainButton(
                label: l10n.yes,
                onPressed: () => unawaited(controller.setEnabled(true)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

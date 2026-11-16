import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/app_settings.dart';
import '../common.dart';
import '../material.dart';

/// How many open items Home shows for tonight: one
/// with "Another one", or a list of three.
class OpenItemsSection extends ConsumerWidget {
  const OpenItemsSection({super.key, required this.mode});

  final OpenItemsMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.settingsOpenItems.toUpperCase(),
          style: context.text.labelMedium,
        ),
        const SizedBox(height: 4),
        Text(l10n.settingsOpenItemsHelp, style: context.text.bodyMedium),
        const SizedBox(height: 12),
        SegmentedButton<OpenItemsMode>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: OpenItemsMode.one,
              label: Text(l10n.openItemsOne),
            ),
            ButtonSegment(
              value: OpenItemsMode.three,
              label: Text(l10n.openItemsThree),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (chosen) => unawaited(
            ref.services.settings.update(
              (s) => s.copyWith(openItems: chosen.single),
            ),
          ),
        ),
      ],
    );
  }
}

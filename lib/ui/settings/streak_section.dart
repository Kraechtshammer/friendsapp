import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/progress.dart' show StreakMode;
import '../common.dart';
import '../material.dart';

/// How "weeks in a row" treats a week without someone beyond the close
/// friends: strict (the run ends) or friendly (it only pauses).
class StreakSection extends ConsumerWidget {
  const StreakSection({super.key, required this.mode});

  final StreakMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.settingsStreak.toUpperCase(),
          style: context.text.labelMedium,
        ),
        const SizedBox(height: 4),
        Text(l10n.settingsStreakHelp, style: context.text.bodyMedium),
        const SizedBox(height: 12),
        SegmentedButton<StreakMode>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: StreakMode.strict,
              label: Text(l10n.streakStrict),
            ),
            ButtonSegment(
              value: StreakMode.friendly,
              label: Text(l10n.streakFriendly),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (chosen) => unawaited(
            ref.services.settings.update(
              (s) => s.copyWith(streakMode: chosen.single),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          mode == StreakMode.strict
              ? l10n.streakStrictHelp
              : l10n.streakFriendlyHelp,
          style: context.text.bodyMedium,
        ),
      ],
    );
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/person.dart';
import '../../domain/stamps.dart';
import '../../l10n/labels.dart';
import '../kept_icon.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/number_stepper.dart';

/// The weights of the stamp rule and the default card size (02-design.md
/// §6.10), each a small stepper. A change counts for contacts from then
/// on; stamps already earned are not changed.
class StampsSection extends ConsumerWidget {
  const StampsSection({super.key, required this.weights});

  final StampWeights weights;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    Widget row(
      Widget leading,
      String label,
      int value,
      int min,
      int max,
      StampWeights Function(StampWeights w, int v) change, {
      String Function(int)? text,
    }) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        spacing: 10,
        children: [
          leading,
          Expanded(child: Text(label, style: context.text.bodyLarge)),
          SizedBox(
            width: 148,
            child: NumberStepper(
              value: value,
              min: min,
              max: max,
              label: text,
              onChanged: (v) => unawaited(
                ref.services.settings.update(
                  (s) => s.copyWith(stampWeights: change(s.stampWeights, v)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Widget classRow(
      Closeness c,
      int value,
      StampWeights Function(StampWeights w, int v) change,
    ) => row(
      KeptIcon(closenessIcon(c), size: 24),
      closenessGroupLabel(c, l10n),
      value,
      StampWeights.minClass,
      StampWeights.maxClass,
      change,
    );
    const noIcon = SizedBox(width: 24);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.settingsStamps.toUpperCase(),
          style: context.text.labelMedium,
        ),
        const SizedBox(height: 4),
        Text(l10n.settingsStampsHelp, style: context.text.bodyMedium),
        const SizedBox(height: 12),
        classRow(
          Closeness.close,
          weights.close,
          (w, v) => w.copyWith(close: v),
        ),
        classRow(
          Closeness.nowAndThen,
          weights.nowAndThen,
          (w, v) => w.copyWith(nowAndThen: v),
        ),
        classRow(
          Closeness.fewTimesAYear,
          weights.fewTimesAYear,
          (w, v) => w.copyWith(fewTimesAYear: v),
        ),
        classRow(
          Closeness.family,
          weights.family,
          (w, v) => w.copyWith(family: v),
        ),
        row(
          noIcon,
          l10n.stampBackInTouch,
          weights.backInTouchBonus,
          StampWeights.minBonus,
          StampWeights.maxBonus,
          (w, v) => w.copyWith(backInTouchBonus: v),
          text: (v) => '+$v',
        ),
        row(
          noIcon,
          l10n.stampLongGap,
          weights.longGapBonus,
          StampWeights.minBonus,
          StampWeights.maxBonus,
          (w, v) => w.copyWith(longGapBonus: v),
          text: (v) => '+$v',
        ),
        row(
          noIcon,
          l10n.stampMeetUp,
          weights.meetMultiplier,
          StampWeights.minMultiplier,
          StampWeights.maxMultiplier,
          (w, v) => w.copyWith(meetMultiplier: v),
          text: (v) => '×$v',
        ),
        row(
          noIcon,
          l10n.stampGaming,
          weights.gameMultiplier,
          StampWeights.minMultiplier,
          StampWeights.maxMultiplier,
          (w, v) => w.copyWith(gameMultiplier: v),
          text: (v) => '×$v',
        ),
        row(
          noIcon,
          l10n.stampGamingClose,
          weights.gameCloseMultiplier,
          StampWeights.minMultiplier,
          StampWeights.maxMultiplier,
          (w, v) => w.copyWith(gameCloseMultiplier: v),
          text: (v) => '×$v',
        ),
        row(
          noIcon,
          l10n.stampCardSize,
          weights.cardSize,
          StampWeights.minCardSize,
          StampWeights.maxCardSize,
          (w, v) => w.copyWith(cardSize: v),
        ),
      ],
    );
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/app_settings.dart';
import '../../domain/person.dart';
import '../../domain/reconnect_span.dart';
import '../../domain/rhythm.dart';
import '../../l10n/labels.dart';
import '../kept_icon.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/rhythm_stepper.dart';

/// The rhythm of each class (02-design.md §6.9, §6.10): one stepper per
/// class over [rhythmSpans] and "None". A rhythm only drives the gentle
/// hint on Home, never an overdue mark. Family starts with none.
class RhythmsSection extends ConsumerWidget {
  const RhythmsSection({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.settingsRhythms.toUpperCase(),
          style: context.text.labelMedium,
        ),
        const SizedBox(height: 4),
        Text(l10n.settingsRhythmsHelp, style: context.text.bodyMedium),
        const SizedBox(height: 12),
        for (final c in Closeness.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              spacing: 10,
              children: [
                KeptIcon(closenessIcon(c), size: 24),
                Expanded(
                  child: Text(
                    closenessGroupLabel(c, l10n),
                    style: context.text.bodyLarge,
                  ),
                ),
                SizedBox(
                  width: 196,
                  child: RhythmStepper(
                    options: rhythmOptions(current: settings.rhythmOf(c)),
                    value: settings.rhythmOf(c),
                    label: (days) => days == null
                        ? l10n.rhythmNone
                        : rhythmLabel(days, l10n),
                    onChanged: (days) => unawaited(
                      ref.services.settings.update(
                        (s) => s.withClassRhythm(c, days),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            spacing: 10,
            children: [
              Expanded(
                child: Text(
                  l10n.settingsReconnectSpan,
                  style: context.text.bodyLarge,
                ),
              ),
              SizedBox(
                width: 196,
                child: RhythmStepper(
                  options: [for (final v in ReconnectSpan.values) v.index],
                  value: settings.reconnectSpan.index,
                  label: (i) =>
                      reconnectSpanLabel(ReconnectSpan.values[i!], l10n),
                  onChanged: (i) => unawaited(
                    ref.services.settings.update(
                      (s) =>
                          s.copyWith(reconnectSpan: ReconnectSpan.values[i!]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(l10n.settingsReconnectSpanHelp, style: context.text.bodyMedium),
      ],
    );
  }
}

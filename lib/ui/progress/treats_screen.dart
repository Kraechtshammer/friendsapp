import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/progress.dart';
import '../../domain/treat.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/dashed_card.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/section_label.dart';
import 'stamp_card.dart';
import 'treat_sheet.dart';

/// Opens the list of treats.
Future<void> openTreats(BuildContext context) =>
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const TreatsScreen()));

/// The treats (02-design.md §6.9, §6.10): the current card, earned
/// treats with "Enjoyed", the waiting queue (start a card, rename, change
/// the stamp number, move, delete, add) and the enjoyed ones. A card can
/// only be started when no other is current.
class TreatsScreen extends ConsumerWidget {
  const TreatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final treats = ref.watch(treatsProvider).value ?? const <Treat>[];
    final stamps = ref.watch(stampsProvider).value ?? const <Stamp>[];
    final current = currentTreat(treats);
    final earned = treatsIn(treats, TreatState.earned);
    final waiting = treatsIn(treats, TreatState.waiting);
    final enjoyed = treatsIn(treats, TreatState.enjoyed);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.treatsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          StampCard(
            treat: current,
            filled: current == null ? 0 : stampsOnCard(stamps, current.id),
          ),
          if (earned.isNotEmpty) ...[
            _Heading(l10n.treatsEarned),
            for (final t in earned)
              _Row(
                treat: t,
                icon: KeptIcons.gift,
                trailing: GreyButton(
                  small: true,
                  label: l10n.treatEnjoyedButton,
                  onPressed: () => unawaited(
                    ref.read(treatsRepositoryProvider).markEnjoyed(t.id),
                  ),
                ),
              ),
          ],
          _Heading(l10n.treatsWaiting),
          for (final t in waiting)
            _Row(
              treat: t,
              icon: KeptIcons.gift,
              onTap: () => showTreatSheet(context, ref, treat: t),
              trailing: current == null
                  ? GreyButton(
                      small: true,
                      label: l10n.treatStart,
                      onPressed: () => unawaited(
                        ref.read(treatsRepositoryProvider).setCurrent(t.id),
                      ),
                    )
                  : null,
            ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => showTreatSheet(context, ref),
            child: DashedCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  Icon(Icons.add_rounded, color: context.kept.muted),
                  Text(
                    l10n.treatAdd,
                    style: context.text.labelLarge?.copyWith(
                      color: context.kept.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (enjoyed.isNotEmpty) ...[
            _Heading(l10n.treatsEnjoyed),
            for (final t in enjoyed)
              _Row(treat: t, icon: KeptIcons.check, muted: true),
          ],
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 22, 0, 10),
    child: SectionLabel(label),
  );
}

class _Row extends StatelessWidget {
  const _Row({
    required this.treat,
    required this.icon,
    this.trailing,
    this.onTap,
    this.muted = false,
  });

  final Treat treat;
  final KeptIcons icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: KeptCard(
        small: true,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          spacing: 12,
          children: [
            Opacity(opacity: muted ? .6 : 1, child: KeptIcon(icon, size: 28)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    treat.name,
                    style: context.text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: muted ? kept.muted : kept.text,
                    ),
                  ),
                  Text(
                    context.l10n.treatStamps(treat.stampsNeeded),
                    style: context.text.bodyMedium,
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

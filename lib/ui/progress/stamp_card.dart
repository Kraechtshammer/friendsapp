import '../../data/database.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/kept_card.dart';
import '../widgets/section_label.dart';
import '../widgets/stamps.dart';

/// The current stamp card (ui-style.md §6, concept V6 · Progress and stamp
/// card): a sun tonal card with the treat's name, its stamps in place and
/// dashed rings for the empty slots. With no current treat it invites the
/// user to choose one. [onMyTreats] opens the list of treats.
class StampCard extends StatelessWidget {
  const StampCard({
    super.key,
    required this.treat,
    required this.filled,
    this.onMyTreats,
  });

  final Treat? treat;
  final int filled;
  final VoidCallback? onMyTreats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tone = context.kept.sunTone;
    final treat = this.treat;
    return KeptCard(
      tone: tone,
      onTap: onMyTreats,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            children: [
              Expanded(
                child: SectionLabel(
                  l10n.stampCardTitle,
                  color: tone.onContainer,
                ),
              ),
              if (onMyTreats != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    Text(
                      l10n.myTreats,
                      style: context.text.labelLarge?.copyWith(
                        fontSize: 14,
                        color: tone.onContainer,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: tone.onContainer,
                    ),
                  ],
                ),
            ],
          ),
          if (treat == null) ...[
            Row(
              spacing: 12,
              children: [
                const KeptIcon(KeptIcons.gift, size: 30),
                Expanded(
                  child: Text(
                    l10n.stampCardChoose,
                    style: context.text.titleLarge?.copyWith(
                      color: tone.onContainer,
                    ),
                  ),
                ),
              ],
            ),
            Text(l10n.stampCardChooseHint),
          ] else ...[
            Row(
              spacing: 12,
              children: [
                const KeptIcon(KeptIcons.gift, size: 30),
                Expanded(
                  child: Text(
                    treat.name,
                    style: context.text.titleLarge?.copyWith(
                      color: tone.onContainer,
                    ),
                  ),
                ),
              ],
            ),
            StampSlots(filled: filled, total: treat.stampsNeeded),
            Text(
              l10n.stampCardLeft(
                (treat.stampsNeeded - filled).clamp(1, treat.stampsNeeded),
              ),
              style: context.text.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

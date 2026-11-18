import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';

/// The icons the user can give an activity, in the order of the grid:
/// the meetup icons first, then the app's other object icons. Messenger
/// stand-ins, settings symbols and the class badge plants are left out
/// (02-design.md §8, 2026-11-18).
const activityIcons = [
  KeptIcons.cups,
  KeptIcons.plate,
  KeptIcons.beer,
  KeptIcons.party,
  KeptIcons.pot,
  KeptIcons.chat,
  KeptIcons.bench,
  KeptIcons.runner,
  KeptIcons.climber,
  KeptIcons.dumbbell,
  KeptIcons.meeple,
  KeptIcons.controller,
  KeptIcons.popcorn,
  KeptIcons.ticket,
  KeptIcons.clapper,
  KeptIcons.notes,
  KeptIcons.guitar,
  KeptIcons.microphone,
  KeptIcons.tools,
  KeptIcons.bag,
  KeptIcons.home,
  KeptIcons.cottage,
  KeptIcons.mountain,
  KeptIcons.people,
  KeptIcons.cake,
  KeptIcons.gift,
  KeptIcons.dice,
  KeptIcons.wasd,
  KeptIcons.phone,
  KeptIcons.calendar,
  KeptIcons.star,
  KeptIcons.leaf,
  KeptIcons.flower,
];

/// The icon stored under [name] (the enum name, as in the database), or
/// null for none or a name this version does not know.
KeptIcons? activityIconByName(String? name) =>
    name == null ? null : KeptIcons.values.asNameMap()[name];

/// The square button beside an activity field: the chosen icon, or a plain
/// placeholder symbol when there is none. A tap opens the grid; the
/// result goes to [onChanged] (null clears it).
class ActivityIconButton extends StatelessWidget {
  const ActivityIconButton({
    super.key,
    required this.icon,
    required this.onChanged,
    this.size = 52,
  });

  final KeptIcons? icon;
  final ValueChanged<KeptIcons?> onChanged;
  final double size;

  Future<void> _pick(BuildContext context) async {
    final picked = await showActivityIconPicker(context, selected: icon);
    if (picked != null) onChanged(picked.icon);
  }

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    final shape = BorderRadius.circular(18);
    final current = icon;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: [
          BoxShadow(color: kept.greyEdge, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: kept.surfaceHigh,
        borderRadius: shape,
        child: InkWell(
          borderRadius: shape,
          onTap: () => _pick(context),
          child: Tooltip(
            message: context.l10n.activityIconButton,
            child: SizedBox.square(
              dimension: size,
              child: Center(
                child: current == null
                    ? Icon(Icons.add_reaction_outlined, color: kept.muted)
                    : KeptIcon(current, size: 30),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// What the grid returned: a picked icon, or null for "No icon".
typedef ActivityIconChoice = ({KeptIcons? icon});

/// Opens the grid of [activityIcons]. Returns null when it is closed
/// without a choice.
Future<ActivityIconChoice?> showActivityIconPicker(
  BuildContext context, {
  KeptIcons? selected,
}) => showModalBottomSheet<ActivityIconChoice>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  backgroundColor: context.kept.surface,
  builder: (_) => _PickerSheet(selected),
);

class _PickerSheet extends StatelessWidget {
  const _PickerSheet(this.selected);

  final KeptIcons? selected;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text(
            l10n.activityIconPick,
            style: context.text.titleLarge?.copyWith(color: kept.text),
          ),
          GridView.extent(
            maxCrossAxisExtent: 64,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final icon in activityIcons)
                _Cell(
                  icon: icon,
                  selected: icon == selected,
                  onTap: () => Navigator.of(context).pop((icon: icon)),
                ),
            ],
          ),
          if (selected != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop((icon: null)),
              child: Text(l10n.activityIconNone),
            ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final KeptIcons icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    final shape = BorderRadius.circular(16);
    return Material(
      color: selected ? kept.surfaceHigh : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: shape,
        side: selected
            ? BorderSide(color: kept.text, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: shape,
        onTap: onTap,
        child: Center(child: KeptIcon(icon, size: 34)),
      ),
    );
  }
}

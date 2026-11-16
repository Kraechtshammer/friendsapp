import '../../data/database.dart';
import '../../domain/person_name.dart';
import '../../domain/recent_people.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import 'person_picker.dart';

/// The row of faces to pick a person from: the recent people
/// ([recentPeople]) and "More", which opens the searchable picker. The
/// picked person always shows in the row. Used by the capture card and the
/// share sheet. Tapping the picked face again unpicks it.
class PersonChoiceRow extends StatelessWidget {
  const PersonChoiceRow({
    super.key,
    required this.people,
    required this.intentions,
    required this.selectedId,
    required this.onChanged,
    required this.textColor,
    required this.fieldColor,
  });

  final List<Person> people;

  /// For the order of the recent people.
  final List<Intention> intentions;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  /// The colour of the first names, to suit the card or sheet behind.
  final Color textColor;

  /// The colour behind the picked face and the "More" icon.
  final Color fieldColor;

  @override
  Widget build(BuildContext context) {
    Person? selected;
    for (final p in people) {
      if (p.id == selectedId) selected = p;
    }
    final shown = recentPeople(people, intentions);
    if (selected != null && !shown.any((p) => p.id == selected!.id)) {
      if (shown.length == 4) shown.removeLast();
      shown.add(selected);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final p in shown)
          Expanded(
            child: _Blob(
              label: firstNameOf(p.name),
              selected: p.id == selected?.id,
              dimmed: selected != null && p.id != selected.id,
              textColor: textColor,
              fieldColor: fieldColor,
              onTap: () => onChanged(p.id == selectedId ? null : p.id),
              face: Avatar.person(p, size: 48, classBadge: true),
            ),
          ),
        Expanded(
          child: _Blob(
            label: context.l10n.captureMore,
            selected: false,
            dimmed: selected != null,
            textColor: textColor,
            fieldColor: fieldColor,
            onTap: () async {
              final picked = await showPersonPicker(context, people);
              if (picked != null) onChanged(picked.id);
            },
            face: _MoreFace(fieldColor),
          ),
        ),
      ],
    );
  }
}

/// A face over a first name. The chosen one sits on the field colour with
/// bold text, the others fade (concept V6b).
class _Blob extends StatelessWidget {
  const _Blob({
    required this.label,
    required this.face,
    required this.selected,
    required this.dimmed,
    required this.textColor,
    required this.fieldColor,
    required this.onTap,
  });

  final String label;
  final Widget face;
  final bool selected;
  final bool dimmed;
  final Color textColor;
  final Color fieldColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Opacity(
        opacity: dimmed ? .45 : 1,
        child: Material(
          color: selected ? fieldColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  face,
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The "More" blob: the search icon on the field colour.
class _MoreFace extends StatelessWidget {
  const _MoreFace(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(24),
    ),
    child: const KeptIcon(KeptIcons.search, size: 26),
  );
}

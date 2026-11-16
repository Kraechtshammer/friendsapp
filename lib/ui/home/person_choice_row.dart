import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/display_name.dart';
import '../../domain/group.dart';
import '../../domain/recent_people.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../widgets/couple_avatar.dart';
import 'person_picker.dart';

/// The row of faces to pick a person from: the recent people
/// ([recentPeople]) and "More", which opens the searchable picker. The
/// picked person always shows in the row. Used by the capture card and the
/// share sheet. Tapping the picked face again unpicks it.
///
/// With [couples] a couple is one more choice, with the couple avatar and
/// both names. A couple with a thought ranks by it like a person; the rest
/// come after the people. [selectedId] and [onChanged] then carry a person
/// id or a group id (uuids, so they cannot clash); the caller tells them
/// apart with its own list of couples.
class PersonChoiceRow extends ConsumerWidget {
  const PersonChoiceRow({
    super.key,
    required this.people,
    required this.intentions,
    required this.selectedId,
    required this.onChanged,
    required this.textColor,
    required this.fieldColor,
    this.couples = const [],
  });

  final List<Person> people;
  final List<GroupWithMembers> couples;

  /// For the order of the recent people.
  final List<Intention> intentions;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  /// The colour of the first names, to suit the card or sheet behind.
  final Color textColor;

  /// The colour behind the picked face and the "More" icon.
  final Color fieldColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names = ref.watch(displayNamesProvider);
    final choices = _choices(names);
    var selectedChoice = choices.where((c) => c.id == selectedId).firstOrNull;
    if (selectedChoice == null && selectedId != null) {
      // Picked through "More": it always shows in the row.
      final extra = _allChoices(names).where((c) => c.id == selectedId);
      if (extra.isNotEmpty) {
        selectedChoice = extra.first;
        if (choices.length == 4) choices.removeLast();
        choices.add(selectedChoice);
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final c in choices)
          Expanded(
            child: _Blob(
              label: c.label,
              selected: c.id == selectedChoice?.id,
              dimmed: selectedChoice != null && c.id != selectedChoice.id,
              textColor: textColor,
              fieldColor: fieldColor,
              onTap: () => onChanged(c.id == selectedId ? null : c.id),
              face: c.couple == null
                  ? Avatar.person(c.person, size: 48, classBadge: true)
                  : CoupleAvatar(
                      c.couple!.members,
                      size: 48,
                      ringColor: c.id == selectedChoice?.id ? fieldColor : null,
                    ),
            ),
          ),
        Expanded(
          child: _Blob(
            label: context.l10n.captureMore,
            selected: false,
            dimmed: selectedChoice != null,
            textColor: textColor,
            fieldColor: fieldColor,
            onTap: () async {
              final picked = await showSubjectPicker(
                context,
                people,
                couples: couples,
              );
              if (picked != null) {
                onChanged(picked.couple?.group.id ?? picked.person.id);
              }
            },
            face: _MoreFace(fieldColor),
          ),
        ),
      ],
    );
  }

  /// Everyone and every couple as a choice, in no special order.
  List<_Choice> _allChoices(Map<String, String> names) => [
    for (final p in people) _Choice(p.id, shortNameIn(names, p), p),
    for (final c in couples)
      _Choice(c.group.id, c.label(names), c.members.first, couple: c),
  ];

  /// The choices the row shows: the recent people and the couples, with
  /// the ones that have a thought first, newest thought first.
  List<_Choice> _choices(Map<String, String> names) {
    final latest = <String, DateTime>{};
    for (final i in intentions) {
      final id = i.personId ?? i.groupId;
      if (id == null) continue;
      final seen = latest[id];
      if (seen == null || i.createdAt.isAfter(seen)) latest[id] = i.createdAt;
    }
    final all = [
      for (final p in recentPeople(people, intentions))
        _Choice(p.id, shortNameIn(names, p), p),
      for (final c in couples)
        _Choice(c.group.id, c.label(names), c.members.first, couple: c),
    ];
    // A stable sort: people and couples without a thought keep their order.
    final withThought =
        [
          for (final (i, c) in all.indexed)
            if (latest[c.id] != null) (i, c),
        ]..sort((a, b) {
          final c = latest[b.$2.id]!.compareTo(latest[a.$2.id]!);
          return c != 0 ? c : a.$1.compareTo(b.$1);
        });
    final without = [
      for (final c in all)
        if (latest[c.id] == null) c,
    ];
    return [for (final (_, c) in withThought) c, ...without].take(4).toList();
  }
}

/// One thing to pick: a person, or a couple ([couple] set; [person] is its
/// first member).
class _Choice {
  const _Choice(this.id, this.label, this.person, {this.couple});

  final String id;
  final String label;
  final Person person;
  final GroupWithMembers? couple;
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

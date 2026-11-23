import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/display_name.dart';
import '../../domain/group.dart';
import '../../domain/recent_people.dart';
import '../common.dart';
import '../material.dart';
import '../people/people_multi_picker.dart';
import '../widgets/face_blob.dart';

/// Everyone and every couple as a choice, for the capture card.
List<PersonChoice> allChoices(
  List<Person> people,
  List<GroupWithMembers> couples,
  Map<String, String> names,
) => [
  for (final p in people) PersonChoice(p.id, shortNameIn(names, p), p),
  for (final c in couples)
    PersonChoice(c.group.id, c.label(names), c.members.first, couple: c),
];

/// The faces to suggest on the capture card (02-design.md §8, 2026-11-23):
/// the people with the most contact events in the last 90 days first (a
/// couple counts its members' events), then the recent people
/// ([recentPeople]), then the couples. At most four.
List<PersonChoice> suggestedChoices({
  required List<Person> people,
  required List<GroupWithMembers> couples,
  required List<Intention> intentions,
  required List<ContactEvent> events,
  required DateTime now,
  required Map<String, String> names,
}) {
  final since = now.subtract(const Duration(days: 90));
  final count = <String, int>{};
  for (final e in events) {
    if (e.at.isAfter(since)) count[e.personId] = (count[e.personId] ?? 0) + 1;
  }
  final base = [
    for (final p in recentPeople(people, intentions, limit: people.length))
      PersonChoice(p.id, shortNameIn(names, p), p),
    for (final c in couples)
      PersonChoice(c.group.id, c.label(names), c.members.first, couple: c),
  ];
  int score(PersonChoice c) =>
      c.members.fold(0, (sum, p) => sum + (count[p.id] ?? 0));
  final ranked = [for (final (i, c) in base.indexed) (i, c)]
    ..sort((a, b) {
      final d = score(b.$2).compareTo(score(a.$2));
      return d != 0 ? d : a.$1.compareTo(b.$1);
    });
  return [for (final (_, c) in ranked.take(4)) c];
}

/// The faces row of the capture card: the chosen people first, then the
/// suggestions that are left (faded), then the dashed "+" that opens the
/// picker. Chosen faces wrap onto more lines; suggestions that do not fit
/// on the first line are left out, so nothing scrolls.
class WhoRow extends ConsumerWidget {
  const WhoRow({
    super.key,
    required this.choices,
    required this.suggestions,
    required this.chosen,
    required this.onChanged,
  });

  final List<PersonChoice> choices;
  final List<PersonChoice> suggestions;

  /// The ids chosen, in the order they were chosen.
  final List<String> chosen;
  final ValueChanged<List<String>> onChanged;

  static const _slot = 60.0;
  static const _gap = 4.0;

  Future<void> _more(BuildContext context) async {
    final picked = await showPeopleMultiPicker(
      context,
      choices,
      title: context.l10n.captureTitle,
      initial: {...chosen},
    );
    if (picked == null) return;
    final ids = {for (final c in picked) c.id};
    onChanged([
      for (final id in chosen)
        if (ids.contains(id)) id,
      for (final c in picked)
        if (!chosen.contains(c.id)) c.id,
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final byId = {for (final c in choices) c.id: c};
    final picked = [
      for (final id in chosen)
        if (byId[id] != null) byId[id]!,
    ];
    final rest = [
      for (final s in suggestions)
        if (!chosen.contains(s.id)) s,
    ];
    void toggle(PersonChoice c) => onChanged(
      chosen.contains(c.id)
          ? [
              for (final id in chosen)
                if (id != c.id) id,
            ]
          : [...chosen, c.id],
    );
    return LayoutBuilder(
      builder: (context, box) {
        final perLine = ((box.maxWidth + _gap) / (_slot + _gap)).floor();
        final room = (perLine - picked.length - 1).clamp(0, rest.length);
        return Wrap(
          spacing: _gap,
          runSpacing: 8,
          children: [
            for (final c in picked)
              FaceBlob(
                label: c.label,
                face: c.face(48),
                selected: true,
                onTap: () => toggle(c),
              ),
            for (final c in rest.take(room))
              FaceBlob(
                label: c.label,
                face: c.face(48),
                faded: true,
                onTap: () => toggle(c),
              ),
            AddFaceBlob(
              label: suggestions.isEmpty && picked.isEmpty
                  ? l10n.capturePickPeople
                  : l10n.captureMore,
              onTap: () => _more(context),
            ),
          ],
        );
      },
    );
  }
}

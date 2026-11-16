import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/group.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../widgets/couple_avatar.dart';
import '../widgets/kept_text_field.dart';

/// A bottom sheet with everyone and a search field. Returns the person
/// tapped, or null.
Future<Person?> showPersonPicker(
  BuildContext context,
  List<Person> people,
) async => (await showSubjectPicker(context, people))?.person;

/// Like [showPersonPicker], and the [couples] are offered as one choice
/// each, above the people ("Anna & Tom", with the couple avatar). Returns
/// who was tapped: a person, or a couple (`ThoughtSubject.couple`).
Future<ThoughtSubject?> showSubjectPicker(
  BuildContext context,
  List<Person> people, {
  List<GroupWithMembers> couples = const [],
}) => showModalBottomSheet<ThoughtSubject>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _PersonPicker(people, couples),
);

class _PersonPicker extends ConsumerStatefulWidget {
  const _PersonPicker(this.people, this.couples);

  final List<Person> people;
  final List<GroupWithMembers> couples;

  @override
  ConsumerState<_PersonPicker> createState() => _PersonPickerState();
}

class _PersonPickerState extends ConsumerState<_PersonPicker> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = _search.text.trim().toLowerCase();
    bool matchesPerson(Person p) =>
        p.name.toLowerCase().contains(query) ||
        (p.nickname ?? '').toLowerCase().contains(query);
    final names = ref.watch(displayNamesProvider);
    final matches = [
      for (final p in widget.people)
        if (matchesPerson(p)) p,
    ];
    final couples = [
      for (final c in widget.couples)
        if (c.members.any(matchesPerson) ||
            c.label(names).toLowerCase().contains(query))
          c,
    ];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: KeptTextField(
                controller: _search,
                hint: l10n.pickerSearchHint,
                onChanged: (_) => setState(() {}),
              ),
            ),
            Expanded(
              child: matches.isEmpty && couples.isEmpty
                  ? Center(
                      child: Text(
                        l10n.pickerNoMatch,
                        style: context.text.bodyMedium,
                      ),
                    )
                  : ListView(
                      children: [
                        for (final c in couples)
                          ListTile(
                            leading: CoupleAvatar(
                              c.members,
                              size: 40,
                              ringColor: context.kept.surface,
                            ),
                            title: Text(
                              c.label(names),
                              style: context.text.bodyLarge,
                            ),
                            onTap: () => Navigator.of(
                              context,
                            ).pop(ThoughtSubject(c.members.first, couple: c)),
                          ),
                        for (final p in matches)
                          ListTile(
                            leading: Avatar.person(p, size: 40),
                            title: Text(p.name, style: context.text.bodyLarge),
                            onTap: () =>
                                Navigator.of(context).pop(ThoughtSubject(p)),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

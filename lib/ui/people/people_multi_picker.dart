import '../../data/database.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../widgets/kept_text_field.dart';
import '../widgets/main_button.dart';

/// A bottom sheet to tick several of [people] (with a search field).
/// Returns the ticked people in the order of [people], or null when closed
/// without Done.
Future<List<Person>?> showPeopleMultiPicker(
  BuildContext context,
  List<Person> people, {
  required String title,
}) => showModalBottomSheet<List<Person>>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _PeopleMultiPicker(people, title),
);

class _PeopleMultiPicker extends StatefulWidget {
  const _PeopleMultiPicker(this.people, this.title);

  final List<Person> people;
  final String title;

  @override
  State<_PeopleMultiPicker> createState() => _PeopleMultiPickerState();
}

class _PeopleMultiPickerState extends State<_PeopleMultiPicker> {
  final _search = TextEditingController();
  final _ticked = <String>{};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = _search.text.trim().toLowerCase();
    final matches = [
      for (final p in widget.people)
        if (p.name.toLowerCase().contains(query) ||
            (p.nickname ?? '').toLowerCase().contains(query))
          p,
    ];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                widget.title,
                style: context.text.titleLarge?.copyWith(
                  color: context.kept.text,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: KeptTextField(
                controller: _search,
                hint: l10n.pickerSearchHint,
                onChanged: (_) => setState(() {}),
              ),
            ),
            Expanded(
              child: matches.isEmpty
                  ? Center(
                      child: Text(
                        l10n.pickerNoMatch,
                        style: context.text.bodyMedium,
                      ),
                    )
                  : ListView(
                      children: [
                        for (final p in matches)
                          CheckboxListTile(
                            value: _ticked.contains(p.id),
                            secondary: Avatar.person(p, size: 40),
                            title: Text(p.name, style: context.text.bodyLarge),
                            onChanged: (on) => setState(() {
                              if (on ?? false) {
                                _ticked.add(p.id);
                              } else {
                                _ticked.remove(p.id);
                              }
                            }),
                          ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: MainButton(
                label: l10n.done,
                onPressed: () => Navigator.of(context).pop([
                  for (final p in widget.people)
                    if (_ticked.contains(p.id)) p,
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

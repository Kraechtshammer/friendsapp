import '../common.dart';
import '../material.dart';
import '../widgets/face_blob.dart';
import '../widgets/kept_text_field.dart';
import '../widgets/main_button.dart';

/// A bottom sheet over the screen with everyone in a grid like the People
/// tab, a search field and a counter. Tapped people get a ring and a check;
/// [initial] holds the ids chosen already. Returns the chosen ones in the
/// order of [choices], or null when closed without Done.
Future<List<PersonChoice>?> showPeopleMultiPicker(
  BuildContext context,
  List<PersonChoice> choices, {
  required String title,
  Set<String> initial = const {},
}) => showModalBottomSheet<List<PersonChoice>>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  backgroundColor: context.kept.surface,
  builder: (_) => _PeopleMultiPicker(choices, title, initial),
);

class _PeopleMultiPicker extends StatefulWidget {
  const _PeopleMultiPicker(this.choices, this.title, this.initial);

  final List<PersonChoice> choices;
  final String title;
  final Set<String> initial;

  @override
  State<_PeopleMultiPicker> createState() => _PeopleMultiPickerState();
}

class _PeopleMultiPickerState extends State<_PeopleMultiPicker> {
  final _search = TextEditingController();
  late final _chosen = {...widget.initial};

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
      for (final c in widget.choices)
        if (c.members.any(
          (p) =>
              p.name.toLowerCase().contains(query) ||
              (p.nickname ?? '').toLowerCase().contains(query),
        ))
          c,
    ];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: context.text.titleLarge?.copyWith(
                        color: context.kept.text,
                      ),
                    ),
                  ),
                  Text(
                    l10n.pickerChosen(_chosen.length),
                    style: context.text.bodyMedium,
                  ),
                ],
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
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 4,
                        runSpacing: 10,
                        children: [
                          for (final c in matches)
                            FaceBlob(
                              label: c.label,
                              face: c.face(54),
                              size: 54,
                              width: 76,
                              selected: _chosen.contains(c.id),
                              onTap: () => setState(() {
                                if (!_chosen.add(c.id)) _chosen.remove(c.id);
                              }),
                            ),
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: MainButton(
                label: l10n.done,
                onPressed: () => Navigator.of(context).pop([
                  for (final c in widget.choices)
                    if (_chosen.contains(c.id)) c,
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

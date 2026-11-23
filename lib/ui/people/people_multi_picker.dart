import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/app_settings.dart';
import '../../domain/group.dart';
import '../../domain/person.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/face_blob.dart';
import '../widgets/grey_icon_button.dart';
import '../widgets/kept_text_field.dart';
import '../widgets/main_button.dart';
import '../widgets/section_label.dart';

/// A bottom sheet over the screen with everyone in a grid like the People
/// tab, a search field and a counter. Tapped people get a ring and a check;
/// [initial] holds the ids chosen already. Returns the chosen ones in the
/// order of [choices], or null when closed without Done.
///
/// A button beside the counter switches between the class sections of the
/// People tab and one list by name; both sort by name, and the last choice
/// is kept (`AppSettings.pickerSort`).
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

class _PeopleMultiPicker extends ConsumerStatefulWidget {
  const _PeopleMultiPicker(this.choices, this.title, this.initial);

  final List<PersonChoice> choices;
  final String title;
  final Set<String> initial;

  @override
  ConsumerState<_PeopleMultiPicker> createState() => _PeopleMultiPickerState();
}

class _PeopleMultiPickerState extends ConsumerState<_PeopleMultiPicker> {
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
    ]..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    final sort = ref.settings.pickerSort;
    Widget grid(List<PersonChoice> items) => Wrap(
      alignment: WrapAlignment.start,
      spacing: 4,
      runSpacing: 10,
      children: [
        for (final c in items)
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
    );
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
                  const SizedBox(width: 12),
                  GreyIconButton(
                    size: 40,
                    radius: 14,
                    icon: sort == PickerSort.byClass
                        ? Icons.sort_by_alpha_rounded
                        : Icons.view_agenda_rounded,
                    tooltip: sort == PickerSort.byClass
                        ? l10n.pickerSortByName
                        : l10n.pickerSortByClass,
                    onPressed: () => ref.services.settings.update(
                      (s) => s.copyWith(
                        pickerSort: sort == PickerSort.byClass
                            ? PickerSort.byName
                            : PickerSort.byClass,
                      ),
                    ),
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
                      child: sort == PickerSort.byName
                          ? grid(matches)
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 14,
                              children: [
                                for (final closeness in Closeness.values)
                                  if (matches.any(
                                    (c) => _classOf(c) == closeness,
                                  ))
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 8,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          child: Row(
                                            spacing: 8,
                                            children: [
                                              KeptIcon(
                                                closenessIcon(closeness),
                                                size: 22,
                                              ),
                                              SectionLabel(
                                                closenessGroupLabel(
                                                  closeness,
                                                  l10n,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        grid([
                                          for (final c in matches)
                                            if (_classOf(c) == closeness) c,
                                        ]),
                                      ],
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

/// The class a choice is shown under: a person's own, a couple's as on the
/// People tab ([coupleClass]).
Closeness _classOf(PersonChoice c) =>
    c.isCouple ? coupleClass(c.members) : c.person.closeness;

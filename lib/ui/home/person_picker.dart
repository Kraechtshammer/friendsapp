import '../../data/database.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../widgets/kept_text_field.dart';

/// A bottom sheet with everyone and a search field. Returns the person
/// tapped, or null.
Future<Person?> showPersonPicker(BuildContext context, List<Person> people) =>
    showModalBottomSheet<Person>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PersonPicker(people),
    );

class _PersonPicker extends StatefulWidget {
  const _PersonPicker(this.people);

  final List<Person> people;

  @override
  State<_PersonPicker> createState() => _PersonPickerState();
}

class _PersonPickerState extends State<_PersonPicker> {
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
    final matches = [
      for (final p in widget.people)
        if (p.name.toLowerCase().contains(query)) p,
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
                          ListTile(
                            leading: Avatar.person(p, size: 40),
                            title: Text(p.name, style: context.text.bodyLarge),
                            onTap: () => Navigator.of(context).pop(p),
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

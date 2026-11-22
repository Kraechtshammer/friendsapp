import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/contact_event.dart';
import '../../domain/intention.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../home/nice_one_screen.dart';
import '../material.dart';
import '../widgets/choice_chips.dart';
import '../widgets/main_button.dart';
import '../widgets/past_day_picker.dart';
import '../widgets/section_label.dart';
import 'with_row.dart';

/// What the sheet hands back: the kind and the time of the contact, and the
/// other people who were there (not the person the sheet was opened for).
typedef LoggedContact = (ContactKind, DateTime, List<Person>);

/// Opens the "We were in touch" sheet for a contact that already happened.
/// The "With" row can add more people: the contact is then one shared event
/// for all of them. After Save it closes, stores the contact and shows the
/// "Nice one" screen, which asks for the activity and the line for next time.
Future<void> showLogContactSheet(
  BuildContext context,
  WidgetRef ref,
  Person person,
) async {
  final result = await showModalBottomSheet<LoggedContact>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: context.kept.surface,
    builder: (_) => _LogContactSheet(person),
  );
  if (result == null || !context.mounted) return;
  await completeLoggedContact(
    context,
    ref,
    person,
    kind: result.$1,
    at: result.$2,
    withPeople: result.$3,
  );
}

class _LogContactSheet extends ConsumerStatefulWidget {
  const _LogContactSheet(this.person);

  final Person person;

  @override
  ConsumerState<_LogContactSheet> createState() => _LogContactSheetState();
}

class _LogContactSheetState extends ConsumerState<_LogContactSheet> {
  var _kind = ContactKind.met;
  var _day = const PastDay.today();
  final _others = <Person>[];

  void _save() => Navigator.of(context).pop<LoggedContact>((
    _kind,
    _day.at(ref.read(clockProvider)()),
    List.of(_others),
  ));

  List<ChipOption<ContactKind>> _kinds(AppLocalizations l10n) => [
    ChipOption(
      ContactKind.wrote,
      l10n.logKindWrote,
      icon: kindIcon(IntentionKind.write),
    ),
    ChipOption(
      ContactKind.called,
      l10n.logKindCalled,
      icon: kindIcon(IntentionKind.call),
    ),
    ChipOption(
      ContactKind.met,
      l10n.logKindMet,
      icon: kindIcon(IntentionKind.meet),
    ),
    ChipOption(
      ContactKind.gamed,
      l10n.logKindGamed,
      icon: kindIcon(IntentionKind.game),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kept = context.kept;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text(
            l10n.logContactTitle(ref.readShortName(widget.person)),
            style: context.text.titleLarge?.copyWith(color: kept.text),
          ),
          SectionLabel(l10n.logContactWhat),
          ChoiceChips<ContactKind>(
            options: _kinds(l10n),
            value: _kind,
            onChanged: (k) => setState(() => _kind = k),
          ),
          WithRow(
            person: widget.person,
            others: _others,
            onChanged: (list) => setState(() {
              _others
                ..clear()
                ..addAll(list);
            }),
          ),
          SectionLabel(l10n.whenSection),
          PastDayChips(value: _day, onChanged: (d) => setState(() => _day = d)),
          MainButton(label: l10n.save, onPressed: _save),
        ],
      ),
    );
  }
}

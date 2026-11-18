import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

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
import '../widgets/section_label.dart';

/// What the sheet hands back: the kind and the time of the contact.
typedef LoggedContact = (ContactKind, DateTime);

/// Opens the "We were in touch" sheet for a contact that already happened.
/// After Save it closes, stores the contact and shows the "Nice one" screen,
/// which asks for the activity and the line for next time.
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
  );
}

enum _Day { today, yesterday, picked }

class _LogContactSheet extends ConsumerStatefulWidget {
  const _LogContactSheet(this.person);

  final Person person;

  @override
  ConsumerState<_LogContactSheet> createState() => _LogContactSheetState();
}

class _LogContactSheetState extends ConsumerState<_LogContactSheet> {
  var _kind = ContactKind.met;
  var _day = _Day.today;
  DateTime? _picked;

  DateTime get _now => ref.read(clockProvider)();

  Future<void> _pick() async {
    final now = _now;
    final today = DateTime(now.year, now.month, now.day);
    final day = await showDatePicker(
      context: context,
      initialDate: DateTime(today.year, today.month, today.day - 1),
      firstDate: DateTime(today.year - 1, today.month, today.day),
      lastDate: today,
    );
    if (day == null || !mounted) return;
    setState(() {
      _picked = day;
      _day = _Day.picked;
    });
  }

  void _save() {
    final now = _now;
    // No time is asked for a past day: noon keeps it inside that day.
    // Today picked in the calendar counts as now, never as a later noon.
    final picked = _picked;
    final isToday = picked != null && DateUtils.isSameDay(picked, now);
    final at = switch (_day) {
      _Day.today => now,
      _Day.picked when isToday => now,
      _Day.yesterday => DateTime(now.year, now.month, now.day - 1, 12),
      _Day.picked => DateTime(picked!.year, picked.month, picked.day, 12),
    };
    Navigator.of(context).pop<LoggedContact>((_kind, at));
  }

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
    final picked = _picked;
    final locale = Localizations.localeOf(context).toString();
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
          SectionLabel(l10n.whenSection),
          ChoiceChips<_Day>(
            options: [
              ChipOption(_Day.today, l10n.timelineToday),
              ChipOption(_Day.yesterday, l10n.logDayYesterday),
              ChipOption(
                _Day.picked,
                picked == null
                    ? l10n.logDayPick
                    : (picked.year == _now.year
                              ? DateFormat.MMMd(locale)
                              : DateFormat.yMMMd(locale))
                          .format(picked),
              ),
            ],
            value: _day,
            onChanged: (d) {
              if (d == _Day.picked) {
                _pick();
              } else {
                setState(() => _day = d);
              }
            },
          ),
          MainButton(label: l10n.save, onPressed: _save),
        ],
      ),
    );
  }
}

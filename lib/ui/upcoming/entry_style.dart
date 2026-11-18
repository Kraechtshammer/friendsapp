import '../../app/theme.dart';
import '../../data/database.dart';
import '../../domain/contact_event.dart';
import '../../domain/intention.dart';
import '../../domain/display_name.dart';
import '../../domain/timeline.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/activity_icon_picker.dart';

/// How a timeline entry looks, shared by the Upcoming tab and the "coming
/// up" cards on Home (concept V6 · Upcoming).

/// The badge colour: pink for a birthday, else by kind.
Color entryAccent(UpcomingEntry e) => switch (e) {
  BirthdayEntry() => KeptColors.pink,
  ThoughtEntry(:final intention) => kindAccent(intention.kind),
};

/// The badge colour of a thought of [kind].
Color kindAccent(IntentionKind kind) => switch (kind) {
  IntentionKind.write => KeptColors.sun,
  IntentionKind.call => KeptColors.sky,
  IntentionKind.meet => KeptColors.mint,
  IntentionKind.game => KeptColors.lilac,
};

KeptIcons entryIcon(UpcomingEntry e) => switch (e) {
  BirthdayEntry() => KeptIcons.cake,
  ThoughtEntry(:final intention) => kindIcon(intention.kind),
};

/// The text of a thought, or its kind when it has none.
String thoughtText(Intention i, AppLocalizations l10n) =>
    i.note.trim().isEmpty ? kindLabel(i.kind, l10n) : i.note.trim();

/// The first line of an entry: "Anna's birthday" or the thought.
String entryTitle(
  UpcomingEntry e,
  AppLocalizations l10n,
  Map<String, String> names,
) => switch (e) {
  BirthdayEntry(:final person) => l10n.birthdayOf(shortNameIn(names, person)),
  ThoughtEntry(:final intention) => thoughtText(intention, l10n),
};

/// The muted line: the age for a birthday, else the person, the kind and
/// the time if there is one. [names] are the short names
/// (`displayNamesProvider`).
String entrySubtitle(
  UpcomingEntry e,
  AppLocalizations l10n,
  Map<String, String> names,
) => switch (e) {
  BirthdayEntry(:final age?) => l10n.turnsAge(age),
  BirthdayEntry(:final person) => closenessLabel(person.closeness, l10n),
  ThoughtEntry(:final person, :final intention, :final time, :final couple) => [
    couple?.label(names) ?? shortNameIn(names, person),
    kindLabel(intention.kind, l10n),
    if (time != null) l10n.timeShort(time),
  ].join(' · '),
};

/// The tilt of the badge at [index]: 2 to 3 degrees, alternating.
double entryTilt(int index) => const [-3.0, 2.0, -2.0, 3.0][index % 4];

/// The icon of a contact on a timeline: the activity's icon when the user
/// gave one, else the kind's.
KeptIcons contactIcon(ContactEvent e) =>
    activityIconByName(e.activityIcon) ??
    switch (e.kind) {
      ContactKind.wrote => KeptIcons.chat,
      ContactKind.called => KeptIcons.phone,
      ContactKind.met => KeptIcons.people,
      ContactKind.gamed => KeptIcons.controller,
      ContactKind.birthdayWish => KeptIcons.cake,
    };

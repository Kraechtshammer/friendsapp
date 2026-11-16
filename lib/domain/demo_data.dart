import '../data/database.dart';
import 'avatar_pick.dart';
import 'intention.dart';
import 'person.dart';

/// The invented people of the demo database (02-design.md §8). All names,
/// numbers and handles are made up: phone numbers are `+4900000001xx`,
/// Telegram names start with `demo_`, Discord IDs start with `0000`.
///
/// Deterministic for a given [today]: one birthday falls on [today] (Lena
/// Hartwig) and one three days later (Sofia Lindqvist). Avatars are picked
/// one after the other with [pickAvatar], as adding them would.
List<Person> demoPeople(DateTime today) {
  final day = DateTime(today.year, today.month, today.day);
  final soon = DateTime(day.year, day.month, day.day + 3);
  final rows = <_Demo>[
    // Close friends (4).
    _Demo(
      'Lena Hartwig',
      Closeness.close,
      Messenger.whatsapp,
      phone: 1,
      birthday: (day.month, day.day, 1994),
    ),
    _Demo(
      'Malik Osei',
      Closeness.close,
      Messenger.whatsapp,
      phone: 2,
      birthday: (3, 3, 1991),
      rhythmDays: 10,
    ),
    _Demo(
      'Sofia Lindqvist',
      Closeness.close,
      Messenger.telegram,
      phone: 3,
      telegram: 'demo_sofia',
      birthday: (soon.month, soon.day, null),
    ),
    _Demo(
      'Paulina Brandt',
      Closeness.close,
      Messenger.signal,
      phone: 4,
      birthday: (8, 22, 1993),
      notes: 'Started a pottery class on Tuesdays.',
    ),
    // Now and then (5).
    _Demo(
      'Kenji Moreau',
      Closeness.nowAndThen,
      Messenger.whatsapp,
      phone: 5,
      reconnecting: true,
    ),
    _Demo(
      'Amira Haddad',
      Closeness.nowAndThen,
      Messenger.whatsapp,
      phone: 6,
      birthday: (11, 14, null),
    ),
    _Demo(
      'Felix Grünberg',
      Closeness.nowAndThen,
      Messenger.discord,
      discord: '000012345678900007',
    ),
    _Demo(
      'Noor Vandersee',
      Closeness.nowAndThen,
      Messenger.telegram,
      telegram: 'demo_noor',
      birthday: (6, 9, 1990),
    ),
    _Demo(
      'Mateo Ruiz Kessler',
      Closeness.nowAndThen,
      Messenger.whatsapp,
      phone: 9,
    ),
    // A few times a year (4).
    _Demo(
      'Ingrid Solberg',
      Closeness.fewTimesAYear,
      Messenger.whatsapp,
      phone: 10,
      reconnecting: true,
      birthday: (1, 30, 1988),
      notes: 'Moved to Bergen. Ask about the new job.',
    ),
    _Demo(
      'Yusuf Aydemir',
      Closeness.fewTimesAYear,
      Messenger.signal,
      signalLink: 'https://signal.me/#eu/demo_yusuf',
    ),
    _Demo(
      'Clara Weissmann',
      Closeness.fewTimesAYear,
      null,
      birthday: (10, 17, null),
    ),
    _Demo(
      'Tobi Okafor',
      Closeness.fewTimesAYear,
      Messenger.telegram,
      phone: 13,
      telegram: 'demo_tobi',
    ),
    // Family (3).
    _Demo(
      'Hilde Brenner',
      Closeness.family,
      Messenger.whatsapp,
      phone: 14,
      birthday: (2, 5, 1956),
      notes: 'Likes a call more than a message.',
    ),
    _Demo(
      'Rosa Brenner',
      Closeness.family,
      Messenger.whatsapp,
      phone: 15,
      birthday: (12, 28, 1984),
    ),
    _Demo(
      'Max Brenner',
      Closeness.family,
      Messenger.whatsapp,
      phone: 16,
      birthday: (7, 11, 1997),
    ),
  ];

  final avatars = <Avatar>[];
  final people = <Person>[];
  for (final (i, d) in rows.indexed) {
    final avatar = pickAvatar(avatars);
    avatars.add(avatar);
    final n = (i + 1).toString().padLeft(2, '0');
    people.add(
      Person(
        id: 'demo-$n',
        name: d.name,
        closeness: d.closeness,
        reconnecting: d.reconnecting,
        rhythmDays: d.rhythmDays,
        mainMessenger: d.messenger,
        phone: d.phone == null
            ? null
            : '+4900000001${d.phone.toString().padLeft(2, '0')}',
        telegramUsername: d.telegram,
        signalLink: d.signalLink,
        discordUserId: d.discord,
        birthdayMonth: d.birthday?.$1,
        birthdayDay: d.birthday?.$2,
        birthdayYear: d.birthday?.$3,
        avatarShape: avatar.shape,
        avatarColor: avatar.color,
        notes: d.notes,
        // Spread over the last months, as if added one by one.
        createdAt: DateTime(day.year, day.month, day.day - 120 + i * 5),
      ),
    );
  }
  return people;
}

/// The invented intentions of the demo database: seven open thoughts and
/// three done ones, then seven plans (four with a date, one of them
/// passed, and three with a horizon), spread over [demoPeople] of the same
/// [today]. Deterministic: each was made a few days before [today], at a
/// fixed hour; the "soon" plan is 15 days old, so it is due.
List<Intention> demoIntentions(DateTime today) {
  final day = DateTime(today.year, today.month, today.day);
  final ids = {for (final p in demoPeople(today)) p.name: p.id};
  DateTime at(int daysBack, int hour) =>
      DateTime(day.year, day.month, day.day - daysBack, hour);
  final rows = <(String, String, IntentionKind, int, int, int?)>[
    // Name, note, kind, days back, hour, done how many days back.
    ('Malik Osei', 'saw a bouldering video', IntentionKind.write, 1, 21, null),
    (
      'Ingrid Solberg',
      'ask about the new job',
      IntentionKind.call,
      2,
      19,
      null,
    ),
    ('Lena Hartwig', 'birthday dinner?', IntentionKind.meet, 3, 12, null),
    ('Kenji Moreau', 'send the ramen place', IntentionKind.write, 4, 8, null),
    ('Hilde Brenner', 'how was the doctor', IntentionKind.call, 5, 18, null),
    (
      'Paulina Brandt',
      'pottery pieces, show?',
      IntentionKind.write,
      6,
      20,
      null,
    ),
    ('Felix Grünberg', '', IntentionKind.game, 9, 17, null),
    ('Sofia Lindqvist', 'return the book', IntentionKind.meet, 8, 10, 2),
    ('Amira Haddad', 'congrats on the flat', IntentionKind.write, 10, 9, 7),
    ('Malik Osei', 'match on Saturday', IntentionKind.call, 12, 22, 11),
  ];
  // Dated and undated plans (M5), for people with no other thought. Days
  // ahead are counted from [day]; a negative number is a date that has
  // passed, so Home asks "Did it happen?".
  DateTime ahead(int days, [int hour = 0, int minute = 0]) =>
      DateTime(day.year, day.month, day.day + days, hour, minute);
  final plans = <(String, String, IntentionKind, int, When)>[
    // Name, note, kind, days back, when.
    (
      'Noor Vandersee',
      'coffee at the market',
      IntentionKind.meet,
      6,
      When.date(ahead(-1, 18)),
    ),
    (
      'Mateo Ruiz Kessler',
      'climbing gym',
      IntentionKind.meet,
      5,
      When.date(ahead(1, 11)),
    ),
    (
      'Clara Weissmann',
      'call about the move',
      IntentionKind.call,
      4,
      When.date(ahead(5)),
    ),
    (
      'Tobi Okafor',
      'game night',
      IntentionKind.game,
      3,
      When.date(ahead(9, 20)),
    ),
    // 15 days old: a "soon" plan is due after 14.
    (
      'Yusuf Aydemir',
      'ramen night',
      IntentionKind.meet,
      15,
      When.horizon(Horizon.soon),
    ),
    (
      'Rosa Brenner',
      'a trip to the coast',
      IntentionKind.meet,
      4,
      When.horizon(Horizon.later),
    ),
    (
      'Max Brenner',
      'barbecue in the park',
      IntentionKind.meet,
      3,
      When.horizon(Horizon.whenCondition, condition: 'when it is warm again'),
    ),
  ];
  return [
    for (final (i, (name, note, kind, back, hour, doneBack)) in rows.indexed)
      Intention(
        id: 'demo-i${(i + 1).toString().padLeft(2, '0')}',
        personId: ids[name]!,
        note: note,
        kind: kind,
        state: doneBack == null ? IntentionState.open : IntentionState.done,
        createdAt: at(back, hour),
        closedAt: doneBack == null ? null : at(doneBack, hour),
      ),
    for (final (i, (name, note, kind, back, w)) in plans.indexed)
      Intention(
        id: 'demo-p${(i + 1).toString().padLeft(2, '0')}',
        personId: ids[name]!,
        note: note,
        kind: kind,
        state: IntentionState.open,
        date: w.date,
        horizon: w.horizon,
        condition: w.condition,
        createdAt: at(back, 15),
      ),
  ];
}

class _Demo {
  const _Demo(
    this.name,
    this.closeness,
    this.messenger, {
    this.phone,
    this.telegram,
    this.signalLink,
    this.discord,
    this.birthday,
    this.reconnecting = false,
    this.rhythmDays,
    this.notes = '',
  });

  final String name;
  final Closeness closeness;
  final Messenger? messenger;

  /// The last two digits of the fake number.
  final int? phone;
  final String? telegram;
  final String? signalLink;
  final String? discord;

  /// Month, day, year (null = unknown).
  final (int, int, int?)? birthday;
  final bool reconnecting;
  final int? rhythmDays;
  final String notes;
}

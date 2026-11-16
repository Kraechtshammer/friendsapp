import '../data/database.dart';
import 'avatar_pick.dart';
import 'birthdays.dart';
import 'contact_event.dart';
import 'idea.dart';
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

/// The invented ideas of the demo database (M10): things to do and to talk
/// about for four people, one with a link, one ticked off. No pictures.
/// Deterministic for a given [today].
List<Idea> demoIdeas(DateTime today) {
  final day = DateTime(today.year, today.month, today.day);
  final ids = {for (final p in demoPeople(today)) p.name: p.id};
  DateTime at(int daysBack) =>
      DateTime(day.year, day.month, day.day - daysBack, 20);
  final rows = <(String, String, IdeaKind, String?, int, int?)>[
    // Name, text, kind, link, days back, done how many days back.
    (
      'Malik Osei',
      'bouldering hall in Altona',
      IdeaKind.toDo,
      'https://example.org/boulderhalle-altona',
      6,
      null,
    ),
    ('Malik Osei', 'his trip to Ghana', IdeaKind.toTalk, null, 12, null),
    ('Malik Osei', 'pub quiz on Thursdays', IdeaKind.toDo, null, 40, 20),
    ('Lena Hartwig', 'the new ramen place', IdeaKind.toDo, null, 9, null),
    (
      'Lena Hartwig',
      'how the half marathon went',
      IdeaKind.toTalk,
      null,
      3,
      null,
    ),
    ('Paulina Brandt', 'her pottery pieces', IdeaKind.toTalk, null, 5, null),
    (
      'Kenji Moreau',
      'film night, something by Ghibli',
      IdeaKind.toDo,
      null,
      8,
      null,
    ),
  ];
  return [
    for (final (i, (name, note, kind, link, back, doneBack)) in rows.indexed)
      Idea(
        id: 'demo-d${(i + 1).toString().padLeft(2, '0')}',
        personId: ids[name]!,
        note: note,
        kind: kind,
        link: link,
        createdAt: at(back),
        doneAt: doneBack == null ? null : at(doneBack),
      ),
  ];
}

/// The invented contact history of the demo database (M6, the friend
/// timeline): about 20 events for five people, in both directions, with
/// activities and notes, and birthday wishes both ways (Paulina's birthday
/// and a birthday of the user). Deterministic for a given [today]: every
/// event lies a fixed number of days back, at a fixed hour.
List<ContactEvent> demoContactEvents(DateTime today) {
  final day = DateTime(today.year, today.month, today.day);
  final ids = {for (final p in demoPeople(today)) p.name: p.id};
  DateTime back(int days, int hour, [int minute = 0]) =>
      DateTime(day.year, day.month, day.day - days, hour, minute);
  const w = ContactKind.wrote,
      c = ContactKind.called,
      m = ContactKind.met,
      g = ContactKind.gamed,
      b = ContactKind.birthdayWish;
  const us = ContactDirection.byUser,
      them = ContactDirection.byThem,
      both = ContactDirection.together;
  // Name, days back, hour, kind, direction, activity, note.
  final rows =
      <(String, int, int, ContactKind, ContactDirection, String?, String?)>[
        ('Paulina Brandt', 2, 20, w, us, null, 'Show the pottery pieces.'),
        (
          'Paulina Brandt',
          9,
          18,
          w,
          them,
          null,
          'Sent a photo of the new bowl.',
        ),
        (
          'Paulina Brandt',
          21,
          11,
          m,
          both,
          'pottery market',
          'Bring her the book.',
        ),
        ('Paulina Brandt', 40, 19, c, us, null, null),
        ('Paulina Brandt', 52, 21, c, them, null, 'Moving in the spring.'),
        ('Malik Osei', 3, 22, w, them, null, 'Sent a climbing video.'),
        ('Malik Osei', 6, 19, w, us, null, 'New job is going well.'),
        ('Malik Osei', 17, 15, m, both, 'bouldering', 'Ramen afterwards.'),
        ('Malik Osei', 33, 20, c, us, null, null),
        ('Malik Osei', 70, 12, m, both, 'barbecue at Anna\'s', null),
        ('Lena Hartwig', 5, 17, w, us, null, 'Ask about the dinner.'),
        ('Lena Hartwig', 12, 21, g, both, 'Mario Kart', null),
        ('Lena Hartwig', 30, 10, c, them, null, 'Back from Lisbon in May.'),
        (
          'Kenji Moreau',
          44,
          18,
          w,
          us,
          null,
          'Wants to hear about the ramen place.',
        ),
        ('Kenji Moreau', 61, 9, w, them, null, null),
        ('Sofia Lindqvist', 8, 20, c, us, null, 'Return the book.'),
        ('Sofia Lindqvist', 27, 16, m, both, 'coffee', null),
        // Birthday wishes: the user to Paulina, and Malik and Paulina to the
        // user on a birthday of the user's 80 days back.
        ('Paulina Brandt', _daysSince(day, 8, 22), 22, b, us, null, null),
        ('Malik Osei', 80, 9, b, them, null, null),
        ('Paulina Brandt', 80, 12, b, them, null, null),
      ];
  return [
    for (final (i, (name, back_, hour, kind, dir, activity, note))
        in rows.indexed)
      ContactEvent(
        id: 'demo-c${(i + 1).toString().padLeft(2, '0')}',
        personId: ids[name]!,
        at: back(back_, hour),
        kind: kind,
        direction: dir,
        source: ContactSource.manual,
        activity: activity,
        note: note,
        createdAt: back(back_, hour, 5),
      ),
  ];
}

/// The default treats of the demo database, in English (the demo is for
/// development only). The same stamp numbers as the real default list.
List<(String, int)> demoTreatNames() => const [
  ('Favourite takeaway', 10),
  ('Cinema evening', 10),
  ('Cake from the good bakery', 10),
  ('A new book or game', 20),
  ('A lazy morning with nothing planned', 10),
  ('A day trip', 30),
  ('Concert or event ticket', 40),
  ('Cook something really fancy', 10),
  ('Bake something new', 10),
  ('A new plant or something for the flat', 20),
  ('Start a small project you put off', 20),
  ('A class or workshop', 30),
];

/// The first demo card is small, so the demo history fills it and the
/// screens show an earned treat.
const demoFirstCardStamps = 12;

/// The evening answers of the demo database: a few Yes and Not today
/// answers in the three weeks before [today].
List<DayAnswer> demoDayAnswers(DateTime today) {
  final day = DateTime(today.year, today.month, today.day);
  // Days back, answer.
  const rows = <(int, DayAnswerValue)>[
    (1, DayAnswerValue.yes),
    (2, DayAnswerValue.notToday),
    (3, DayAnswerValue.yes),
    (5, DayAnswerValue.yes),
    (6, DayAnswerValue.yes),
    (9, DayAnswerValue.notToday),
    (12, DayAnswerValue.yes),
    (14, DayAnswerValue.yes),
    (19, DayAnswerValue.yes),
  ];
  return [
    for (final (back, answer) in rows)
      DayAnswer(
        day: dayKey(DateTime(day.year, day.month, day.day - back)),
        answer: answer,
        answeredAt: DateTime(day.year, day.month, day.day - back, 19, 30),
      ),
  ];
}

/// Days from the last 22 August (or any month and day) up to [day].
int _daysSince(DateTime day, int month, int dayOfMonth) {
  final last = lastBirthday(month, dayOfMonth, day);
  return day.difference(last).inDays;
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

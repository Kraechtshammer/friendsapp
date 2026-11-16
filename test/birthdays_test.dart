import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/app_settings.dart';
import 'package:kept/data/contact_events_repository.dart';
import 'package:kept/data/database.dart';
import 'package:kept/data/people_repository.dart';
import 'package:kept/domain/birthday_notifications.dart';
import 'package:kept/domain/birthdays.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/platform/notifications.dart';

import 'fake_notifications.dart';

Person person(String id, {int? month, int? day, int? year}) => Person(
  id: id,
  name: id,
  closeness: Closeness.close,
  avatarShape: AvatarShape.scallop,
  avatarColor: AvatarColor.mint,
  reconnecting: false,
  notes: '',
  createdAt: DateTime(2026),
  birthdayMonth: month,
  birthdayDay: day,
  birthdayYear: year,
);

ContactEvent wish(
  String personId,
  DateTime at, {
  ContactDirection direction = ContactDirection.byUser,
  ContactKind kind = ContactKind.birthdayWish,
}) => ContactEvent(
  id: '$personId-$at-$direction-$kind',
  personId: personId,
  at: at,
  kind: kind,
  direction: direction,
  source: ContactSource.manual,
  createdAt: at,
);

void main() {
  group('days', () {
    test('29 February counts on 28 February without a leap day', () {
      expect(isBirthdayOn(2, 29, DateTime(2027, 2, 28)), isTrue);
      expect(isBirthdayOn(2, 29, DateTime(2027, 3, 1)), isFalse);
      expect(isBirthdayOn(2, 29, DateTime(2028, 2, 29)), isTrue);
      expect(isBirthdayOn(2, 29, DateTime(2028, 2, 28)), isFalse);
      expect(isBirthdayOn(2, 28, DateTime(2027, 2, 28)), isTrue);
    });

    test('birthdaysOn keeps the order and ignores unknown birthdays', () {
      final people = [
        person('a', month: 11, day: 16),
        person('b'),
        person('c', month: 11, day: 17),
        person('d', month: 11, day: 16, year: 1990),
        person('e', month: 11),
      ];
      expect(
        birthdaysOn(people, DateTime(2026, 11, 16, 23, 59)).map((p) => p.id),
        ['a', 'd'],
      );
    });

    test('next birthday: same day, later this year, over the year change', () {
      expect(
        nextBirthday(11, 16, DateTime(2026, 11, 16, 23)),
        DateTime(2026, 11, 16),
      );
      expect(
        nextBirthday(12, 31, DateTime(2026, 11, 16)),
        DateTime(2026, 12, 31),
      );
      expect(
        nextBirthday(1, 1, DateTime(2026, 12, 31, 22)),
        DateTime(2027, 1, 1),
      );
      expect(nextBirthday(2, 29, DateTime(2027, 3, 1)), DateTime(2028, 2, 29));
      expect(nextBirthday(2, 29, DateTime(2026, 3, 1)), DateTime(2027, 2, 28));
    });

    test('last birthday: same day, earlier this year, last year', () {
      expect(
        lastBirthday(11, 16, DateTime(2026, 11, 16, 8)),
        DateTime(2026, 11, 16),
      );
      expect(lastBirthday(1, 2, DateTime(2026, 11, 16)), DateTime(2026, 1, 2));
      expect(
        lastBirthday(12, 31, DateTime(2027, 1, 1)),
        DateTime(2026, 12, 31),
      );
      expect(lastBirthday(2, 29, DateTime(2027, 3, 1)), DateTime(2027, 2, 28));
    });

    test('age only with a year before the date', () {
      expect(ageTurned(1994, DateTime(2026, 11, 16)), 32);
      expect(ageTurned(null, DateTime(2026, 11, 16)), isNull);
      expect(ageTurned(2026, DateTime(2026, 11, 16)), isNull);
      // A leap day child turns a year older on 28 February too.
      expect(ageTurned(2000, DateTime(2027, 2, 28)), 27);
    });

    test('congratulated: only a wish by the user on that day', () {
      final day = DateTime(2026, 11, 16);
      expect(
        congratulatedOn([wish('a', DateTime(2026, 11, 16, 9))], day),
        isTrue,
      );
      expect(
        congratulatedOn([wish('a', DateTime(2026, 11, 15, 23))], day),
        isFalse,
      );
      expect(
        congratulatedOn([
          wish(
            'a',
            DateTime(2026, 11, 16, 9),
            direction: ContactDirection.byThem,
          ),
        ], day),
        isFalse,
      );
      expect(
        congratulatedOn([
          wish('a', DateTime(2026, 11, 16, 9), kind: ContactKind.wrote),
        ], day),
        isFalse,
      );
      expect(
        congratulatedIds([
          wish('a', DateTime(2026, 11, 16, 9)),
          wish('b', DateTime(2026, 11, 17, 0, 1)),
        ], day),
        {'a'},
      );
    });
  });

  group('the own birthday setting', () {
    test('stored as MM-DD or YYYY-MM-DD, cleared by null', () {
      const withYear = AppSettings(ownBirthday: Birthday(3, 7, 1990));
      expect(withYear.toMap()['ownBirthday'], '1990-03-07');
      expect(AppSettings.fromMap({'ownBirthday': '1990-03-07'}), withYear);
      expect(
        AppSettings.fromMap({'ownBirthday': '02-29'}).ownBirthday,
        const Birthday(2, 29),
      );
      expect(AppSettings.fromMap({'ownBirthday': '02-30'}).ownBirthday, isNull);
      expect(AppSettings.fromMap({'ownBirthday': 'x'}).ownBirthday, isNull);
      expect(withYear.withOwnBirthday(null).toMap()['ownBirthday'], isNull);
      expect(
        withYear.copyWith(eveningOn: false).ownBirthday,
        withYear.ownBirthday,
      );
    });

    test('typed fields follow the person form rules', () {
      final now = DateTime(2026, 11, 16);
      expect(BirthdayFields.check('', '', '', now).ok, isTrue);
      expect(BirthdayFields.check('', '', '', now).birthday, isNull);
      expect(
        BirthdayFields.check('7', '3', '', now).birthday,
        const Birthday(3, 7),
      );
      expect(BirthdayFields.check('29', '2', '', now).ok, isTrue);
      expect(BirthdayFields.check('29', '2', '2023', now).ok, isFalse);
      expect(BirthdayFields.check('7', '', '', now).ok, isFalse);
      expect(BirthdayFields.check('7', '3', '2027', now).ok, isFalse);
    });
  });

  group('notification plan', () {
    final lena = person('lena', month: 11, day: 16, year: 1994);
    final sofia = person('sofia', month: 11, day: 19);
    final nobody = person('nobody');

    List<(String, DateTime, bool)> plan(
      DateTime now, {
      Set<String> congratulated = const {},
      bool on = true,
      int minute = 19 * 60,
      List<Person>? people,
    }) => [
      for (final a in birthdayAlarms(
        people: people ?? [lena, sofia, nobody],
        congratulated: congratulated,
        now: now,
        on: on,
        minute: minute,
      ))
        (a.person.id, a.at, a.late),
    ];

    test('evening and 23:00 on the next birthday of each person', () {
      expect(plan(DateTime(2026, 11, 16, 14)), [
        ('lena', DateTime(2026, 11, 16, 19), false),
        ('lena', DateTime(2026, 11, 16, 23), true),
        ('sofia', DateTime(2026, 11, 19, 19), false),
        ('sofia', DateTime(2026, 11, 19, 23), true),
      ]);
    });

    test('past times are left out; both past moves to next year', () {
      expect(plan(DateTime(2026, 11, 16, 20), people: [lena]), [
        ('lena', DateTime(2026, 11, 16, 23), true),
      ]);
      expect(plan(DateTime(2026, 11, 16, 23, 30), people: [lena]), [
        ('lena', DateTime(2027, 11, 16, 19), false),
        ('lena', DateTime(2027, 11, 16, 23), true),
      ]);
    });

    test('congratulated today: next year', () {
      expect(
        plan(
          DateTime(2026, 11, 16, 9),
          people: [lena],
          congratulated: {'lena'},
        ),
        [
          ('lena', DateTime(2027, 11, 16, 19), false),
          ('lena', DateTime(2027, 11, 16, 23), true),
        ],
      );
      // Congratulated on another day does not matter.
      expect(
        plan(
          DateTime(2026, 11, 16, 9),
          people: [sofia],
          congratulated: {'sofia'},
        ),
        hasLength(2),
      );
    });

    test('no 23:00 one when the evening time is 23:00 or later', () {
      expect(plan(DateTime(2026, 11, 16, 9), people: [lena], minute: 23 * 60), [
        ('lena', DateTime(2026, 11, 16, 23), false),
      ]);
      expect(
        plan(DateTime(2026, 11, 16, 9), people: [lena], minute: 23 * 60 + 30),
        [('lena', DateTime(2026, 11, 16, 23, 30), false)],
      );
      expect(
        plan(DateTime(2026, 11, 16, 9), people: [lena], minute: 22 * 60 + 59),
        hasLength(2),
      );
    });

    test('the off switch silences them', () {
      expect(plan(DateTime(2026, 11, 16, 9), on: false), isEmpty);
    });

    test('excluded weekdays are not an input: a Monday birthday comes', () {
      // 16 November 2026 is a Monday; the plan has no weekday parameter.
      expect(DateTime(2026, 11, 16).weekday, DateTime.monday);
      expect(plan(DateTime(2026, 11, 16, 9), people: [lena]), hasLength(2));
    });

    test('a leap day birthday in a year without one', () {
      final leap = person('leap', month: 2, day: 29);
      expect(
        plan(DateTime(2027, 2, 1), people: [leap]).first.$2,
        DateTime(2027, 2, 28, 19),
      );
    });

    test('ids: stable, separate per slot, outside the evening range', () {
      final a = birthdayNotificationId('lena', late: false);
      final b = birthdayNotificationId('lena', late: true);
      expect(birthdayNotificationId('lena', late: false), a);
      expect(b, a + 1);
      expect(birthdayNotificationId('sofia', late: false), isNot(a));
      for (final id in [a, b]) {
        expect(isBirthdayNotificationId(id), isTrue);
        expect(id, lessThan(1 << 31));
      }
      for (var day = 101; day <= 107; day++) {
        expect(isBirthdayNotificationId(day), isFalse);
      }
    });

    test('responses: payload and buttons', () {
      final payload = birthdayPayload(
        'lena',
        DateTime(2026, 11, 16, 23),
        late: true,
      );
      expect(payload, 'birthday:lena:2026-11-16:late');
      expect(
        birthdayResponseFor(actionId: birthdayYesAction, payload: payload),
        BirthdayResponse(
          personId: 'lena',
          day: DateTime(2026, 11, 16),
          late: true,
          action: BirthdayAction.yes,
        ),
      );
      expect(
        birthdayResponseFor(
          actionId: birthdayOpenChatAction,
          payload: payload,
        )!.action,
        BirthdayAction.openChat,
      );
      expect(
        birthdayResponseFor(payload: payload)!.action,
        BirthdayAction.open,
      );
      expect(birthdayResponseFor(actionId: 'x', payload: payload), isNull);
      expect(birthdayResponseFor(payload: 'evening'), isNull);
    });
  });

  group('Yes from the notification', () {
    late AppDatabase db;
    late ContactEventsRepository events;
    late Person lena;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      events = ContactEventsRepository(db);
      lena = await PeopleRepository(db).add(
        name: 'Lena Hartwig',
        closeness: Closeness.close,
        birthdayMonth: 11,
        birthdayDay: 16,
      );
    });

    tearDown(() => db.close());

    test('stores once and cancels the late one', () async {
      final fake = FakeNotifications();
      final response = BirthdayResponse(
        personId: lena.id,
        day: DateTime(2026, 11, 16),
        late: false,
        action: BirthdayAction.yes,
      );
      await recordBirthdayYes(
        events,
        fake,
        response,
        now: DateTime(2026, 11, 16, 19, 5),
      );
      await recordBirthdayYes(
        events,
        fake,
        response,
        now: DateTime(2026, 11, 16, 19, 6),
      );
      final stored = await events.watchForPerson(lena.id).first;
      expect(stored, hasLength(1));
      expect(stored.single.kind, ContactKind.birthdayWish);
      expect(stored.single.direction, ContactDirection.byUser);
      expect(stored.single.source, ContactSource.confirmed);
      expect(stored.single.at, DateTime(2026, 11, 16, 19, 5));
      final late = birthdayNotificationId(lena.id, late: true);
      expect(fake.cancelled, [late, late]);
    });

    test('a Yes after midnight counts for the birthday', () async {
      await recordBirthdayYes(
        events,
        FakeNotifications(),
        BirthdayResponse(
          personId: lena.id,
          day: DateTime(2026, 11, 16),
          late: true,
          action: BirthdayAction.yes,
        ),
        now: DateTime(2026, 11, 17, 0, 10),
      );
      final stored = (await events.watchForPerson(lena.id).first).single;
      expect(dayKey(stored.at), '2026-11-16');
    });

    test(
      'a person deleted in between: nothing stored, late cancelled',
      () async {
        final fake = FakeNotifications();
        await expectLater(
          recordBirthdayYes(
            events,
            fake,
            BirthdayResponse(
              personId: 'gone',
              day: DateTime(2026, 11, 16),
              late: false,
              action: BirthdayAction.yes,
            ),
          ),
          throwsA(anything),
        );
        expect(fake.cancelled, [birthdayNotificationId('gone', late: true)]);
      },
    );
  });
}

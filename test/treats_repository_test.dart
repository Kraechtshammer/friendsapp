import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/app/services.dart';
import 'package:kept/data/app_settings.dart';
import 'package:kept/data/contact_events_repository.dart';
import 'package:kept/data/database.dart';
import 'package:kept/data/treats_repository.dart';
import 'package:kept/domain/birthday_notifications.dart';
import 'package:kept/domain/contact_event.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/domain/progress.dart';
import 'package:kept/domain/stamps.dart';
import 'package:kept/domain/treat.dart';
import 'package:kept/platform/notifications.dart';

import 'fake_notifications.dart';

void main() {
  late AppServices services;
  late AppDatabase db;
  late ContactEventsRepository events;
  late TreatsRepository treats;
  late DateTime added;

  // Week of Monday 16 November 2026.
  final mon = DateTime(2026, 11, 16, 10);
  final wed = DateTime(2026, 11, 18, 10);
  final nextMon = DateTime(2026, 11, 23, 10);

  setUp(() {
    services = AppServices(
      db: AppDatabase(NativeDatabase.memory()),
      openDemo: () => AppDatabase(NativeDatabase.memory()),
    );
    db = services.db;
    events = services.contactEventsFor(demo: false);
    treats = services.treatsFor(demo: false);
    // Added a few days before the first contact: no gap bonus.
    added = DateTime(2026, 11, 14);
  });
  tearDown(() => services.close());

  Future<Person> person(
    String name, {
    Closeness closeness = Closeness.close,
    bool reconnecting = false,
    DateTime? now,
  }) => services
      .peopleFor(demo: false)
      .add(
        name: name,
        closeness: closeness,
        reconnecting: reconnecting,
        now: now ?? added,
      );

  Future<ContactEvent> contact(
    Person p,
    DateTime at, {
    ContactKind kind = ContactKind.wrote,
    ContactDirection direction = ContactDirection.byUser,
  }) => events.add(
    personId: p.id,
    at: at,
    kind: kind,
    direction: direction,
    source: ContactSource.manual,
  );

  Future<List<Stamp>> stamps() => treats.watchStamps().first;
  Future<int> total() async => stampTotal(await stamps());
  Future<List<Treat>> allTreats() => treats.watchAll().first;
  Future<Treat> treatOf(String id) async =>
      (await allTreats()).firstWhere((t) => t.id == id);

  group('awarding', () {
    test(
      'a message by the user earns a stamp, in the same transaction',
      () async {
        final tom = await person('Tom');
        final e = await contact(tom, mon);
        final all = await stamps();
        expect(all, hasLength(1));
        expect(all.single.value, 1);
        expect(all.single.personId, tom.id);
        expect(all.single.contactEventId, e.id);
        expect(all.single.treatId, isNull);
      },
    );

    test('incoming contact earns nothing', () async {
      final tom = await person('Tom');
      await contact(tom, mon, direction: ContactDirection.byThem);
      await contact(
        tom,
        wed,
        kind: ContactKind.called,
        direction: ContactDirection.byThem,
      );
      await events.addByThemOnce(
        personId: tom.id,
        kind: ContactKind.wrote,
        at: wed,
      );
      await events.setWishFrom(tom.id, mon, on: true, at: mon);
      expect(await stamps(), isEmpty);
    });

    test(
      'at most one stamp per person and week; a lower one adds nothing',
      () async {
        final tom = await person('Tom', closeness: Closeness.nowAndThen);
        await contact(tom, mon);
        await contact(tom, wed);
        await contact(
          tom,
          wed.add(const Duration(hours: 1)),
          kind: ContactKind.called,
        );
        expect(await total(), 2);
        expect(await stamps(), hasLength(1));
      },
    );

    test(
      'a meet-up after a message raises the week to the higher value',
      () async {
        final tom = await person('Tom', closeness: Closeness.nowAndThen);
        await contact(tom, mon);
        expect(await total(), 2);
        final meet = await contact(
          tom,
          wed,
          kind: ContactKind.met,
          direction: ContactDirection.together,
        );
        // 2 for the message, a meet-up is worth 4: raised by 2, not 4 more.
        expect(await total(), 4);
        final raise = (await stamps()).where(
          (s) => s.contactEventId == meet.id,
        );
        expect(stampTotal(raise), 2);
        // A call afterwards adds nothing.
        await contact(
          tom,
          wed.add(const Duration(days: 1)),
          kind: ContactKind.called,
        );
        expect(await total(), 4);
      },
    );

    test('different people and different weeks each earn', () async {
      final tom = await person('Tom');
      final ann = await person('Ann');
      await contact(tom, mon);
      await contact(ann, mon);
      await contact(tom, nextMon);
      expect(await total(), 3);
    });

    test('Sunday night and Monday morning are two weeks', () async {
      final tom = await person('Tom');
      await contact(tom, DateTime(2026, 11, 22, 23, 59));
      await contact(tom, DateTime(2026, 11, 23, 0, 0));
      expect(await total(), 2);
      // Monday 00:00 is in the same week as the Sunday: nothing more.
      await contact(tom, DateTime(2026, 11, 16, 0, 0));
      expect(await total(), 2);
      // The Sunday before is the week before: one more.
      await contact(tom, DateTime(2026, 11, 15, 23, 59));
      expect(await total(), 3);
    });

    test('the bonuses count: getting back in touch and a long gap', () async {
      final kenji = await person(
        'Kenji',
        closeness: Closeness.nowAndThen,
        reconnecting: true,
        now: DateTime(2026, 9, 1),
      );
      // 2 + 1 (back in touch) + 1 (added 76 days ago, rhythm 42) = 4.
      await contact(kenji, mon);
      expect(await total(), 4);
      // The next week the contact before was 7 days ago: 2 + 1.
      await contact(kenji, nextMon);
      expect(await total(), 7);
    });

    test('the contact before counts in any direction', () async {
      final tom = await person('Tom', now: DateTime(2026, 6, 1));
      // An incoming message three days before ends the gap.
      await contact(
        tom,
        mon.subtract(const Duration(days: 3)),
        direction: ContactDirection.byThem,
      );
      await contact(tom, mon);
      expect(await total(), 1);
    });

    test('the weights from the settings are used', () async {
      await services.settings.update(
        (s) => s.copyWith(
          stampWeights: const StampWeights(close: 4, meetMultiplier: 3),
        ),
      );
      final tom = await person('Tom');
      await contact(
        tom,
        mon,
        kind: ContactKind.met,
        direction: ContactDirection.together,
      );
      expect(await total(), 12);
    });

    test('every path that stores a contact event awards', () async {
      final tom = await person('Tom');
      final ann = await person('Ann');
      final ben = await person('Ben');
      final eva = await person('Eva');
      final moe = await person('Moe');
      // 1. Done on a thought, "Did it happen?" and Done on "Did you write?".
      final thought = await services
          .intentionsFor(demo: false)
          .add(personId: tom.id, note: 'Bouldering', kind: IntentionKind.meet);
      final done = await events.completeIntention(thought.id, at: mon);
      expect(done.kind, ContactKind.met);
      // 2. "Did you write?", the reconnect pick: a plain add.
      await contact(ann, mon);
      // 3. A birthday wish by the user, from the app.
      await events.addBirthdayWishOnce(
        personId: ben.id,
        day: mon,
        at: mon,
        source: ContactSource.manual,
      );
      // 4. "Yes" on a birthday notification, as the background handler does.
      final notifications = FakeNotifications();
      await recordBirthdayYes(
        events,
        notifications,
        BirthdayResponse(
          personId: eva.id,
          day: DateTime(2026, 11, 16),
          late: false,
          action: BirthdayAction.yes,
        ),
        now: mon,
      );
      final byPerson = {for (final s in await stamps()) s.personId: s.value};
      expect(byPerson[tom.id], 2, reason: 'meet-up, close friend');
      expect(byPerson[ann.id], 1);
      expect(byPerson[ben.id], 1);
      expect(byPerson.containsKey(eva.id), isTrue);
      expect(byPerson.containsKey(moe.id), isFalse);
    });

    test('deleting a contact event leaves its stamp', () async {
      final tom = await person('Tom');
      final e = await contact(tom, mon);
      await events.delete(e.id);
      final left = await stamps();
      expect(left, hasLength(1));
      expect(left.single.contactEventId, isNull);
      expect(await total(), 1);
      // Deleting the person leaves it too.
      await services.peopleFor(demo: false).delete(tom.id);
      expect(await total(), 1);
      // And a second contact the same week after deleting earns nothing.
    });
  });

  group('the card', () {
    test('stamps go onto the current card; the full card is earned', () async {
      final cinema = await treats.add('Cinema', 3);
      expect(await treats.setCurrent(cinema.id), isTrue);
      final a = await person('A');
      final b = await person('B');
      final c = await person('C');
      await contact(a, mon);
      await contact(b, mon);
      var t = await treatOf(cinema.id);
      expect(t.state, TreatState.current);
      expect(stampsOnCard(await stamps(), cinema.id), 2);
      await contact(c, mon);
      t = await treatOf(cinema.id);
      expect(t.state, TreatState.earned);
      expect(t.earnedAt, isNotNull);
      expect(stampsOnCard(await stamps(), cinema.id), 3);
      expect(currentTreat(await allTreats()), isNull);
    });

    test('extra value carries over: loose, then onto the next card', () async {
      final cake = await treats.add('Cake', 3);
      final book = await treats.add('Book', 5);
      await treats.setCurrent(cake.id);
      final a = await person('A');
      final b = await person('B', closeness: Closeness.fewTimesAYear);
      await contact(a, mon);
      await contact(a, nextMon);
      // 2 on the card; B is worth 3: 1 fits, 2 stay loose.
      await contact(b, mon);
      expect((await treatOf(cake.id)).state, TreatState.earned);
      expect(stampsOnCard(await stamps(), cake.id), 3);
      final loose = (await stamps()).where((s) => s.treatId == null);
      expect(stampTotal(loose), 2);
      expect(await total(), 5);
      // More stamps without a current card stay loose.
      final c = await person('C');
      await contact(c, mon);
      expect(stampTotal((await stamps()).where((s) => s.treatId == null)), 3);
      // Choosing the next card puts them on it, oldest first.
      expect(await treats.setCurrent(book.id), isTrue);
      expect(stampsOnCard(await stamps(), book.id), 3);
      expect((await treatOf(book.id)).state, TreatState.current);
      expect((await stamps()).where((s) => s.treatId == null), isEmpty);
      expect(await total(), 6);
    });

    test('choosing a card too small for the loose stamps fills it and keeps the rest', () async {
      final a = await person('A', closeness: Closeness.fewTimesAYear);
      await contact(a, mon);
      await contact(await person('B', closeness: Closeness.fewTimesAYear), mon);
      expect(await total(), 6);
      final small = await treats.add('Small', 4);
      await treats.setCurrent(small.id);
      expect((await treatOf(small.id)).state, TreatState.earned);
      expect(stampsOnCard(await stamps(), small.id), 4);
      expect(stampTotal((await stamps()).where((s) => s.treatId == null)), 2);
      expect(await total(), 6);
    });

    test('a raise goes onto the current card', () async {
      final card = await treats.add('Card', 10);
      await treats.setCurrent(card.id);
      final tom = await person('Tom', closeness: Closeness.nowAndThen);
      await contact(tom, mon);
      await contact(
        tom,
        wed,
        kind: ContactKind.gamed,
        direction: ContactDirection.together,
      );
      expect(stampsOnCard(await stamps(), card.id), 4);
    });

    test('only one card is current at a time', () async {
      final one = await treats.add('One', 5);
      final two = await treats.add('Two', 5);
      expect(await treats.setCurrent(one.id), isTrue);
      expect(await treats.setCurrent(two.id), isFalse);
      expect((await treatOf(two.id)).state, TreatState.waiting);
    });

    test('an earned treat can be marked enjoyed, once earned', () async {
      final one = await treats.add('One', 1);
      final two = await treats.add('Two', 5);
      await treats.markEnjoyed(two.id);
      expect((await treatOf(two.id)).state, TreatState.waiting);
      await treats.setCurrent(one.id);
      await contact(await person('Tom'), mon);
      expect((await treatOf(one.id)).state, TreatState.earned);
      await treats.markEnjoyed(one.id, now: wed);
      final t = await treatOf(one.id);
      expect(t.state, TreatState.enjoyed);
      expect(t.enjoyedAt, wed);
      expect(t.earnedAt, isNotNull);
    });
  });

  group('editing treats', () {
    test('add puts a waiting treat at the end', () async {
      await treats.add('One', 10);
      final two = await treats.add('  Two  ', 20);
      expect(two.name, 'Two');
      expect(two.state, TreatState.waiting);
      expect([for (final t in await allTreats()) t.name], ['One', 'Two']);
    });

    test('rename and the stamp number work on waiting treats only', () async {
      final a = await treats.add('A', 10);
      final b = await treats.add('B', 10);
      await treats.rename(a.id, 'Alpha');
      await treats.setStampsNeeded(a.id, 15);
      await treats.setStampsNeeded(b.id, 0);
      expect((await treatOf(a.id)).name, 'Alpha');
      expect((await treatOf(a.id)).stampsNeeded, 15);
      expect((await treatOf(b.id)).stampsNeeded, 1);
      await treats.setCurrent(a.id);
      await treats.rename(a.id, 'Changed');
      await treats.setStampsNeeded(a.id, 99);
      expect((await treatOf(a.id)).name, 'Alpha');
      expect((await treatOf(a.id)).stampsNeeded, 15);
    });

    test('move reorders the queue and stops at the ends', () async {
      final a = await treats.add('A', 1);
      final b = await treats.add('B', 1);
      final c = await treats.add('C', 1);
      Future<List<String>> names() async => [
        for (final t in await allTreats()) t.name,
      ];
      await treats.move(c.id, up: true);
      expect(await names(), ['A', 'C', 'B']);
      await treats.move(a.id, up: false);
      expect(await names(), ['C', 'A', 'B']);
      await treats.move(c.id, up: true);
      await treats.move(b.id, up: false);
      expect(await names(), ['C', 'A', 'B']);
    });

    test('delete removes a waiting treat, not an earned one', () async {
      final a = await treats.add('A', 1);
      final b = await treats.add('B', 5);
      await treats.setCurrent(a.id);
      await contact(await person('Tom'), mon);
      expect((await treatOf(a.id)).state, TreatState.earned);
      await treats.delete(a.id);
      await treats.delete(b.id);
      expect([for (final t in await allTreats()) t.name], ['A']);
      // The stamps on it stay.
      expect(await total(), 1);
    });
  });

  group('the first start', () {
    final names = [for (var i = 1; i <= 12; i++) ('Treat $i', i * 10)];

    test('the default treats are put in once, all waiting', () async {
      await services.ensureStampsReady(names);
      var all = await allTreats();
      expect(all, hasLength(12));
      expect(all.every((t) => t.state == TreatState.waiting), isTrue);
      expect(all.first.name, 'Treat 1');
      expect((await services.settings.load()).defaultTreatsInserted, isTrue);
      // A deleted default does not come back.
      await treats.delete(all.first.id);
      await services.ensureStampsReady(names);
      all = await allTreats();
      expect(all, hasLength(11));
    });

    test('the backfill runs the rule over the history in time order', () async {
      final tom = await person('Tom', closeness: Closeness.nowAndThen);
      final ann = await person('Ann');
      // Raw rows, as the earlier milestones stored them.
      var n = 0;
      Future<void> raw(
        Person p,
        DateTime at,
        ContactKind k,
        ContactDirection d,
      ) => db
          .into(db.contactEvents)
          .insert(
            ContactEvent(
              id: 'e${n++}',
              personId: p.id,
              at: at,
              kind: k,
              direction: d,
              source: ContactSource.manual,
              createdAt: at,
            ),
          );
      const w = ContactKind.wrote, us = ContactDirection.byUser;
      // Out of order on purpose.
      await raw(tom, wed, ContactKind.met, ContactDirection.together);
      await raw(tom, mon, w, us);
      await raw(ann, mon, w, ContactDirection.byThem);
      await raw(ann, nextMon, w, us);
      expect(await stamps(), isEmpty);

      await services.ensureStampsReady(names);
      // Tom: message 2, then the meet-up raises to 4. Ann: one, incoming none.
      expect(await total(), 5);
      final byPerson = <String?, int>{};
      for (final s in await stamps()) {
        byPerson[s.personId] = (byPerson[s.personId] ?? 0) + s.value;
      }
      expect(byPerson[tom.id], 4);
      expect(byPerson[ann.id], 1);
    });

    test('the backfill cannot run twice', () async {
      final tom = await person('Tom');
      await db
          .into(db.contactEvents)
          .insert(
            ContactEvent(
              id: 'old',
              personId: tom.id,
              at: mon,
              kind: ContactKind.wrote,
              direction: ContactDirection.byUser,
              source: ContactSource.manual,
              createdAt: mon,
            ),
          );
      await services.ensureStampsReady(names);
      expect(await total(), 1);
      expect((await services.settings.load()).stampsBackfilled, isTrue);
      // A new, later event earns through add; a second start does not
      // award the old one again.
      await contact(tom, nextMon);
      await services.ensureStampsReady(names);
      await services.ensureStampsReady(names);
      expect(await total(), 2);
      // Two starts at the same moment do not double either.
      final other = AppServices(
        db: AppDatabase(NativeDatabase.memory()),
        openDemo: () => AppDatabase(NativeDatabase.memory()),
      );
      addTearDown(other.close);
      final p = await other
          .peopleFor(demo: false)
          .add(name: 'X', closeness: Closeness.close, now: added);
      await other.db
          .into(other.db.contactEvents)
          .insert(
            ContactEvent(
              id: 'x',
              personId: p.id,
              at: mon,
              kind: ContactKind.wrote,
              direction: ContactDirection.byUser,
              source: ContactSource.manual,
              createdAt: mon,
            ),
          );
      await Future.wait([
        other.ensureStampsReady(names),
        other.ensureStampsReady(names),
      ]);
      expect(
        stampTotal(await other.treatsFor(demo: false).watchStamps().first),
        1,
      );
      expect(
        (await other.treatsFor(demo: false).watchAll().first),
        hasLength(12),
      );
    });
  });

  group('settings', () {
    test(
      'the weights and flags are stored and broken values fall back',
      () async {
        await services.settings.update(
          (s) => s.copyWith(
            stampWeights: const StampWeights(
              close: 2,
              longGapBonus: 0,
              meetMultiplier: 3,
              cardSize: 12,
            ),
          ),
        );
        final s = await services.settings.load();
        expect(s.stampWeights.close, 2);
        expect(s.stampWeights.longGapBonus, 0);
        expect(s.stampWeights.meetMultiplier, 3);
        expect(s.stampWeights.cardSize, 12);
        expect(s.stampWeights.nowAndThen, 2);
        final broken = AppSettings.fromMap({
          'stampClose': '99',
          'stampCardSize': 'x',
          'stampMeet': '0',
        });
        expect(broken.stampWeights, const StampWeights());
      },
    );
  });
}

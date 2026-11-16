import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/database.dart';
import 'package:kept/data/ideas_repository.dart';
import 'package:kept/data/intentions_repository.dart';
import 'package:kept/data/people_repository.dart';
import 'package:kept/domain/idea.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/person.dart';

void main() {
  late AppDatabase db;
  late IdeasRepository repo;
  late PeopleRepository people;
  late Person anna;
  late Directory tmp;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = IdeasRepository(db);
    people = PeopleRepository(db);
    anna = await people.add(name: 'Anna', closeness: Closeness.close);
    tmp = await Directory.systemTemp.createTemp('kept_ideas_');
  });
  tearDown(() async {
    await db.close();
    if (await tmp.exists()) await tmp.delete(recursive: true);
  });

  Future<File> picture(String name) async =>
      File('${tmp.path}/$name')..writeAsBytesSync([1, 2, 3]);

  test('adds, orders newest first, and stores empty links as null', () async {
    final a = await repo.add(
      personId: anna.id,
      note: ' hall ',
      kind: IdeaKind.toDo,
      link: '  ',
      now: DateTime(2026, 11, 1, 9, 0, 0, 500),
    );
    final b = await repo.add(
      personId: anna.id,
      note: 'trip',
      kind: IdeaKind.toTalk,
      link: 'https://example.org',
      now: DateTime(2026, 11, 2),
    );
    expect(a.note, 'hall');
    expect(a.link, isNull);
    expect(a.createdAt, DateTime(2026, 11, 1, 9));
    expect(await repo.watchForPerson(anna.id).first, [b, a]);
    final row = await db.customSelect('SELECT kind FROM ideas').get();
    expect(row.map((r) => r.read<String>('kind')), contains('toTalk'));
  });

  test('updates text, kind and link; ticks off and opens again', () async {
    final a = await repo.add(
      personId: anna.id,
      note: 'hall',
      kind: IdeaKind.toDo,
    );
    await repo.update(
      a.id,
      note: 'trip',
      kind: IdeaKind.toTalk,
      link: 'example.org',
    );
    var stored = (await repo.watchForPerson(anna.id).first).single;
    expect(
      (stored.note, stored.kind, stored.link),
      ('trip', IdeaKind.toTalk, 'example.org'),
    );
    await repo.setDone(a.id, true, now: DateTime(2026, 11, 3, 8));
    stored = (await repo.watchForPerson(anna.id).first).single;
    expect(stored.doneAt, DateTime(2026, 11, 3, 8));
    await repo.setDone(a.id, false);
    stored = (await repo.watchForPerson(anna.id).first).single;
    expect(stored.doneAt, isNull);
  });

  test('deleting an idea deletes its picture file', () async {
    final file = await picture('a.jpg');
    final a = await repo.add(
      personId: anna.id,
      note: '',
      kind: IdeaKind.toDo,
      imagePath: file.path,
    );
    expect(await repo.imagePaths(), [file.path]);
    await repo.delete(a.id);
    expect(await repo.watchForPerson(anna.id).first, isEmpty);
    expect(file.existsSync(), isFalse);
  });

  test('ideas go with their person', () async {
    await repo.add(personId: anna.id, note: 'x', kind: IdeaKind.toDo);
    await people.delete(anna.id);
    expect(await repo.imagePaths(), isEmpty);
    expect(await db.select(db.ideas).get(), isEmpty);
  });

  test('the cleanup removes old pictures no idea refers to', () async {
    final now = DateTime.now();
    final kept = await picture('kept.jpg');
    final orphan = await picture('orphan.png');
    final fresh = await picture('fresh.jpg');
    final old = now.subtract(const Duration(days: 2));
    kept.setLastModifiedSync(old);
    orphan.setLastModifiedSync(old);
    await repo.add(
      personId: anna.id,
      note: '',
      kind: IdeaKind.toDo,
      imagePath: kept.path,
    );
    final removed = await removeOrphanPictures(
      tmp,
      await repo.imagePaths(),
      now: now,
    );
    expect(removed, 1);
    expect(kept.existsSync(), isTrue);
    expect(orphan.existsSync(), isFalse);
    // Just copied by a share whose sheet may still be open.
    expect(fresh.existsSync(), isTrue);
    expect(
      await removeOrphanPictures(Directory('${tmp.path}/none'), const []),
      0,
    );
  });

  test('a thought keeps a link; update changes and clears it', () async {
    final thoughts = IntentionsRepository(db);
    final t = await thoughts.add(
      personId: anna.id,
      note: 'hall',
      link: 'https://example.org',
    );
    expect(t.link, 'https://example.org');
    expect((await thoughts.watchForPerson(anna.id).first).single.link, t.link);
    await thoughts.update(
      t.id,
      note: 'hall',
      kind: IntentionKind.meet,
      when: const When.none(),
      link: ' ',
    );
    expect((await thoughts.watchForPerson(anna.id).first).single.link, isNull);
  });
}

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:uuid/uuid.dart';

import '../domain/idea.dart';
import 'database.dart';

/// Reads and writes the ideas of one database: the real one or, in demo
/// mode, the demo one (AppServices.ideasFor). An idea is something to do
/// or to talk about with a person (02-design.md §3, F11, M10).
///
/// A picture is a file in the app's own `shared/` folder (copied there by
/// the share channel); the row keeps its path. Deleting the idea deletes
/// the file. Ideas deleted with their person leave their file behind; the
/// start-up cleanup ([removeOrphanPictures]) removes those.
class IdeasRepository {
  IdeasRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// All ideas of one person, open and done, newest first.
  Stream<List<Idea>> watchForPerson(String personId) =>
      (_db.select(_db.ideas)
            ..where((t) => t.personId.equals(personId))
            ..orderBy([
              (t) => OrderingTerm.desc(t.createdAt),
              // drift stores whole seconds; the id keeps the order stable.
              (t) => OrderingTerm.desc(t.id),
            ]))
          .watch();

  /// The picture paths of all ideas, for the cleanup.
  Future<List<String>> imagePaths() async {
    final rows = await (_db.select(
      _db.ideas,
    )..where((t) => t.imagePath.isNotNull())).get();
    return [for (final r in rows) r.imagePath!];
  }

  /// Adds an open idea with a new id. Empty [link] and [imagePath] are
  /// stored as null. [now] is for tests.
  Future<Idea> add({
    required String personId,
    required String note,
    required IdeaKind kind,
    String? link,
    String? imagePath,
    DateTime? now,
  }) async {
    final idea = Idea(
      id: _uuid.v4(),
      personId: personId,
      note: note.trim(),
      kind: kind,
      link: _orNull(link),
      imagePath: _orNull(imagePath),
      createdAt: _wholeSeconds(now ?? DateTime.now()),
    );
    await _db.into(_db.ideas).insert(idea);
    return idea;
  }

  /// Changes the text, the kind and the link, as the edit sheet does.
  Future<void> update(
    String id, {
    required String note,
    required IdeaKind kind,
    String? link,
  }) => (_db.update(_db.ideas)..where((t) => t.id.equals(id))).write(
    IdeasCompanion(
      note: Value(note.trim()),
      kind: Value(kind),
      link: Value(_orNull(link)),
    ),
  );

  /// Ticks the idea off ([done]) or opens it again. [now] is for tests.
  Future<void> setDone(String id, bool done, {DateTime? now}) =>
      (_db.update(_db.ideas)..where((t) => t.id.equals(id))).write(
        IdeasCompanion(
          doneAt: Value(done ? _wholeSeconds(now ?? DateTime.now()) : null),
        ),
      );

  /// Deletes the idea and its picture file, if it has one.
  Future<void> delete(String id) async {
    final row = await (_db.select(
      _db.ideas,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    await (_db.delete(_db.ideas)..where((t) => t.id.equals(id))).go();
    final path = row?.imagePath;
    if (path != null) await deletePictureFile(path);
  }

  /// Replaces all ideas with [ideas] in one step. For the demo database;
  /// the people they refer to must be there already.
  Future<void> replaceAll(List<Idea> ideas) => _db.transaction(() async {
    await _db.delete(_db.ideas).go();
    await _db.batch((b) => b.insertAll(_db.ideas, ideas));
  });

  static String? _orNull(String? text) {
    final t = text?.trim();
    return t == null || t.isEmpty ? null : t;
  }

  static DateTime _wholeSeconds(DateTime t) => t.subtract(
    Duration(milliseconds: t.millisecond, microseconds: t.microsecond),
  );
}

/// Deletes a picture file; a missing file or a failure is only logged.
Future<void> deletePictureFile(String path) async {
  try {
    final file = File(path);
    if (await file.exists()) await file.delete();
  } catch (e) {
    debugPrint('Picture not deleted: ${e.runtimeType}');
  }
}

/// Removes the files in [dir] that no idea refers to ([referenced]). Files
/// changed in the last hour before [now] stay: a share may just have
/// copied one and its sheet may still be open. Returns how many went.
Future<int> removeOrphanPictures(
  Directory dir,
  Iterable<String> referenced, {
  DateTime? now,
}) async {
  if (!await dir.exists()) return 0;
  final keep = {for (final p in referenced) File(p).absolute.path};
  final limit = (now ?? DateTime.now()).subtract(const Duration(hours: 1));
  var removed = 0;
  await for (final entry in dir.list()) {
    if (entry is! File) continue;
    if (keep.contains(entry.absolute.path)) continue;
    if ((await entry.lastModified()).isAfter(limit)) continue;
    try {
      await entry.delete();
      removed++;
    } catch (e) {
      debugPrint('Orphan picture not deleted: ${e.runtimeType}');
    }
  }
  return removed;
}

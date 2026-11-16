import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:kept/platform/photo_store.dart';

/// 1000 x 600: left third red, middle third green, right third blue.
Uint8List testPng({int? orientation}) {
  final im = img.Image(width: 1000, height: 600);
  for (final p in im) {
    p.setRgb(
      p.x < 333 ? 255 : 0,
      p.x >= 333 && p.x < 666 ? 255 : 0,
      p.x >= 666 ? 255 : 0,
    );
  }
  if (orientation != null) im.exif.imageIfd.orientation = orientation;
  // JPEG at quality 100 keeps the three colours clear and carries EXIF.
  return orientation == null
      ? img.encodePng(im)
      : img.encodeJpg(im, quality: 100);
}

img.Image load(File f) => img.decodeJpg(f.readAsBytesSync())!;

void main() {
  late Directory tmp;
  late FilePhotoStore store;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('kept_photos');
    store = FilePhotoStore(baseDir: tmp);
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  test('saves a 384 x 384 JPEG, centre square by default', () async {
    final name = await store.saveSquare(testPng());
    expect(name, endsWith('.jpg'));
    final file = await store.fileFor(name);
    expect(file.parent.path, '${tmp.path}/avatars');
    final bytes = file.readAsBytesSync();
    expect(bytes.sublist(0, 2), [0xFF, 0xD8]);
    final out = load(file);
    expect((out.width, out.height), (384, 384));
    // Centre square is x 200..800: red edge, green middle, blue edge.
    final left = out.getPixel(10, 192);
    final mid = out.getPixel(192, 192);
    final right = out.getPixel(373, 192);
    expect(left.r > 200 && left.g < 60, isTrue);
    expect(mid.g > 200 && mid.r < 60, isTrue);
    expect(right.b > 200 && right.r < 60, isTrue);
  });

  test('honours a given crop rect', () async {
    final name = await store.saveSquare(
      testPng(),
      crop: const Rect.fromLTWH(0, 0, 300, 300),
    );
    final out = load(await store.fileFor(name));
    expect((out.width, out.height), (384, 384));
    final p = out.getPixel(192, 192);
    expect(p.r > 200 && p.g < 60 && p.b < 60, isTrue);
  });

  test('applies EXIF orientation before cropping', () async {
    // Orientation 6: rotated 90 degrees, so the picture is 600 x 1000 and
    // the red third (left in the file) ends up at the top.
    final name = await store.saveSquare(testPng(orientation: 6));
    final out = load(await store.fileFor(name));
    expect((out.width, out.height), (384, 384));
    final top = out.getPixel(192, 10);
    final bottom = out.getPixel(192, 373);
    expect(top.r > 200 && top.b < 60, isTrue);
    expect(bottom.b > 200 && bottom.r < 60, isTrue);
  });

  test('read and delete', () async {
    final name = await store.saveSquare(testPng());
    expect(await store.read(name), isNotNull);
    await store.delete(name);
    expect(await store.read(name), isNull);
    await store.delete(name); // no error when already gone
  });

  test('deleteUnused keeps only the given names', () async {
    final a = await store.saveSquare(testPng());
    final b = await store.saveSquare(testPng());
    final c = await store.saveSquare(testPng());
    await store.deleteUnused({b});
    expect(await store.read(a), isNull);
    expect(await store.read(b), isNotNull);
    expect(await store.read(c), isNull);
  });

  test('rejects bytes that are not a picture', () async {
    expect(store.saveSquare(Uint8List.fromList([1, 2, 3])), throwsA(anything));
  });
}

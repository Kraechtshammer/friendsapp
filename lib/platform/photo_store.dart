import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Side length of a stored picture, in pixels.
const photoSize = 384;

/// Profile pictures: stored small, one file per picture, named by UUID.
abstract class PhotoStore {
  /// Cuts [bytes] (any format `image` reads, EXIF orientation applied) to
  /// [crop] (a square in pixels of the oriented source; null means the
  /// centre square), scales to 384 x 384 and stores it as JPEG. Returns the
  /// file name.
  Future<String> saveSquare(Uint8List bytes, {Rect? crop});

  /// The stored picture [name], or null if the file is gone.
  Future<Uint8List?> read(String name);

  /// The file of [name]; it may not exist.
  Future<File> fileFor(String name);

  Future<void> delete(String name);

  /// Deletes every stored picture whose name is not in [keep].
  Future<void> deleteUnused(Set<String> keep);

  /// Lets the user pick a picture with the system photo picker. Returns the
  /// original bytes, or null if cancelled.
  Future<Uint8List?> pickFromGallery();
}

/// [PhotoStore] on files under `<base>/avatars`. [baseDir] is the
/// application support directory unless given (tests).
class FilePhotoStore implements PhotoStore {
  const FilePhotoStore({this.baseDir});

  final Directory? baseDir;

  Future<Directory> _dir() async {
    final base = baseDir ?? await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/avatars');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  @override
  Future<String> saveSquare(Uint8List bytes, {Rect? crop}) async {
    final rect = crop == null
        ? null
        : [crop.left, crop.top, crop.width, crop.height];
    final jpg = await Isolate.run(() => encodeSquare(bytes, rect));
    final name = '${const Uuid().v4()}.jpg';
    await File('${(await _dir()).path}/$name').writeAsBytes(jpg, flush: true);
    return name;
  }

  @override
  Future<File> fileFor(String name) async =>
      File('${(await _dir()).path}/$name');

  @override
  Future<Uint8List?> read(String name) async {
    final f = await fileFor(name);
    return f.existsSync() ? f.readAsBytes() : null;
  }

  @override
  Future<void> delete(String name) async {
    final f = await fileFor(name);
    if (f.existsSync()) await f.delete();
  }

  @override
  Future<void> deleteUnused(Set<String> keep) async {
    await for (final e in (await _dir()).list()) {
      if (e is! File) continue;
      final name = e.uri.pathSegments.last;
      if (!keep.contains(name)) await e.delete();
    }
  }

  @override
  Future<Uint8List?> pickFromGallery() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    return file?.readAsBytes();
  }
}

/// The pure part of [PhotoStore.saveSquare], public for tests. [crop] is
/// `[left, top, width, height]`. Runs on whichever isolate calls it.
Uint8List encodeSquare(Uint8List bytes, List<double>? crop) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const FormatException('Not a picture Kept can read.');
  }
  final src = img.bakeOrientation(decoded);
  int x, y, side;
  if (crop == null) {
    side = math.min(src.width, src.height);
    x = (src.width - side) ~/ 2;
    y = (src.height - side) ~/ 2;
  } else {
    side = math.max(1, math.min(crop[2], crop[3]).round());
    side = math.min(side, math.min(src.width, src.height));
    x = crop[0].round().clamp(0, src.width - side);
    y = crop[1].round().clamp(0, src.height - side);
  }
  final square = img.copyCrop(src, x: x, y: y, width: side, height: side);
  final small = img.copyResize(
    square,
    width: photoSize,
    height: photoSize,
    interpolation: img.Interpolation.average,
  );
  return img.encodeJpg(small, quality: 85);
}

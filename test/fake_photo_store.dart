import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:kept/platform/photo_store.dart';

/// [PhotoStore] in memory. [saveSquare] stores the bytes unchanged under a
/// counted name; [picked] is what [pickFromGallery] returns.
class FakePhotoStore implements PhotoStore {
  final files = <String, Uint8List>{};
  Uint8List? picked;
  var _n = 0;

  @override
  Future<String> saveSquare(Uint8List bytes, {Rect? crop}) async {
    final name = 'fake-${_n++}.jpg';
    files[name] = bytes;
    return name;
  }

  @override
  Future<Uint8List?> read(String name) async => files[name];

  @override
  Future<File> fileFor(String name) async => File('/fake-avatars/$name');

  @override
  Future<void> delete(String name) async => files.remove(name);

  @override
  Future<void> deleteUnused(Set<String> keep) async =>
      files.removeWhere((name, _) => !keep.contains(name));

  @override
  Future<Uint8List?> pickFromGallery() async => picked;
}

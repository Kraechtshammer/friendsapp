import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kept/ui/kept_icon.dart';

void main() {
  test('every icon has its file, and every file its icon', () {
    final files = Directory('assets/icons')
        .listSync()
        .map((f) => f.uri.pathSegments.last)
        .toSet();
    expect(files, {for (final icon in KeptIcons.values) '${icon.name}.svg'});
  });
}

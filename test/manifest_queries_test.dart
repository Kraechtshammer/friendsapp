import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kept/domain/chat_app.dart';

void main() {
  test('the manifest lets Kept. see every chat app package', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    final listed = RegExp(r'<package android:name="([^"]+)"')
        .allMatches(manifest)
        .map((m) => m.group(1))
        .toSet();
    final needed = {for (final app in ChatApp.values) ...app.packages};
    expect(listed, needed);
  });
}

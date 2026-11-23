import 'dart:async';

import 'package:kept/ui/varied_text.dart';

/// Runs before every test file: rotating texts always show their first
/// variant, so tests can look for the original text.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  variantPicker = (_) => 0;
  await testMain();
}

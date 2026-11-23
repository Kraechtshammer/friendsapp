import 'dart:math';

import '../l10n/app_localizations.dart';
import 'material.dart';

/// Texts that rotate: the "Nice one" heading and line, and the example
/// hints in text fields (02-design.md §8, 2026-11-16). Each place picks one
/// of several equal texts at random when it opens and keeps it while it is
/// open. The first of each list is the original text.

/// Returns a number from 0 to below the given count. Tests set it to
/// always return 0 (test/flutter_test_config.dart), so they see the first
/// text.
int Function(int count) variantPicker = Random().nextInt;

/// Gives a [State] one random variant number for its whole life.
mixin VariedText<T extends StatefulWidget> on State<T> {
  late final int _variant = variantPicker(1 << 16);

  /// One of [texts]. Lists of the same length pick the same position, so
  /// a heading and its line stay a pair.
  String vary(List<String> texts) => texts[_variant % texts.length];
}

extension VariedTexts on AppLocalizations {
  List<String> get niceOneTitles => [
    niceOneTitle,
    niceOneTitle2,
    niceOneTitle3,
    niceOneTitle4,
    niceOneTitle5,
    niceOneTitle6,
  ];

  List<String> get niceOneSubtitles => [
    niceOneSubtitle,
    niceOneSubtitle2,
    niceOneSubtitle3,
    niceOneSubtitle4,
    niceOneSubtitle5,
    niceOneSubtitle6,
  ];

  List<String> get captureHints => [
    captureHint,
    captureHint2,
    captureHint3,
    captureHint4,
    captureHint5,
    captureHint6,
  ];

  List<String> get nextTimeHints => [
    nextTimeHint,
    nextTimeHint2,
    nextTimeHint3,
    nextTimeHint4,
    nextTimeHint5,
    nextTimeHint6,
  ];

  List<String> get ideaTextHints => [
    ideaTextHint,
    ideaTextHint2,
    ideaTextHint3,
    ideaTextHint4,
    ideaTextHint5,
    ideaTextHint6,
  ];

  List<String> get whenConditionHints => [
    whenConditionHint,
    whenConditionHint2,
    whenConditionHint3,
    whenConditionHint4,
    whenConditionHint5,
    whenConditionHint6,
  ];
}

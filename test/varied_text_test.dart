import 'package:flutter_test/flutter_test.dart';
import 'package:kept/l10n/app_localizations.dart';
import 'package:kept/ui/varied_text.dart';

void main() {
  for (final locale in AppLocalizations.supportedLocales) {
    test('every rotating text has six different variants ($locale)', () {
      final l10n = lookupAppLocalizations(locale);
      for (final texts in [
        l10n.niceOneTitles,
        l10n.niceOneSubtitles,
        l10n.captureHints,
        l10n.nextTimeHints,
        l10n.ideaTextHints,
        l10n.whenConditionHints,
      ]) {
        expect(texts.toSet(), hasLength(6), reason: texts.first);
      }
    });
  }
}

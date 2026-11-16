import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/app_settings.dart';
import '../common.dart';
import '../material.dart';

/// The theme choice (system, light or dark, ui-style.md §2) and the language.
class LookSection extends ConsumerWidget {
  const LookSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.settingsTheme.toUpperCase(), style: context.text.labelMedium),
        const SizedBox(height: 12),
        SegmentedButton<AppThemeMode>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: AppThemeMode.system,
              label: Text(l10n.themeSystem),
            ),
            ButtonSegment(
              value: AppThemeMode.light,
              label: Text(l10n.themeLight),
            ),
            ButtonSegment(
              value: AppThemeMode.dark,
              label: Text(l10n.themeDark),
            ),
          ],
          selected: {ref.settings.themeMode},
          onSelectionChanged: (chosen) => unawaited(
            ref.services.settings.update(
              (s) => s.copyWith(themeMode: chosen.single),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.settingsLanguage.toUpperCase(),
          style: context.text.labelMedium,
        ),
        const SizedBox(height: 12),
        SegmentedButton<AppLanguage>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: AppLanguage.system,
              label: Text(l10n.themeSystem),
            ),
            ButtonSegment(
              value: AppLanguage.en,
              label: Text(l10n.languageEnglish),
            ),
            ButtonSegment(
              value: AppLanguage.de,
              label: Text(l10n.languageGerman),
            ),
          ],
          selected: {ref.settings.language},
          onSelectionChanged: (chosen) => unawaited(
            ref.services.settings.update(
              (s) => s.copyWith(language: chosen.single),
            ),
          ),
        ),
      ],
    );
  }
}

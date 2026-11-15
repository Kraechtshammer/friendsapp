import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/app_settings.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/avatar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.settings;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.settingsTheme.toUpperCase(),
            style: context.text.labelMedium,
          ),
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
            selected: {settings.themeMode},
            onSelectionChanged: (chosen) => unawaited(
              ref.services.settings.update(
                (s) => s.copyWith(themeMode: chosen.single),
              ),
            ),
          ),
          if (kDebugMode) _Development(demoMode: settings.demoMode),
        ],
      ),
    );
  }
}

/// Development builds only (02-design.md §8, demo data). These texts are
/// hard-coded English on purpose: the user never sees them, so they are
/// not ARB keys.
class _Development extends ConsumerWidget {
  const _Development({required this.demoMode});

  final bool demoMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Text('DEVELOPMENT', style: context.text.labelMedium),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Demo data'),
          subtitle: const Text(
            'Shows invented people. Your own data is not touched.',
          ),
          value: demoMode,
          onChanged: (on) => unawaited(ref.services.setDemoMode(on)),
        ),
        // Throwaway, see [badgePreview].
        ValueListenableBuilder(
          valueListenable: badgePreview,
          builder: (context, on, _) => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Class badge on the People tab'),
            subtitle: const Text('Preview only.'),
            value: on,
            onChanged: (value) => badgePreview.value = value,
          ),
        ),
      ],
    );
  }
}

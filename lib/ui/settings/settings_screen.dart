import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/app_settings.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/kept_card.dart';
import 'about.dart';
import 'development_section.dart';
import 'evening_section.dart';
import 'incoming_section.dart';
import 'open_items_section.dart';
import 'own_birthday_row.dart';
import 'permissions_screen.dart';
import 'rhythms_section.dart';
import 'stamps_section.dart';
import 'streak_section.dart';
import 'update_tiles.dart';

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
          KeptCard(
            small: true,
            onTap: () => openPermissions(context),
            child: Row(
              spacing: 12,
              children: [
                const KeptIcon(KeptIcons.check, size: 28),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.permTitle, style: context.text.titleLarge),
                      Text(l10n.permRowHelp, style: context.text.bodyMedium),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          const SizedBox(height: 32),
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
          const SizedBox(height: 32),
          OpenItemsSection(mode: settings.openItems),
          const SizedBox(height: 32),
          RhythmsSection(settings: settings),
          const SizedBox(height: 32),
          StampsSection(weights: settings.stampWeights),
          const SizedBox(height: 32),
          StreakSection(mode: settings.streakMode),
          const SizedBox(height: 32),
          EveningSection(settings: settings),
          const SizedBox(height: 32),
          OwnBirthdayRow(birthday: settings.ownBirthday),
          const SizedBox(height: 32),
          IncomingSection(settings: settings),
          const SizedBox(height: 32),
          // In-app update, not in a Play build (update_controller.dart).
          const UpdateSection(),
          const SizedBox(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsAbout),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => unawaited(openAbout(context, ref)),
          ),
          if (kDebugMode) DevelopmentSection(demoMode: settings.demoMode),
        ],
      ),
    );
  }
}

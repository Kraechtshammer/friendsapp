import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/update_controller.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/kept_card.dart';
import 'about.dart';
import 'permissions_screen.dart';
import 'settings_pages.dart';

/// Settings as a list of categories: a coloured icon, a title, one muted
/// line about what is inside, and a chevron. Each row opens its own page
/// (04-architecture.md §2.4).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final latest = ref.watch(updateProvider).latest;
    final builtIn = ref.watch(incomingBuiltInProvider);

    void open(Widget page) => unawaited(
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page)),
    );

    final rows = <Widget>[
      _CategoryRow(
        icon: KeptIcons.moon,
        title: l10n.settingsEvening,
        line: l10n.settingsCatEveningLine,
        onTap: () => open(const EveningPage()),
      ),
      _CategoryRow(
        icon: KeptIcons.people,
        title: l10n.settingsCatFriends,
        line: builtIn
            ? l10n.settingsCatFriendsLine
            : l10n.settingsCatFriendsLineNoListener,
        onTap: () => open(const FriendsPage()),
      ),
      _CategoryRow(
        icon: KeptIcons.cake,
        title: l10n.settingsCatBirthdays,
        line: l10n.settingsCatBirthdaysLine,
        onTap: () => open(const BirthdaysPage()),
      ),
      _CategoryRow(
        icon: KeptIcons.stamp,
        title: l10n.settingsCatStamps,
        line: l10n.settingsCatStampsLine,
        onTap: () => open(const StampsPage()),
      ),
      _CategoryRow(
        icon: KeptIcons.palette,
        title: l10n.settingsCatLook,
        line: l10n.settingsCatLookLine,
        onTap: () => open(const LookPage()),
      ),
      _CategoryRow(
        icon: KeptIcons.shield,
        title: l10n.permTitle,
        line: l10n.permRowHelp,
        onTap: () => openPermissions(context),
      ),
      _CategoryRow(
        icon: KeptIcons.download,
        title: l10n.updateSection,
        line: latest == null
            ? l10n.settingsCatUpdatesLine
            : l10n.updateAvailableTile('${latest.version}'),
        onTap: () => open(const UpdatesPage()),
      ),
      _CategoryRow(
        icon: KeptIcons.info,
        title: l10n.settingsAbout,
        line: l10n.settingsCatAboutLine,
        onTap: () => unawaited(openAbout(context, ref)),
      ),
      if (kDebugMode)
        _CategoryRow(
          icon: KeptIcons.wasd,
          title: 'Development',
          line: 'Demo data',
          onTap: () => open(const DevelopmentPage()),
        ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rows.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => rows[i],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.icon,
    required this.title,
    required this.line,
    required this.onTap,
  });

  final KeptIcons icon;
  final String title;
  final String line;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return KeptCard(
      small: true,
      onTap: onTap,
      child: Row(
        spacing: 12,
        children: [
          KeptIcon(icon, size: 28),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleLarge),
                Text(line, style: context.text.bodyMedium),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

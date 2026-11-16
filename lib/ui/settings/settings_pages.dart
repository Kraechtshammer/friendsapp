import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../common.dart';
import '../material.dart';
import 'development_section.dart';
import 'evening_section.dart';
import 'incoming_section.dart';
import 'look_section.dart';
import 'open_items_section.dart';
import 'own_birthday_row.dart';
import 'rhythms_section.dart';
import 'stamps_section.dart';
import 'streak_section.dart';
import 'update_tiles.dart';

/// One category page of Settings: an app bar with the title and the
/// sections one under the other, 32 apart.
class _CategoryPage extends StatelessWidget {
  const _CategoryPage({required this.title, required this.sections});

  final String title;
  final List<Widget> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) const SizedBox(height: 32),
            sections[i],
          ],
        ],
      ),
    );
  }
}

/// Settings › Evening question: the evening question, then open items.
class EveningPage extends ConsumerWidget {
  const EveningPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.settings;
    return _CategoryPage(
      title: context.l10n.settingsEvening,
      sections: [
        EveningSection(settings: settings),
        OpenItemsSection(mode: settings.openItems),
      ],
    );
  }
}

/// Settings › Friends: rhythms, then incoming messages.
class FriendsPage extends ConsumerWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.settings;
    return _CategoryPage(
      title: context.l10n.settingsCatFriends,
      sections: [
        RhythmsSection(settings: settings),
        IncomingSection(settings: settings),
      ],
    );
  }
}

/// Settings › Birthdays: the user's own birthday.
class BirthdaysPage extends ConsumerWidget {
  const BirthdaysPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _CategoryPage(
      title: context.l10n.settingsCatBirthdays,
      sections: [OwnBirthdayRow(birthday: ref.settings.ownBirthday)],
    );
  }
}

/// Settings › Stamps and streak.
class StampsPage extends ConsumerWidget {
  const StampsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.settings;
    return _CategoryPage(
      title: context.l10n.settingsCatStamps,
      sections: [
        StampsSection(weights: settings.stampWeights),
        StreakSection(mode: settings.streakMode),
      ],
    );
  }
}

/// Settings › Look: the theme choice.
class LookPage extends StatelessWidget {
  const LookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _CategoryPage(
      title: context.l10n.settingsCatLook,
      sections: const [LookSection()],
    );
  }
}

/// Settings › Updates. Not part of a Play build (update_controller.dart).
class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _CategoryPage(
      title: context.l10n.updateSection,
      sections: const [UpdateSection()],
    );
  }
}

/// Settings › Development, debug builds only.
class DevelopmentPage extends ConsumerWidget {
  const DevelopmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _CategoryPage(
      title: 'Development',
      sections: [DevelopmentSection(demoMode: ref.settings.demoMode)],
    );
  }
}

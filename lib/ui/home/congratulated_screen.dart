import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/birthdays.dart';
import '../../domain/contact_event.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../widgets/kept_card.dart';
import '../widgets/kept_switch.dart';

/// Opens "Who congratulated you?" for the user's own birthday.
void openCongratulated(BuildContext context, Birthday birthday) => unawaited(
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => CongratulatedScreen(birthday)),
  ),
);

/// "Who congratulated you?" (02-design.md §6.8 and §8, birthdays): all
/// people with a switch each, for the user's most recent birthday (today on
/// the day). On stores a birthday wish from that person (source manual)
/// dated that day; off deletes it again. Nobody is listed as missing and
/// nothing is counted.
class CongratulatedScreen extends ConsumerWidget {
  const CongratulatedScreen(this.birthday, {super.key});

  final Birthday birthday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final now = ref.watch(clockProvider)();
    final day = lastBirthday(birthday.month, birthday.day, now);
    final isToday =
        day.year == now.year && day.month == now.month && day.day == now.day;
    final people = ref.watch(peopleProvider).value ?? const <Person>[];
    final wishes = ref.watch(
      birthdayWishesProvider((ContactDirection.byThem, day)),
    );
    final from = {for (final e in wishes.value ?? const []) e.personId};
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Row(
            spacing: 14,
            children: [
              const KeptIcon(KeptIcons.cake, size: 44),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.congratulatedTitle,
                      style: context.text.headlineLarge,
                    ),
                    Text(
                      isToday
                          ? l10n.congratulatedToday
                          : l10n.congratulatedOn(day),
                      style: context.text.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (people.isEmpty)
            Text(l10n.captureNoPeople, style: context.text.bodyMedium)
          else
            KeptCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  for (final p in people)
                    _Row(
                      person: p,
                      on: from.contains(p.id),
                      enabled: wishes.hasValue,
                      onChanged: (on) => unawaited(
                        ref
                            .read(contactEventsRepositoryProvider)
                            .setWishFrom(
                              p.id,
                              day,
                              on: on,
                              // On the day: now. Later: midday of that day.
                              at: isToday
                                  ? now
                                  : DateTime(day.year, day.month, day.day, 12),
                            ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.person,
    required this.on,
    required this.enabled,
    required this.onChanged,
  });

  final Person person;
  final bool on;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => onChanged(!on) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          spacing: 12,
          children: [
            Avatar.person(person, size: 44),
            Expanded(
              child: Text(
                person.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelLarge?.copyWith(
                  color: context.kept.text,
                ),
              ),
            ),
            KeptSwitch(value: on, onChanged: enabled ? onChanged : (_) {}),
          ],
        ),
      ),
    );
  }
}

/// On the user's own birthday, on Home: "Who congratulated you?" with the
/// cake. Opens [CongratulatedScreen]. Not shown on other days or when the
/// birthday is not set.
class OwnBirthdayCard extends ConsumerWidget {
  const OwnBirthdayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final birthday = ref.settings.ownBirthday;
    final now = ref.watch(clockProvider)();
    if (birthday == null || !isBirthdayOn(birthday.month, birthday.day, now)) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: KeptCard(
        tone: context.kept.sunTone,
        onTap: () => openCongratulated(context, birthday),
        child: Row(
          spacing: 14,
          children: [
            const KeptIcon(KeptIcons.cake, size: 40),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    l10n.congratulatedTitle,
                    style: context.text.titleLarge?.copyWith(
                      color: context.kept.sunTone.onContainer,
                    ),
                  ),
                  Text(
                    l10n.ownBirthdayCardHint,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.kept.sunTone.onContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/group.dart';
import '../../domain/person.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../widgets/couple_avatar.dart';
import '../widgets/grey_button.dart';
import '../widgets/grey_icon_button.dart';
import '../widgets/main_button.dart';
import '../widgets/section_label.dart';
import 'couple_screen.dart';
import 'edit_person_screen.dart';
import 'import_contacts_screen.dart';
import 'person_screen.dart';
import 'pictures_card.dart';
import 'reconnect_card.dart';

/// Everyone, grouped by class in the order of [Closeness]. Groups with
/// nobody are left out. See concept V6 · People (docs/concepts/gen_v6.py).
class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(peopleProvider);
    final title = Row(
      children: [
        Expanded(
          child: Text(
            context.l10n.peopleTitle,
            style: context.text.headlineLarge,
          ),
        ),
        GreyIconButton(
          icon: Icons.add_rounded,
          tooltip: context.l10n.addPersonTitle,
          onPressed: () => _openAddMenu(context),
        ),
      ],
    );
    final Widget body = switch (people) {
      AsyncValue(value: final list?) when list.isEmpty => Column(
        spacing: 16,
        children: [
          _Hint(context.l10n.peopleEmpty),
          MainButton(
            label: context.l10n.addFromContacts,
            onPressed: () => openImportContacts(context),
          ),
          GreyButton(
            label: context.l10n.addByHand,
            onPressed: () => openEditPerson(context),
          ),
        ],
      ),
      AsyncValue(value: final list?) => _Groups(list),
      AsyncValue(hasError: true) => _Hint(context.l10n.peopleError),
      _ => const SizedBox.shrink(),
    };
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
      children: [
        title,
        const SizedBox(height: 14),
        if (people.value case final list? when list.isNotEmpty) ...[
          PicturesCard(list),
          ReconnectCard(list),
        ],
        body,
      ],
    );
  }
}

/// The classes with their people. A linked couple is one entry, in the
/// class of the closer member ([closestClass]); inside a class everything
/// is sorted by name, a couple by its first member's.
class _Groups extends ConsumerWidget {
  const _Groups(this.people);

  final List<Person> people;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couples = ref.watch(couplesProvider).value ?? const [];
    final coupled = {
      for (final c in couples)
        for (final p in c.members) p.id,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 14,
      children: [
        for (final closeness in Closeness.values)
          ...() {
            final items = <(String, Widget)>[
              for (final p in people)
                if (p.closeness == closeness && !coupled.contains(p.id))
                  (p.name.toLowerCase(), _PersonBlob(p)),
              for (final c in couples)
                if (closestClass(c.members) == closeness)
                  (c.members.first.name.toLowerCase(), _CoupleBlob(c)),
            ]..sort((a, b) => a.$1.compareTo(b.$1));
            return [
              if (items.isNotEmpty)
                _Group(closeness, [for (final i in items) i.$2]),
            ];
          }(),
      ],
    );
  }
}

/// The "+" menu: contacts or by hand.
void _openAddMenu(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.contacts_rounded),
            title: Text(context.l10n.addMenuContacts),
            onTap: () {
              Navigator.of(sheet).pop();
              openImportContacts(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: Text(context.l10n.addMenuByHand),
            onTap: () {
              Navigator.of(sheet).pop();
              openEditPerson(context);
            },
          ),
        ],
      ),
    ),
  );
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24),
    child: Text(
      text,
      style: context.text.bodyMedium,
      textAlign: TextAlign.center,
    ),
  );
}

/// One class: its label and its people, wrapping onto more lines.
class _Group extends StatelessWidget {
  const _Group(this.closeness, this.items);

  final Closeness closeness;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 10,
    children: [
      Row(
        spacing: 8,
        children: [
          KeptIcon(closenessIcon(closeness), size: 22),
          SectionLabel(closenessGroupLabel(closeness, context.l10n)),
        ],
      ),
      Wrap(spacing: 16, runSpacing: 16, children: items),
    ],
  );
}

/// Avatar over the short name; opens the person page.
class _PersonBlob extends ConsumerWidget {
  const _PersonBlob(this.person);

  final Person person;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstName = ref.shortName(person);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => PersonScreen(id: person.id)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 54, maxWidth: 76),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Avatar.person(person, size: 54),
            Text(
              firstName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.kept.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Both faces over "Anna & Tom"; opens the couple page.
class _CoupleBlob extends ConsumerWidget {
  const _CoupleBlob(this.couple);

  final GroupWithMembers couple;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CoupleScreen(id: couple.group.id),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 54, maxWidth: 104),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            CoupleAvatar(couple.members, size: 54),
            Text(
              couple.label(ref.watch(displayNamesProvider)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.kept.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

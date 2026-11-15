import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/database.dart';
import '../../domain/person.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/avatar.dart';
import '../widgets/section_label.dart';
import 'person_screen.dart';

/// Everyone, grouped by class in the order of [Closeness]. Groups with
/// nobody are left out. See concept V6 · People (docs/concepts/gen_v6.py).
class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(peopleProvider);
    final title = Text(
      context.l10n.peopleTitle,
      style: context.text.headlineLarge,
    );
    final Widget body = switch (people) {
      AsyncValue(value: final list?) when list.isEmpty => _Hint(
        context.l10n.peopleEmpty,
      ),
      AsyncValue(value: final list?) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          for (final closeness in Closeness.values)
            if (list.any((p) => p.closeness == closeness))
              _Group(
                closeness,
                list.where((p) => p.closeness == closeness).toList(),
              ),
        ],
      ),
      AsyncValue(hasError: true) => _Hint(context.l10n.peopleError),
      _ => const SizedBox.shrink(),
    };
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
      children: [title, const SizedBox(height: 14), body],
    );
  }
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
  const _Group(this.closeness, this.people);

  final Closeness closeness;
  final List<Person> people;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 10,
    children: [
      SectionLabel(closenessGroupLabel(closeness, context.l10n)),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [for (final p in people) _PersonBlob(p)],
      ),
    ],
  );
}

/// Avatar over first name; opens the person page.
class _PersonBlob extends StatelessWidget {
  const _PersonBlob(this.person);

  final Person person;

  @override
  Widget build(BuildContext context) {
    final firstName = person.name.trim().split(RegExp(r'\s+')).first;
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
            // Throwaway badge preview, see [badgePreview].
            ValueListenableBuilder(
              valueListenable: badgePreview,
              builder: (context, badge, _) =>
                  Avatar.person(person, size: 54, badge: badge),
            ),
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

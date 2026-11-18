import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/contact_photos.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/people_repository.dart';
import '../../domain/person.dart';
import '../../domain/phone_number.dart';
import '../../l10n/labels.dart';
import '../../platform/contacts.dart';
import '../../platform/installed_apps.dart';
import '../../platform/photo_store.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/choice_chips.dart';
import '../widgets/section_label.dart';

/// The class step of the import and of the first-start flow: a legend of the
/// four class icons, the choice of one messenger for all, and a list of
/// names with the four icons as a single choice each. One implementation for
/// both screens. The parent keeps the state.
class ClassAssignment extends ConsumerWidget {
  const ClassAssignment({
    super.key,
    required this.contacts,
    required this.closeness,
    required this.messenger,
    required this.onCloseness,
    required this.onMessenger,
  });

  final List<PhoneContact> contacts;
  final Map<String, Closeness> closeness;
  final ChatApp? messenger;
  final void Function(String contactId, Closeness value) onCloseness;
  final ValueChanged<ChatApp?> onMessenger;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final installed =
        ref.watch(installedChatAppsProvider).value ?? InstalledChatApps.all;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ClassLegend(),
        const SizedBox(height: 16),
        SectionLabel(l10n.importMessengerAll),
        const SizedBox(height: 8),
        ChoiceChips<ChatApp?>(
          options: [
            ChipOption(null, l10n.messengerNone),
            for (final m in installed.choices(messenger))
              ChipOption(m, messengerLabel(m, l10n)),
          ],
          value: messenger,
          onChanged: onMessenger,
        ),
        const SizedBox(height: 12),
        for (final c in contacts)
          ClassRow(
            c.name,
            value: closeness[c.id] ?? Closeness.nowAndThen,
            onChanged: (v) => onCloseness(c.id, v),
          ),
      ],
    );
  }
}

/// Adds [contacts] as people, one after the other so each sees the avatars
/// before. Shared by the import and the first-start flow. With [source] and
/// [photos], each contact's picture is read one by one and stored with the
/// centre crop; only the chosen contacts are asked for it.
Future<void> addContactsAsPeople(
  PeopleRepository repo,
  List<PhoneContact> contacts,
  Map<String, Closeness> closeness,
  ChatApp? messenger, {
  ContactsSource? source,
  PhotoStore? photos,
}) async {
  for (final c in contacts) {
    final photo = source == null || photos == null
        ? null
        : await storeContactPhoto(source, photos, c.id);
    await repo.add(
      photo: photo,
      name: c.name,
      contactId: c.id,
      closeness: closeness[c.id] ?? Closeness.nowAndThen,
      chatApp: messenger,
      phone: c.phones.isEmpty ? null : normalisePhone(c.phones.first),
      birthdayMonth: c.birthdayMonth,
      birthdayDay: c.birthdayDay,
      birthdayYear: c.birthdayYear,
    );
  }
}

/// The four class icons with their names, in a tonal card at the top.
class ClassLegend extends StatelessWidget {
  const ClassLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kept.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: kept.shadow, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(l10n.classLegendHint, style: context.text.bodyMedium),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              for (final c in Closeness.values)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    KeptIcon(closenessIcon(c), size: 24),
                    Flexible(
                      child: Text(
                        closenessLabel(c, l10n),
                        style: context.text.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A name and the four class icons as a single choice.
class ClassRow extends StatelessWidget {
  const ClassRow(
    this.name, {
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String name;
  final Closeness value;
  final ValueChanged<Closeness> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      spacing: 8,
      children: [
        Expanded(
          child: Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        for (final c in Closeness.values)
          Tooltip(
            message: closenessLabel(c, context.l10n),
            child: Semantics(
              selected: c == value,
              button: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => onChanged(c),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: c == value ? KeptColors.sun : Colors.transparent,
                  ),
                  child: KeptIcon(closenessIcon(c), size: 26),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

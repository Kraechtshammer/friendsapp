import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_settings.dart';
import '../data/database.dart';
import '../data/people_repository.dart';
import '../platform/chat_opener.dart';
import '../platform/contacts.dart';
import 'services.dart';

/// Set in main() with the services created at start.
final servicesProvider = Provider<AppServices>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);

/// The phone's contacts. Tests override it with a fake.
final contactsSourceProvider = Provider<ContactsSource>(
  (ref) => const DeviceContacts(),
);

/// Opens chats in the messenger apps. Tests override it with a fake.
final chatOpenerProvider = Provider<ChatOpener>(
  (ref) => const AndroidChatOpener(),
);

/// All settings, from the real database.
final settingsProvider = StreamProvider<AppSettings>(
  (ref) => ref.watch(servicesProvider).settings.watch(),
);

/// Where people are written: the demo or the real database, following
/// `demoMode`. Screens write through it once the settings are loaded.
final peopleRepositoryProvider = Provider<PeopleRepository>((ref) {
  final demo = ref.watch(
    settingsProvider.select((s) => s.value?.demoMode ?? false),
  );
  return ref.watch(servicesProvider).peopleFor(demo: demo);
});

/// Everyone, ordered by name. Waits for the settings, so demo mode never
/// shows the real people for a moment.
final peopleProvider = StreamProvider<List<Person>>((ref) async* {
  final demo = ref.watch(settingsProvider.selectAsync((s) => s.demoMode));
  final services = ref.watch(servicesProvider);
  yield* services.peopleFor(demo: await demo).watchAll();
});

/// One person; null once deleted.
final personProvider = StreamProvider.family<Person?, String>((ref, id) async* {
  final demo = ref.watch(settingsProvider.selectAsync((s) => s.demoMode));
  final services = ref.watch(servicesProvider);
  yield* services.peopleFor(demo: await demo).watch(id);
});

extension SettingsOrDefault on WidgetRef {
  /// The settings, or the defaults while loading or if the database fails,
  /// so the app still opens.
  AppSettings get settings =>
      watch(settingsProvider).value ?? const AppSettings();
  AppServices get services => read(servicesProvider);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_settings.dart';
import '../data/database.dart';
import '../data/intentions_repository.dart';
import '../data/people_repository.dart';
import '../platform/app_shortcuts.dart';
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

/// The launcher icon's shortcuts. Tests override it with a fake.
final appShortcutsProvider = Provider<AppShortcuts>(
  (ref) => const QuickActionsShortcuts(),
);

/// The current time, for the greeting. Tests override it with a fixed time.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Counts requests to focus the capture field (the launcher shortcut). The
/// capture card listens and takes the focus when the number changes.
class CaptureFocusRequests extends Notifier<int> {
  @override
  int build() => 0;

  void request() => state++;
}

final captureFocusProvider = NotifierProvider<CaptureFocusRequests, int>(
  CaptureFocusRequests.new,
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

/// Where intentions are written: the demo or the real database, following
/// `demoMode`, like [peopleRepositoryProvider].
final intentionsRepositoryProvider = Provider<IntentionsRepository>((ref) {
  final demo = ref.watch(
    settingsProvider.select((s) => s.value?.demoMode ?? false),
  );
  return ref.watch(servicesProvider).intentionsFor(demo: demo);
});

/// The open intentions of everyone, newest first. Waits for the settings,
/// like [peopleProvider].
final openIntentionsProvider = StreamProvider<List<Intention>>((ref) async* {
  final demo = ref.watch(settingsProvider.selectAsync((s) => s.demoMode));
  final services = ref.watch(servicesProvider);
  yield* services.intentionsFor(demo: await demo).watchOpen();
});

/// All intentions of one person, in every state, newest first.
final personIntentionsProvider = StreamProvider.family<List<Intention>, String>(
  (ref, personId) async* {
    final demo = ref.watch(settingsProvider.selectAsync((s) => s.demoMode));
    final services = ref.watch(servicesProvider);
    yield* services.intentionsFor(demo: await demo).watchForPerson(personId);
  },
);

extension SettingsOrDefault on WidgetRef {
  /// The settings, or the defaults while loading or if the database fails,
  /// so the app still opens.
  AppSettings get settings =>
      watch(settingsProvider).value ?? const AppSettings();
  AppServices get services => read(servicesProvider);
}

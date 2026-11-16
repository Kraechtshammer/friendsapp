import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_settings.dart';
import '../data/contact_events_repository.dart';
import '../data/database.dart';
import '../data/day_answers_repository.dart';
import '../data/ideas_repository.dart';
import '../data/intentions_repository.dart';
import '../data/people_repository.dart';
import '../data/treats_repository.dart';
import '../domain/chat_question.dart';
import '../domain/contact_event.dart';
import '../platform/app_shortcuts.dart';
import '../platform/chat_opener.dart';
import '../platform/contacts.dart';
import '../platform/incoming_listener.dart';
import '../platform/link_opener.dart';
import '../platform/notifications.dart';
import '../platform/share_receiver.dart';
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

/// Opens links in the browser. Tests override it with a fake.
final linkOpenerProvider = Provider<LinkOpener>(
  (ref) => const AndroidLinkOpener(),
);

/// Shares from other apps (M10). Tests override it with a fake.
final shareReceiverProvider = Provider<ShareReceiver>(
  (ref) => const AndroidShareReceiver(),
);

/// The launcher icon's shortcuts. Tests override it with a fake.
final appShortcutsProvider = Provider<AppShortcuts>(
  (ref) => const QuickActionsShortcuts(),
);

/// The app's notifications (the evening question). Tests override it with
/// a fake.
final notificationsProvider = Provider<Notifications>(
  (ref) => LocalNotifications(),
);

/// The optional notification listener for incoming contact (M7). Tests
/// override it with a fake. See incoming_listener.dart for removing it.
final incomingListenerProvider = Provider<IncomingListener>(
  (ref) => const AndroidIncomingListener(),
);

/// Whether the user has granted notification access to the listener. Read
/// again when Settings comes back to the front.
final incomingAccessProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(incomingListenerProvider).hasAccess(),
);

/// Whether the app may show notifications. Read again when the app comes
/// back to the front and after asking for the permission.
final notificationsEnabledProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(notificationsProvider).areEnabled(),
);

/// Counts requests to scroll Home to the open thoughts ("Yes" on the
/// evening question). The open thoughts listen, like [captureFocusProvider].
class OpenThoughtsRequests extends Notifier<int> {
  @override
  int build() => 0;

  void request() => state++;
}

final openThoughtsRequestProvider = NotifierProvider<OpenThoughtsRequests, int>(
  OpenThoughtsRequests.new,
);

/// The "Did you write?" question after an "Open chat" tap. Set when the
/// chat is opened; HomeShell asks it when the app is back in front and
/// clears it, so it is asked once. Kept in memory on purpose: if the app is
/// killed in between, nothing is asked. Tests set it directly.
class PendingChatQuestion extends Notifier<ChatQuestion?> {
  @override
  ChatQuestion? build() => null;

  void set(ChatQuestion question) => state = question;

  /// Returns the question and forgets it.
  ChatQuestion? take() {
    final question = state;
    state = null;
    return question;
  }
}

final pendingChatQuestionProvider =
    NotifierProvider<PendingChatQuestion, ChatQuestion?>(
      PendingChatQuestion.new,
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

/// Where contact events are written: the demo or the real database,
/// following `demoMode`, like [peopleRepositoryProvider].
final contactEventsRepositoryProvider = Provider<ContactEventsRepository>((
  ref,
) {
  final demo = ref.watch(
    settingsProvider.select((s) => s.value?.demoMode ?? false),
  );
  return ref.watch(servicesProvider).contactEventsFor(demo: demo);
});

/// All contact events of one person, newest first.
final personContactEventsProvider =
    StreamProvider.family<List<ContactEvent>, String>((ref, personId) async* {
      final demo = ref.watch(settingsProvider.selectAsync((s) => s.demoMode));
      final services = ref.watch(servicesProvider);
      yield* services
          .contactEventsFor(demo: await demo)
          .watchForPerson(personId);
    });

/// All contact events of everyone, newest first, from the content database
/// (demo or real). For the owed replies.
final allContactEventsProvider = StreamProvider<List<ContactEvent>>((
  ref,
) async* {
  final demo = ref.watch(settingsProvider.selectAsync((s) => s.demoMode));
  final services = ref.watch(servicesProvider);
  yield* services.contactEventsFor(demo: await demo).watchAll();
});

/// The person's newest non-empty contact note; null if there is none.
final personLatestNoteProvider = StreamProvider.family<String?, String>((
  ref,
  personId,
) async* {
  final demo = ref.watch(settingsProvider.selectAsync((s) => s.demoMode));
  final services = ref.watch(servicesProvider);
  yield* services.contactEventsFor(demo: await demo).watchLatestNote(personId);
});

/// The birthday wishes in one direction on one local day (midnight), of
/// everyone, from the content database (demo or real, like
/// [personContactEventsProvider]).
final birthdayWishesProvider =
    StreamProvider.family<List<ContactEvent>, (ContactDirection, DateTime)>((
      ref,
      key,
    ) async* {
      final demo = ref.watch(settingsProvider.selectAsync((s) => s.demoMode));
      final services = ref.watch(servicesProvider);
      yield* services
          .contactEventsFor(demo: await demo)
          .watchBirthdayWishes(key.$1, key.$2);
    });

/// The real people, also in demo mode. The birthday notifications are
/// planned from them only: their "Yes" writes to the real database
/// (02-design.md §8, demo data).
final realPeopleProvider = StreamProvider<List<Person>>(
  (ref) => ref.watch(servicesProvider).peopleFor(demo: false).watchAll(),
);

/// The user's birthday wishes on one local day (midnight) in the real
/// database, also in demo mode; see [realPeopleProvider].
final realWishesByUserProvider =
    StreamProvider.family<List<ContactEvent>, DateTime>(
      (ref, day) => ref
          .watch(servicesProvider)
          .contactEventsFor(demo: false)
          .watchBirthdayWishes(ContactDirection.byUser, day),
    );

/// Where day answers are written: the demo or the real database, following
/// `demoMode`, like [peopleRepositoryProvider].
final dayAnswersRepositoryProvider = Provider<DayAnswersRepository>((ref) {
  final demo = ref.watch(
    settingsProvider.select((s) => s.value?.demoMode ?? false),
  );
  return ref.watch(servicesProvider).dayAnswersFor(demo: demo);
});

/// All day answers, from the content database (demo or real). For "Your
/// numbers" on the Progress tab.
final dayAnswersProvider = StreamProvider<List<DayAnswer>>((ref) async* {
  final demo = ref.watch(settingsProvider.selectAsync((s) => s.demoMode));
  final services = ref.watch(servicesProvider);
  yield* services.dayAnswersFor(demo: await demo).watchAll();
});

/// Where treats are changed: the demo or the real database, following
/// `demoMode`, like [peopleRepositoryProvider].
final treatsRepositoryProvider = Provider<TreatsRepository>((ref) {
  final demo = ref.watch(
    settingsProvider.select((s) => s.value?.demoMode ?? false),
  );
  return ref.watch(servicesProvider).treatsFor(demo: demo);
});

/// All treats, in queue order, from the content database.
final treatsProvider = StreamProvider<List<Treat>>((ref) async* {
  final demo = ref.watch(settingsProvider.selectAsync((s) => s.demoMode));
  final services = ref.watch(servicesProvider);
  yield* services.treatsFor(demo: await demo).watchAll();
});

/// All stamps, oldest first, from the content database. Their values add
/// up to the count that only grows.
final stampsProvider = StreamProvider<List<Stamp>>((ref) async* {
  final demo = ref.watch(settingsProvider.selectAsync((s) => s.demoMode));
  final services = ref.watch(servicesProvider);
  yield* services.treatsFor(demo: await demo).watchStamps();
});

/// The stamps one contact event earned, for the Nice one screen.
final eventStampsProvider = StreamProvider.family<List<Stamp>, String>((
  ref,
  eventId,
) async* {
  final demo = ref.watch(settingsProvider.selectAsync((s) => s.demoMode));
  final services = ref.watch(servicesProvider);
  yield* services.treatsFor(demo: await demo).watchForEvent(eventId);
});

/// Where ideas are written: the demo or the real database, following
/// `demoMode`, like [peopleRepositoryProvider].
final ideasRepositoryProvider = Provider<IdeasRepository>((ref) {
  final demo = ref.watch(
    settingsProvider.select((s) => s.value?.demoMode ?? false),
  );
  return ref.watch(servicesProvider).ideasFor(demo: demo);
});

/// All ideas of one person, open and done, newest first.
final personIdeasProvider = StreamProvider.family<List<Idea>, String>((
  ref,
  personId,
) async* {
  final demo = ref.watch(settingsProvider.selectAsync((s) => s.demoMode));
  final services = ref.watch(servicesProvider);
  yield* services.ideasFor(demo: await demo).watchForPerson(personId);
});

extension SettingsOrDefault on WidgetRef {
  /// The settings, or the defaults while loading or if the database fails,
  /// so the app still opens.
  AppSettings get settings =>
      watch(settingsProvider).value ?? const AppSettings();
  AppServices get services => read(servicesProvider);
}

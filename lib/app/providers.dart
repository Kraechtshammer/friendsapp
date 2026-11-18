import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_settings.dart';
import '../data/contact_events_repository.dart';
import '../data/database.dart';
import '../data/day_answers_repository.dart';
import '../data/groups_repository.dart';
import '../data/ideas_repository.dart';
import '../data/intentions_repository.dart';
import '../data/people_repository.dart';
import '../data/treats_repository.dart';
import '../domain/chat_question.dart';
import '../domain/contact_event.dart';
import '../domain/display_name.dart';
import '../domain/group.dart';
import '../platform/app_shortcuts.dart';
import '../platform/chat_opener.dart';
import '../platform/contact_entries.dart';
import '../platform/contacts.dart';
import '../platform/incoming_listener.dart';
import '../platform/link_opener.dart';
import '../platform/notifications.dart';
import '../platform/photo_store.dart';
import '../platform/share_receiver.dart';
import 'build_flags.dart';
import 'services.dart';

/// Set in main() with the services created at start.
final servicesProvider = Provider<AppServices>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);

/// Whether HomeShell may show the first-start flow. Tests that are about
/// something else switch it off.
final firstStartEnabledProvider = Provider<bool>((ref) => true);

/// The phone's contacts. Tests override it with a fake.
final contactsSourceProvider = Provider<ContactsSource>(
  (ref) => const DeviceContacts(),
);

/// Whether the contacts permission is granted. Read again when the app
/// comes back to the front.
final contactsAccessProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.watch(contactsSourceProvider).hasAccess(),
);

/// Opens chats in the messenger apps. Tests override it with a fake.
final chatOpenerProvider = Provider<ChatOpener>(
  (ref) => const AndroidChatOpener(),
);

/// The ways to reach a person that their phone contact holds. Tests
/// override it with a fake.
final contactEntriesProvider = Provider<ContactEntries>(
  (ref) => const AndroidContactEntries(),
);

/// Opens links in the browser. Tests override it with a fake.
final linkOpenerProvider = Provider<LinkOpener>(
  (ref) => const AndroidLinkOpener(),
);

/// Shares from other apps. Tests override it with a fake.
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

/// People's pictures (platform/photo_store.dart). Tests override it with
/// a fake.
final photoStoreProvider = Provider<PhotoStore>(
  (ref) => const FilePhotoStore(),
);

/// The bytes of a stored picture, by file name; null if the file is gone.
/// Kept for the whole run: a name never changes its content (a new picture
/// gets a new name), 54 small JPEGs are about 2 MB, and a list that scrolls
/// shows the avatars at once.
final photoBytesProvider = FutureProvider.family<Uint8List?, String>(
  (ref, name) => ref.watch(photoStoreProvider).read(name),
);

/// Whether the optional notification listener is built in (the build flag
/// [keptIncoming]). False: the UI shows nothing about it; "They wrote" by
/// hand stays. Tests that are about the listener switch it on.
final incomingBuiltInProvider = Provider<bool>((ref) => keptIncoming);

/// The optional notification listener for incoming contact. Tests
/// override it with a fake. Without the build flag a no-op, and the
/// compiler drops [AndroidIncomingListener] and its channel.
final incomingListenerProvider = Provider<IncomingListener>(
  (ref) => keptIncoming
      ? const AndroidIncomingListener()
      : const NoIncomingListener(),
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

/// Short display names of everyone in [peopleProvider]: person id -> name
/// (domain/display_name.dart). Empty until the people are loaded.
final displayNamesProvider = Provider<Map<String, String>>((ref) {
  final people = ref.watch(peopleProvider).value;
  return people == null ? const {} : displayNamesOf(people);
});

/// One person; null once deleted.
final personProvider = StreamProvider.family<Person?, String>((ref, id) async* {
  final demo = ref.watch(settingsProvider.selectAsync((s) => s.demoMode));
  final services = ref.watch(servicesProvider);
  yield* services.peopleFor(demo: await demo).watch(id);
});

/// Where groups (couples) are written: the demo or the real database,
/// following `demoMode`, like [peopleRepositoryProvider].
final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  final demo = ref.watch(
    settingsProvider.select((s) => s.value?.demoMode ?? false),
  );
  return ref.watch(servicesProvider).groupsFor(demo: demo);
});

/// All couples with their members, oldest first. Waits for the settings,
/// like [peopleProvider].
final couplesProvider = StreamProvider<List<GroupWithMembers>>((ref) async* {
  final demo = ref.watch(settingsProvider.selectAsync((s) => s.demoMode));
  final services = ref.watch(servicesProvider);
  yield* services.groupsFor(demo: await demo).watchCouples();
});

/// The couple a person is in; null if none.
final personCoupleProvider = StreamProvider.family<GroupWithMembers?, String>((
  ref,
  personId,
) async* {
  final demo = ref.watch(settingsProvider.selectAsync((s) => s.demoMode));
  final services = ref.watch(servicesProvider);
  yield* services.groupsFor(demo: await demo).watchCoupleOf(personId);
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

/// The couples by group id. Empty until they are loaded.
final couplesByIdProvider = Provider<Map<String, GroupWithMembers>>((ref) {
  final couples = ref.watch(couplesProvider).value ?? const [];
  return {for (final c in couples) c.group.id: c};
});

/// Who a thought is for (a person or a couple); null when not known.
/// The lists that show thoughts call it for each row.
final thoughtSubjectProvider = Provider<ThoughtSubject? Function(Intention)>((
  ref,
) {
  final byId = {
    for (final p in ref.watch(peopleProvider).value ?? const <Person>[])
      p.id: p,
  };
  final couples = ref.watch(couplesByIdProvider);
  return (i) => subjectOf(i, byId, couples);
});

/// A person's own thoughts in every state plus the open thoughts of the
/// couple they are in (shown on both members' pages), newest first.
final personThoughtsProvider = Provider.family<List<Intention>, String>((
  ref,
  personId,
) {
  final own = ref.watch(personIntentionsProvider(personId)).value ?? const [];
  final groupId = ref.watch(personCoupleProvider(personId)).value?.group.id;
  if (groupId == null) return own;
  final shared = [
    for (final i in ref.watch(openIntentionsProvider).value ?? const [])
      if (i.groupId == groupId) i,
  ];
  return [...own, ...shared]..sort((a, b) {
    final c = b.createdAt.compareTo(a.createdAt);
    return c != 0 ? c : b.id.compareTo(a.id);
  });
});

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

/// All contact events of everyone in the real database, newest first, also
/// in demo mode; see [realPeopleProvider]. The evening question's reasons
/// are predicted from them.
final realContactEventsProvider = StreamProvider<List<ContactEvent>>(
  (ref) => ref.watch(servicesProvider).contactEventsFor(demo: false).watchAll(),
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

extension ShortNames on WidgetRef {
  /// The short name of [person] (nickname, first name, "Max M" ...), and
  /// rebuilds the widget when it changes.
  String shortName(Person person) =>
      watch(displayNamesProvider.select((m) => m[person.id])) ??
      shortNameIn(const {}, person);

  /// Like [shortName], for event handlers: read once, no rebuild.
  String readShortName(Person person) =>
      shortNameIn(read(displayNamesProvider), person);
}

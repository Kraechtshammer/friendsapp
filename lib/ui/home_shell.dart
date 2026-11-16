import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../data/app_settings.dart';
import '../data/database.dart';
import '../domain/birthday_notifications.dart';
import '../domain/birthdays.dart';
import '../domain/contact_event.dart';
import '../domain/evening_question.dart';
import '../platform/notifications.dart';
import 'common.dart';
import 'home/chat_question_screen.dart';
import 'home/home_screen.dart';
import 'home/open_chat.dart';
import 'kept_icon.dart';
import 'material.dart';
import 'people/people_screen.dart';
import 'progress/progress_screen.dart';
import 'upcoming/upcoming_screen.dart';

/// The four tabs: Home, Upcoming, People, Progress. Settings open from the
/// gear on Home.
///
/// It also keeps the evening question (02-design.md §2.2) scheduled: at
/// every start, after every change of its settings and when the language
/// changes. And it handles "Yes" on it.
///
/// The same goes for the birthday notifications (02-design.md §8, birthdays
/// M4): planned again at every start, when the real people, the evening
/// settings, the language or today's wishes change, and when the app comes
/// back on a new day. "Open chat" and a tap open Home at the birthday
/// pick.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  var _tab = 0;
  String? _shortcutTitle;
  EveningPlan? _scheduled;
  BirthdayPlan? _birthdaysScheduled;
  var _permissionAsked = false;
  late final AppLifecycleListener _lifecycle;

  /// The day whose birthday wishes are watched, and the subscription.
  DateTime? _wishDay;
  ProviderSubscription<AsyncValue<List<ContactEvent>>>? _wishes;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
    unawaited(
      ref
          .read(notificationsProvider)
          .setUp(onAnswer: _onEveningAnswer, onBirthday: _onBirthday),
    );
    ref.listenManual(settingsProvider, (_, next) {
      if (next.value case final settings?) _onSettings(settings);
    });
    ref.listenManual(realPeopleProvider, (_, _) => _scheduleBirthdays());
    _watchWishes(schedule: false);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _wishes?.close();
    super.dispose();
  }

  DateTime _today() {
    final now = ref.read(clockProvider)();
    return DateTime(now.year, now.month, now.day);
  }

  /// Watches the user's birthday wishes of today in the real database, and
  /// plans the birthday notifications again when they change.
  void _watchWishes({bool schedule = true}) {
    final day = _today();
    if (day == _wishDay) return;
    _wishDay = day;
    _wishes?.close();
    _wishes = ref.listenManual(
      realWishesByUserProvider(day),
      (_, _) => _scheduleBirthdays(),
    );
    // Not from initState: the texts need the context.
    if (schedule) _scheduleBirthdays();
  }

  void _onResume() {
    _askPendingQuestion();
    _watchWishes();
  }

  /// Back from a messenger after "Open chat": ask "Did you write?" once
  /// (02-design.md §2.3).
  void _askPendingQuestion() {
    final question = ref.read(pendingChatQuestionProvider.notifier).take();
    if (question == null || !mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ChatQuestionScreen(question)),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The texts of the notification follow the language.
    if (ref.read(settingsProvider).value case final settings?) {
      _onSettings(settings);
    }
    // Register the launcher shortcut, again if the language changes.
    final title = context.l10n.shortcutCapture;
    if (title == _shortcutTitle) return;
    _shortcutTitle = title;
    ref
        .read(appShortcutsProvider)
        .setUp(captureTitle: title, onCapture: _openCapture);
  }

  /// The launcher shortcut: Home, with the capture field focused.
  void _openCapture() {
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => _tab = 0);
    ref.read(captureFocusProvider.notifier).request();
  }

  void _onSettings(AppSettings settings) {
    _scheduleEvening(settings);
    _scheduleBirthdays();
    unawaited(_askPermissionOnce(settings));
  }

  /// Plans the birthday notifications from the real people, once the
  /// settings, the people and today's wishes are loaded. Excluded weekdays
  /// do not matter; the evening question's switch does.
  void _scheduleBirthdays() {
    if (!mounted) return;
    final day = _wishDay;
    final settings = ref.read(settingsProvider).value;
    final people = ref.read(realPeopleProvider).value;
    final wishes = day == null
        ? null
        : ref.read(realWishesByUserProvider(day)).value;
    if (settings == null || people == null || wishes == null) return;
    final now = ref.read(clockProvider)();
    final l10n = context.l10n;
    final plan = BirthdayPlan(
      alarms: birthdayAlarms(
        people: people,
        congratulated: congratulatedIds(wishes, now),
        now: now,
        on: settings.eveningOn,
        minute: settings.eveningMinute,
      ),
      title: l10n.birthdayNotification,
      lateTitle: l10n.birthdayLateNotification,
      lateBody: l10n.birthdayLateNotificationBody,
      yes: l10n.birthdayYes,
      openChat: l10n.birthdayOpenChat,
      channelName: l10n.birthdayChannel,
    );
    if (plan == _birthdaysScheduled) return;
    _birthdaysScheduled = plan;
    unawaited(ref.read(notificationsProvider).scheduleBirthdays(plan));
  }

  /// A birthday notification that reached the app. "Yes" is stored as the
  /// background handler would (real database, once). "Open chat" and a tap
  /// open Home at the birthday pick; "Open chat" also opens the messenger
  /// and queues "Did you congratulate?".
  void _onBirthday(BirthdayResponse response) {
    final services = ref.read(servicesProvider);
    if (response.action == BirthdayAction.yes) {
      unawaited(
        recordBirthdayYes(
          services.contactEventsFor(demo: false),
          ref.read(notificationsProvider),
          response,
        ).then<void>(
          (_) {},
          onError: (Object e) => debugPrint('Birthday wish not stored: $e'),
        ),
      );
      return;
    }
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => _tab = 0);
    ref.read(openThoughtsRequestProvider.notifier).request();
    if (response.action == BirthdayAction.openChat) {
      unawaited(_openBirthdayChat(response.personId));
    }
  }

  Future<void> _openBirthdayChat(String personId) async {
    final services = ref.read(servicesProvider);
    final person = await services.peopleFor(demo: false).watch(personId).first;
    if (person == null || !mounted) return;
    await openChat(context, ref, person, birthday: true);
  }

  void _scheduleEvening(AppSettings settings) {
    final l10n = context.l10n;
    final plan = EveningPlan(
      weekdays: eveningWeekdays(
        on: settings.eveningOn,
        excluded: settings.eveningExcludedDays,
      ),
      minute: settings.eveningMinute,
      title: l10n.eveningQuestion,
      yes: l10n.eveningYes,
      notToday: l10n.eveningNotToday,
      channelName: l10n.eveningChannel,
    );
    if (plan == _scheduled) return;
    _scheduled = plan;
    unawaited(ref.read(notificationsProvider).scheduleEvening(plan));
  }

  /// Asks for the notification permission once, on the first start with
  /// the evening question on. Later only switching it on in Settings asks.
  Future<void> _askPermissionOnce(AppSettings settings) async {
    if (!settings.eveningOn || settings.notificationPermissionAsked) return;
    if (_permissionAsked) return;
    _permissionAsked = true;
    final services = ref.read(servicesProvider);
    final notifications = ref.read(notificationsProvider);
    try {
      await services.settings.update(
        (s) => s.copyWith(notificationPermissionAsked: true),
      );
      await notifications.requestPermission();
    } catch (e) {
      debugPrint('Notification permission not asked: $e');
    }
    if (mounted) ref.invalidate(notificationsEnabledProvider);
  }

  /// "Yes" or a tap on the evening question: store it and show the open
  /// thoughts. Answers from the notification always go to the real
  /// database, as the background "Not today" does.
  void _onEveningAnswer(DayAnswerValue answer) {
    final answers = ref.read(servicesProvider).dayAnswersFor(demo: false);
    unawaited(
      answers
          .setToday(answer)
          .then<void>(
            (_) {},
            onError: (Object e) => debugPrint('Evening answer not stored: $e'),
          ),
    );
    if (answer != DayAnswerValue.yes || !mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => _tab = 0);
    ref.read(openThoughtsRequestProvider.notifier).request();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _tab,
          children: [
            HomeScreen(
              onAddPeople: () => setState(() => _tab = 2),
              onShowUpcoming: () => setState(() => _tab = 1),
            ),
            const UpcomingScreen(),
            const PeopleScreen(),
            const ProgressScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (next) => setState(() => _tab = next),
        destinations: [
          NavigationDestination(
            icon: const KeptIcon(KeptIcons.home, size: 26),
            label: l10n.tabHome,
          ),
          NavigationDestination(
            icon: const KeptIcon(KeptIcons.calendar, size: 26),
            label: l10n.tabUpcoming,
          ),
          NavigationDestination(
            icon: const KeptIcon(KeptIcons.people, size: 26),
            label: l10n.tabPeople,
          ),
          NavigationDestination(
            icon: const KeptIcon(KeptIcons.stamp, size: 26),
            label: l10n.tabProgress,
          ),
        ],
      ),
    );
  }
}

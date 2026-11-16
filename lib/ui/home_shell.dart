import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../data/app_settings.dart';
import '../domain/contact_event.dart';
import '../domain/evening_question.dart';
import 'common.dart';
import 'home/chat_question_screen.dart';
import 'home/home_screen.dart';
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
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  var _tab = 0;
  String? _shortcutTitle;
  EveningPlan? _scheduled;
  var _permissionAsked = false;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _askPendingQuestion);
    unawaited(
      ref.read(notificationsProvider).setUp(onAnswer: _onEveningAnswer),
    );
    ref.listenManual(settingsProvider, (_, next) {
      if (next.value case final settings?) _onSettings(settings);
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
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
    unawaited(_askPermissionOnce(settings));
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
            HomeScreen(onAddPeople: () => setState(() => _tab = 2)),
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

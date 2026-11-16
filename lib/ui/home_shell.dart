import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import 'common.dart';
import 'home/home_screen.dart';
import 'kept_icon.dart';
import 'material.dart';
import 'people/people_screen.dart';
import 'progress/progress_screen.dart';
import 'upcoming/upcoming_screen.dart';

/// The four tabs: Home, Upcoming, People, Progress. Settings open from the
/// gear on Home.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  var _tab = 0;
  String? _shortcutTitle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

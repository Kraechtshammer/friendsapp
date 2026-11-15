import 'common.dart';
import 'home/home_screen.dart';
import 'kept_icon.dart';
import 'material.dart';
import 'people/people_screen.dart';
import 'progress/progress_screen.dart';
import 'upcoming/upcoming_screen.dart';

/// The four tabs: Home, Upcoming, People, Progress. Settings open from the
/// gear on Home.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _tab,
          children: const [
            HomeScreen(),
            UpcomingScreen(),
            PeopleScreen(),
            ProgressScreen(),
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

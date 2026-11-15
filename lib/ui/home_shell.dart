import 'common.dart';
import 'home/home_screen.dart';
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
      // Plain icons for now; the app's own colourful ones follow.
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (next) => setState(() => _tab = next),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_rounded),
            label: l10n.tabHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_rounded),
            label: l10n.tabUpcoming,
          ),
          NavigationDestination(
            icon: const Icon(Icons.group_rounded),
            label: l10n.tabPeople,
          ),
          NavigationDestination(
            icon: const Icon(Icons.star_rounded),
            label: l10n.tabProgress,
          ),
        ],
      ),
    );
  }
}

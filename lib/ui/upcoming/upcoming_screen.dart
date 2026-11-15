import '../common.dart';
import '../material.dart';

class UpcomingScreen extends StatelessWidget {
  const UpcomingScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      TabPage(title: context.l10n.tabUpcoming, child: const EmptyHint());
}

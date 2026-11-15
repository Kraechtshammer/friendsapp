import '../common.dart';
import '../material.dart';

class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      TabPage(title: context.l10n.tabPeople, child: const EmptyHint());
}

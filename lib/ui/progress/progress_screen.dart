import '../common.dart';
import '../material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      TabPage(title: context.l10n.tabProgress, child: const EmptyHint());
}

import '../app/theme.dart';
import '../l10n/app_localizations.dart';
import 'material.dart';

extension ContextHelpers on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// The app's own colours (`app/theme.dart`).
  KeptColors get kept => Theme.of(this).extension<KeptColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
}

/// The frame of a tab: the screen title, optional buttons beside it, and the
/// content below. Paddings from docs/style/ui-style.md §5.
class TabPage extends StatelessWidget {
  const TabPage({
    super.key,
    required this.title,
    this.actions = const [],
    required this.child,
  });

  final String title;
  final List<Widget> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: context.text.headlineLarge)),
              ...actions,
            ],
          ),
          const SizedBox(height: 14),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Stands in for a screen that is not built yet.
class EmptyHint extends StatelessWidget {
  const EmptyHint({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Text(context.l10n.nothingHereYet, style: context.text.bodyMedium),
  );
}

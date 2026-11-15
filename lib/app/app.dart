import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../ui/home_shell.dart';
import '../ui/material.dart';
import 'providers.dart';
import 'theme.dart';

class KeptApp extends ConsumerWidget {
  const KeptApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ref.watch(themeModeProvider),
      // Material 3 Expressive components take their colours and type from
      // the current Material theme.
      builder: (context, child) => M3ETheme(
        data: M3EThemeData.fromMaterial(Theme.of(context)),
        child: child!,
      ),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: const HomeShell(),
    );
  }
}

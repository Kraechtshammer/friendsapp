import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../common.dart';
import '../material.dart';

/// Development builds only (02-design.md §8, demo data). These texts are
/// hard-coded English on purpose: the user never sees them, so they are
/// not ARB keys.
class DevelopmentSection extends ConsumerWidget {
  const DevelopmentSection({super.key, required this.demoMode});

  final bool demoMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('DEVELOPMENT', style: context.text.labelMedium),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Demo data'),
          subtitle: const Text(
            'Shows invented people. Your own data is not touched.',
          ),
          value: demoMode,
          onChanged: (on) => unawaited(ref.services.setDemoMode(on)),
        ),
      ],
    );
  }
}

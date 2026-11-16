import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/ideas.dart';
import '../common.dart';
import '../material.dart';

/// Opens [link] in the browser; a short note if nothing could open it.
Future<void> openLink(BuildContext context, WidgetRef ref, String link) async {
  final messenger = ScaffoldMessenger.of(context);
  final failed = context.l10n.linkNotOpened;
  final opened = await ref.read(linkOpenerProvider).open(link);
  if (!opened) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(failed)));
  }
}

/// A small tappable row with a link (M10): the link symbol and the link
/// without its scheme, muted, one line. Opens it in the browser.
class LinkRow extends ConsumerWidget {
  const LinkRow(this.link, {super.key, this.color});

  final String link;

  /// Defaults to the muted text colour.
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = this.color ?? context.kept.muted;
    return Semantics(
      button: true,
      label: context.l10n.openLink,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => unawaited(openLink(context, ref, link)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 32),
          child: Row(
            spacing: 6,
            children: [
              Icon(Icons.link_rounded, size: 18, color: color),
              Flexible(
                child: Text(
                  shortLink(link),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    color: color,
                    decoration: TextDecoration.underline,
                    decorationColor: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The small link mark on a thought that has a link (M10). The thought
/// sheet opens the link.
class LinkMark extends StatelessWidget {
  const LinkMark({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.openLink,
    child: Icon(Icons.link_rounded, size: 20, color: context.kept.muted),
  );
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;

import '../../app/providers.dart';
import '../../app/update_controller.dart';
import '../../domain/app_update.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/app_update.dart' show releasesPageUrl;
import '../common.dart';
import '../material.dart';
import '../widgets/kept_switch.dart';
import '../widgets/link_row.dart' show openLink;

/// Settings › App update (02-design.md §8, in-app update): the switch for
/// the check; while on, check now, the found update, "restart update",
/// "What's new" and deleting the downloaded APK; while off, one line that
/// says so. "Releases on GitHub" is always there: updating by hand works
/// without the check. Not part of a Play build (see update_controller.dart).
class UpdateSection extends ConsumerWidget {
  const UpdateSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final on = ref.settings.updateCheckEnabled;
    final controller = ref.read(updateProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.updateSection.toUpperCase(), style: context.text.labelMedium),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.updateSwitch),
          // Switching off waits while a download runs (the controller
          // ignores it then).
          trailing: KeptSwitch(
            value: on,
            onChanged: (v) => unawaited(controller.setEnabled(v)),
          ),
          onTap: () => unawaited(controller.setEnabled(!on)),
        ),
        if (on)
          const _UpdateTiles()
        else
          Text(l10n.updateOff, style: context.text.bodyMedium),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.updateReleasesPage),
          subtitle: Text(l10n.updateReleasesPageHint),
          trailing: const Icon(Icons.open_in_new_rounded),
          onTap: () => unawaited(openLink(context, ref, releasesPageUrl)),
        ),
      ],
    );
  }
}

class _UpdateTiles extends ConsumerWidget {
  const _UpdateTiles();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final update = ref.watch(updateProvider);
    final controller = ref.read(updateProvider.notifier);
    final latest = update.latest;

    Future<void> checkNow() async {
      final messenger = ScaffoldMessenger.of(context);
      final ok = await controller.check();
      if (!context.mounted) return;
      final found = ref.read(updateProvider).latest;
      if (!ok) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.updateCheckFailed)));
      } else if (found == null) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.updateUpToDate)));
      } else {
        await showUpdateDialog(context);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.updateCheck),
          subtitle: Text(
            update.phase == UpdatePhase.checking
                ? l10n.updateChecking
                : _status(context, ref, update),
          ),
          trailing: update.phase == UpdatePhase.checking
              ? const _Spinner()
              : null,
          onTap: update.busy ? null : () => unawaited(checkNow()),
        ),
        if (latest != null)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.updateAvailableTile('${latest.version}')),
            subtitle: Text(switch (update.phase) {
              UpdatePhase.downloading => l10n.updateDownloading(
                (update.progress * 100).floor(),
              ),
              _ => l10n.updateAvailableHint,
            }),
            trailing: update.phase == UpdatePhase.downloading
                ? const _Spinner()
                : null,
            onTap: () => unawaited(showUpdateDialog(context)),
          ),
        if (latest != null && update.apkReady)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.updateRestart),
            subtitle: Text(l10n.updateRestartHint),
            onTap: update.phase == UpdatePhase.downloading
                ? null
                : () {
                    unawaited(controller.install());
                    unawaited(showUpdateDialog(context));
                  },
          ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.whatsNewTile),
          subtitle: update.installed == null
              ? null
              : Text(l10n.whatsNewTileHint('${update.installed}')),
          onTap: () =>
              unawaited(showWhatsNewDialog(context, controller.whatsNew())),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.updateDeleteFile),
          subtitle: Text(
            update.filesSize == 0
                ? l10n.updateNoFile
                : l10n.updateFileSize(_megabytes(context, update.filesSize)),
          ),
          onTap:
              update.filesSize == 0 || update.phase == UpdatePhase.downloading
              ? null
              : () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await controller.deleteFiles();
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.updateFileDeleted)),
                  );
                },
        ),
      ],
    );
  }

  String _status(BuildContext context, WidgetRef ref, UpdateState update) {
    final l10n = context.l10n;
    final version = '${update.installed ?? ''}';
    final last = update.lastCheck;
    if (last == null) return l10n.updateStatusNotChecked(version);
    final now = ref.read(clockProvider)();
    final locale = Localizations.localeOf(context).toString();
    final today =
        now.year == last.year && now.month == last.month && now.day == last.day;
    final format = today
        ? DateFormat.Hm(locale)
        : DateFormat.MMMd(locale).add_Hm();
    return l10n.updateStatusChecked(version, format.format(last));
  }
}

String _megabytes(BuildContext context, int bytes) =>
    '${NumberFormat('0.0', Localizations.localeOf(context).toString()).format(bytes / 1000000)} MB';

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) => const SizedBox.square(
    dimension: 24,
    child: CircularProgressIndicator(strokeWidth: 3),
  );
}

/// The update popup: version, release notes, then download progress and
/// what to do next. Shown once per new version on its own (HomeShell) and
/// from Settings.
Future<void> showUpdateDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => const _UpdateDialog(),
);

class _UpdateDialog extends ConsumerWidget {
  const _UpdateDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final update = ref.watch(updateProvider);
    final controller = ref.read(updateProvider.notifier);
    final latest = update.latest;
    if (latest == null) {
      // Nothing (left) to install, e.g. checked again meanwhile.
      return AlertDialog(
        content: Text(l10n.updateUpToDate),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.updateClose),
          ),
        ],
      );
    }
    final problem = update.problem;

    return AlertDialog(
      title: Text(l10n.updateDialogTitle('${latest.version}')),
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          _Notes(userNotes(latest.notes)),
          const SizedBox(height: 16),
          switch (update.phase) {
            UpdatePhase.downloading => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                LinearProgressIndicator(value: update.progress),
                Text(
                  l10n.updateDownloading((update.progress * 100).floor()),
                  style: context.text.bodyMedium,
                ),
              ],
            ),
            UpdatePhase.installing => Text(
              l10n.updateInstalling,
              style: context.text.bodyMedium,
            ),
            _ when problem != null => Text(
              [
                _problemText(problem, l10n),
                if (problem == UpdateProblem.installFailed &&
                    update.problemMessage != null)
                  update.problemMessage!,
              ].join('\n'),
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.error,
              ),
            ),
            _ => Text(l10n.updateCloseHint, style: context.text.bodyMedium),
          },
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await controller.markPopupShown();
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(update.busy ? l10n.updateClose : l10n.updateLater),
        ),
        if (update.phase == UpdatePhase.installing)
          TextButton(
            onPressed: () => unawaited(controller.install()),
            child: Text(l10n.updateRestart),
          )
        else
          TextButton(
            onPressed: update.busy
                ? null
                : () => unawaited(controller.install()),
            child: Text(l10n.updateInstall),
          ),
      ],
    );
  }
}

/// "What's new": the changes of the installed version, on the first start
/// after an update (HomeShell) and from Settings. Earlier versions follow,
/// each collapsed.
Future<void> showWhatsNewDialog(BuildContext context, Future<WhatsNew> notes) =>
    showDialog<void>(
      context: context,
      builder: (context) => _WhatsNewDialog(notes),
    );

class _WhatsNewDialog extends StatelessWidget {
  const _WhatsNewDialog(this.notes);

  final Future<WhatsNew> notes;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder(
      future: notes,
      builder: (context, snapshot) {
        final whatsNew = snapshot.data;
        return AlertDialog(
          title: Text(
            whatsNew == null
                ? l10n.whatsNewTile
                : l10n.whatsNewTitle('${whatsNew.version}'),
          ),
          scrollable: true,
          content: switch (snapshot) {
            AsyncSnapshot(hasError: true) => Text(l10n.whatsNewFailed),
            AsyncSnapshot(:final data?) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _Notes(data.sections),
                if (data.earlier.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(l10n.whatsNewEarlier, style: context.text.labelMedium),
                  for (final release in data.earlier) _EarlierVersion(release),
                ],
              ],
            ),
            _ => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            ),
          },
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.updateClose),
            ),
          ],
        );
      },
    );
  }
}

/// Release notes as headed bullet lists.
class _Notes extends StatelessWidget {
  const _Notes(this.sections);

  final List<NotesSection> sections;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        if (sections.isEmpty) Text(l10n.updateNotesEmpty),
        for (final section in sections) ...[
          if (section.kind != NotesKind.other)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _heading(section.kind, l10n),
                style: context.text.titleSmall?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
          for (final item in section.items) _Bullet(item),
        ],
      ],
    );
  }
}

/// One earlier version in "What's new": a row that opens its notes.
class _EarlierVersion extends StatefulWidget {
  const _EarlierVersion(this.release);

  final ReleaseNotes release;

  @override
  State<_EarlierVersion> createState() => _EarlierVersionState();
}

class _EarlierVersionState extends State<_EarlierVersion> {
  var _open = false;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _open = !_open),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.whatsNewVersion('${widget.release.version}'),
                  style: context.text.bodyLarge,
                ),
              ),
              AnimatedRotation(
                turns: _open ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.expand_more_rounded),
              ),
            ],
          ),
        ),
      ),
      AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.topCenter,
        child: _open
            ? Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _Notes(userNotes(widget.release.notes)),
              )
            : const SizedBox(width: double.infinity),
      ),
    ],
  );
}

String _heading(NotesKind kind, AppLocalizations l10n) => switch (kind) {
  NotesKind.added => l10n.notesNew,
  NotesKind.fixed => l10n.notesFixed,
  NotesKind.improved => l10n.notesImproved,
  NotesKind.other => '',
};

String _problemText(UpdateProblem problem, AppLocalizations l10n) =>
    switch (problem) {
      UpdateProblem.checkFailed => l10n.updateCheckFailed,
      UpdateProblem.downloadFailed => l10n.updateDownloadFailed,
      UpdateProblem.noPermission => l10n.updateNoPermission,
      UpdateProblem.installAborted => l10n.updateAborted,
      UpdateProblem.installFailed => l10n.updateFailed,
    };

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Text('•'),
      ),
      Expanded(child: Text(text)),
    ],
  );
}

/// In-app update from GitHub releases (02-design.md §8, in-app update).
///
/// The check is a conscious choice: off until the user switches it on
/// (`AppSettings.updateCheckEnabled`). While it is off the app makes no
/// network request at all. Every request of [UpdateController] goes through
/// one gate, [UpdateController._online], which reads the switch first.
///
/// Not part of a Play build (Google Play does not allow apps that update
/// themselves). To remove it, delete:
/// - `lib/domain/app_update.dart`, `lib/platform/app_update.dart`, this file,
///   `lib/ui/settings/update_tiles.dart`, `lib/ui/home/update_ask_card.dart`,
///   `android/app/src/main/kotlin/de/gartenpa/kept/UpdateChannel.kt`,
///   `scripts/update_test_server.dart` and their tests
///   (`test/app_update_test.dart`, `test/update_controller_test.dart`,
///   `test/update_screens_test.dart`, `test/fake_update_service.dart`);
/// - INTERNET and REQUEST_INSTALL_PACKAGES in `AndroidManifest.xml`;
/// - the two `UpdateChannel` lines in `MainActivity.kt`;
/// - in `HomeShell` the `_lookForUpdate` calls and method, in `HomeScreen`
///   the `UpdateAskCard`, in Settings the `UpdateSection`, in "Permissions
///   and privacy" the update card, in the first-start flow the update page
///   and the `markVersionSeen` call;
/// - in `about.dart` the [installedVersionProvider] (use `appVersion`);
/// - the texts starting with `update`, `whatsNew` and `notes`, and change
///   `fsWelcomePrivacy` and `permNothingLeaves` back to "nothing is sent".
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings_repository.dart';
import '../domain/app_update.dart';
import '../platform/app_update.dart';
import 'licences.dart';
import 'providers.dart';

enum UpdatePhase { idle, checking, downloading, installing }

enum UpdateProblem {
  /// GitHub couldn't be reached.
  checkFailed,
  downloadFailed,

  /// "Install unknown apps" is still off for Kept.
  noPermission,

  /// The user cancelled Android's install dialog.
  installAborted,

  /// Android refused the APK (e.g. signed with another key).
  installFailed,
}

@immutable
class UpdateState {
  const UpdateState({
    this.installed,
    this.latest,
    this.phase = UpdatePhase.idle,
    this.progress = 0,
    this.apkReady = false,
    this.filesSize = 0,
    this.lastCheck,
    this.problem,
    this.problemMessage,
  });

  final AppVersion? installed;

  /// A release newer than the installed version, if any.
  final ReleaseInfo? latest;
  final UpdatePhase phase;

  /// Download progress, 0…1.
  final double progress;

  /// The APK of [latest] is downloaded completely.
  final bool apkReady;

  /// All downloaded update files, in bytes.
  final int filesSize;
  final DateTime? lastCheck;
  final UpdateProblem? problem;

  /// Android's reason for [UpdateProblem.installFailed].
  final String? problemMessage;

  bool get busy => phase != UpdatePhase.idle;
}

/// The changes "What's new" shows.
@immutable
class WhatsNew {
  const WhatsNew(this.version, this.sections, {this.earlier = const []});

  /// The installed version.
  final AppVersion version;

  /// The new changes, shown open.
  final List<NotesSection> sections;

  /// Older versions, shown collapsed below (see [earlierReleases]).
  final List<ReleaseNotes> earlier;

  /// The new releases and the earlier ones, merged into [sections] and
  /// listed in [earlier].
  factory WhatsNew.of(
    AppVersion installed,
    List<ReleaseNotes> releases,
    List<ReleaseNotes> all,
  ) => WhatsNew(
    installed,
    mergedNotes(releases),
    earlier: earlierReleases(
      all,
      // Newest first, so the last one is the oldest new release.
      before: releases.lastOrNull?.version ?? installed,
    ),
  );
}

/// Thrown by the gate when a request was attempted with the check off.
class UpdateCheckOff implements Exception {
  const UpdateCheckOff();

  @override
  String toString() => 'The update check is off';
}

/// The update service. Tests override it with a fake.
final updateServiceProvider = Provider<UpdateService>(
  (ref) => AndroidUpdateService(),
);

/// The installed version as text, for the licence page; [appVersion] if
/// Android cannot tell (tests, or a build without the update channel).
final installedVersionProvider = FutureProvider<String>((ref) async {
  try {
    final version = await ref.read(updateServiceProvider).installedVersion();
    return version?.toString() ?? appVersion;
  } catch (_) {
    return appVersion;
  }
});

final updateProvider = NotifierProvider<UpdateController, UpdateState>(
  UpdateController.new,
);

/// Looks for updates (on start and on resume, at most every 30 minutes, or by
/// hand), downloads the APK and starts Android's installer. The APK stays
/// until the new version runs (then [checkIfDue] deletes it) or the user
/// deletes it, so "restart update" needn't download it again.
class UpdateController extends Notifier<UpdateState> {
  UpdateService get _service => ref.read(updateServiceProvider);
  SettingsRepository get _settings => ref.read(servicesProvider).settings;

  var _cleanedUp = false;

  /// The update waits for the user to allow installing apps.
  var _awaitingPermission = false;

  @override
  UpdateState build() {
    final sub = _service.installResults.listen(_onInstallResult);
    ref.onDispose(sub.cancel);
    return const UpdateState();
  }

  /// Whether the user has switched the update check on, read fresh from the
  /// settings each time.
  Future<bool> _enabled() async => (await _settings.load()).updateCheckEnabled;

  /// The one gate for the network: every request to GitHub (latest release,
  /// release list, APK download) is made through here, and only while the
  /// check is switched on. Throws [UpdateCheckOff] otherwise.
  Future<T> _online<T>(
    Future<T> Function(UpdateService service) request,
  ) async {
    if (!await _enabled()) throw const UpdateCheckOff();
    return request(_service);
  }

  void _set({
    AppVersion? installed,
    ReleaseInfo? Function()? latest,
    UpdatePhase? phase,
    double? progress,
    bool? apkReady,
    int? filesSize,
    DateTime? lastCheck,
    UpdateProblem? Function()? problem,
    String? problemMessage,
  }) {
    final s = state;
    final newProblem = problem == null ? s.problem : problem();
    state = UpdateState(
      installed: installed ?? s.installed,
      latest: latest == null ? s.latest : latest(),
      phase: phase ?? s.phase,
      progress: progress ?? s.progress,
      apkReady: apkReady ?? s.apkReady,
      filesSize: filesSize ?? s.filesSize,
      lastCheck: lastCheck ?? s.lastCheck,
      problem: newProblem,
      problemMessage: newProblem == null
          ? null
          : problemMessage ?? s.problemMessage,
    );
  }

  Future<AppVersion?> _installed() async {
    if (state.installed != null) return state.installed;
    final version = await _service.installedVersion();
    _set(installed: version);
    return version;
  }

  Future<void> _refreshFiles() async {
    final latest = state.latest;
    _set(
      apkReady: latest != null && await _service.downloaded(latest) != null,
      filesSize: await _service.filesSize(),
    );
  }

  /// Switches the update check on or off, and marks the question as
  /// answered. Off forgets a found update and deletes the downloaded files;
  /// not while a download runs (Settings disables the switch then).
  Future<void> setEnabled(bool on) async {
    if (!on && state.phase == UpdatePhase.downloading) return;
    await _settings.update(
      (s) => s.copyWith(updateCheckEnabled: on, updateCheckAsked: true),
    );
    if (on) return;
    _awaitingPermission = false;
    _set(
      latest: () => null,
      phase: UpdatePhase.idle,
      problem: () => null,
      apkReady: false,
    );
    try {
      await _service.deleteAll();
      _set(filesSize: await _service.filesSize());
    } catch (e) {
      debugPrint('Update files not deleted: $e');
    }
  }

  /// On start and when the app comes back: if the check is on, deletes the
  /// APK of an update that has been installed meanwhile, and checks if the
  /// last check is [updateCheckInterval] ago. Off: does nothing.
  Future<void> checkIfDue() async {
    if (state.busy) return;
    try {
      if (!await _enabled()) return;
      final installed = await _installed();
      if (!_cleanedUp && installed != null) {
        _cleanedUp = true;
        await _service.cleanUp(installed);
      }
      final last = DateTime.tryParse(
        await _settings.status(SettingsRepository.lastUpdateCheck) ?? '',
      );
      if (last != null) _set(lastCheck: last);
      if (updateCheckDue(last, DateTime.now())) {
        await check();
      } else {
        await _refreshFiles();
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  /// Looks for a newer release now. Returns false if GitHub couldn't be
  /// reached, or the check is off.
  Future<bool> check() async {
    if (state.busy) return false;
    _set(phase: UpdatePhase.checking, problem: () => null);
    var ok = true;
    try {
      final installed = await _installed();
      final release = await _online((s) => s.fetchLatest());
      final now = DateTime.now();
      await _settings.setStatus(
        SettingsRepository.lastUpdateCheck,
        now.toIso8601String(),
      );
      _set(
        lastCheck: now,
        latest: () =>
            release != null && installed != null && release.version > installed
            ? release
            : null,
      );
    } on UpdateCheckOff {
      ok = false;
    } catch (e) {
      debugPrint('Update check failed: $e');
      ok = false;
      _set(problem: () => UpdateProblem.checkFailed);
    }
    try {
      await _refreshFiles();
    } catch (e) {
      debugPrint('Update files not read: $e');
    }
    _set(phase: UpdatePhase.idle);
    return ok;
  }

  /// Whether the popup should show for the found update: once per version.
  Future<bool> popupDue() async {
    final latest = state.latest;
    if (latest == null) return false;
    final shown = AppVersion.tryParse(
      await _settings.status(SettingsRepository.updatePopupShown) ?? '',
    );
    return shown == null || latest.version > shown;
  }

  Future<void> markPopupShown() async {
    final latest = state.latest;
    if (latest == null) return;
    await _settings.setStatus(
      SettingsRepository.updatePopupShown,
      '${latest.version}',
    );
  }

  /// Downloads the APK if needed and starts the installer. Also the
  /// "restart update" button: it abandons an unfinished install first.
  Future<void> install() async {
    final latest = state.latest;
    if (latest == null || state.phase == UpdatePhase.downloading) return;
    _set(problem: () => null);
    try {
      if (!await _service.canInstall()) {
        // Continues in [resumed] once the user comes back from Settings.
        _awaitingPermission = true;
        await _service.openInstallPermission();
        return;
      }
      var apk = await _service.downloaded(latest);
      if (apk == null) {
        _set(phase: UpdatePhase.downloading, progress: 0);
        try {
          apk = await _online<File>(
            (s) => s.download(
              latest,
              // Whole percents are enough and spare the UI ~400 rebuilds.
              (p) {
                if ((p * 100).floor() != (state.progress * 100).floor()) {
                  _set(progress: p);
                }
              },
            ),
          );
        } catch (e) {
          debugPrint('Update download failed: $e');
          _set(
            phase: UpdatePhase.idle,
            problem: () => UpdateProblem.downloadFailed,
          );
          await _refreshFiles();
          return;
        }
        await _refreshFiles();
      }
      _set(phase: UpdatePhase.installing);
      await _service.install(apk);
      // Android now asks the user. If they confirm, the app is stopped and
      // replaced; otherwise [_onInstallResult] gets the answer.
    } on PlatformException catch (e) {
      debugPrint('Update install failed: $e');
      _set(
        phase: UpdatePhase.idle,
        problem: () => UpdateProblem.installFailed,
        problemMessage: e.message,
      );
    } on FileSystemException catch (e) {
      debugPrint('Update file failed: $e');
      _set(
        phase: UpdatePhase.idle,
        problem: () => UpdateProblem.downloadFailed,
      );
    }
  }

  void _onInstallResult(InstallResult result) {
    if (result.status == InstallResult.success) {
      _set(phase: UpdatePhase.idle);
      return;
    }
    _set(
      phase: UpdatePhase.idle,
      problem: () => result.wasAborted
          ? UpdateProblem.installAborted
          : UpdateProblem.installFailed,
      problemMessage: result.message,
    );
  }

  /// The app came back to the foreground.
  Future<void> resumed() async {
    if (_awaitingPermission) {
      _awaitingPermission = false;
      try {
        if (await _service.canInstall()) {
          await install();
        } else {
          _set(problem: () => UpdateProblem.noPermission);
        }
      } catch (e) {
        debugPrint('Install permission not read: $e');
      }
      return;
    }
    await checkIfDue();
  }

  /// The first start after an update: the changes since the version that
  /// ran before, or null if there is nothing to show. The version counts as
  /// seen once the notes could be read; if GitHub can't be reached, the next
  /// start or resume tries again. With the check off: nothing, and nothing
  /// is fetched.
  Future<WhatsNew?> whatsNewOnStart() async {
    try {
      if (!await _enabled()) return null;
      final installed = await _installed();
      if (installed == null) return null;
      final lastRun = AppVersion.tryParse(
        await _settings.status(SettingsRepository.lastRunVersion) ?? '',
      );
      final firstStartDone = (await _settings.load()).firstStartDone;
      if (!whatsNewDue(
        lastRun: lastRun,
        installed: installed,
        onboardingDone: firstStartDone,
      )) {
        if (lastRun != installed && firstStartDone) await markVersionSeen();
        return null;
      }
      final all = await _online((s) => s.fetchReleases());
      final releases = releasesBetween(all, since: lastRun, upTo: installed);
      final whatsNew = WhatsNew.of(installed, releases, all);
      await _cacheNotes(installed, releases, whatsNew.earlier);
      await markVersionSeen();
      // Earlier versions alone are no reason to show the popup.
      return whatsNew.sections.isEmpty ? null : whatsNew;
    } catch (e) {
      debugPrint("What's new failed: $e");
      return null;
    }
  }

  /// For Settings: the installed version's notes and the earlier versions,
  /// from GitHub. Offline (or with the check off), what was stored at the
  /// last update. Throws if neither works.
  Future<WhatsNew> whatsNew() async {
    final installed = await _installed();
    if (installed == null) throw StateError('Version unknown');
    try {
      final all = await _online((s) => s.fetchReleases());
      final releases = releasesBetween(all, since: null, upTo: installed);
      final whatsNew = WhatsNew.of(installed, releases, all);
      await _cacheNotes(installed, releases, whatsNew.earlier);
      return whatsNew;
    } catch (_) {
      final cached = await _cachedNotes(installed);
      if (cached == null) rethrow;
      return cached;
    }
  }

  /// Records the installed version as seen. Also at the end of the
  /// first-start flow, so a fresh install doesn't show "What's new". No
  /// network.
  Future<void> markVersionSeen() async {
    try {
      final installed = await _installed();
      if (installed == null) return;
      await _settings.setStatus(
        SettingsRepository.lastRunVersion,
        '$installed',
      );
    } catch (e) {
      debugPrint('Version not recorded: $e');
    }
  }

  Future<void> _cacheNotes(
    AppVersion version,
    List<ReleaseNotes> releases,
    List<ReleaseNotes> earlier,
  ) async {
    // Nothing to keep if GitHub has no release for this version (a test
    // build): Settings asks again next time.
    if (releases.isEmpty) return;
    await _settings.setStatus(
      SettingsRepository.whatsNew,
      jsonEncode({
        'version': '$version',
        'releases': [for (final r in releases) r.toJson()],
        'earlier': [for (final r in earlier) r.toJson()],
      }),
    );
  }

  Future<WhatsNew?> _cachedNotes(AppVersion version) async {
    try {
      final json = jsonDecode(
        await _settings.status(SettingsRepository.whatsNew) ?? '',
      );
      if (json is! Map<String, dynamic> ||
          AppVersion.tryParse('${json['version']}') != version) {
        return null;
      }
      List<ReleaseNotes> read(Object? list) => [
        for (final r
            in (list as List? ?? const []).whereType<Map<String, dynamic>>())
          ?ReleaseNotes.fromJson(r),
      ];
      return WhatsNew(
        version,
        mergedNotes(read(json['releases'])),
        earlier: read(json['earlier']),
      );
    } catch (_) {
      return null; // nothing stored yet, or unreadable
    }
  }

  /// Deletes all downloaded update files (also while an install hangs).
  Future<void> deleteFiles() async {
    if (state.phase == UpdatePhase.downloading) return;
    await _service.deleteAll();
    _set(phase: UpdatePhase.idle);
    await _refreshFiles();
  }
}

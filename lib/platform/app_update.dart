/// In-app update (02-design.md §8): the network, the files and the channel
/// to Android's installer (UpdateChannel.kt). Not part of a Play build: see
/// `app/update_controller.dart` for what to remove.
///
/// Nothing here decides whether the network may be used. Every request goes
/// through the gate in `UpdateController`, which lets it pass only while the
/// user has switched the update check on.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../app/build_flags.dart';
import '../domain/app_update.dart';

/// Where the releases come from. The repository is public, so no token.
/// For testing, a build can point elsewhere with
/// `--dart-define=UPDATE_RELEASE_URL=...` (scripts/update_test_server.dart).
const _latestReleaseUrl = String.fromEnvironment(
  'UPDATE_RELEASE_URL',
  defaultValue:
      'https://api.github.com/repos/Kraechtshammer/friendsapp/releases/latest',
);

/// The recent releases, for "What's new" after an update. Overridden with
/// `--dart-define=UPDATE_RELEASES_URL=...` for tests.
const _releasesUrl = String.fromEnvironment(
  'UPDATE_RELEASES_URL',
  defaultValue: 'https://api.github.com/repos/Kraechtshammer/friendsapp/releases?per_page=20',
);

/// The releases page, opened in the browser (Settings, "Releases on
/// GitHub"). Opening it is not a request by the app.
const releasesPageUrl = 'https://github.com/Kraechtshammer/friendsapp/releases';

const _userAgent = 'Kept-App';

/// How an install ended (PackageInstaller's status codes, sent by
/// UpdateChannel.kt). Success is rarely seen: Android stops the app to
/// replace it.
class InstallResult {
  const InstallResult(this.status, this.message);

  static const success = 0;
  static const aborted = 3;

  final int status;
  final String? message;

  bool get wasAborted => status == aborted;
}

/// Checks GitHub for a newer release, downloads its APK into the app's
/// files and hands it to Android's installer. Behind an interface so tests
/// can fake it.
abstract class UpdateService {
  /// Install results, after [install] (not when the user confirmed the
  /// update: then the app is stopped).
  Stream<InstallResult> get installResults;

  /// The installed versionName; null if it cannot be read.
  Future<AppVersion?> installedVersion();

  /// The latest release, or null if there is none with an APK. Throws on
  /// network errors. Network.
  Future<ReleaseInfo?> fetchLatest();

  /// The recent releases (GitHub lists the newest 20). Throws on network
  /// errors. Network.
  Future<List<ReleaseNotes>> fetchReleases();

  /// The complete APK of [release], if it was downloaded already.
  Future<File?> downloaded(ReleaseInfo release);

  /// Downloads the APK of [release]. [onProgress] gets 0…1. Network.
  Future<File> download(
    ReleaseInfo release,
    void Function(double progress) onProgress,
  );

  /// Deletes APKs of the installed version or older and broken downloads,
  /// i.e. what's left after an update. Call when no download runs.
  Future<void> cleanUp(AppVersion installed);

  /// The size of all downloaded update files in bytes (0 if none).
  Future<int> filesSize();

  /// Deletes all downloaded update files.
  Future<void> deleteAll();

  /// Whether the user allowed Kept. to install apps.
  Future<bool> canInstall();

  /// Opens Android's "Install unknown apps" switch for Kept.
  Future<void> openInstallPermission();

  /// Hands [apk] to Android's installer, which asks the user to confirm.
  /// Abandons an earlier, unfinished install first.
  Future<void> install(File apk);
}

/// [UpdateService] with `dart:io` and the channel `de.gartenpa.kept/updater`.
/// UI isolate only.
class AndroidUpdateService implements UpdateService {
  AndroidUpdateService() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'installResult') {
        final args = Map<String, dynamic>.from(call.arguments as Map);
        _results.add(
          InstallResult(args['status'] as int, args['message'] as String?),
        );
      }
    });
  }

  static const _channel = MethodChannel('de.gartenpa.kept/updater');

  final _results = StreamController<InstallResult>.broadcast();

  @override
  Stream<InstallResult> get installResults => _results.stream;

  @override
  Future<AppVersion?> installedVersion() async => AppVersion.tryParse(
    await _channel.invokeMethod<String>('installedVersion') ?? '',
  );

  @override
  Future<ReleaseInfo?> fetchLatest() async {
    final json = await _getJson(_latestReleaseUrl);
    return json is Map<String, dynamic>
        ? ReleaseInfo.fromJson(json, listener: keptIncoming)
        : null;
  }

  @override
  Future<List<ReleaseNotes>> fetchReleases() async {
    final json = await _getJson(_releasesUrl);
    if (json is! List) return const [];
    return [
      for (final release in json.whereType<Map<String, dynamic>>())
        ?ReleaseNotes.fromJson(release),
    ];
  }

  /// GitHub's answer, or null for 404 (no release yet).
  Future<Object?> _getJson(String url) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client.getUrl(Uri.parse(url));
      request.headers
        ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json')
        ..set(HttpHeaders.userAgentHeader, _userAgent);
      final response = await request.close().timeout(
        const Duration(seconds: 20),
      );
      if (response.statusCode == HttpStatus.notFound) {
        await response.drain<void>();
        return null;
      }
      if (response.statusCode != HttpStatus.ok) {
        await response.drain<void>();
        throw HttpException('GitHub answered ${response.statusCode}');
      }
      return jsonDecode(await response.transform(utf8.decoder).join());
    } finally {
      client.close();
    }
  }

  Future<Directory> _dir() async {
    final dir = Directory(
      '${(await getApplicationSupportDirectory()).path}/updates',
    );
    return dir.create(recursive: true);
  }

  @override
  Future<File?> downloaded(ReleaseInfo release) async {
    final file = File(
      '${(await _dir()).path}/${apkFileName(release.version, listener: keptIncoming)}',
    );
    return await file.exists() && await file.length() == release.apkSize
        ? file
        : null;
  }

  @override
  Future<File> download(
    ReleaseInfo release,
    void Function(double progress) onProgress,
  ) async {
    final target = File(
      '${(await _dir()).path}/${apkFileName(release.version, listener: keptIncoming)}',
    );
    final part = File('${target.path}.part');
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      // GitHub redirects to its file storage; HttpClient follows that.
      final request = await client.getUrl(Uri.parse(release.apkUrl));
      request.headers.set(HttpHeaders.userAgentHeader, _userAgent);
      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      if (response.statusCode != HttpStatus.ok) {
        await response.drain<void>();
        throw HttpException('Download answered ${response.statusCode}');
      }
      final sink = part.openWrite();
      var received = 0;
      try {
        // A stalled connection fails instead of hanging forever.
        await for (final chunk in response.timeout(
          const Duration(seconds: 30),
        )) {
          sink.add(chunk);
          received += chunk.length;
          onProgress((received / release.apkSize).clamp(0, 1));
        }
      } finally {
        await sink.close();
      }
      if (received != release.apkSize) {
        await part.delete();
        throw const HttpException('Download incomplete');
      }
      // The rename marks the file as complete.
      return await part.rename(target.path);
    } catch (_) {
      if (await part.exists()) await part.delete();
      rethrow;
    } finally {
      client.close();
    }
  }

  @override
  Future<void> cleanUp(AppVersion installed) async {
    final files = {
      for (final file in await (await _dir()).list().toList())
        if (file is File) file.uri.pathSegments.last: file,
    };
    for (final name in updateFilesToDelete(files.keys, installed)) {
      await files[name]!.delete();
    }
  }

  @override
  Future<int> filesSize() async {
    var size = 0;
    await for (final entity in (await _dir()).list()) {
      if (entity is File) size += await entity.length();
    }
    return size;
  }

  @override
  Future<void> deleteAll() async {
    final dir = await _dir();
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  @override
  Future<bool> canInstall() async =>
      await _channel.invokeMethod<bool>('canInstall') ?? false;

  @override
  Future<void> openInstallPermission() =>
      _channel.invokeMethod<void>('openInstallPermission');

  @override
  Future<void> install(File apk) =>
      _channel.invokeMethod<void>('install', {'path': apk.path});
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:kept/domain/app_update.dart';
import 'package:kept/platform/app_update.dart';

/// [UpdateService] without Android or the network. Counts every network
/// request in [networkRequests]; set [failOnNetwork] to make each of them a
/// test failure as well.
class FakeUpdateService implements UpdateService {
  FakeUpdateService({this.installed = '1.0.0'});

  String? installed;
  ReleaseInfo? latest;
  List<ReleaseNotes> releases = const [];
  Object? fetchError;
  Object? downloadError;
  Object? installError;
  bool allowed = true;
  bool apkStored = false;
  int storedBytes = 0;
  bool failOnNetwork = false;

  /// Every network request, by name: fetchLatest, fetchReleases, download.
  final networkRequests = <String>[];
  var downloads = 0;
  var installs = 0;
  var permissionOpened = 0;
  var cleanUps = 0;
  var deletes = 0;

  final _results = StreamController<InstallResult>.broadcast();

  /// Sends what UpdateChannel.kt would send after an install.
  void sendResult(int status, [String? message]) =>
      _results.add(InstallResult(status, message));

  void _network(String name) {
    networkRequests.add(name);
    if (failOnNetwork) {
      throw StateError('Network request "$name" while the check is off');
    }
  }

  @override
  Stream<InstallResult> get installResults => _results.stream;

  @override
  Future<AppVersion?> installedVersion() async =>
      AppVersion.tryParse(installed ?? '');

  @override
  Future<ReleaseInfo?> fetchLatest() async {
    _network('fetchLatest');
    if (fetchError case final e?) throw e;
    return latest;
  }

  @override
  Future<List<ReleaseNotes>> fetchReleases() async {
    _network('fetchReleases');
    if (fetchError case final e?) throw e;
    return releases;
  }

  @override
  Future<File?> downloaded(ReleaseInfo release) async =>
      apkStored ? File('/fake/${apkFileName(release.version)}') : null;

  @override
  Future<File> download(
    ReleaseInfo release,
    void Function(double progress) onProgress,
  ) async {
    _network('download');
    downloads++;
    if (downloadError case final e?) throw e;
    onProgress(0.5);
    onProgress(1);
    apkStored = true;
    storedBytes = release.apkSize;
    return File('/fake/${apkFileName(release.version)}');
  }

  @override
  Future<void> cleanUp(AppVersion installed) async => cleanUps++;

  @override
  Future<int> filesSize() async => storedBytes;

  @override
  Future<void> deleteAll() async {
    deletes++;
    apkStored = false;
    storedBytes = 0;
  }

  @override
  Future<bool> canInstall() async => allowed;

  @override
  Future<void> openInstallPermission() async => permissionOpened++;

  @override
  Future<void> install(File apk) async {
    installs++;
    if (installError case final e?) throw e;
  }
}

/// A release newer than the fake's default installed version.
ReleaseInfo fakeRelease([String version = '1.1.0']) => ReleaseInfo(
  version: AppVersion.tryParse(version)!,
  notes: '## New\n\n- Something new\n\n## Behind the scenes\n\n- CI\n',
  apkUrl: 'https://example.invalid/kept-$version.apk',
  apkSize: 2000000,
);

/// What the platform channel throws for Android's errors.
PlatformException installRefused() =>
    PlatformException(code: 'INSTALL_ERROR', message: 'signatures differ');

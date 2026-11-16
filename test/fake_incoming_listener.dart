import 'package:kept/domain/incoming_contact.dart';
import 'package:kept/platform/incoming_listener.dart';

/// [IncomingListener] without the platform. Records what the app sends and
/// hands out [queue] as the listener would.
class FakeIncomingListener implements IncomingListener {
  FakeIncomingListener({this.access = false});

  /// What [hasAccess] returns.
  bool access;

  /// The switch as last sent; null if never sent.
  bool? enabled;

  /// Every watch list sent, in order.
  final watchLists = <List<WatchEntry>>[];

  /// What [takeQueue] returns next; emptied by it.
  final queue = <IncomingEntry>[];

  var accessSettingsOpened = 0;

  @override
  Future<void> setEnabled(bool on) async {
    enabled = on;
    if (!on) queue.clear();
  }

  @override
  Future<void> setWatchList(List<WatchEntry> entries) async =>
      watchLists.add(entries);

  @override
  Future<List<IncomingEntry>> takeQueue() async {
    final entries = [...queue];
    queue.clear();
    return entries;
  }

  @override
  Future<bool> hasAccess() async => access;

  @override
  Future<void> openAccessSettings() async => accessSettingsOpened++;
}

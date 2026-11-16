import 'dart:async';

/// Runs an action once after a burst of calls: each call waits [delay]
/// again, and only the last one runs.
class Debouncer {
  Debouncer(this.delay);

  final Duration delay;
  Timer? _timer;

  /// Runs [action] after [delay], unless called again before.
  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Whether an action is waiting.
  bool get isPending => _timer?.isActive ?? false;

  /// Drops the waiting action, if any.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}

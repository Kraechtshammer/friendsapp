import 'dart:async';

import 'package:flutter/services.dart';

import '../common.dart';
import '../material.dart';

/// Experiment, debug builds only: can Kept. capture a chat through another
/// app's "create shortcut" picker and open it again? The native side is
/// android/.../ShortcutProbe.kt. Results live in memory only; "Copy report"
/// puts them on the clipboard for the developer. Hard-coded English like
/// the rest of Development.
class ShortcutProbePage extends StatefulWidget {
  const ShortcutProbePage({super.key});

  @override
  State<ShortcutProbePage> createState() => _ShortcutProbePageState();
}

class _ShortcutProbePageState extends State<ShortcutProbePage> {
  static const _channel = MethodChannel('de.gartenpa.kept/shortcutProbe');

  List<Map<String, String>>? _apps;
  String? _error;
  final _results = <String, Map<String, Object?>>{};
  final _launches = <String, String>{};

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final list = await _channel.invokeListMethod<Map<Object?, Object?>>(
        'list',
      );
      if (!mounted) return;
      setState(() {
        _apps = [
          for (final m in list ?? const <Map<Object?, Object?>>[])
            m.map((k, v) => MapEntry('$k', '$v')),
        ];
      });
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  String _key(Map<String, String> app) =>
      '${app['package']}/${app['activity']}';

  Future<void> _pick(Map<String, String> app) async {
    try {
      final r = await _channel.invokeMapMethod<String, Object?>('pick', {
        'package': app['package'],
        'activity': app['activity'],
      });
      if (!mounted) return;
      setState(() => _results[_key(app)] = r ?? {'error': 'no result'});
    } catch (e) {
      if (mounted) setState(() => _results[_key(app)] = {'error': '$e'});
    }
  }

  Future<void> _launch(String key, String uri) async {
    final r = await _channel.invokeMethod<String>('launch', {'uri': uri});
    if (mounted) setState(() => _launches[key] = r ?? 'no answer');
  }

  String _report() {
    final b = StringBuffer('Chat shortcut experiment\n');
    for (final app in _apps ?? const <Map<String, String>>[]) {
      final key = _key(app);
      b.writeln('\n${app['app']} - ${app['label']} ($key)');
      final r = _results[key];
      if (r == null) {
        b.writeln('  not tried');
        continue;
      }
      r.forEach((k, v) => b.writeln('  $k: $v'));
      final l = _launches[key];
      if (l != null) b.writeln('  launch: $l');
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final apps = _apps;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat shortcut test'),
        actions: [
          IconButton(
            tooltip: 'Copy report',
            icon: const Icon(Icons.copy),
            onPressed: () {
              unawaited(Clipboard.setData(ClipboardData(text: _report())));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Report copied')));
            },
          ),
        ],
      ),
      body: _error != null
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $_error'),
            )
          : apps == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Apps offering a "create shortcut" picker. Tap one, pick a '
                  'chat, then try "Open captured". Copy the report when done.',
                ),
                const SizedBox(height: 16),
                if (apps.isEmpty) const Text('No app offers a picker.'),
                for (final app in apps) _tile(context, app),
              ],
            ),
    );
  }

  Widget _tile(BuildContext context, Map<String, String> app) {
    final key = _key(app);
    final r = _results[key];
    final uri = r?['legacyUri'] as String?;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${app['app']}', style: context.text.titleMedium),
            Text('${app['label']}\n$key', style: context.text.bodySmall),
            if (r != null) ...[
              const SizedBox(height: 8),
              SelectableText(
                r.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
                style: context.text.bodySmall,
              ),
            ],
            if (_launches[key] != null) Text('launch: ${_launches[key]}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: () => unawaited(_pick(app)),
                  child: const Text('Pick a chat'),
                ),
                if (uri != null)
                  OutlinedButton(
                    onPressed: () => unawaited(_launch(key, uri)),
                    child: const Text('Open captured'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

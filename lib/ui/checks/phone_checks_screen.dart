// Throwaway: the "Phone checks" screen. Delete it together with
// lib/platform/phone_checks.dart once the checks on the phone are done.

import 'dart:typed_data';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../platform/phone_checks.dart' as checks;
import '../common.dart';
import '../material.dart';

class PhoneChecksScreen extends StatelessWidget {
  const PhoneChecksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone checks')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
        children: const [
          _ScheduledCheck(),
          _ButtonsCheck(),
          _ChatsCheck(),
          _ListenerCheck(),
          _IconsCheck(),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: context.text.titleLarge),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

/// Lines of text that can be selected and copied.
class _Lines extends StatelessWidget {
  const _Lines(this.lines);

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SelectableText(
        lines.isEmpty ? '(none)' : lines.join('\n'),
        style: context.text.bodySmall?.copyWith(fontFamily: 'monospace'),
      ),
    );
  }
}

String _error(Object e) => 'Error: $e';

// Check 1 ---------------------------------------------------------------

class _ScheduledCheck extends StatefulWidget {
  const _ScheduledCheck();

  @override
  State<_ScheduledCheck> createState() => _ScheduledCheckState();
}

class _ScheduledCheckState extends State<_ScheduledCheck> {
  String _status = '';
  List<String> _pending = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final List<PendingNotificationRequest> pending = await checks
          .pendingChecks();
      if (!mounted) return;
      setState(() {
        _pending = [for (final p in pending) '#${p.id}  ${p.body ?? ''}'];
      });
    } catch (e) {
      if (mounted) setState(() => _status = _error(e));
    }
  }

  Future<void> _schedule(int minutes) async {
    try {
      if (!await checks.ensureNotificationPermission()) {
        setState(() => _status = 'Notifications are not allowed.');
        return;
      }
      final at = await checks.scheduleCheck(Duration(minutes: minutes));
      setState(
        () => _status =
            'Scheduled for ${checks.hhmmss(at)} '
            '(now ${checks.hhmmss(DateTime.now())})',
      );
    } catch (e) {
      setState(() => _status = _error(e));
    }
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: '1. Scheduled notification (inexact)',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in [2, 15, 60])
              FilledButton(
                onPressed: () => _schedule(m),
                child: Text('In $m minutes'),
              ),
          ],
        ),
        if (_status.isNotEmpty) _Lines([_status]),
        Row(
          children: [
            Expanded(child: Text('Pending', style: context.text.titleSmall)),
            TextButton(onPressed: _refresh, child: const Text('Refresh')),
          ],
        ),
        _Lines(_pending),
      ],
    );
  }
}

// Check 2 ---------------------------------------------------------------

class _ButtonsCheck extends StatefulWidget {
  const _ButtonsCheck();

  @override
  State<_ButtonsCheck> createState() => _ButtonsCheckState();
}

class _ButtonsCheckState extends State<_ButtonsCheck> {
  String _status = '';
  List<String> _log = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final log = await checks.actionLog();
      if (mounted) setState(() => _log = log);
    } catch (e) {
      if (mounted) setState(() => _status = _error(e));
    }
  }

  Future<void> _show() async {
    try {
      if (!await checks.ensureNotificationPermission()) {
        setState(() => _status = 'Notifications are not allowed.');
        return;
      }
      await checks.showButtonsNotification();
      setState(() => _status = 'Shown at ${checks.hhmmss(DateTime.now())}');
    } catch (e) {
      setState(() => _status = _error(e));
    }
  }

  Future<void> _clear() async {
    try {
      await checks.clearActionLog();
    } catch (e) {
      setState(() => _status = _error(e));
    }
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: '2. Notification buttons, app closed',
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            onPressed: _show,
            child: const Text('Show notification with buttons'),
          ),
        ),
        if (_status.isNotEmpty) _Lines([_status]),
        Row(
          children: [
            Expanded(child: Text('Button log', style: context.text.titleSmall)),
            TextButton(onPressed: _refresh, child: const Text('Refresh')),
            TextButton(onPressed: _clear, child: const Text('Clear')),
          ],
        ),
        _Lines(_log),
      ],
    );
  }
}

// Check 3 ---------------------------------------------------------------

class _ChatsCheck extends StatefulWidget {
  const _ChatsCheck();

  @override
  State<_ChatsCheck> createState() => _ChatsCheckState();
}

class _ChatsCheckState extends State<_ChatsCheck> {
  final _phone = TextEditingController();
  final _telegram = TextEditingController();
  final _discord = TextEditingController();

  /// Outcome per button, keyed by its label.
  final Map<String, String> _results = {};

  @override
  void dispose() {
    _phone.dispose();
    _telegram.dispose();
    _discord.dispose();
    super.dispose();
  }

  String get _number => _phone.text.replaceAll(RegExp(r'[^0-9]'), '');
  String get _user => _telegram.text.trim().replaceFirst('@', '');
  String get _discordId => _discord.text.trim();

  Future<void> _run(String key, Future<String> Function() action) async {
    setState(() => _results[key] = '...');
    String outcome;
    try {
      outcome = await action();
    } catch (e) {
      outcome = _error(e);
    }
    if (mounted) setState(() => _results[key] = outcome);
  }

  Future<String> _launch(String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    return 'returned $ok';
  }

  Future<String> _intent(String url, String package) async {
    final intent = AndroidIntent(
      action: 'android.intent.action.VIEW',
      data: url,
      package: package,
    );
    final resolves = await intent.canResolveActivity() ?? false;
    if (!resolves) return 'cannot resolve (not launched)';
    await intent.launch();
    return 'resolves, launched';
  }

  Widget _try(String key, Future<String> Function() action) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          OutlinedButton(onPressed: () => _run(key, action), child: Text(key)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_results[key] ?? '', style: context.text.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _messenger(String name, List<Widget> rows) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(name, style: context.text.titleSmall),
          ...rows,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const whatsapp = 'com.whatsapp';
    const telegram = 'org.telegram.messenger';
    const signal = 'org.thoughtcrime.securesms';
    const discord = 'com.discord';
    return _Section(
      title: '3. Opening chats',
      children: [
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone number, international (4915112345678)',
          ),
        ),
        TextField(
          controller: _telegram,
          decoration: const InputDecoration(labelText: 'Telegram username'),
        ),
        TextField(
          controller: _discord,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Discord user ID'),
        ),
        _messenger('WhatsApp', [
          _try('WA https', () => _launch('https://wa.me/$_number')),
          _try('WA scheme', () => _launch('whatsapp://send?phone=$_number')),
          _try('WA intent', () => _intent('https://wa.me/$_number', whatsapp)),
        ]),
        _messenger('Telegram', [
          _try('TG https user', () => _launch('https://t.me/$_user')),
          _try('TG https phone', () => _launch('https://t.me/+$_number')),
          _try('TG scheme user', () => _launch('tg://resolve?domain=$_user')),
          _try('TG scheme phone', () => _launch('tg://resolve?phone=$_number')),
          _try(
            'TG intent user',
            () => _intent('https://t.me/$_user', telegram),
          ),
          _try(
            'TG intent phone',
            () => _intent('https://t.me/+$_number', telegram),
          ),
        ]),
        _messenger('Signal', [
          _try('Signal https', () => _launch('https://signal.me/#p/+$_number')),
          _try('Signal scheme', () => _launch('sgnl://signal.me/#p/+$_number')),
          _try(
            'Signal intent',
            () => _intent('https://signal.me/#p/+$_number', signal),
          ),
        ]),
        _messenger('Discord', [
          _try(
            'Discord https',
            () => _launch('https://discord.com/users/$_discordId'),
          ),
          _try(
            'Discord scheme',
            () => _launch('discord://-/users/$_discordId'),
          ),
          _try(
            'Discord intent',
            () => _intent('https://discord.com/users/$_discordId', discord),
          ),
        ]),
      ],
    );
  }
}

// Check 4 ---------------------------------------------------------------

class _ListenerCheck extends StatefulWidget {
  const _ListenerCheck();

  @override
  State<_ListenerCheck> createState() => _ListenerCheckState();
}

class _ListenerCheckState extends State<_ListenerCheck>
    with WidgetsBindingObserver {
  String _enabled = '?';
  List<String> _log = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Back from Android's settings: show the new state.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    String enabled;
    List<String> log;
    try {
      enabled = (await checks.listenerEnabled()) ? 'yes' : 'no';
      log = (await checks.listenerLog()).reversed.toList();
    } catch (e) {
      enabled = _error(e);
      log = [];
    }
    if (mounted) {
      setState(() {
        _enabled = enabled;
        _log = log;
      });
    }
  }

  Future<void> _clear() async {
    try {
      await checks.clearListenerLog();
    } catch (e) {
      setState(() => _enabled = _error(e));
    }
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: '4. Notification listener',
      children: [
        Text('Listener enabled: $_enabled'),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            onPressed: () async {
              try {
                await checks.openListenerSettings();
              } catch (e) {
                setState(() => _enabled = _error(e));
              }
            },
            child: const Text('Open listener settings'),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Text('Log, newest first', style: context.text.titleSmall),
            ),
            TextButton(onPressed: _refresh, child: const Text('Refresh')),
            TextButton(onPressed: _clear, child: const Text('Clear')),
          ],
        ),
        _Lines(_log),
      ],
    );
  }
}

// Check 5 ---------------------------------------------------------------

class _IconsCheck extends StatefulWidget {
  const _IconsCheck();

  @override
  State<_IconsCheck> createState() => _IconsCheckState();
}

class _IconsCheckState extends State<_IconsCheck> {
  static const _packages = [
    'com.whatsapp',
    'org.telegram.messenger',
    'org.thoughtcrime.securesms',
    'com.discord',
  ];

  /// Per package: the icon, or an error text, or null for "not installed".
  final Map<String, Object?> _icons = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    for (final p in _packages) {
      try {
        _icons[p] = await checks.appIcon(p);
      } catch (e) {
        _icons[p] = _error(e);
      }
    }
    if (mounted) setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: '5. Messenger app icons',
      children: [
        if (!_loaded) const Text('Loading...'),
        if (_loaded)
          for (final p in _packages)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 48,
                    child: switch (_icons[p]) {
                      final Uint8List bytes => Image.memory(bytes),
                      _ => const SizedBox.shrink(),
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(switch (_icons[p]) {
                      Uint8List _ => p,
                      null => '$p: not installed',
                      final other => '$p: $other',
                    }),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

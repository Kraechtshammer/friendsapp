/// The messengers "Open chat" knows (02-design.md §8, 2026-11-18, "Any
/// messenger, one chat target"). Each person stores one [ChatApp] and one
/// optional chat target: a link, a username or an ID.
///
/// Link formats, bare-target templates and contact MIME types come from
/// research, not from tests on the phone, unless marked tested. The debug
/// page "Chat link test" (Settings › Development) is where they are checked.
library;

enum ChatApp {
  whatsapp,
  signal,
  telegram,
  discord,
  linkedin,
  threema,
  line,
  viber,
  messenger,
  instagram,
  element,
  snapchat,
  teams,
  slack,
  sms;

  /// Android packages, the main one first. Empty for [sms]: the phone's
  /// default SMS app answers `smsto:` and Kept. does not name it.
  List<String> get packages => switch (this) {
    whatsapp => const ['com.whatsapp', 'com.whatsapp.w4b'],
    signal => const ['org.thoughtcrime.securesms'],
    telegram => const ['org.telegram.messenger', 'org.telegram.messenger.web'],
    discord => const ['com.discord'],
    linkedin => const ['com.linkedin.android'],
    threema => const [
      'ch.threema.app',
      'ch.threema.app.libre',
      'ch.threema.app.work',
    ],
    line => const ['jp.naver.line.android'],
    viber => const ['com.viber.voip'],
    messenger => const ['com.facebook.orca'],
    instagram => const ['com.instagram.android'],
    element => const ['im.vector.app'],
    snapchat => const ['com.snapchat.android'],
    teams => const ['com.microsoft.teams'],
    slack => const ['com.Slack'],
    sms => const [],
  };

  /// Web hosts whose links belong to this app, to recognise a chat link
  /// in a contact's Website field. A subdomain matches too.
  List<String> get hosts => switch (this) {
    whatsapp => const ['wa.me', 'whatsapp.com'],
    signal => const ['signal.me', 'signal.group'],
    telegram => const ['t.me', 'telegram.me'],
    discord => const ['discord.com', 'discordapp.com'],
    linkedin => const ['linkedin.com', 'lnkd.in'],
    threema => const ['threema.id'],
    line => const ['line.me'],
    viber => const ['viber.com'],
    messenger => const ['m.me', 'messenger.com'],
    instagram => const ['instagram.com', 'ig.me'],
    element => const ['matrix.to'],
    snapchat => const ['snapchat.com'],
    teams => const ['teams.microsoft.com', 'teams.live.com'],
    slack => const ['slack.com'],
    sms => const [],
  };

  /// Custom link schemes of this app; a link with one goes to this app.
  List<String> get schemes => switch (this) {
    whatsapp => const ['whatsapp'],
    signal => const ['sgnl'],
    telegram => const ['tg'],
    discord => const ['discord'],
    linkedin => const ['linkedin'],
    threema => const ['threema'],
    line => const ['line'],
    viber => const ['viber'],
    messenger => const ['fb-messenger'],
    instagram => const ['instagram'],
    element => const ['matrix', 'element'],
    snapchat => const ['snapchat'],
    teams => const ['msteams'],
    slack => const ['slack'],
    sms => const ['smsto', 'sms'],
  };

  /// The MIME type of the entry this app writes into a linked contact,
  /// when it writes one. WhatsApp, Signal and Telegram were seen on the
  /// developer's phone (2026-11-18); Threema and Viber are unverified.
  String? get contactMimeType => switch (this) {
    whatsapp => 'vnd.android.cursor.item/vnd.com.whatsapp.profile',
    signal => 'vnd.android.cursor.item/vnd.org.thoughtcrime.securesms.contact',
    telegram =>
      'vnd.android.cursor.item/vnd.org.telegram.messenger.android.profile',
    threema => 'vnd.android.cursor.item/vnd.ch.threema.app.profile',
    viber => 'vnd.android.cursor.item/vnd.com.viber.voip.viber_number_message',
    _ => null,
  };

  /// True if a bare username or ID (not a link) can be turned into a link
  /// for this app. The edit page uses it for the hint under the field.
  bool get takesBareTarget => switch (this) {
    signal || slack => false,
    _ => true,
  };

  /// True if [link] leads to the person's profile rather than the chat
  /// (one more tap there). Snapchat has no chat link at all; Line, Discord
  /// user and Matrix user links open the profile (02-design.md §8).
  bool opensProfile(String link) => switch (this) {
    snapchat => true,
    line => link.contains('/ti/p/'),
    discord => link.contains('/users/'),
    element => link.contains('#/@'),
    _ => false,
  };

  /// The link for a bare username or ID, or null if this app has no
  /// known link for one (then only a full link helps).
  String? bareTargetLink(String target) {
    var t = target.trim();
    if (t.isEmpty) return null;
    final digits = _digitsOnly(t);
    switch (this) {
      case whatsapp:
        return digits == null ? null : 'https://wa.me/$digits';
      case telegram:
        if (t.startsWith('@')) t = t.substring(1);
        return _plainName(t) ? 'https://t.me/$t' : null;
      case discord:
        // A user ID: digits only. Opens the profile, not the chat.
        return digits != null && digits == t
            ? 'https://discord.com/users/$t'
            : null;
      case linkedin:
        // The profile name from the address bar. The compose link opens a
        // new message to them; tested in the browser by the developer
        // (2026-11-18), not yet in the LinkedIn app.
        return _plainName(t)
            ? 'https://www.linkedin.com/messaging/compose/?recipient=$t'
            : null;
      case threema:
        final id = t.toUpperCase();
        return RegExp(r'^[0-9A-Z*]{8}$').hasMatch(id)
            ? 'threema://compose?id=$id'
            : null;
      case line:
        if (t.startsWith('@') || t.startsWith('~')) t = t.substring(1);
        return _plainName(t) ? 'https://line.me/ti/p/~$t' : null;
      case viber:
        return digits == null ? null : 'viber://chat?number=%2B$digits';
      case messenger:
        return _plainName(t) ? 'https://m.me/$t' : null;
      case instagram:
        if (t.startsWith('@')) t = t.substring(1);
        return _plainName(t) ? 'https://ig.me/m/$t' : null;
      case element:
        return RegExp(r'^@[^:\s]+:[^\s]+$').hasMatch(t)
            ? 'https://matrix.to/#/$t'
            : null;
      case snapchat:
        return _plainName(t) ? 'https://www.snapchat.com/add/$t' : null;
      case teams:
        return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)
            ? 'https://teams.microsoft.com/l/chat/0/0?users=$t'
            : null;
      case sms:
        return digits == null ? null : 'smsto:+$digits';
      case signal:
      case slack:
        return null;
    }
  }

  /// The link built from the person's phone number, or null if this app
  /// does not open a chat by number.
  String? phoneLink(String? phone) {
    final digits = _digitsOnly(phone);
    if (digits == null) return null;
    return switch (this) {
      whatsapp => 'https://wa.me/$digits',
      signal => 'https://signal.me/#p/+$digits',
      telegram => 'https://t.me/+$digits',
      viber => 'viber://chat?number=%2B$digits',
      sms => 'smsto:+$digits',
      _ => null,
    };
  }

  /// The app a link belongs to, by scheme or host; null if none.
  static ChatApp? forLink(String link) {
    final uri = _asUri(link);
    if (uri == null) return null;
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();
    for (final app in values) {
      if (app.schemes.contains(scheme)) return app;
      if ((scheme == 'http' || scheme == 'https') &&
          app.hosts.any((h) => host == h || host.endsWith('.$h'))) {
        return app;
      }
    }
    return null;
  }

  /// The chat target as a link this app can open, or null. A full link is
  /// taken as it is (one without a scheme but with this app's host gets
  /// `https://`); a bare username or ID goes through [bareTargetLink].
  String? targetLink(String? target) {
    final t = target?.trim() ?? '';
    if (t.isEmpty) return null;
    if (_hasScheme(t)) return _tidy(t);
    final withHttps = 'https://$t';
    if (forLink(withHttps) == this) return _tidy(withHttps);
    return bareTargetLink(t);
  }

  /// Small fixes to a pasted link. Discord: a message link
  /// (`/channels/@me/<chat>/<message>`, from "Copy Message Link") becomes
  /// the link of the chat, which the developer tested (2026-11-18).
  String _tidy(String link) {
    if (this != discord) return link;
    final m = RegExp(
      r'^(https://(?:[a-z]+\.)?discord(?:app)?\.com/channels/@me/\d+)/\d+/?$',
    ).firstMatch(link);
    return m == null ? link : m.group(1)!;
  }
}

/// Where "Open chat" should try to go, in order (02-design.md §8): the chat
/// target, then the phone number. The app's entry in the linked contact
/// and the app's main screen are tried by the caller around this list.
List<String> chatLinks(ChatApp app, {String? target, String? phone}) => [
  ?app.targetLink(target),
  ?app.phoneLink(phone),
];

bool _hasScheme(String s) =>
    RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*:').hasMatch(s) &&
    // "anna:matrix.org" style text is not a scheme; a scheme has no dot
    // before the colon and is followed by // or is a known scheme.
    (s.contains('://') || RegExp(r'^(smsto|sms|tel|mailto):').hasMatch(s));

Uri? _asUri(String link) {
  final t = link.trim();
  if (!_hasScheme(t)) return null;
  return Uri.tryParse(t);
}

bool _plainName(String s) => RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(s);

/// The digits of a phone-like text, or null if it is not phone-like.
String? _digitsOnly(String? s) {
  final t = s?.trim();
  if (t == null || t.isEmpty) return null;
  if (!RegExp(r'^\+?[0-9 ()/.-]+$').hasMatch(t)) return null;
  final d = t.replaceAll(RegExp(r'\D'), '');
  return d.isEmpty ? null : d;
}

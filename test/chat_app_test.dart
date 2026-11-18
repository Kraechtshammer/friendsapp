import 'package:flutter_test/flutter_test.dart';
import 'package:kept/domain/chat_app.dart';

void main() {
  group('targetLink', () {
    test('a full link is kept as it is', () {
      const dm = 'https://discord.com/channels/@me/123456';
      expect(ChatApp.discord.targetLink(dm), dm);
      expect(
        ChatApp.signal.targetLink(' https://signal.me/#eu/abc '),
        'https://signal.me/#eu/abc',
      );
      expect(
        ChatApp.threema.targetLink('threema://compose?id=ABCD1234'),
        'threema://compose?id=ABCD1234',
      );
    });

    test('a link without scheme but with the app host gets https', () {
      expect(ChatApp.telegram.targetLink('t.me/anna'), 'https://t.me/anna');
    });

    test('bare usernames and IDs per app', () {
      expect(ChatApp.telegram.targetLink('@anna'), 'https://t.me/anna');
      expect(
        ChatApp.discord.targetLink('80351110224678912'),
        'https://discord.com/users/80351110224678912',
      );
      expect(
        ChatApp.threema.targetLink('abcd1234'),
        'threema://compose?id=ABCD1234',
      );
      expect(
        ChatApp.linkedin.targetLink('anna-meier'),
        'https://www.linkedin.com/messaging/compose/?recipient=anna-meier',
      );
      expect(
        ChatApp.element.targetLink('@anna:matrix.org'),
        'https://matrix.to/#/@anna:matrix.org',
      );
      expect(
        ChatApp.teams.targetLink('anna@firma.de'),
        'https://teams.microsoft.com/l/chat/0/0?users=anna@firma.de',
      );
      expect(
        ChatApp.whatsapp.targetLink('+49 170 1234567'),
        'https://wa.me/491701234567',
      );
      expect(ChatApp.sms.targetLink('+49 170 1234567'), 'smsto:+491701234567');
    });

    test('apps without a bare-target link need a full link', () {
      expect(ChatApp.signal.targetLink('anna.42'), isNull);
      expect(ChatApp.slack.targetLink('U123'), isNull);
      expect(ChatApp.signal.takesBareTarget, isFalse);
      expect(ChatApp.telegram.takesBareTarget, isTrue);
      // Agrees with bareTargetLink: every app but Signal and Slack has a
      // link for some bare username or ID.
      const samples = {
        ChatApp.whatsapp: '+4917',
        ChatApp.telegram: 'anna',
        ChatApp.discord: '123',
        ChatApp.linkedin: 'anna',
        ChatApp.threema: 'ABCD1234',
        ChatApp.line: 'anna',
        ChatApp.viber: '+4917',
        ChatApp.messenger: 'anna',
        ChatApp.instagram: 'anna',
        ChatApp.element: '@anna:matrix.org',
        ChatApp.snapchat: 'anna',
        ChatApp.teams: 'anna@firma.de',
        ChatApp.sms: '+4917',
      };
      for (final app in ChatApp.values) {
        expect(app.takesBareTarget, samples.containsKey(app), reason: app.name);
        final sample = samples[app];
        if (sample != null) {
          expect(app.bareTargetLink(sample), isNotNull, reason: app.name);
        }
      }
    });

    test('nonsense gives no link', () {
      expect(ChatApp.telegram.targetLink(''), isNull);
      expect(ChatApp.telegram.targetLink('two words'), isNull);
      expect(ChatApp.discord.targetLink('anna'), isNull);
      expect(ChatApp.threema.targetLink('short'), isNull);
    });
  });

  test('phone links only for apps that open a chat by number', () {
    expect(
      ChatApp.whatsapp.phoneLink('+49 170 1234567'),
      'https://wa.me/491701234567',
    );
    expect(
      ChatApp.signal.phoneLink('+491701234567'),
      'https://signal.me/#p/+491701234567',
    );
    expect(
      ChatApp.telegram.phoneLink('+491701234567'),
      'https://t.me/+491701234567',
    );
    expect(ChatApp.discord.phoneLink('+491701234567'), isNull);
    expect(ChatApp.whatsapp.phoneLink(null), isNull);
  });

  test('forLink finds the app by host or scheme', () {
    expect(ChatApp.forLink('https://t.me/anna'), ChatApp.telegram);
    expect(ChatApp.forLink('https://www.linkedin.com/in/x'), ChatApp.linkedin);
    expect(
      ChatApp.forLink('https://myteam.slack.com/archives/D1'),
      ChatApp.slack,
    );
    expect(ChatApp.forLink('tg://resolve?domain=anna'), ChatApp.telegram);
    expect(ChatApp.forLink('smsto:+4917'), ChatApp.sms);
    expect(ChatApp.forLink('https://example.com'), isNull);
    expect(ChatApp.forLink('not a link'), isNull);
  });

  test('chatLinks tries the target, then the phone', () {
    expect(chatLinks(ChatApp.telegram, target: '@anna', phone: '+4917'), [
      'https://t.me/anna',
      'https://t.me/+4917',
    ]);
    expect(chatLinks(ChatApp.discord, phone: '+4917'), isEmpty);
  });

  test('every app but sms has a package, and stored names stay', () {
    for (final app in ChatApp.values) {
      expect(app.packages.isEmpty, app == ChatApp.sms, reason: app.name);
    }
    // Schema 5 stored these ChatApp names; schema 6 reads them as ChatApp.
    for (final old in ['whatsapp', 'telegram', 'signal', 'discord']) {
      expect(ChatApp.values.byName(old).name, old);
    }
  });
}

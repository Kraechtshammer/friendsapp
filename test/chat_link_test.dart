import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/chat_link.dart';
import 'package:kept/domain/person.dart';

Person person({
  Messenger? messenger,
  String? phone,
  String? telegram,
  String? signal,
  String? discord,
}) => Person(
  id: 'p',
  name: 'Tom',
  closeness: Closeness.close,
  reconnecting: false,
  mainMessenger: messenger,
  phone: phone,
  telegramUsername: telegram,
  signalLink: signal,
  discordUserId: discord,
  avatarShape: AvatarShape.values.first,
  avatarColor: AvatarColor.values.first,
  notes: '',
  createdAt: DateTime(2026),
);

void main() {
  test('no main messenger gives no link', () {
    expect(chatLink(person(phone: '+491701234567')), isNull);
  });

  test('whatsapp uses the number without the plus', () {
    expect(
      chatLink(person(messenger: Messenger.whatsapp, phone: '+49 170 1234567')),
      const ChatLink(
        package: 'com.whatsapp',
        uri: 'https://wa.me/491701234567',
      ),
    );
    expect(
      chatLink(person(messenger: Messenger.whatsapp)),
      const ChatLink(package: 'com.whatsapp'),
    );
  });

  test('telegram prefers the user name, then the number', () {
    const pkg = 'org.telegram.messenger';
    expect(
      chatLink(
        person(messenger: Messenger.telegram, telegram: '@tom', phone: '+4917'),
      ),
      const ChatLink(package: pkg, uri: 'https://t.me/tom'),
    );
    expect(
      chatLink(person(messenger: Messenger.telegram, phone: '+491701234567')),
      const ChatLink(package: pkg, uri: 'https://t.me/+491701234567'),
    );
    expect(
      chatLink(person(messenger: Messenger.telegram)),
      const ChatLink(package: pkg),
    );
  });

  test('signal prefers the stored link, then the number', () {
    const pkg = 'org.thoughtcrime.securesms';
    expect(
      chatLink(
        person(
          messenger: Messenger.signal,
          signal: 'https://signal.me/#eu/abc',
          phone: '+4917',
        ),
      ),
      const ChatLink(package: pkg, uri: 'https://signal.me/#eu/abc'),
    );
    expect(
      chatLink(person(messenger: Messenger.signal, phone: '+491701234567')),
      const ChatLink(package: pkg, uri: 'https://signal.me/#p/+491701234567'),
    );
    expect(
      chatLink(person(messenger: Messenger.signal)),
      const ChatLink(package: pkg),
    );
  });

  test('discord needs the user id', () {
    expect(
      chatLink(person(messenger: Messenger.discord, discord: '123456')),
      const ChatLink(
        package: 'com.discord',
        uri: 'https://discord.com/users/123456',
      ),
    );
    expect(
      chatLink(person(messenger: Messenger.discord)),
      const ChatLink(package: 'com.discord'),
    );
  });
}

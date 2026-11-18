import 'package:flutter_test/flutter_test.dart';
import 'package:kept/domain/chat_app.dart';
import 'package:kept/platform/installed_apps.dart';

void main() {
  const some = InstalledChatApps({
    'org.thoughtcrime.securesms',
    'com.whatsapp.w4b',
  }, sms: true);

  test('has and packageFor', () {
    expect(some.has(ChatApp.signal), isTrue);
    expect(some.has(ChatApp.whatsapp), isTrue);
    expect(some.has(ChatApp.telegram), isFalse);
    expect(some.has(ChatApp.sms), isTrue);
    expect(some.packageFor(ChatApp.whatsapp), 'com.whatsapp.w4b');
    expect(some.packageFor(ChatApp.telegram), 'org.telegram.messenger');
    expect(some.packageFor(ChatApp.sms), isNull);
  });

  test('choices: installed in list order, plus the current one', () {
    expect(some.choices(null), [ChatApp.whatsapp, ChatApp.signal, ChatApp.sms]);
    expect(some.choices(ChatApp.discord), [
      ChatApp.whatsapp,
      ChatApp.signal,
      ChatApp.discord,
      ChatApp.sms,
    ]);
    expect(InstalledChatApps.all.choices(null), ChatApp.values);
  });
}

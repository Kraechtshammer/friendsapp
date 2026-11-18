import 'package:flutter_test/flutter_test.dart';
import 'package:kept/domain/chat_app.dart';
import 'package:kept/domain/contact_route.dart';

ContactEntry entry(String id, String mime, [String? value]) =>
    ContactEntry(id: id, mimeType: mime, value: value);

void main() {
  const web = ContactEntry.websiteMimeType;

  test('messenger entries and chat links from the Website field', () {
    final routes = contactRoutes([
      entry('1', 'vnd.android.cursor.item/vnd.com.whatsapp.voip.call'),
      entry('2', 'vnd.android.cursor.item/vnd.com.whatsapp.profile'),
      entry('3', web, 'https://example.org'),
      entry('4', web, 't.me/anna'),
      entry(
        '5',
        'vnd.android.cursor.item/vnd.org.telegram.messenger.android.profile',
      ),
      entry('6', web, 'https://discord.com/channels/@me/123'),
      entry(
        '7',
        'vnd.android.cursor.item/com.google.android.apps.tachyon.phone.meet',
      ),
    ]);
    expect(routes, [
      ContactRoute(ChatApp.whatsapp, entry: entry('2', 'x')),
      ContactRoute(ChatApp.telegram, entry: entry('5', 'x')),
      const ContactRoute(ChatApp.telegram, link: 'https://t.me/anna'),
      const ContactRoute(
        ChatApp.discord,
        link: 'https://discord.com/channels/@me/123',
      ),
    ]);
  });

  test('one entry per app, nothing from an empty contact', () {
    const signal =
        'vnd.android.cursor.item/vnd.org.thoughtcrime.securesms.contact';
    expect(contactRoutes([entry('1', signal), entry('2', signal)]), [
      ContactRoute(ChatApp.signal, entry: entry('1', signal)),
    ]);
    expect(contactRoutes(const []), isEmpty);
  });
}

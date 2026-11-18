import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/domain/picture_chooser.dart';

Person person(String name, {String? photo, String? nickname}) => Person(
  id: name,
  name: name,
  nickname: nickname,
  photo: photo,
  closeness: Closeness.close,
  avatarShape: AvatarShape.squircle,
  avatarColor: AvatarColor.coral,
  chatApp: ChatApp.whatsapp,
  reconnecting: false,
  notes: '',
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  test('people without a picture come first, each group A to Z', () {
    final order = pictureChooserOrder([
      person('Zoe', photo: 'z.jpg'),
      person('tom'),
      person('Anna', photo: 'a.jpg'),
      person('Ben'),
    ]);
    expect([for (final p in order) p.name], ['Ben', 'tom', 'Anna', 'Zoe']);
  });

  test('the search matches names and nicknames, ignoring case', () {
    final people = [
      person('Tom Berger'),
      person('Anna', nickname: 'Tommy', photo: 'a.jpg'),
      person('Ben'),
    ];
    expect(
      [for (final p in pictureChooserOrder(people, query: ' TOM ')) p.name],
      ['Tom Berger', 'Anna'],
    );
    expect(pictureChooserOrder(people, query: 'xyz'), isEmpty);
  });

  test('withoutPicture counts people with no photo', () {
    expect(
      withoutPicture([person('A'), person('B', photo: 'b.jpg'), person('C')]),
      2,
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:kept/domain/avatar_pick.dart';
import 'package:kept/domain/person.dart';

void main() {
  test('the tie order holds every pair once', () {
    expect(avatarOrder.toSet(), hasLength(24));
  });

  test('the first 24 picks are all different', () {
    final used = <Avatar>[];
    for (var i = 0; i < 24; i++) {
      used.add(pickAvatar(used));
    }
    expect(used.toSet(), hasLength(24));
  });

  test('consecutive picks differ in shape and colour', () {
    final used = <Avatar>[];
    for (var i = 0; i < 30; i++) {
      final next = pickAvatar(used);
      if (used.isNotEmpty) {
        expect(next.shape, isNot(used.last.shape), reason: 'pick $i');
        expect(next.color, isNot(used.last.color), reason: 'pick $i');
      }
      used.add(next);
    }
  });

  test('takes the least used pair, then the least used colour', () {
    // Everything used once except the pair (arch, pink).
    final used = [
      for (final a in avatarOrder)
        if (a != (shape: AvatarShape.arch, color: AvatarColor.pink)) a,
    ];
    expect(pickAvatar(used), (
      shape: AvatarShape.arch,
      color: AvatarColor.pink,
    ));

    // Coral is taken by everyone; a free pair with another colour wins.
    expect(
      pickAvatar([
        (shape: AvatarShape.scallop, color: AvatarColor.coral),
        (shape: AvatarShape.squircle, color: AvatarColor.coral),
      ]).color,
      isNot(AvatarColor.coral),
    );
  });

  test('is deterministic', () {
    final used = [
      (shape: AvatarShape.leaf, color: AvatarColor.sky),
      (shape: AvatarShape.scallop, color: AvatarColor.coral),
    ];
    expect(pickAvatar(used), pickAvatar(used.reversed));
  });
}

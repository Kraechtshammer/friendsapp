import 'package:flutter_test/flutter_test.dart';
import 'package:kept/domain/display_name.dart';

PersonNameInput p(String id, String name, [String? nick]) =>
    (id: id, name: name, nickname: nick);

void main() {
  group('displayNames', () {
    test('unique first name is shown alone', () {
      final r = displayNames([
        p('1', 'Max Müller'),
        p('2', 'Anna-Lena von Berg'),
      ]);
      expect(r, {'1': 'Max', '2': 'Anna-Lena'});
    });

    test('shared first name gets the last initial (developer example)', () {
      final r = displayNames([p('1', 'Max Müller'), p('2', 'Max Friedrichs')]);
      expect(r['1'], 'Max M');
      expect(r['2'], 'Max F');
    });

    test('same first name and initial falls back to full name', () {
      final r = displayNames([
        p('1', 'Max Müller'),
        p('2', 'Max Meier'),
        p('3', 'Max Friedrichs'),
      ]);
      expect(r, {'1': 'Max Müller', '2': 'Max Meier', '3': 'Max F'});
    });

    test('identical full names stay identical', () {
      final r = displayNames([p('1', 'Max Müller'), p('2', 'Max Müller')]);
      expect(r, {'1': 'Max Müller', '2': 'Max Müller'});
    });

    test('one-word person next to a full name keeps the bare first name', () {
      final r = displayNames([p('1', 'Max'), p('2', 'Max Müller')]);
      expect(r, {'1': 'Max', '2': 'Max M'});
    });

    test('two one-word people with the same name show the full name', () {
      final r = displayNames([p('1', 'Tom'), p('2', 'tom')]);
      expect(r, {'1': 'Tom', '2': 'tom'});
    });

    test('comparison ignores case and spaces, output keeps spelling', () {
      final r = displayNames([
        p('1', ' max  müller '),
        p('2', 'MAX Friedrichs'),
      ]);
      expect(r['1'], 'max M');
      expect(r['2'], 'MAX F');
    });

    test('lower-case particles: last word is used', () {
      final r = displayNames([p('1', 'Anna von Berg'), p('2', 'Anna Schmidt')]);
      expect(r['1'], 'Anna B');
      expect(r['2'], 'Anna S');
    });

    test('umlaut initials are upper-cased', () {
      final r = displayNames([p('1', 'Max österreicher'), p('2', 'Max Fuchs')]);
      expect(r['1'], 'Max Ö');
    });

    test('nickname wins', () {
      final r = displayNames([
        p('1', 'Max Müller', 'Maxi'),
        p('2', 'Max Fuchs'),
      ]);
      expect(r, {'1': 'Maxi', '2': 'Max'});
    });

    test('blank nickname counts as none', () {
      final r = displayNames([
        p('1', 'Max Müller', '  '),
        p('2', 'Anna Berg', ''),
      ]);
      expect(r, {'1': 'Max', '2': 'Anna'});
    });

    test('equal nicknames get the last initial, then the full name', () {
      final r = displayNames([
        p('1', 'Max Müller', 'Mo'),
        p('2', 'Eva Fuchs', 'mo'),
        p('3', 'Tim Meier', 'Mo'),
      ]);
      expect(r, {'1': 'Max Müller', '2': 'mo F', '3': 'Tim Meier'});
    });

    test('equal nicknames with different initials', () {
      final r = displayNames([
        p('1', 'Max Müller', 'Mo'),
        p('2', 'Eva Fuchs', 'Mo'),
      ]);
      expect(r, {'1': 'Mo M', '2': 'Mo F'});
    });

    test('nickname person does not block the first name for others', () {
      final r = displayNames([
        p('1', 'Max Müller', 'Maxi'),
        p('2', 'Max Fuchs'),
      ]);
      expect(r['2'], 'Max');
    });

    test('empty input', () {
      expect(displayNames([]), isEmpty);
    });
  });

  group('initialOf', () {
    test('upper-cases the first letter', () {
      expect(initialOf('max M'), 'M');
      expect(initialOf('Ökö'), 'Ö');
    });
    test('keeps an emoji whole', () {
      expect(initialOf('😀 Tom'), '😀');
    });
    test('empty text', () {
      expect(initialOf('  '), '');
    });
  });
}

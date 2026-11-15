import 'package:flutter_test/flutter_test.dart';
import 'package:kept/domain/phone_number.dart';

void main() {
  test('keeps a leading plus and digits', () {
    expect(normalisePhone('+49 (170) 123-4567'), '+491701234567');
  });

  test('00 becomes plus', () {
    expect(normalisePhone('0043 660 1234567'), '+436601234567');
  });

  test('a single 0 gets the default country code', () {
    expect(normalisePhone('0170 1234567'), '+491701234567');
    expect(
      normalisePhone('0170 1234567', defaultCountryCode: '41'),
      '+411701234567',
    );
  });

  test('other numbers keep their digits', () {
    expect(normalisePhone('170 1234567'), '1701234567');
  });

  test('too short is null', () {
    expect(normalisePhone('12345'), isNull);
    expect(normalisePhone('+1 23 4'), isNull);
    expect(normalisePhone(''), isNull);
  });
}

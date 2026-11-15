/// Cleans a phone number from the contacts into the form the chat apps
/// want: digits with a leading `+`. A number with one leading `0` is taken
/// as national and gets [defaultCountryCode]. Returns null if fewer than
/// six digits are left.
String? normalisePhone(String raw, {String defaultCountryCode = '49'}) {
  final trimmed = raw.trim();
  final digits = trimmed.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 6) {
    return null;
  }
  if (trimmed.startsWith('+')) {
    return '+$digits';
  }
  if (digits.startsWith('00')) {
    return '+${digits.substring(2)}';
  }
  if (digits.startsWith('0')) {
    return '+$defaultCountryCode${digits.substring(1)}';
  }
  return digits;
}

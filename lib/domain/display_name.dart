/// Short display names for a list of people.
///
/// The developer has many people who share a first name, so "Max" alone is
/// not enough, but the full name is too long for most places. The rules are
/// in docs/02-design.md §8 (row "Short display names").
library;

typedef PersonNameInput = ({String id, String name, String? nickname});

/// Returns person id -> short display name.
///
/// Rules, in order:
/// 1. A nickname wins. Two equal nicknames are treated like a shared first
///    name (rule 3 and 4 below, with the nickname as the first name).
/// 2. A first name that nobody else uses is shown alone: "Max".
/// 3. A shared first name gets the initial of the last name, no dot:
///    "Max M", "Max F".
/// 4. If that still collides, the full name is shown.
/// 5. Identical full names stay identical: nothing more can be done.
///
/// The first name is the first word of `name`. The last name is the last
/// word, and only exists when `name` has two or more words. A one-word
/// person has no initial, so next to "Max Müller" they stay "Max" while
/// "Max Müller" becomes "Max M". Both labels differ, so nobody is hidden.
/// Comparing ignores case and surrounding spaces; the output keeps the
/// original spelling. A blank nickname counts as none. Only people who are
/// shown by their first name take part in first-name collisions: someone
/// shown by a nickname does not block "Max" for another person.
Map<String, String> displayNames(Iterable<PersonNameInput> people) {
  final parsed = [for (final p in people) _Parsed(p)];
  final result = <String, String>{};

  final withNick = parsed.where((p) => p.nickname != null);
  final withoutNick = parsed.where((p) => p.nickname == null);

  _resolve(withNick, (p) => p.nickname!, result, soleLabel: (p) => p.nickname!);
  _resolve(withoutNick, (p) => p.first, result, soleLabel: (p) => p.first);
  return result;
}

/// Groups by the lower-cased [head], then applies rules 2 to 4.
void _resolve(
  Iterable<_Parsed> people,
  String Function(_Parsed) head,
  Map<String, String> out, {
  required String Function(_Parsed) soleLabel,
}) {
  final groups = <String, List<_Parsed>>{};
  for (final p in people) {
    groups.putIfAbsent(head(p).toLowerCase(), () => []).add(p);
  }
  for (final group in groups.values) {
    if (group.length == 1) {
      out[group.single.id] = soleLabel(group.single);
      continue;
    }
    String label(_Parsed p) {
      final initial = p.lastInitial;
      return initial == null ? head(p) : '${head(p)} $initial';
    }

    final counts = <String, int>{};
    for (final p in group) {
      counts.update(label(p).toLowerCase(), (n) => n + 1, ifAbsent: () => 1);
    }
    for (final p in group) {
      out[p.id] = counts[label(p).toLowerCase()] == 1 ? label(p) : p.full;
    }
  }
}

/// The letter shown in an avatar: the first character, upper-cased.
///
/// Works on code points, so umlauts and emoji are not cut in half. Joined
/// emoji sequences are not handled. Returns an empty string for empty text.
String initialOf(String displayName) {
  final text = displayName.trim();
  if (text.isEmpty) return '';
  return String.fromCharCode(text.runes.first).toUpperCase();
}

class _Parsed {
  _Parsed(PersonNameInput p)
    : id = p.id,
      full = p.name.trim(),
      nickname = _blankToNull(p.nickname) {
    final words = full.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final list = words.toList();
    first = list.isEmpty ? '' : list.first;
    last = list.length >= 2 ? list.last : null;
  }

  final String id;
  final String full;
  final String? nickname;
  late final String first;
  late final String? last;

  /// Upper-cased first letter of the last word as written ("von Berg" -> "B").
  String? get lastInitial => last == null ? null : initialOf(last!);

  static String? _blankToNull(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}

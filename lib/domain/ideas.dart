import '../data/database.dart';
import 'idea.dart';
import 'intention.dart';
import 'pick_order.dart';

/// Rules for ideas per person (F11) as pure functions.

/// Shared text split into a link and the rest (sharing in): the first
/// http(s) URL becomes the link, the text around it the note. Plain text
/// has no link.
class SplitText {
  const SplitText(this.text, this.link);

  final String text;
  final String? link;

  @override
  bool operator ==(Object other) =>
      other is SplitText && other.text == text && other.link == link;

  @override
  int get hashCode => Object.hash(text, link);

  @override
  String toString() => 'SplitText($text, $link)';
}

final _url = RegExp(r'https?://[^\s<>"]+', caseSensitive: false);

/// Closing marks that end a sentence more often than they end a URL.
const _trailing = '.,;:!?)]}\'"';

/// Splits [shared] into the first URL and the rest. The rest has its
/// spaces tidied; a URL in brackets or at the end of a sentence loses the
/// closing mark.
SplitText splitSharedText(String shared) {
  final match = _url.firstMatch(shared);
  if (match == null) return SplitText(_tidy(shared), null);
  var link = match.group(0)!;
  var end = match.end;
  while (link.isNotEmpty && _trailing.contains(link[link.length - 1])) {
    // Keep a bracket that the URL itself opened, as in Wikipedia links.
    final last = link[link.length - 1];
    if (last == ')' && link.contains('(')) break;
    link = link.substring(0, link.length - 1);
    end--;
  }
  final rest = shared.substring(0, match.start) + shared.substring(end);
  return SplitText(_tidy(rest), link);
}

String _tidy(String text) => text
    .split('\n')
    .map((l) => l.replaceAll(RegExp(r'[ \t]+'), ' ').trim())
    .where((l) => l.isNotEmpty)
    .join('\n')
    // A dash or colon left alone after the URL went, as in "Title - URL".
    .replaceAll(RegExp(r'\s*[-–:|]\s*$'), '')
    .trim();

/// The open ideas of [kind] among [ideas], newest first.
List<Idea> openIdeas(Iterable<Idea> ideas, IdeaKind kind) =>
    [
      for (final i in ideas)
        if (i.doneAt == null && i.kind == kind) i,
    ]..sort((a, b) {
      final c = b.createdAt.compareTo(a.createdAt);
      return c != 0 ? c : b.id.compareTo(a.id);
    });

/// Which kind of idea helps with [pick]: something to do for a
/// meet-up, a game and a due plan; something to talk about for writing and
/// calling, the reconnect person and the gentle hint. Null for a birthday
/// and an owed reply, which have their own reason.
IdeaKind? ideaKindFor(Pick pick) => switch (pick) {
  PlanPick() => IdeaKind.toDo,
  IntentionPick(:final intention) => switch (intention.kind) {
    IntentionKind.meet || IntentionKind.game => IdeaKind.toDo,
    IntentionKind.write || IntentionKind.call => IdeaKind.toTalk,
  },
  ReconnectPick() || HintPick() => IdeaKind.toTalk,
  BirthdayPick() || ReplyPick() => null,
};

/// The idea to show on [pick]: the newest open one of the kind that helps;
/// null when there is none.
Idea? ideaForPick(Pick pick, Iterable<Idea> ideas) {
  final kind = ideaKindFor(pick);
  if (kind == null) return null;
  final open = openIdeas(
    ideas.where((i) => i.personId == pick.person.id),
    kind,
  );
  return open.isEmpty ? null : open.first;
}

/// A short form of [link] for a small row: no scheme, no "www.", no
/// trailing slash.
String shortLink(String link) => link
    .trim()
    .replaceFirst(RegExp(r'^https?://', caseSensitive: false), '')
    .replaceFirst(RegExp(r'^www\.', caseSensitive: false), '')
    .replaceFirst(RegExp(r'/$'), '');

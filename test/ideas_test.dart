import 'package:flutter_test/flutter_test.dart';
import 'package:kept/data/database.dart';
import 'package:kept/domain/idea.dart';
import 'package:kept/domain/ideas.dart';
import 'package:kept/domain/intention.dart';
import 'package:kept/domain/person.dart';
import 'package:kept/domain/pick_order.dart';
import 'package:kept/platform/link_opener.dart';
import 'package:kept/platform/share_receiver.dart';

/// The pure rules of M10: splitting shared text, which idea helps a pick,
/// and reading the channel's map.
void main() {
  group('splitSharedText', () {
    test('plain text has no link', () {
      expect(
        splitSharedText('  bouldering   hall\n\n in Altona '),
        const SplitText('bouldering hall\nin Altona', null),
      );
    });

    test('a bare URL is all link', () {
      expect(
        splitSharedText('https://example.org/a?b=1'),
        const SplitText('', 'https://example.org/a?b=1'),
      );
    });

    test('the URL goes to the link, the rest to the text', () {
      expect(
        splitSharedText('Look at this https://example.org/hall nice'),
        const SplitText('Look at this nice', 'https://example.org/hall'),
      );
      expect(
        splitSharedText('Boulder hall\nhttps://example.org/hall'),
        const SplitText('Boulder hall', 'https://example.org/hall'),
      );
    });

    test('a title with a dash before the URL loses the dash', () {
      expect(
        splitSharedText('Boulder hall - http://example.org'),
        const SplitText('Boulder hall', 'http://example.org'),
      );
    });

    test('a closing mark after the URL stays in the text side', () {
      expect(
        splitSharedText('See (https://example.org/x).'),
        const SplitText('See ().', 'https://example.org/x'),
      );
      expect(
        splitSharedText('Wiki https://en.wikipedia.org/wiki/A_(b)'),
        const SplitText('Wiki', 'https://en.wikipedia.org/wiki/A_(b)'),
      );
    });

    test('only the first URL becomes the link', () {
      final split = splitSharedText('https://a.example https://b.example');
      expect(split.link, 'https://a.example');
      expect(split.text, 'https://b.example');
    });
  });

  test('shortLink drops the scheme, www and the last slash', () {
    expect(shortLink('https://www.example.org/hall/'), 'example.org/hall');
    expect(shortLink('example.org'), 'example.org');
  });

  test('withScheme adds https only where there is none', () {
    expect(withScheme('example.org'), 'https://example.org');
    expect(withScheme('http://example.org'), 'http://example.org');
  });

  group('ideaForPick', () {
    final created = DateTime(2026, 11, 1);
    final tom = Person(
      id: 'tom',
      name: 'Tom',
      closeness: Closeness.close,
      reconnecting: false,
      avatarShape: AvatarShape.scallop,
      avatarColor: AvatarColor.coral,
      notes: '',
      createdAt: created,
    );
    Intention thought(IntentionKind kind) => Intention(
      id: 'i',
      personId: 'tom',
      note: '',
      kind: kind,
      state: IntentionState.open,
      createdAt: created,
    );
    Idea idea(String id, IdeaKind kind, int day, {bool done = false}) => Idea(
      id: id,
      personId: 'tom',
      note: id,
      kind: kind,
      createdAt: DateTime(2026, 11, day),
      doneAt: done ? DateTime(2026, 11, 20) : null,
    );
    final ideas = [
      idea('old do', IdeaKind.toDo, 2),
      idea('new do', IdeaKind.toDo, 5),
      idea('done do', IdeaKind.toDo, 9, done: true),
      idea('talk', IdeaKind.toTalk, 3),
    ];

    test('meet, game and plan picks get the newest open to-do idea', () {
      for (final pick in [
        IntentionPick(tom, thought(IntentionKind.meet)),
        IntentionPick(tom, thought(IntentionKind.game)),
        PlanPick(tom, thought(IntentionKind.write)),
      ]) {
        expect(ideaForPick(pick, ideas)?.id, 'new do');
      }
    });

    test('write and call picks get the newest talk idea', () {
      for (final kind in [IntentionKind.write, IntentionKind.call]) {
        expect(
          ideaForPick(IntentionPick(tom, thought(kind)), ideas)?.id,
          'talk',
        );
      }
    });

    test('nothing without a fitting idea, and nothing on a birthday', () {
      expect(
        ideaForPick(IntentionPick(tom, thought(IntentionKind.call)), [
          ideas.first,
        ]),
        isNull,
      );
      expect(ideaForPick(BirthdayPick(tom), ideas), isNull);
      expect(ideaForPick(ReplyPick(tom, since: created), ideas), isNull);
    });
  });

  test('parseSharedItem reads text and images and skips the rest', () {
    expect(
      (parseSharedItem({'type': 'text', 'text': 'hi'}) as SharedText).text,
      'hi',
    );
    expect(
      (parseSharedItem({
        'type': 'image',
        'path': '/x/a.jpg',
      }) as SharedImage).path,
      '/x/a.jpg',
    );
    expect(parseSharedItem({'type': 'text', 'text': '  '}), isNull);
    expect(parseSharedItem({'type': 'video'}), isNull);
    expect(parseSharedItem(null), isNull);
  });
}

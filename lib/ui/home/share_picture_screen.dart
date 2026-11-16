import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/app_settings.dart';
import '../../data/database.dart';
import '../../data/ideas_repository.dart' show deletePictureFile;
import '../../domain/picture_chooser.dart';
import '../../platform/photo_store.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../people/photo_crop_screen.dart';
import '../widgets/avatar.dart';
import '../widgets/grey_button.dart';
import '../widgets/kept_card.dart';
import '../widgets/kept_text_field.dart';
import '../widgets/main_button.dart';
import '../widgets/picture_thumb.dart';
import '../widgets/section_label.dart';
import '../widgets/tag.dart';

/// A picture was shared into the app: asks what it is for, with the picture
/// big on top. Resolves to true when the user wants it kept as an idea (the
/// caller then shows the "Keep this for…" sheet), else false: the picture
/// became someone's picture, or the user cancelled. The shared file at
/// [path] is deleted in every case except the idea.
///
/// The flow: choice ([_ChoiceScreen]) → who ([_WhoseScreen]) → crop
/// (`cropAndSavePhoto`) → saved ([_PictureSetScreen]), whose Done closes the
/// app's screen so the gallery is back in front.
Future<bool> showSharedPicture(BuildContext context, String path) async {
  final keepAsIdea = await Navigator.of(context)
      .push<bool>(MaterialPageRoute(builder: (_) => _ChoiceScreen(path)));
  if (keepAsIdea == true) return true;
  await deletePictureFile(path);
  return false;
}

/// The first screen: two big choices, the one used last time first and in
/// the main colour.
class _ChoiceScreen extends ConsumerWidget {
  const _ChoiceScreen(this.path);

  final String path;

  void _choose(BuildContext context, WidgetRef ref, ShareImageChoice choice) {
    unawaited(
      ref.services.settings.update((s) => s.copyWith(shareImageChoice: choice)),
    );
    if (choice == ShareImageChoice.idea) {
      Navigator.of(context).pop(true);
    } else {
      unawaited(
        Navigator.of(context)
            .push<void>(MaterialPageRoute(builder: (_) => _WhoseScreen(path))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final last = ref.settings.shareImageChoice;
    final cards = {
      ShareImageChoice.picture: (
        KeptIcons.people,
        l10n.shareUseAsPicture,
        l10n.shareUseAsPictureLine,
      ),
      ShareImageChoice.idea: (
        KeptIcons.star,
        l10n.shareKeepAsIdea,
        l10n.shareKeepAsIdeaLine,
      ),
    };
    final order = [last, ...ShareImageChoice.values.where((c) => c != last)];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.sharePictureTitle, style: context.text.headlineLarge),
              const SizedBox(height: 16),
              Expanded(child: _BigPicture(path)),
              const SizedBox(height: 22),
              for (final (i, c) in order.indexed) ...[
                if (i > 0) const SizedBox(height: 14),
                _ChoiceCard(
                  icon: cards[c]!.$1,
                  title: cards[c]!.$2,
                  line: cards[c]!.$3,
                  highlighted: i == 0,
                  onTap: () => _choose(context, ref, c),
                ),
              ],
              const SizedBox(height: 18),
              GreyButton(
                label: l10n.cancel,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The shared picture as a big card-like tile.
class _BigPicture extends StatelessWidget {
  const _BigPicture(this.path);

  final String path;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    final radius = BorderRadius.circular(28);
    return Container(
      decoration: BoxDecoration(
        color: kept.surface,
        borderRadius: radius,
        boxShadow: [BoxShadow(color: kept.shadow, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          cacheWidth: 1200,
          errorBuilder: (_, _, _) =>
              Icon(Icons.image_outlined, color: kept.muted, size: 64),
        ),
      ),
    );
  }
}

/// One of the two big choices. The highlighted one is a coral pill-like
/// card with a tilted "Last time" tag; the other is a surface card.
class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.line,
    required this.highlighted,
    required this.onTap,
  });

  final KeptIcons icon;
  final String title;
  final String line;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    const radius = BorderRadius.all(Radius.circular(26));
    final text = highlighted ? KeptColors.onAccent : kept.text;
    final muted = highlighted ? KeptColors.onAccent : kept.muted;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: highlighted ? KeptColors.coralEdge : kept.shadow,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: highlighted ? KeptColors.coral : kept.surface,
            borderRadius: radius,
            child: InkWell(
              borderRadius: radius,
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Row(
                  spacing: 14,
                  children: [
                    KeptIcon(icon, size: 36),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(
                            title,
                            style: outfit(19, FontWeight.w600, color: text),
                          ),
                          Text(
                            line,
                            style: context.text.bodyMedium?.copyWith(
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (highlighted)
          PositionedDirectional(
            end: 14,
            top: -12,
            child: Tag(
              context.l10n.shareLastTime,
              accent: KeptColors.sun,
              tilt: 3,
            ),
          ),
      ],
    );
  }
}

/// "Whose picture is this?": a grid of everyone, people without a picture
/// first. A tap goes to the crop, saves, and shows [_PictureSetScreen].
class _WhoseScreen extends ConsumerStatefulWidget {
  const _WhoseScreen(this.path);

  final String path;

  @override
  ConsumerState<_WhoseScreen> createState() => _WhoseScreenState();
}

class _WhoseScreenState extends ConsumerState<_WhoseScreen> {
  final _query = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _pick(Person person, List<Person> everyone) async {
    if (_busy) return;
    _busy = true;
    try {
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      final failed = context.l10n.cropFailed;
      final Uint8List bytes;
      try {
        bytes = await File(widget.path).readAsBytes();
      } catch (e) {
        debugPrint('Shared picture not read: ${e.runtimeType}');
        messenger.showSnackBar(SnackBar(content: Text(failed)));
        return;
      }
      if (!mounted) return;
      final name = await cropAndSavePhoto(
        context,
        ref,
        bytes,
        shape: person.avatarShape,
      );
      if (name == null) return;
      final store = ref.read(photoStoreProvider);
      await ref.read(peopleRepositoryProvider).setPhoto(person.id, name);
      final old = person.photo;
      if (old != null && old != name) await store.delete(old);
      await deletePictureFile(widget.path);
      final remaining =
          withoutPicture(everyone) - (person.photo == null ? 1 : 0);
      if (!mounted) return;
      unawaited(
        navigator.pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => _PictureSetScreen(
              person: person,
              photoName: name,
              remaining: remaining,
            ),
          ),
        ),
      );
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kept = context.kept;
    final state = ref.watch(peopleProvider);
    final everyone = state.value ?? const <Person>[];
    final names = ref.watch(displayNamesProvider);
    final shown = pictureChooserOrder(everyone, query: _query.text);
    final lacking = shown.where((p) => p.photo == null).toList();
    final having = shown.where((p) => p.photo != null).toList();
    Widget grid(List<Person> people) => SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => _PersonTile(
            person: people[i],
            name: names[people[i].id] ?? people[i].name,
            onTap: () => unawaited(_pick(people[i], everyone)),
          ),
          childCount: people.length,
        ),
      ),
    );
    Widget label(String text) => SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 10),
      sliver: SliverToBoxAdapter(child: SectionLabel(text)),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.shareWhoseTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Row(
              spacing: 12,
              children: [
                PictureThumb(widget.path, size: 52),
                Expanded(
                  child: KeptTextField(
                    controller: _query,
                    hint: l10n.shareFindFriend,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.hasValue && everyone.isEmpty
                ? Center(
                    child: Text(
                      l10n.captureNoPeople,
                      style: context.text.bodyMedium?.copyWith(
                        color: kept.muted,
                      ),
                    ),
                  )
                : shown.isEmpty && state.hasValue
                ? Center(
                    child: Text(
                      l10n.shareNobodyFound,
                      style: context.text.bodyMedium?.copyWith(
                        color: kept.muted,
                      ),
                    ),
                  )
                : CustomScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      if (lacking.isNotEmpty) ...[
                        label('${l10n.shareNoPictureYet} · ${lacking.length}'),
                        grid(lacking),
                      ],
                      if (having.isNotEmpty) ...[
                        label(l10n.shareHasPicture),
                        grid(having),
                      ],
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// A face and a short name; a small mint tick marks who has a picture.
class _PersonTile extends StatelessWidget {
  const _PersonTile({
    required this.person,
    required this.name,
    required this.onTap,
  });

  final Person person;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    final has = person.photo != null;
    return Semantics(
      button: true,
      label: has ? '$name, ${context.l10n.shareHasPicture}' : name,
      child: ExcludeSemantics(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Column(
              spacing: 8,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Avatar.person(person, size: 72),
                    if (has)
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: KeptColors.mint,
                            shape: BoxShape.circle,
                            border: Border.all(color: kept.ground, width: 2),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: KeptColors.onAccent,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium?.copyWith(color: kept.text),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The happy end: the new picture large in the person's shape, a line, and
/// Done, which closes the app's screen (back to the gallery). Back does the
/// same: the share is finished either way.
class _PictureSetScreen extends ConsumerWidget {
  const _PictureSetScreen({
    required this.person,
    required this.photoName,
    required this.remaining,
  });

  final Person person;
  final String photoName;
  final int remaining;

  void _done(BuildContext context, WidgetRef ref) {
    final receiver = ref.read(shareReceiverProvider);
    // Leave the app showing Home, so it does not come back to this screen.
    Navigator.of(context).popUntil((r) => r.isFirst);
    unawaited(receiver.finish());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final kept = context.kept;
    final name = ref.shortName(person);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _done(context, ref);
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                KeptCard(
                  tone: kept.mintTone,
                  padding: const EdgeInsets.fromLTRB(20, 36, 20, 28),
                  child: Column(
                    spacing: 6,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _ShapedPhoto(
                            store: ref.read(photoStoreProvider),
                            name: photoName,
                            person: person,
                            size: 176,
                          ),
                          PositionedDirectional(
                            end: -22,
                            top: -8,
                            child: Tag(
                              l10n.shareDoneTag,
                              accent: KeptColors.sun,
                              tilt: 6,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        l10n.shareDoneTitle,
                        style: context.text.headlineLarge,
                      ),
                      Text(
                        l10n.shareDoneLine(name),
                        textAlign: TextAlign.center,
                        style: context.text.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  remaining > 0
                      ? l10n.shareStillNoPicture(remaining)
                      : l10n.shareAllHavePicture,
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium?.copyWith(color: kept.muted),
                ),
                const Spacer(flex: 2),
                MainButton(
                  label: l10n.shareDoneButton,
                  onPressed: () => _done(context, ref),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The stored picture in the person's avatar shape, with the avatar's hard
/// shadow. Shows the plain avatar until the file is read.
// TODO(avatar): once Avatar draws pictures itself, use Avatar.person(size: 176).
class _ShapedPhoto extends StatelessWidget {
  const _ShapedPhoto({
    required this.store,
    required this.name,
    required this.person,
    required this.size,
  });

  final PhotoStore store;
  final String name;
  final Person person;
  final double size;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: store.read(name),
      builder: (context, snap) {
        final bytes = snap.data;
        if (bytes == null) return Avatar.person(person, size: size);
        final path = avatarPath(person.avatarShape, size);
        return SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _ShadowPainter(path),
            child: ClipPath(
              clipper: _PathClipper(path),
              child: Image.memory(
                bytes,
                fit: BoxFit.cover,
                width: size,
                height: size,
                cacheWidth: (size * 3).round(),
                gaplessPlayback: true,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShadowPainter extends CustomPainter {
  _ShadowPainter(this.path);

  final Path path;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(
    path.shift(const Offset(0, 3)),
    Paint()..color = KeptColors.avatarShadow,
  );

  @override
  bool shouldRepaint(_ShadowPainter old) => old.path != path;
}

class _PathClipper extends CustomClipper<Path> {
  _PathClipper(this.path);

  final Path path;

  @override
  Path getClip(Size size) => path;

  @override
  bool shouldReclip(_PathClipper old) => old.path != path;
}

import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import '../../app/theme.dart';
import '../../data/database.dart';
import '../../domain/group.dart';
import '../common.dart';
import '../material.dart';
import 'avatar.dart';
import 'couple_avatar.dart';

/// Someone to pick: a person, or a linked couple ([couple] set; [person] is
/// its first member). [id] is the person id or the group id.
class PersonChoice {
  const PersonChoice(this.id, this.label, this.person, {this.couple});

  final String id;
  final String label;
  final Person person;
  final GroupWithMembers? couple;

  bool get isCouple => couple != null;

  /// The people it stands for.
  List<Person> get members => couple?.members ?? [person];

  Widget face(double size) => couple == null
      ? Avatar.person(person, size: size)
      : CoupleAvatar(couple!.members, size: size);
}

/// A round face over a first name. [selected] adds a coloured ring and a
/// small check badge; [faded] dims it (a suggestion not chosen yet).
class FaceBlob extends StatelessWidget {
  const FaceBlob({
    super.key,
    required this.label,
    required this.face,
    this.selected = false,
    this.faded = false,
    this.size = 48,
    this.width = 60,
    this.onTap,
  });

  final String label;
  final Widget face;
  final bool selected;
  final bool faded;
  final double size;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    final ring = size + 10;
    return Semantics(
      button: onTap != null,
      selected: selected,
      child: Opacity(
        opacity: faded && !selected ? .5 : 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            width: width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 2,
              children: [
                SizedBox.square(
                  dimension: ring,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      if (selected)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: KeptColors.coral,
                              width: 2.5,
                            ),
                          ),
                          child: SizedBox.square(dimension: ring),
                        ),
                      face,
                      if (selected)
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: KeptColors.mint,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: KeptColors.onAccent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: kept.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The dashed "+" circle at the end of a row of faces, with an optional
/// [label] under it.
class AddFaceBlob extends StatelessWidget {
  const AddFaceBlob({
    super.key,
    required this.onTap,
    this.label = '',
    this.size = 48,
    this.width = 60,
  });

  final VoidCallback onTap;
  final String label;
  final double size;
  final double width;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    return Semantics(
      button: true,
      label: label.isEmpty ? null : label,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              SizedBox.square(
                dimension: size + 10,
                child: CustomPaint(
                  painter: _DashedCircle(kept.line),
                  child: Icon(Icons.add_rounded, color: kept.text),
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: kept.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedCircle extends CustomPainter {
  const _DashedCircle(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final d = size.shortestSide - 10;
    final circle = Path()
      ..addOval(
        Rect.fromCenter(center: size.center(Offset.zero), width: d, height: d),
      );
    for (final PathMetric m in circle.computeMetrics()) {
      for (var at = 0.0; at < m.length; at += 11) {
        canvas.drawPath(m.extractPath(at, math.min(at + 6, m.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedCircle old) => old.color != color;
}

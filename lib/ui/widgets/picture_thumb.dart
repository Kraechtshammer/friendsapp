import 'dart:io';

import '../common.dart';
import '../material.dart';

/// A small rounded picture (an idea's picture): radius 12, hard
/// shadow 3 as for small things (ui-style.md §5). Tapping it shows the
/// picture larger in a dialog; a tap there closes it. A missing file shows
/// an empty tile.
class PictureThumb extends StatelessWidget {
  const PictureThumb(this.path, {super.key, this.size = 52});

  final String path;
  final double size;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    final radius = BorderRadius.circular(12);
    return Semantics(
      button: true,
      image: true,
      label: context.l10n.ideaPicture,
      child: GestureDetector(
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) => _LargePicture(path),
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: kept.surfaceHigh,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(color: kept.shadow, offset: const Offset(0, 3)),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
              cacheWidth: (size * 3).round(),
              errorBuilder: (_, _, _) => Icon(
                Icons.image_outlined,
                color: kept.muted,
                size: size * .45,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LargePicture extends StatelessWidget {
  const _LargePicture(this.path);

  final String path;

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.all(16),
    child: GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.file(
          File(path),
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const SizedBox(height: 120),
        ),
      ),
    ),
  );
}

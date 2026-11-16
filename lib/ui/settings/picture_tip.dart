import '../../app/theme.dart';
import '../common.dart';
import '../material.dart';
import '../widgets/kept_card.dart';
import '../widgets/tag.dart';

/// A small tip: sharing a photo from the gallery into Kept. makes it
/// someone's picture. Three tilted tags (Photo, Share, Kept.) show the way.
/// Shown at the bottom of Settings › Friends.
class PictureTip extends StatelessWidget {
  const PictureTip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final kept = context.kept;
    Widget arrow() => Icon(
      Icons.arrow_forward_rounded,
      size: 20,
      color: kept.skyTone.onContainer,
    );
    return KeptCard(
      tone: kept.skyTone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          Text(l10n.tipSharePicture, style: context.text.bodyLarge),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              Tag(l10n.tipStepPhoto, accent: KeptColors.sun, tilt: -3),
              arrow(),
              Tag(l10n.tipStepShare, accent: KeptColors.lilac, tilt: 2),
              arrow(),
              const Tag('Kept.', accent: KeptColors.coral, tilt: -2),
            ],
          ),
        ],
      ),
    );
  }
}

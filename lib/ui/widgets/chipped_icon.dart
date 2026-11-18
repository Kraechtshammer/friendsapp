import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';

/// A [KeptIcon] with an optional small second icon in a round chip at its
/// lower right, for "and also" (02-design.md §8: a birthday the user
/// congratulated on shows a chip; chat when they also texted).
class ChippedIcon extends StatelessWidget {
  const ChippedIcon(this.icon, {super.key, this.chip, this.size = 30});

  final KeptIcons icon;
  final KeptIcons? chip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final main = KeptIcon(icon, size: size);
    if (chip == null) return main;
    final d = size * .56;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        main,
        Positioned(
          right: -d * .35,
          bottom: -d * .3,
          child: Container(
            width: d,
            height: d,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.kept.surfaceHigh,
              shape: BoxShape.circle,
            ),
            child: KeptIcon(chip!, size: d * .72, shadow: false),
          ),
        ),
      ],
    );
  }
}

/// The chip on a past birthday: chat when the user congratulated and also
/// texted that day, a party popper when they only congratulated, none
/// otherwise.
KeptIcons? wishChip({required bool congratulated, required bool texted}) =>
    !congratulated
    ? null
    : texted
    ? KeptIcons.chat
    : KeptIcons.party;

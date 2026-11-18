import 'package:flutter_svg/flutter_svg.dart';

import 'material.dart';

/// The app's own colourful icons, drawn to docs/style/icon-style.md. Each
/// name is a file in `assets/icons/`.
enum KeptIcons {
  home,
  cottage,
  calendar,
  people,
  stamp,
  cake,
  mountain,
  phone,
  dice,
  chat,
  whatsapp,
  check,
  gear,
  search,
  popcorn,
  star,
  leaf,
  telegram,
  signal,
  discord,
  gift,
  controller,
  cups,
  wasd,
  bench,
  party,

  // Messenger stand-ins added for the chat app list (02-design.md §8,
  // 2026-11-18); whatsapp, telegram, signal and discord are above.
  linkedin,
  threema,
  line,
  viber,
  messenger,
  instagram,
  element,
  snapchat,
  teams,
  slack,
  sms,

  // Settings categories.
  moon,
  palette,
  shield,
  download,
  info,

  // The class badge on an avatar: a plant that grows with the class.
  sprout,
  bud,
  flower,

  // Activities of a meetup (02-design.md §8, 2026-11-18).
  beer,
  meeple,
  climber,
  ticket,
  clapper,
  notes,
  guitar,
  pot,
  tools,
  dumbbell,
  microphone,
  plate,
  bag,
  runner;

  String get asset => 'assets/icons/$name.svg';
}

/// Shows one of the [KeptIcons] with the small hard shadow every colourful
/// icon has (docs/style/ui-style.md §5): the icon's own shape in black at
/// 30 %, a little below it.
class KeptIcon extends StatelessWidget {
  const KeptIcon(this.icon, {super.key, this.size = 24, this.shadow = true});

  final KeptIcons icon;
  final double size;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final picture = SvgPicture.asset(icon.asset, width: size, height: size);
    if (!shadow) return picture;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 2,
          left: 0,
          child: SvgPicture.asset(
            icon.asset,
            width: size,
            height: size,
            colorFilter: const ColorFilter.mode(
              Color(0x4D000000),
              BlendMode.srcIn,
            ),
          ),
        ),
        picture,
      ],
    );
  }
}

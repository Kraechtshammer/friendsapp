import 'dart:math' as math;

import '../../app/theme.dart';
import '../common.dart';
import '../material.dart';

/// The date badge (ui-style.md §6): an accent fill, the weekday in small
/// caps over the day number, tilted by [tilt] degrees, hard shadow 4.
/// 56 x 58 with radius 18; [small] is the 46 x 48 version with radius 15
/// used on the Home cards (concept V6 · Home, "Coming up").
class DateBadge extends StatelessWidget {
  const DateBadge({
    super.key,
    required this.date,
    required this.accent,
    this.tilt = 0,
    this.small = false,
  });

  final DateTime date;
  final Color accent;
  final double tilt;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final weekday = l10n.dateWeekday(date).replaceAll('.', '').toUpperCase();
    final badge = Container(
      width: small ? 46 : 56,
      height: small ? 48 : 58,
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(small ? 15 : 18),
        boxShadow: [
          BoxShadow(color: context.kept.shadow, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            weekday,
            style: outfit(
              small ? 10 : 11,
              FontWeight.w600,
              color: KeptColors.onAccent,
            ).copyWith(letterSpacing: .88, height: 1.1),
          ),
          Text(
            l10n.dateDayNumber(date),
            style: outfit(
              small ? 19 : 23,
              FontWeight.w700,
              color: KeptColors.onAccent,
            ).copyWith(height: 1.1),
          ),
        ],
      ),
    );
    return tilt == 0
        ? badge
        : Transform.rotate(angle: tilt * math.pi / 180, child: badge);
  }
}

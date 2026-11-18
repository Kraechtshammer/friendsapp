import '../../data/database.dart';
import '../material.dart';
import 'avatar.dart';

/// Small avatars side by side, each overlapping the one before by a third,
/// for a name line (02-design.md §8, Timeline faces, option D). Shows at
/// most [max] people; the rest are left out.
class FaceStack extends StatelessWidget {
  const FaceStack(this.people, {super.key, this.size = 18, this.max = 4});

  final List<Person> people;
  final double size;
  final int max;

  @override
  Widget build(BuildContext context) {
    final shown = people.take(max).toList();
    if (shown.isEmpty) return const SizedBox.shrink();
    final step = size * 2 / 3;
    return SizedBox(
      width: size + step * (shown.length - 1),
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: step * i,
              child: Avatar.person(shown[i], size: size),
            ),
        ],
      ),
    );
  }
}

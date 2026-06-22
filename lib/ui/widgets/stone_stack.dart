import 'package:flutter/material.dart';

/// Maps a streak length to a (bucketed) number of stones for the cairn visual.
///
/// One literal stone per day would be unreadable at 47+, so the stack grows on a
/// slow milestone scale. Anchored to the design samples: 12→4, 19→5, 34→6, 47→7.
int stoneCountForStreak(int streak, {int cap = 9}) {
  const thresholds = [1, 3, 7, 12, 19, 30, 45, 65, 90, 120, 160, 210];
  var n = 0;
  for (final t in thresholds) {
    if (streak >= t) {
      n++;
    } else {
      break;
    }
  }
  return n.clamp(1, cap);
}

/// A little cairn: pebbles stacked tallest-at-the-base, the crowning stone in
/// sage, the rest alternating sand/grey. Stones overlap and may overflow above
/// [boxHeight] (the reserved layout height) so rows stay an even height while
/// taller stacks rise out of them — exactly like the design.
class StoneStack extends StatelessWidget {
  const StoneStack({
    super.key,
    required this.count,
    this.minSize = 13,
    this.maxSize = 19,
    this.overlap = 4,
    this.width = 40,
    this.boxHeight,
  });

  /// Number of stones to render (use [stoneCountForStreak]).
  final int count;

  /// Height of the top (crowning) stone.
  final double minSize;

  /// Height of the bottom (base) stone.
  final double maxSize;

  /// Vertical overlap between adjacent stones.
  final double overlap;

  /// Horizontal footprint reserved for the stack.
  final double width;

  /// Reserved layout height. If null, the stack takes its natural height; if
  /// smaller than the natural height, stones overflow upward (not clipped).
  final double? boxHeight;

  static String _assetForTopIndex(int i) {
    if (i == 0) return 'assets/stone_sage.png'; // crown
    return i.isOdd ? 'assets/stone_sand.png' : 'assets/stone_grey.png';
  }

  @override
  Widget build(BuildContext context) {
    final n = count.clamp(1, 12);

    // Heights from top (index 0 = smallest) to bottom (index n-1 = largest).
    final sizes = List<double>.generate(
      n,
      (i) => n == 1 ? maxSize : minSize + (maxSize - minSize) * (i / (n - 1)),
    );

    final contentHeight = sizes.reduce((a, b) => a + b) - overlap * (n - 1);
    final height = boxHeight ?? contentHeight;

    final children = <Widget>[];
    var bottomOffset = 0.0;
    for (var j = 0; j < n; j++) {
      final topIndex = n - 1 - j; // build bottom-up so the crown paints on top
      final h = sizes[topIndex];
      children.add(
        Positioned(
          bottom: bottomOffset,
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset(_assetForTopIndex(topIndex), height: h, fit: BoxFit.contain),
          ),
        ),
      );
      bottomOffset += h - overlap;
    }

    return SizedBox(
      width: width,
      height: height,
      child: Stack(clipBehavior: Clip.none, alignment: Alignment.bottomCenter, children: children),
    );
  }
}

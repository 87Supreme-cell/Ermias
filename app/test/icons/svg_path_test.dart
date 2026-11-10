import 'dart:ui';

import 'package:ermias/src/icons/ermias_icons.dart';
import 'package:ermias/src/icons/svg_path.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('absolute and relative lines end where SVG says', () {
    final path = parseSvgPath('M8 6h13');
    expect(path.getBounds(), const Rect.fromLTRB(8, 6, 21, 6));
  });

  test('implicit repeated commands continue the previous command', () {
    // "l-5-3-5 3" is two relative lines: (17,22) → (12,19) → (7,22)
    final bounds = parseSvgPath('M17 22l-5-3-5 3').getBounds();
    expect(bounds, const Rect.fromLTRB(7, 19, 17, 22));
  });

  test('numbers packed without separators are split like a browser does', () {
    // "2.73.73" is 2.73 then .73
    expect(tokenizeSvgNumbers('2.73.73-4'), [2.73, 0.73, -4]);
    expect(tokenizeSvgNumbers('.01'), [0.01]);
  });

  test('arcs are supported', () {
    final bounds = parseSvgPath('M3 12a9 3 0 0 0 18 0').getBounds();
    expect(bounds.left, closeTo(3, 0.01));
    expect(bounds.right, closeTo(21, 0.01));
    expect(bounds.bottom, closeTo(15, 0.05));
  });

  test('every icon used by the app parses', () {
    for (final icon in ErmiasIconData.values) {
      expect(() => icon.toPath(), returnsNormally, reason: icon.name);
    }
  });

  test('unsupported commands are rejected', () {
    expect(() => parseSvgPath('M0 0 Q1 1 2 2'), throwsFormatException);
  });
}

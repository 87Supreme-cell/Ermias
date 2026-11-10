import 'dart:convert';
import 'dart:io';

import 'package:ermias/src/theme/css_background.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _themes() {
  final json = jsonDecode(
    File('assets/themes.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  return json['themes'] as Map<String, dynamic>;
}

void main() {
  test('parses the Blues glow background', () {
    final blues = _themes()['Blues'] as Map<String, dynamic>;
    final bg = parseCssBackground(blues['bg'] as String);

    expect(bg.base, const Color(0xFFEEF3FB));
    expect(bg.glows, hasLength(3));
    final first = bg.glows.first;
    expect(first.radii, const Size(900, 600));
    expect(first.center, const FractionalOffset(0, 0));
    expect(first.color, const Color.fromRGBO(59, 130, 246, 0.38));
    expect(first.stop, closeTo(0.60, 1e-9));
    expect(bg.glows[1].center, const FractionalOffset(1, 0.25));
  });

  test('parses a 135deg swatch gradient', () {
    final g = parseCssLinearGradient(
      'linear-gradient(135deg, #3B82F6, #1E3A8A)',
    );
    expect(g.colors, const [Color(0xFF3B82F6), Color(0xFF1E3A8A)]);
    expect(g.begin, Alignment.topLeft);
    expect(g.end, Alignment.bottomRight);
  });

  test('every theme background and swatch parses', () {
    for (final entry in _themes().entries) {
      final t = entry.value as Map<String, dynamic>;
      expect(
        () => parseCssBackground(t['bg'] as String),
        returnsNormally,
        reason: entry.key,
      );
      expect(
        () => parseCssLinearGradient(t['swatch'] as String),
        returnsNormally,
        reason: entry.key,
      );
    }
  });

  test('rejects backgrounds without a solid base color last', () {
    expect(
      () => parseCssBackground(
        'radial-gradient(10px 10px at 0% 0%, #000000, transparent 50%)',
      ),
      throwsFormatException,
    );
  });
}

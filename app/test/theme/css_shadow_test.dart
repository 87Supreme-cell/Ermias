import 'dart:ui';

import 'package:ermias/src/theme/css_shadow.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a single shadow', () {
    final s = parseCssShadow('0 24px 60px rgba(15,26,46,0.22)');
    expect(s, hasLength(1));
    expect(s.single.offset, const Offset(0, 24));
    expect(
      s.single.blurSigma,
      closeTo(30, 0.01),
      reason: 'CSS shadow sigma is half the blur',
    );
    expect(s.single.spreadRadius, 0);
    expect(s.single.color, const Color.fromRGBO(15, 26, 46, 0.22));
  });

  test('parses two layers including a spread ring', () {
    final s = parseCssShadow(
      '0 24px 60px rgba(0,0,0,0.55), 0 0 0 1px rgba(0,229,255,0.15)',
    );
    expect(s, hasLength(2));
    expect(s[1].offset, Offset.zero);
    expect(s[1].blurSigma, closeTo(0, 0.01));
    expect(s[1].spreadRadius, 1);
  });

  test('rejects inset and malformed shadows', () {
    for (final bad in ['inset 0 1px 2px #000000', '0 1px', '']) {
      expect(() => parseCssShadow(bad), throwsFormatException, reason: bad);
    }
  });
}

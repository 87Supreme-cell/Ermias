import 'dart:ui';

import 'package:ermias/src/theme/css_color.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses six-digit hex', () {
    expect(parseCssColor('#1E4FD8'), const Color(0xFF1E4FD8));
  });

  test('parses rgba with fractional alpha', () {
    expect(parseCssColor('rgba(255,255,255,0.55)'),
        const Color.fromRGBO(255, 255, 255, 0.55));
  });

  test('tolerates spaces inside rgba', () {
    expect(parseCssColor(' rgba(0, 229, 255, 0.14) '),
        const Color.fromRGBO(0, 229, 255, 0.14));
  });

  test('parses transparent', () {
    expect(parseCssColor('transparent'), const Color(0x00000000));
  });

  test('rejects syntax outside the supported subset', () {
    for (final bad in ['hsl(1,2%,3%)', '#FFF', 'rgba(300,0,0,1)', 'rgba(0,0,0,2)', 'red', '']) {
      expect(() => parseCssColor(bad), throwsFormatException, reason: bad);
    }
  });
}

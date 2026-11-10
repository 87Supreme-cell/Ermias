import 'dart:io';
import 'dart:ui';

import 'package:ermias/src/theme/ermias_theme.dart';
import 'package:ermias/src/theme/theme_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// The 01_themes acceptance tests, automated for every theme.
void main() {
  final catalog = ThemeCatalog.fromJsonString(File('assets/themes.json').readAsStringSync());

  test('contrast math matches WCAG reference values', () {
    expect(contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)), closeTo(21, 0.01));
    expect(contrastRatio(const Color(0xFF777777), const Color(0xFFFFFFFF)), closeTo(4.48, 0.01));
  });

  test('composite blends a translucent color over its base', () {
    final c = composite(const Color.fromRGBO(255, 255, 255, 0.5), const Color(0xFF000000));
    expect((c.r * 255).round(), 128);
    expect(c.a, 1);
  });

  for (final name in catalog.names) {
    final t = catalog[name];
    final base = t.bg.base;
    final pairs = <String, (Color, Color)>{
      'ink on background': (t.ink, base),
      'muted on background': (t.muted, base),
      'accentText on accentSoft': (t.accentText, composite(t.accentSoft, base)),
      'warnText on warnSoft': (t.warnText, composite(t.warnSoft, base)),
      'onAccent on accent': (t.onAccent, t.accent),
      'onWarn on warn': (t.onWarn, t.warn),
      'invInk on invBg': (t.invInk, t.invBg),
      'invMuted on invBg': (t.invMuted, t.invBg),
    };

    for (final MapEntry(key: label, value: (fg, bg)) in pairs.entries) {
      test('$name: $label meets 4.5:1', () {
        expect(contrastRatio(fg, bg), greaterThanOrEqualTo(4.5));
      });
    }

    test('$name: accent and warning differ in grayscale (>= 1.5, D-024)', () {
      expect(contrastRatio(t.accent, t.warn), greaterThanOrEqualTo(1.5));
    });
  }
}

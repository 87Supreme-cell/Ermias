import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'css_color.dart';
import 'css_tokens.dart';

/// One elliptical glow from a CSS `radial-gradient(…)` layer: [color] at the
/// [center], fading out by [stop] (a fraction of [radii]).
@immutable
class RadialGlow {
  const RadialGlow({
    required this.radii,
    required this.center,
    required this.color,
    required this.stop,
  });

  final Size radii;
  final FractionalOffset center;
  final Color color;
  final double stop;
}

/// A theme background: soft glows layered over a solid [base] color.
@immutable
class CssBackground {
  const CssBackground({required this.glows, required this.base});

  final List<RadialGlow> glows;
  final Color base;
}

final _radial = RegExp(
    r'^radial-gradient\(\s*(\S+)\s+(\S+)\s+at\s+(\d+(?:\.\d+)?)%\s+(\d+(?:\.\d+)?)%\s*,(.*)\)$');
final _linear = RegExp(r'^linear-gradient\(\s*135deg\s*,(.*)\)$');
final _stopColor = RegExp(r'^(.*\S)\s+(\d+(?:\.\d+)?)%$');

/// Parses `themes.json` `bg` values: radial-gradient layers, then a solid
/// base color as the last layer. Anything else throws [FormatException].
CssBackground parseCssBackground(String input) {
  final layers = splitTopLevelCommas(input.trim());
  final base = parseCssColor(layers.last);
  final glows = layers.sublist(0, layers.length - 1).map(_parseGlow);
  return CssBackground(glows: List.unmodifiable(glows), base: base);
}

RadialGlow _parseGlow(String layer) {
  final m = _radial.firstMatch(layer);
  if (m == null) throw FormatException('Unsupported background layer', layer);
  final stops = splitTopLevelCommas(m.group(5)!);
  if (stops.length != 2) throw FormatException('Expected color, transparent N%', layer);
  final fade = _stopColor.firstMatch(stops[1]);
  if (fade == null || fade.group(1) != 'transparent') {
    throw FormatException('Expected the glow to fade to transparent', layer);
  }
  return RadialGlow(
    radii: Size(parsePx(m.group(1)!), parsePx(m.group(2)!)),
    center: FractionalOffset(
        double.parse(m.group(3)!) / 100, double.parse(m.group(4)!) / 100),
    color: parseCssColor(stops[0]),
    stop: double.parse(fade.group(2)!) / 100,
  );
}

/// Parses swatch values: `linear-gradient(135deg, colorA, colorB)`.
LinearGradient parseCssLinearGradient(String input) {
  final m = _linear.firstMatch(input.trim());
  if (m == null) throw FormatException('Unsupported linear gradient', input);
  final colors = splitTopLevelCommas(m.group(1)!).map(parseCssColor).toList();
  if (colors.length < 2) throw FormatException('Gradient needs two colors', input);
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: List.unmodifiable(colors),
  );
}

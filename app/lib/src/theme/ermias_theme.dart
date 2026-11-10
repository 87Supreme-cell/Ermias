import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'css_background.dart';
import 'css_color.dart';
import 'css_shadow.dart';

/// Every key a theme in `Code/shared/themes.json` must define, no more.
const themeKeys = {
  'bg',
  'ink',
  'muted',
  'glass',
  'glassBorder',
  'solid',
  'line',
  'track',
  'accent',
  'onAccent',
  'accentSoft',
  'accentText',
  'warn',
  'onWarn',
  'warnSoft',
  'warnText',
  'dashed',
  'subtle',
  'btnBg',
  'btnBorder',
  'bubble',
  'flyout',
  'shadow',
  'swatch',
  'invBg',
  'invInk',
  'invMuted',
  'invBorder',
  'invLine',
  'invBtn',
  'riskLocal',
  'riskHybrid',
  'riskExposed',
};

/// One color theme, typed. Key meanings: `Code/shared/README.md`.
@immutable
class ErmiasTheme {
  ErmiasTheme._(this.name, Map<String, String> v)
    : bg = parseCssBackground(v['bg']!),
      swatch = parseCssLinearGradient(v['swatch']!),
      shadow = parseCssShadow(v['shadow']!),
      _colors = Map.unmodifiable({
        for (final key in themeKeys.difference({'bg', 'swatch', 'shadow'}))
          key: parseCssColor(v[key]!),
      });

  /// Builds a theme, rejecting missing, unknown or non-string keys.
  factory ErmiasTheme.fromJson(String name, Map<String, Object?> json) {
    final missing = themeKeys.difference(json.keys.toSet());
    final unknown = json.keys.toSet().difference(themeKeys);
    if (missing.isNotEmpty || unknown.isNotEmpty) {
      throw FormatException(
        'Theme "$name": missing ${missing.toList()}, unknown ${unknown.toList()}',
      );
    }
    final values = <String, String>{};
    for (final MapEntry(:key, :value) in json.entries) {
      if (value is! String)
        throw FormatException('Theme "$name": "$key" is not a string');
      values[key] = value;
    }
    return ErmiasTheme._(name, values);
  }

  final String name;
  final CssBackground bg;
  final LinearGradient swatch;
  final List<BoxShadow> shadow;
  final Map<String, Color> _colors;

  Color get ink => _colors['ink']!;
  Color get muted => _colors['muted']!;
  Color get glass => _colors['glass']!;
  Color get glassBorder => _colors['glassBorder']!;
  Color get solid => _colors['solid']!;
  Color get line => _colors['line']!;
  Color get track => _colors['track']!;
  Color get accent => _colors['accent']!;
  Color get onAccent => _colors['onAccent']!;
  Color get accentSoft => _colors['accentSoft']!;
  Color get accentText => _colors['accentText']!;
  Color get warn => _colors['warn']!;
  Color get onWarn => _colors['onWarn']!;
  Color get warnSoft => _colors['warnSoft']!;
  Color get warnText => _colors['warnText']!;
  Color get dashed => _colors['dashed']!;
  Color get subtle => _colors['subtle']!;
  Color get btnBg => _colors['btnBg']!;
  Color get btnBorder => _colors['btnBorder']!;
  Color get bubble => _colors['bubble']!;
  Color get flyout => _colors['flyout']!;
  Color get invBg => _colors['invBg']!;
  Color get invInk => _colors['invInk']!;
  Color get invMuted => _colors['invMuted']!;
  Color get invBorder => _colors['invBorder']!;
  Color get invLine => _colors['invLine']!;
  Color get invBtn => _colors['invBtn']!;
  Color get riskLocal => _colors['riskLocal']!;
  Color get riskHybrid => _colors['riskHybrid']!;
  Color get riskExposed => _colors['riskExposed']!;
}

/// WCAG 2 contrast ratio between two opaque colors (1 to 21).
double contrastRatio(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Blends a possibly translucent [over] onto an opaque [base].
Color composite(Color over, Color base) => Color.alphaBlend(over, base);

double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

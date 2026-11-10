import 'dart:ui';

final _hex6 = RegExp(r'^#([0-9a-fA-F]{6})$');
final _rgba = RegExp(
  r'^rgba\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d*\.?\d+)\s*\)$',
);

/// Parses the CSS color subset used by `themes.json`: `#RRGGBB`,
/// `rgba(r,g,b,a)` and `transparent`.
///
/// Anything else throws [FormatException]. Rejecting is deliberate: a theme
/// value the app cannot read must fail loudly, not render a guessed color.
Color parseCssColor(String input) {
  final value = input.trim();
  if (value == 'transparent') return const Color(0x00000000);

  final hex = _hex6.firstMatch(value);
  if (hex != null)
    return Color(0xFF000000 | int.parse(hex.group(1)!, radix: 16));

  final rgba = _rgba.firstMatch(value);
  if (rgba == null) throw FormatException('Unsupported CSS color', input);

  final channels = [for (var i = 1; i <= 3; i++) int.parse(rgba.group(i)!)];
  final alpha = double.parse(rgba.group(4)!);
  if (channels.any((c) => c > 255) || alpha > 1) {
    throw FormatException('CSS color out of range', input);
  }
  return Color.fromRGBO(channels[0], channels[1], channels[2], alpha);
}

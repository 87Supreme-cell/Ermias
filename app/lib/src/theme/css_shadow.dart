import 'package:flutter/painting.dart';

import 'css_color.dart';
import 'css_tokens.dart';

/// Parses a CSS `box-shadow` list: layers of `x y blur [spread] color`.
///
/// `inset` and other forms are rejected with [FormatException].
List<BoxShadow> parseCssShadow(String input) {
  if (input.trim().isEmpty) throw FormatException('Empty shadow', input);
  return List.unmodifiable(splitTopLevelCommas(input).map(_parseLayer));
}

BoxShadow _parseLayer(String layer) {
  final colorStart = layer.indexOf(RegExp(r'rgba\(|#|transparent'));
  if (colorStart < 0) throw FormatException('Shadow layer has no color', layer);

  final lengths = layer.substring(0, colorStart).trim().split(RegExp(r'\s+'));
  if (lengths.length < 3 || lengths.length > 4) {
    throw FormatException('Expected x y blur [spread]', layer);
  }
  final values = lengths.map(parsePx).toList();
  return BoxShadow(
    offset: Offset(values[0], values[1]),
    blurRadius: values[2],
    spreadRadius: values.length == 4 ? values[3] : 0,
    color: parseCssColor(layer.substring(colorStart)),
  );
}

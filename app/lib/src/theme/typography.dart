import 'package:flutter/painting.dart';

import 'ermias_theme.dart';

/// Monaco is requested from the operating system and never bundled (D-016).
const _family = 'Monaco';
const _fallbacks = ['Menlo', 'Consolas', 'DejaVu Sans Mono', 'monospace'];

/// Type scale from 01_themes: 400/500 text, 600 headings and buttons,
/// 700 for the PRIMARY FOCUS title.
abstract final class ErmiasType {
  static TextStyle text(
    ErmiasTheme t, {
    double size = 14,
    FontWeight weight = FontWeight.w400,
  }) => _base(t.ink, size, weight).copyWith(height: 1.45);

  static TextStyle muted(
    ErmiasTheme t, {
    double size = 13,
    FontWeight weight = FontWeight.w400,
  }) => _base(t.muted, size, weight);

  static TextStyle heading(ErmiasTheme t, {double size = 15}) =>
      _base(t.ink, size, FontWeight.w600);

  static TextStyle title(ErmiasTheme t) =>
      _base(t.ink, 15, FontWeight.w700).copyWith(letterSpacing: 0.08 * 15);

  static TextStyle data(ErmiasTheme t, {double size = 12, Color? color}) =>
      _base(color ?? t.ink, size, FontWeight.w400);

  static TextStyle _base(Color color, double size, FontWeight weight) =>
      TextStyle(
        fontFamily: _family,
        fontFamilyFallback: _fallbacks,
        fontSize: size,
        fontWeight: weight,
        color: color,
      );
}

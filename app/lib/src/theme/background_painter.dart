import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import 'css_background.dart';

/// Paints a [CssBackground]: the base color, then each elliptical glow.
class ThemeBackgroundPainter extends CustomPainter {
  const ThemeBackgroundPainter(this.background);

  final CssBackground background;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = background.base);
    for (final glow in background.glows) {
      canvas.drawRect(rect, Paint()..shader = _shaderFor(glow, size));
    }
  }

  ui.Shader _shaderFor(RadialGlow glow, Size size) {
    final center = glow.center.alongSize(size);
    final squash = glow.radii.height / glow.radii.width;
    final matrix = Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..scaleByDouble(1, squash, 1, 1)
      ..translateByDouble(-center.dx, -center.dy, 0, 1);
    // Fade to the glow's own color at zero alpha. CSS `transparent` blends in
    // premultiplied space; fading to transparent black here would add grey.
    return ui.Gradient.radial(
      center,
      glow.radii.width,
      [glow.color, glow.color.withValues(alpha: 0)],
      [0, glow.stop],
      TileMode.clamp,
      matrix.storage,
    );
  }

  @override
  bool shouldRepaint(ThemeBackgroundPainter oldDelegate) =>
      oldDelegate.background != background;
}

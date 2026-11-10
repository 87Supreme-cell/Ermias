import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'theme_scope.dart';

/// Translucent, blurred surface (01_themes). Header and strips use
/// `blur(18px) saturate(150%)`; overlay panels ([flyout]) use the more opaque
/// flyout color, `blur(22px) saturate(160%)` and the theme shadow.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.flyout = false,
    this.radius = 14,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final bool flyout;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final shape = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: flyout ? t.flyout : t.glass,
        border: Border.all(color: t.glassBorder),
        borderRadius: shape,
        boxShadow: flyout ? t.shadow : null,
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: BackdropFilter(
          filter: flyout ? _filter(22, 1.6) : _filter(18, 1.5),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

ui.ImageFilter _filter(double blur, double saturation) =>
    ui.ImageFilter.compose(
      outer: ui.ColorFilter.matrix(_saturate(saturation)),
      inner: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
    );

/// CSS `saturate()` as a 4×5 color matrix (Filter Effects spec).
List<double> _saturate(double s) => [
  0.213 + 0.787 * s,
  0.715 - 0.715 * s,
  0.072 - 0.072 * s,
  0,
  0,
  0.213 - 0.213 * s,
  0.715 + 0.285 * s,
  0.072 - 0.072 * s,
  0,
  0,
  0.213 - 0.213 * s,
  0.715 - 0.715 * s,
  0.072 + 0.928 * s,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
];

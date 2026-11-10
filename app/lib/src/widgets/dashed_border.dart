import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// A rounded rectangle with a dashed outline (Flutter has no dashed border).
/// Used for external, data-only sources (06).
class DashedBorder extends StatelessWidget {
  const DashedBorder({
    super.key,
    required this.color,
    required this.child,
    this.radius = 12,
  });

  final Color color;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
    foregroundPainter: _DashedPainter(color, radius),
    child: child,
  );
}

class _DashedPainter extends CustomPainter {
  const _DashedPainter(this.color, this.radius);

  final Color color;
  final double radius;

  static const _dash = 5.0;
  static const _gap = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.5),
          Radius.circular(radius),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final ui.PathMetric metric in outline.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += _dash + _gap) {
        canvas.drawPath(metric.extractPath(d, d + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) =>
      old.color != color || old.radius != radius;
}

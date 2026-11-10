import 'package:flutter/widgets.dart';

/// Connection risk tiers always pair color with shape (DESIGN_DECISIONS):
/// circle = Local, diamond = Hybrid, triangle = Exposed (and warnings).
enum RiskShape { circle, diamond, triangle }

class RiskMark extends StatelessWidget {
  const RiskMark(this.shape, {super.key, required this.color, this.size = 10});

  final RiskShape shape;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _RiskPainter(shape, color));
}

class _RiskPainter extends CustomPainter {
  const _RiskPainter(this.shape, this.color);

  final RiskShape shape;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width;
    final h = size.height;
    switch (shape) {
      case RiskShape.circle:
        canvas.drawCircle(Offset(w / 2, h / 2), w * 0.45, paint);
      case RiskShape.diamond:
        canvas.drawPath(
            Path()
              ..moveTo(w / 2, h * 0.05)
              ..lineTo(w * 0.95, h / 2)
              ..lineTo(w / 2, h * 0.95)
              ..lineTo(w * 0.05, h / 2)
              ..close(),
            paint);
      case RiskShape.triangle:
        canvas.drawPath(
            Path()
              ..moveTo(w / 2, h * 0.05)
              ..lineTo(w * 0.96, h * 0.93)
              ..lineTo(w * 0.04, h * 0.93)
              ..close(),
            paint);
    }
  }

  @override
  bool shouldRepaint(_RiskPainter old) => old.shape != shape || old.color != color;
}

import 'package:flutter/widgets.dart';

import 'ermias_icons.dart';

/// Draws an [ErmiasIconData] outline at [size], stroke 1.8 in a 24-unit box.
class ErmiasIcon extends StatelessWidget {
  const ErmiasIcon(this.icon, {super.key, required this.color, this.size = 18});

  final ErmiasIconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.square(size),
      painter: _IconPainter(icon, color),
    ),
  );
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.icon, this.color);

  static final _cache = <ErmiasIconData, Path>{};

  final ErmiasIconData icon;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _cache.putIfAbsent(icon, icon.toPath);
    canvas.scale(size.width / 24, size.height / 24);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_IconPainter old) =>
      old.icon != icon || old.color != color;
}

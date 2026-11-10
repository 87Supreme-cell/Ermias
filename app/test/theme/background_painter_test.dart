import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ermias/src/theme/background_painter.dart';
import 'package:ermias/src/theme/css_background.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

const _black = Color(0xFF000000);

Future<(ByteData, int)> _render(CssBackground bg, Size size) async {
  final recorder = ui.PictureRecorder();
  ThemeBackgroundPainter(bg).paint(Canvas(recorder), size);
  final image = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
  final bytes = (await image.toByteData())!;
  return (bytes, size.width.toInt());
}

List<int> _rgb((ByteData, int) img, int x, int y) {
  final (bytes, width) = img;
  final i = (y * width + x) * 4;
  return [bytes.getUint8(i), bytes.getUint8(i + 1), bytes.getUint8(i + 2)];
}

RadialGlow _glow(Color color, Size radii) =>
    RadialGlow(radii: radii, center: const FractionalOffset(0.5, 0.5), color: color, stop: 1);

void main() {
  testWidgets('the first CSS layer is painted on top', (tester) async {
    await tester.runAsync(() async {
      final img = await _render(
        CssBackground(base: _black, glows: [
          _glow(const Color(0xFFFF0000), const Size(100, 100)),
          _glow(const Color(0xFF0000FF), const Size(100, 100)),
        ]),
        const Size(200, 200),
      );
      final center = _rgb(img, 100, 100);
      expect(center[0], greaterThan(240), reason: 'red layer on top');
      expect(center[2], lessThan(15), reason: 'blue layer underneath');
    });
  });

  testWidgets('glows are ellipses with the CSS radii, centered where CSS says', (tester) async {
    await tester.runAsync(() async {
      final img = await _render(
        CssBackground(base: _black, glows: [_glow(const Color(0xFFFFFFFF), const Size(100, 50))]),
        const Size(400, 400),
      );
      expect(_rgb(img, 280, 200)[0], greaterThan(30), reason: 'inside the 100 px x-radius');
      expect(_rgb(img, 200, 280), [0, 0, 0], reason: 'outside the 50 px y-radius');
      expect(_rgb(img, 200, 200)[0], greaterThan(240), reason: 'full color at the center');
    });
  });
}

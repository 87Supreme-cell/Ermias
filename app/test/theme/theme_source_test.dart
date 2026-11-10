import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app theme asset is byte-identical to Code/shared/themes.json', () {
    final source = File('../Code/shared/themes.json').readAsBytesSync();
    final copy = File('assets/themes.json').readAsBytesSync();
    expect(
      copy,
      equals(source),
      reason: 'Edit Code/shared/themes.json, then copy it to app/assets/.',
    );
  });
}

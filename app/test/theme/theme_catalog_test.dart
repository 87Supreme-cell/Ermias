import 'dart:convert';
import 'dart:io';

import 'package:ermias/src/theme/theme_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

String _source() => File('assets/themes.json').readAsStringSync();

void main() {
  test('loads the four locked themes in order, Blues first', () {
    final catalog = ThemeCatalog.fromJsonString(_source());
    expect(catalog.names, ['Blues', 'Cyberpunk', 'Sunburst', 'Earth tones']);
    expect(ThemeCatalog.defaultName, 'Blues');
    expect(catalog.defaultTheme, same(catalog['Blues']));
  });

  test('a theme missing a key is rejected', () {
    final json = jsonDecode(_source()) as Map<String, dynamic>;
    ((json['themes'] as Map<String, dynamic>)['Blues'] as Map<String, dynamic>).remove('warn');
    expect(() => ThemeCatalog.fromJsonString(jsonEncode(json)),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('warn'))));
  });

  test('a theme with an unknown key is rejected', () {
    final json = jsonDecode(_source()) as Map<String, dynamic>;
    ((json['themes'] as Map<String, dynamic>)['Blues'] as Map<String, dynamic>)['glow'] = '#000000';
    expect(() => ThemeCatalog.fromJsonString(jsonEncode(json)), throwsFormatException);
  });

  test('looking up an unknown theme throws', () {
    expect(() => ThemeCatalog.fromJsonString(_source())['Neon'], throwsArgumentError);
  });
}

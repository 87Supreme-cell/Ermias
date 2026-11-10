import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'ermias_theme.dart';

/// The themes defined in `Code/shared/themes.json`, in file order.
@immutable
class ThemeCatalog {
  const ThemeCatalog._(this._themes);

  /// Parses the whole file. Any invalid theme fails the load.
  factory ThemeCatalog.fromJsonString(String source) {
    final root = jsonDecode(source);
    if (root is! Map<String, Object?> ||
        root['themes'] is! Map<String, Object?>) {
      throw const FormatException(
        'themes.json: expected an object with "themes"',
      );
    }
    final themes = <String, ErmiasTheme>{};
    for (final MapEntry(:key, :value)
        in (root['themes']! as Map<String, Object?>).entries) {
      if (value is! Map<String, Object?>)
        throw FormatException('Theme "$key" is not an object');
      themes[key] = ErmiasTheme.fromJson(key, value);
    }
    if (!themes.containsKey(defaultName)) {
      throw const FormatException(
        'themes.json: the default theme "$defaultName" is missing',
      );
    }
    return ThemeCatalog._(Map.unmodifiable(themes));
  }

  static const defaultName = 'Blues';

  final Map<String, ErmiasTheme> _themes;

  List<String> get names => List.unmodifiable(_themes.keys);

  ErmiasTheme get defaultTheme => this[defaultName];

  ErmiasTheme operator [](String name) =>
      _themes[name] ??
      (throw ArgumentError.value(name, 'name', 'Unknown theme'));
}

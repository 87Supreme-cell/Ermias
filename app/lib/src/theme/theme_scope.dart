import 'package:flutter/widgets.dart';

import 'ermias_theme.dart';

/// Makes the active [ErmiasTheme] available to every widget below it.
class ThemeScope extends InheritedWidget {
  const ThemeScope({super.key, required this.theme, required super.child});

  final ErmiasTheme theme;

  static ErmiasTheme of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'No ThemeScope above this widget');
    return scope!.theme;
  }

  @override
  bool updateShouldNotify(ThemeScope oldWidget) => oldWidget.theme != theme;
}

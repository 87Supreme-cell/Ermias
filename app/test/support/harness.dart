import 'dart:io';

import 'package:ermias/src/theme/ermias_theme.dart';
import 'package:ermias/src/theme/theme_catalog.dart';
import 'package:ermias/src/theme/theme_scope.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final testCatalog = ThemeCatalog.fromJsonString(File('assets/themes.json').readAsStringSync());

/// Reference viewport for layout tests (Code/reference/screenshots: 1440 wide).
const referenceSize = Size(1440, 1040);

Future<void> pumpThemed(WidgetTester tester, Widget child,
    {ErmiasTheme? theme, Size size = referenceSize}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  // Mirrors the real app: a navigator gives the page a focus scope.
  await tester.pumpWidget(WidgetsApp(
    color: const Color(0xFF000000),
    pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) =>
        PageRouteBuilder<T>(settings: settings, pageBuilder: (context, _, _) => builder(context)),
    builder: (context, navigator) =>
        ThemeScope(theme: theme ?? testCatalog.defaultTheme, child: navigator!),
    home: child,
  ));
}

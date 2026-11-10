import 'dart:io';

import 'package:ermias/src/theme/glass.dart';
import 'package:ermias/src/theme/theme_catalog.dart';
import 'package:ermias/src/theme/theme_scope.dart';
import 'package:ermias/src/theme/typography.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = ThemeCatalog.fromJsonString(
    File('assets/themes.json').readAsStringSync(),
  );

  test(
    'text and data styles use Monaco with per-OS fallbacks (D-015, D-016)',
    () {
      final style = ErmiasType.data(catalog.defaultTheme);
      expect(style.fontFamily, 'Monaco');
      expect(style.fontFamilyFallback, [
        'Menlo',
        'Consolas',
        'DejaVu Sans Mono',
        'monospace',
      ]);
      expect(
        ErmiasType.title(catalog.defaultTheme).fontWeight,
        FontWeight.w700,
      );
    },
  );

  testWidgets(
    'GlassSurface blurs behind itself and reads colors from the theme',
    (tester) async {
      final theme = catalog['Cyberpunk'];
      await tester.pumpWidget(
        ThemeScope(
          theme: theme,
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: GlassSurface(child: SizedBox(width: 10, height: 10)),
          ),
        ),
      );
      expect(find.byType(BackdropFilter), findsOneWidget);
      final box =
          tester.widget<DecoratedBox>(find.byType(DecoratedBox)).decoration
              as BoxDecoration;
      expect(box.color, theme.glass);
      expect((box.border! as Border).top.color, theme.glassBorder);
    },
  );

  testWidgets('flyout GlassSurface uses the flyout color and theme shadow', (
    tester,
  ) async {
    final theme = catalog.defaultTheme;
    await tester.pumpWidget(
      ThemeScope(
        theme: theme,
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: GlassSurface(
            flyout: true,
            child: SizedBox(width: 10, height: 10),
          ),
        ),
      ),
    );
    final box =
        tester.widget<DecoratedBox>(find.byType(DecoratedBox)).decoration
            as BoxDecoration;
    expect(box.color, theme.flyout);
    expect(box.boxShadow, theme.shadow);
  });
}

import 'package:ermias/src/app.dart';
import 'package:ermias/src/mock/mock_data.dart';
import 'package:ermias/src/theme/glass.dart';
import 'package:ermias/src/theme/solid.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

Color _surface<T extends Widget>(WidgetTester tester) => (tester
        .widget<DecoratedBox>(find.descendant(of: find.byType(T), matching: find.byType(DecoratedBox)).first)
        .decoration as BoxDecoration)
    .color!;

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = referenceSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ErmiasApp(
      catalog: testCatalog,
      resources: FakeResourceSource(),
      audit: MockAuditSink(),
      model: mockModel,
    ));
    await tester.pump();
  }

  testWidgets('switching theme re-themes every surface without a restart', (tester) async {
    await pumpApp(tester);
    expect(_surface<GlassSurface>(tester), testCatalog['Blues'].glass);
    expect(_surface<SolidSurface>(tester), testCatalog['Blues'].solid);

    await tester.tap(find.bySemanticsLabel('Earth tones theme'));
    await tester.pump();
    expect(_surface<GlassSurface>(tester), testCatalog['Earth tones'].glass);
    expect(_surface<SolidSurface>(tester), testCatalog['Earth tones'].solid);
  });

  testWidgets('the gear opens the Settings screen and Back returns', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pumpAndSettle();
    expect(find.textContaining('section 13'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Back to workbench'));
    await tester.pumpAndSettle();
    expect(find.text('PRIMARY FOCUS'), findsOneWidget);
  });
}

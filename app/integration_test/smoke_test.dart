// WO-1 smoke test: the real app, the real Rust core, on the desktop.
// Run: flutter test integration_test -d macos
// Screenshots are written to <app temp dir>/ermias-wo1-shots/.
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:ermias/src/app.dart';
import 'package:ermias/src/header/resource_source.dart';
import 'package:ermias/src/mock/mock_data.dart';
import 'package:ermias/src/rust/frb_generated.dart';
import 'package:ermias/src/shell/shell_state.dart';
import 'package:ermias/src/theme/theme_catalog.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

final _shotKey = GlobalKey();
final _shotDir = Directory('${Directory.systemTemp.path}/ermias-wo1-shots');

/// Counts readings so the test can prove the strip updates live.
class _CountingSource implements ResourceSource {
  _CountingSource(this._inner);

  final ResourceSource _inner;
  int readingsSeen = 0;

  @override
  Stream<ResourceReading> readings(Duration every) =>
      _inner.readings(every).map((r) {
        readingsSeen++;
        return r;
      });

  @override
  Future<ModelCheck> checkModel(ModelIdentity model) =>
      _inner.checkModel(model);
}

Future<void> _wait(WidgetTester tester, Duration d) async {
  final end = DateTime.now().add(d);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.pump();
  final boundary =
      _shotKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 2);
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  _shotDir.createSync(recursive: true);
  File('${_shotDir.path}/$name.png')
      .writeAsBytesSync(png!.buffer.asUint8List());
}

Future<void> _tapTab(WidgetTester tester, PanelId id) async {
  await tester.tap(find.byKey(ValueKey('tab-${id.name}')));
  await tester.pump();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('WO-1 smoke: shell, themes and header on the real core', (
    tester,
  ) async {
    await RustLib.init();
    final catalog = ThemeCatalog.fromJsonString(
      await rootBundle.loadString('assets/themes.json'),
    );
    final modelFile = File(
      '${Directory.systemTemp.path}/ermias-smoke-model.bin',
    )..writeAsStringSync(mockModelContents, flush: true);
    final source = _CountingSource(const RustResourceSource());
    final audit = MockAuditSink();

    Future<void> launch() => tester.pumpWidget(
      RepaintBoundary(
        key: _shotKey,
        child: ErmiasApp(
          key: UniqueKey(),
          catalog: catalog,
          resources: source,
          audit: audit,
          model: mockModelAt(modelFile.path),
        ),
      ),
    );

    // 1. Live readings from Rust, and a passing hash check.
    await launch();
    await _wait(tester, const Duration(seconds: 5));
    expect(
      source.readingsSeen,
      greaterThanOrEqualTo(2),
      reason: 'resource strip updates live',
    );
    expect(
      find.textContaining(RegExp(r'^\d+\.\d / \d+\.\d GB$')),
      findsOneWidget,
    );
    expect(find.textContaining(RegExp(r'^\d+%$')), findsOneWidget);
    expect(
      find.textContaining(RegExp(r'^\d{4}-\d\d-\d\d \d\d:\d\d$')),
      findsOneWidget,
    );
    expect(find.textContaining('✓'), findsOneWidget);
    expect(audit.entries, isEmpty);
    await _shot(tester, '01-workbench-blues');

    // 2. Panels: one per side, both sides together, closing.
    await _tapTab(tester, PanelId.databases);
    await _tapTab(tester, PanelId.projectGrade);
    expect(find.byKey(const ValueKey('panel-databases')), findsOneWidget);
    expect(find.byKey(const ValueKey('panel-projectGrade')), findsOneWidget);
    await _shot(tester, '02-panels-databases-grade');
    await _tapTab(tester, PanelId.auditLog);
    await _tapTab(tester, PanelId.taskChain);
    expect(find.byKey(const ValueKey('panel-databases')), findsNothing);
    expect(find.byKey(const ValueKey('panel-auditLog')), findsOneWidget);
    await _shot(tester, '03-panels-audit-tasks');
    await _tapTab(tester, PanelId.auditLog);
    await _tapTab(tester, PanelId.taskChain);

    // 3. Every theme, without a restart.
    for (final (i, name) in ['Cyberpunk', 'Sunburst', 'Earth tones'].indexed) {
      await tester.tap(find.bySemanticsLabel('$name theme'));
      await tester.pump();
      await _shot(
        tester,
        '0${4 + i}-theme-${name.toLowerCase().replaceAll(' ', '-')}',
      );
    }
    await tester.tap(find.bySemanticsLabel('Blues theme'));
    await tester.pump();

    // 4. Settings opens from the gear.
    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pumpAndSettle();
    expect(find.textContaining('section 13'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Back to workbench'));
    await tester.pumpAndSettle();

    // 5. Changing the model file makes the hash check fail visibly and logs it.
    modelFile.writeAsStringSync('tampered\n', flush: true);
    await launch();
    await _wait(tester, const Duration(seconds: 2));
    expect(find.textContaining('hash mismatch'), findsOneWidget);
    expect(
      audit.entries.where(
        (e) => e.kind == 'model_hash_mismatch' && e.needsHuman,
      ),
      hasLength(1),
    );
    await _shot(tester, '07-model-hash-mismatch');

    debugPrint('SMOKE: readings=${source.readingsSeen} shots=${_shotDir.path}');
  });
}

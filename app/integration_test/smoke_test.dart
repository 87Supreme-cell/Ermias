// Smoke test on the real app, the real Rust core, on the desktop.
// Run: flutter test integration_test -d macos
// Screenshots are written to <app temp dir>/ermias-shots/.
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:ermias/src/app.dart';
import 'package:ermias/src/header/resource_source.dart';
import 'package:ermias/src/mock/mock_data.dart';
import 'package:ermias/src/mock/mock_workspace.dart';
import 'package:ermias/src/rust/frb_generated.dart';
import 'package:ermias/src/shell/shell_state.dart';
import 'package:ermias/src/theme/theme_catalog.dart';
import 'package:ermias/src/workspace/models.dart';
import 'package:ermias/src/workspace/workspace_controller.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

final _shotKey = GlobalKey();
final _shotDir = Directory('${Directory.systemTemp.path}/ermias-shots');

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

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.tap(f);
  await tester.pump();
}

Finder _tab(PanelId id) => find.byKey(ValueKey('tab-${id.name}'));

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Smoke: WO-1 shell, themes, header + WO-2 panels on the real core', (
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
    final workspace = WorkspaceController(mockWorkspace());

    Future<void> launch() => tester.pumpWidget(
      RepaintBoundary(
        key: _shotKey,
        child: ErmiasApp(
          key: UniqueKey(),
          catalog: catalog,
          resources: source,
          workspace: workspace,
          model: mockModelAt(modelFile.path),
        ),
      ),
    );

    // WO-1 · live readings from Rust and a passing hash check.
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
    expect(find.textContaining('✓'), findsOneWidget);
    expect(
      workspace.value.audit.where((e) => e.kind.startsWith('model_')),
      isEmpty,
    );
    await _shot(tester, '01-workbench-blues');

    // 04 · a citation chip opens its source.
    await _tap(tester, find.bySemanticsLabel('Source laws · 1182'));
    expect(find.textContaining('chunk 1182'), findsOneWidget);
    await _tap(tester, find.bySemanticsLabel('Source laws · 1182'));

    // 06 + 09 · panels with real contents; turning a source off updates its figure.
    await _tap(tester, _tab(PanelId.databases));
    await _tap(tester, _tab(PanelId.projectGrade));
    expect(find.text('external.db'), findsOneWidget);
    expect(find.text('8.1'), findsWidgets);
    await _shot(tester, '02-panels-databases-grade');
    await _tap(tester, find.bySemanticsLabel('tools.db is on'));
    expect(workspace.figureFor(PanelId.databases), '3/5');
    await _tap(tester, find.bySemanticsLabel('tools.db is off'));

    // 07 + 08 · audit log and task chain.
    await _tap(tester, _tab(PanelId.auditLog));
    await _tap(tester, _tab(PanelId.taskChain));
    expect(
      find.text('Turned on tools.db'),
      findsOneWidget,
      reason: 'the toggle above was logged',
    );
    await _shot(tester, '03-panels-audit-tasks');
    await _tap(tester, _tab(PanelId.auditLog));
    await _tap(tester, _tab(PanelId.taskChain));

    // 03 · Exposed window; ending the connection takes effect and is logged.
    await _tap(tester, find.bySemanticsLabel(RegExp(r'^1 Exposed connection')));
    expect(find.text('Exposed connection'), findsOneWidget);
    await _shot(tester, '04-connections-exposed');
    await _tap(
      tester,
      find.bySemanticsLabel('End connection Frontier API session'),
    );
    expect(workspace.value.countOf(ConnectionTier.exposed), 0);
    expect(find.text('No exposed connections.'), findsOneWidget);
    await _tap(tester, find.bySemanticsLabel('Close exposed connection'));
    await _tap(tester, _tab(PanelId.auditLog));
    expect(find.text('Ended Frontier API session · exposed'), findsOneWidget);
    await _tap(tester, _tab(PanelId.auditLog));

    // 05 · an external model asks before anything leaves the machine.
    await _tap(tester, find.bySemanticsLabel(RegExp(r'^Model: ')));
    await _tap(tester, find.text('External · data only'));
    await tester.enterText(
      find.byType(EditableText),
      'Compare our retention rules with the frontier model',
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(
      find.text('Send this question to an external model?'),
      findsOneWidget,
    );
    await _shot(tester, '05-approval-before-external-call');
    await _tap(tester, find.bySemanticsLabel('Approve this call'));
    expect(workspace.value.audit.first.kind, 'left_machine');
    expect(workspace.value.conversation.last.model, 'External · data only');

    // 01 · every theme, live.
    for (final (i, name) in ['Cyberpunk', 'Sunburst', 'Earth tones'].indexed) {
      await _tap(tester, find.bySemanticsLabel('$name theme'));
      await _shot(
        tester,
        '0${6 + i}-theme-${name.toLowerCase().replaceAll(' ', '-')}',
      );
    }
    await _tap(tester, find.bySemanticsLabel('Blues theme'));

    // 02 · Settings; 07 · full log.
    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pumpAndSettle();
    expect(find.textContaining('section 13'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Back to workbench'));
    await tester.pumpAndSettle();
    await _tap(tester, _tab(PanelId.auditLog));
    await tester.tap(find.bySemanticsLabel('Open full log'));
    await tester.pumpAndSettle();
    expect(find.textContaining('entries · saved locally'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Back to workbench'));
    await tester.pumpAndSettle();

    // 02 · changing the model file fails the hash check visibly and is logged.
    modelFile.writeAsStringSync('tampered\n', flush: true);
    await launch();
    await _wait(tester, const Duration(seconds: 2));
    expect(find.textContaining('hash mismatch'), findsOneWidget);
    expect(workspace.value.audit.first.kind, 'model_hash_mismatch');
    await _shot(tester, '09-model-hash-mismatch');

    debugPrint(
      'SMOKE: readings=${source.readingsSeen} audit=${workspace.value.audit.length} shots=${_shotDir.path}',
    );
  });
}

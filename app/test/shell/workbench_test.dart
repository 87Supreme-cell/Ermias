import 'package:ermias/src/shell/overlay_panel.dart';
import 'package:ermias/src/shell/shell_state.dart';
import 'package:ermias/src/shell/workbench.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

Finder _tab(PanelId id) => find.byKey(ValueKey('tab-${id.name}'));
Finder _panel(PanelId id) => find.byKey(ValueKey('panel-${id.name}'));

Future<void> _pumpWorkbench(WidgetTester tester, {ShellState initial = const ShellState()}) {
  var state = initial;
  return pumpThemed(
    tester,
    StatefulBuilder(
      builder: (context, setState) => Workbench(
        state: state,
        onChanged: (update) => setState(() => state = update(state)),
        header: const SizedBox(key: ValueKey('header'), height: 128),
      ),
    ),
  );
}

void main() {
  testWidgets('opening Audit log replaces Databases', (tester) async {
    await _pumpWorkbench(tester);
    await tester.tap(_tab(PanelId.databases));
    await tester.pump();
    await tester.tap(_tab(PanelId.auditLog));
    await tester.pump();
    expect(_panel(PanelId.databases), findsNothing);
    expect(_panel(PanelId.auditLog), findsOneWidget);
  });

  testWidgets('Databases and Project grade stay open together', (tester) async {
    await _pumpWorkbench(tester);
    await tester.tap(_tab(PanelId.databases));
    await tester.tap(_tab(PanelId.projectGrade));
    await tester.pump();
    expect(_panel(PanelId.databases), findsOneWidget);
    expect(_panel(PanelId.projectGrade), findsOneWidget);
  });

  for (final id in PanelId.values) {
    testWidgets('${id.label} closes from its tab and from its close button', (tester) async {
      await _pumpWorkbench(tester);
      await tester.tap(_tab(id));
      await tester.pump();
      await tester.tap(_tab(id));
      await tester.pump();
      expect(_panel(id), findsNothing);

      await tester.tap(_tab(id));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Close ${panelHeading(id).$1.toLowerCase()}'));
      await tester.pump();
      expect(_panel(id), findsNothing);
    });
  }

  testWidgets('with panels closed the center spans the gap between the strips', (tester) async {
    await _pumpWorkbench(tester);
    final left = tester.getRect(find.byKey(const ValueKey('strip-left')));
    final right = tester.getRect(find.byKey(const ValueKey('strip-right')));
    final center = tester.getRect(find.byKey(const ValueKey('center')));
    expect(center.left, left.right + 16);
    expect(center.right, right.left - 16);
    expect(left.width, 56);
  });

  testWidgets('panels overlay the center without resizing it, aligned with the strips (D-026)',
      (tester) async {
    await _pumpWorkbench(tester);
    final before = tester.getRect(find.byKey(const ValueKey('center')));
    await tester.tap(_tab(PanelId.databases));
    await tester.tap(_tab(PanelId.taskChain));
    await tester.pump();
    expect(tester.getRect(find.byKey(const ValueKey('center'))), before);

    final strip = tester.getRect(find.byKey(const ValueKey('strip-left')));
    final left = tester.getRect(_panel(PanelId.databases));
    final right = tester.getRect(_panel(PanelId.taskChain));
    expect(left.top, strip.top);
    expect(left.width, 400);
    expect(left.left, 96);
    expect(referenceSize.width - right.right, 96);
    expect(strip.top, 164, reason: 'reference position at 1440 px with a 128 px header');
  });

  testWidgets('tabs are expandable buttons with 44 px targets', (tester) async {
    await _pumpWorkbench(tester, initial: const ShellState(left: PanelId.databases));
    expect(tester.getSemantics(_tab(PanelId.databases)),
        isSemantics(isButton: true, hasExpandedState: true, isExpanded: true));
    expect(tester.getSemantics(_tab(PanelId.auditLog)),
        isSemantics(isButton: true, hasExpandedState: true, isExpanded: false));
    for (final id in PanelId.values) {
      final size = tester.getSize(_tab(id));
      expect(size.width >= 44 && size.height >= 44, isTrue, reason: id.label);
    }
  });

  testWidgets('tabs work from the keyboard', (tester) async {
    await _pumpWorkbench(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(_panel(PanelId.databases), findsOneWidget);
  });

  testWidgets('every tab and close button is reachable and usable by keyboard', (tester) async {
    await _pumpWorkbench(tester);
    Future<void> tabTo(String label) async {
      for (var i = 0; i < 12; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final focused = FocusManager.instance.primaryFocus?.context;
        if (focused != null &&
            find.descendant(of: find.bySemanticsLabel(label), matching: find.byWidget(focused.widget)).evaluate().isNotEmpty) {
          return;
        }
      }
      fail('Tab never reached $label');
    }

    await tabTo('Project grade');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(_panel(PanelId.projectGrade), findsOneWidget);

    await tabTo('Close project grade');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(_panel(PanelId.projectGrade), findsNothing);
  });

  testWidgets('the smallest window width still lays out both panels', (tester) async {
    var state = const ShellState(left: PanelId.databases, right: PanelId.taskChain);
    await pumpThemed(
      tester,
      StatefulBuilder(
        builder: (context, setState) => Workbench(
          state: state,
          onChanged: (update) => setState(() => state = update(state)),
          header: const SizedBox(height: 128),
        ),
      ),
      size: const Size(480, 720), // window minimum is 1024×720; 480 wide is a margin below it
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('mock figures are labeled MOCK', (tester) async {
    await _pumpWorkbench(tester);
    expect(find.textContaining('MOCK'), findsWidgets);
  });
}

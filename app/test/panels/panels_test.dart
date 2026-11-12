import 'package:ermias/src/audit/audit_sink.dart';
import 'package:ermias/src/mock/mock_workspace.dart';
import 'package:ermias/src/panels/audit_log_panel.dart';
import 'package:ermias/src/panels/databases_panel.dart';
import 'package:ermias/src/panels/project_grade_panel.dart';
import 'package:ermias/src/panels/task_chain_panel.dart';
import 'package:ermias/src/shell/shell_state.dart';
import 'package:ermias/src/widgets/dashed_border.dart';
import 'package:ermias/src/workspace/workspace_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

WorkspaceController _controller() =>
    WorkspaceController(mockWorkspace(), now: () => DateTime(2026, 11, 10, 11));

Future<void> _pumpPanel(WidgetTester tester, Widget panel) => pumpThemed(
  tester,
  Align(
    alignment: Alignment.topLeft,
    child: SizedBox(width: 368, child: panel),
  ),
);

void main() {
  group('06 Databases', () {
    testWidgets('lists every source with rank, grade, weight and on/off', (
      tester,
    ) async {
      final c = _controller();
      await _pumpPanel(tester, DatabasesPanel(controller: c));
      for (final name in [
        'laws.db',
        'principles.db',
        'practices.db',
        'tools.db',
        'external.db',
      ]) {
        expect(find.text(name), findsOneWidget);
      }
      expect(find.text('9/10'), findsOneWidget);
      expect(find.text('data only'), findsOneWidget);
      expect(find.text('1.0'), findsOneWidget);
      expect(find.textContaining('never as instructions'), findsOneWidget);
    });

    testWidgets(
      'external.db sits last with a dashed warning border and starts off',
      (tester) async {
        final c = _controller();
        await _pumpPanel(tester, DatabasesPanel(controller: c));
        expect(find.byType(DashedBorder), findsOneWidget);
        final external = tester.getSemantics(
          find.bySemanticsLabel('external.db is off'),
        );
        expect(
          external,
          isSemantics(isButton: true, hasToggledState: true, isToggled: false),
        );
      },
    );

    testWidgets(
      'turning a database off updates the panel and the strip figure',
      (tester) async {
        final c = _controller();
        await _pumpPanel(tester, DatabasesPanel(controller: c));
        await tester.tap(find.bySemanticsLabel('tools.db is on'));
        await tester.pump();
        expect(find.bySemanticsLabel('tools.db is off'), findsOneWidget);
        expect(c.figureFor(PanelId.databases), '3/5');
      },
    );

    testWidgets('adjust mode reorders ranks and changes weights', (
      tester,
    ) async {
      final c = _controller();
      await _pumpPanel(tester, DatabasesPanel(controller: c));
      await tester.tap(find.bySemanticsLabel('Adjust ranks and weights'));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Move practices.db up'));
      await tester.pump();
      expect(c.value.databases[1].name, 'practices.db');
      await tester.tap(find.bySemanticsLabel('Lower weight of laws.db'));
      await tester.pump();
      expect(c.value.databases.first.weight, closeTo(0.9, 1e-9));
      await tester.tap(find.bySemanticsLabel('Done adjusting'));
      await tester.pump();
      expect(find.bySemanticsLabel('Move practices.db up'), findsNothing);
    });
  });

  group('07 Audit log', () {
    testWidgets('newest first; rejections and data leaving shown as warnings', (
      tester,
    ) async {
      final c = _controller();
      await _pumpPanel(tester, AuditLogPanel(controller: c, onOpenFull: () {}));
      final top = tester.getTopLeft(
        find.text('External answer stored as data · rank 5'),
      );
      final bottom = tester.getTopLeft(
        find.text('Gate passed · search(laws.db)'),
      );
      expect(top.dy, lessThan(bottom.dy));
      expect(
        find.bySemanticsLabel(RegExp(r'^Warning: Gate rejected')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'^Warning: Left machine')),
        findsOneWidget,
      );
      expect(find.text('10:42:31'), findsOneWidget);
    });

    testWidgets('a new event appears at the top', (tester) async {
      final c = _controller();
      await _pumpPanel(tester, AuditLogPanel(controller: c, onOpenFull: () {}));
      c.toggleDatabase('tools.db');
      await tester.pump();
      final newest = tester.getTopLeft(find.text('Turned off tools.db'));
      final older = tester.getTopLeft(
        find.text('External answer stored as data · rank 5'),
      );
      expect(newest.dy, lessThan(older.dy));
    });

    testWidgets('a row opens to show its detail', (tester) async {
      final c = _controller();
      await _pumpPanel(tester, AuditLogPanel(controller: c, onOpenFull: () {}));
      expect(find.textContaining('not on the allowlist'), findsNothing);
      await tester.tap(
        find.text('Gate rejected · write_file outside allowlist'),
      );
      await tester.pump();
      expect(find.textContaining('not on the allowlist'), findsOneWidget);
    });

    testWidgets('Open full log calls through', (tester) async {
      var opened = false;
      await _pumpPanel(
        tester,
        AuditLogPanel(
          controller: _controller(),
          onOpenFull: () => opened = true,
        ),
      );
      await tester.tap(find.bySemanticsLabel('Open full log'));
      expect(opened, isTrue);
    });

    testWidgets('the full log lists every entry with its date', (tester) async {
      final c = _controller();
      c.record(
        AuditEntry(
          time: DateTime(2026, 11, 10, 11),
          kind: 'approval',
          summary: 'Extra',
          needsHuman: false,
        ),
      );
      await pumpThemed(tester, FullAuditLog(controller: c));
      expect(find.text('Extra'), findsOneWidget);
      expect(find.textContaining('2026-11-10'), findsWidgets);
    });
  });

  group('08 Task chain', () {
    testWidgets('stages show done, current and waiting; current is marked', (
      tester,
    ) async {
      await _pumpPanel(tester, TaskChainPanel(controller: _controller()));
      expect(find.text('Engineering'), findsOneWidget);
      expect(find.text('In progress · step 4 of 5'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Code, current')), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Engineering, done')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('Tech data, waiting')),
        findsOneWidget,
      );
    });
  });

  group('09 Project grade', () {
    testWidgets('total, change, components and Needs you', (tester) async {
      var reviewed = false;
      await _pumpPanel(
        tester,
        ProjectGradePanel(
          controller: _controller(),
          onReview: () => reviewed = true,
        ),
      );
      expect(find.text('8.1'), findsOneWidget);
      expect(find.text('+0.3 since last milestone'), findsOneWidget);
      expect(find.text('Claims with a source'), findsOneWidget);
      expect(find.text('41 / 42'), findsOneWidget);
      expect(
        find.text('1 rejected gate call · 1 claim with split samples'),
        findsOneWidget,
      );
      expect(find.textContaining('MOCK'), findsWidgets);
      await tester.tap(find.bySemanticsLabel('Review now'));
      expect(reviewed, isTrue);
    });
  });
}

import 'package:ermias/src/header/connections_box.dart';
import 'package:ermias/src/mock/mock_workspace.dart';
import 'package:ermias/src/workspace/models.dart';
import 'package:ermias/src/workspace/workspace_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

Future<(WorkspaceController, List<String>)> _pump(WidgetTester tester) async {
  final c = WorkspaceController(
    mockWorkspace(),
    now: () => DateTime(2026, 11, 10, 11),
  );
  final calls = <String>[];
  await pumpThemed(
    tester,
    Align(
      alignment: Alignment.topCenter,
      child: ConnectionsBox(
        controller: c,
        onOpenAuditLog: () => calls.add('audit'),
      ),
    ),
  );
  return (c, calls);
}

Finder _tier(String name) =>
    find.bySemanticsLabel(RegExp('^\\d+ $name connection'));

void main() {
  testWidgets(
    'Local is not openable; Hybrid opens a window listing its connections',
    (tester) async {
      await _pump(tester);
      expect(find.bySemanticsLabel(RegExp('not openable')), findsOneWidget);
      await tester.tap(_tier('Hybrid'));
      await tester.pump();
      expect(find.text('Hybrid connections'), findsOneWidget);
      expect(find.text('Frontier API'), findsOneWidget);
      expect(find.text('Package mirror'), findsOneWidget);
      expect(find.text('internet allowed · not active'), findsOneWidget);
    },
  );

  testWidgets('only one window at a time', (tester) async {
    await _pump(tester);
    await tester.tap(_tier('Hybrid'));
    await tester.pump();
    await tester.tap(_tier('Exposed'));
    await tester.pump();
    expect(find.text('Hybrid connections'), findsNothing);
    expect(find.text('Exposed connection'), findsOneWidget);
    expect(find.text('Sent: question only · 412 tokens'), findsOneWidget);
  });

  testWidgets(
    'Revoke removes the connection at once, updates the count and logs it',
    (tester) async {
      final (c, _) = await _pump(tester);
      await tester.tap(_tier('Hybrid'));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Revoke Package mirror'));
      await tester.pump();
      expect(find.text('Package mirror'), findsNothing);
      expect(
        find.bySemanticsLabel(RegExp(r'^1 Hybrid connection')),
        findsOneWidget,
      );
      expect(c.value.audit.first.summary, 'Revoked Package mirror · hybrid');
    },
  );

  testWidgets('End connection removes the exposed session and logs it', (
    tester,
  ) async {
    final (c, _) = await _pump(tester);
    await tester.tap(_tier('Exposed'));
    await tester.pump();
    await tester.tap(
      find.bySemanticsLabel('End connection Frontier API session'),
    );
    await tester.pump();
    expect(c.value.countOf(ConnectionTier.exposed), 0);
    expect(find.text('No exposed connections.'), findsOneWidget);
  });

  testWidgets('Open in audit log calls through and closes the window', (
    tester,
  ) async {
    final (_, calls) = await _pump(tester);
    await tester.tap(_tier('Exposed'));
    await tester.pump();
    await tester.tap(
      find.bySemanticsLabel('Open Frontier API session in audit log'),
    );
    await tester.pump();
    expect(calls, ['audit']);
    expect(find.text('Exposed connection'), findsNothing);
  });

  testWidgets('the close button closes the window', (tester) async {
    await _pump(tester);
    await tester.tap(_tier('Hybrid'));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Close hybrid connections'));
    await tester.pump();
    expect(find.text('Hybrid connections'), findsNothing);
  });
}

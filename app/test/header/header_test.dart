import 'package:ermias/src/header/header_bar.dart';
import 'package:ermias/src/header/resource_source.dart';
import 'package:ermias/src/mock/mock_data.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';
import '../support/harness.dart';

const _gib = 1024 * 1024 * 1024;

ResourceReading _reading({required double usedGiB, required double cpu, required DateTime at}) =>
    ResourceReading(
      memory: MemoryReading(usedBytes: (usedGiB * _gib).round(), totalBytes: 16 * _gib),
      cpuPercent: cpu,
      at: at,
    );

Future<(FakeResourceSource, MockAuditSink, List<String>)> _pump(
  WidgetTester tester, {
  ModelCheck check = ModelCheck.ok,
}) async {
  final source = FakeResourceSource(check: check);
  final audit = MockAuditSink();
  final picked = <String>[];
  await pumpThemed(
    tester,
    HeaderBar(
      resources: source,
      audit: audit,
      model: mockModel,
      catalog: testCatalog,
      activeTheme: 'Blues',
      onTheme: picked.add,
      onSettings: () => picked.add('settings'),
    ),
  );
  await tester.pump();
  return (source, audit, picked);
}

/// Stream events arrive on a microtask; the second pump renders them.
Future<void> _emit(WidgetTester tester, FakeResourceSource source, ResourceReading r) async {
  source.emit(r);
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('memory, CPU and clock update live', (tester) async {
    final (source, _, _) = await _pump(tester);
    await _emit(tester, source, _reading(usedGiB: 9.8, cpu: 42, at: DateTime(2026, 11, 10, 10, 43)));
    expect(find.text('9.8 / 16.0 GB'), findsOneWidget);
    expect(find.text('42%'), findsOneWidget);
    expect(find.text('2026-11-10 10:43'), findsOneWidget);

    await _emit(tester, source, _reading(usedGiB: 10.1, cpu: 7, at: DateTime(2026, 11, 10, 10, 44)));
    expect(find.text('10.1 / 16.0 GB'), findsOneWidget);
    expect(find.text('7%'), findsOneWidget);
    expect(find.text('2026-11-10 10:44'), findsOneWidget);
  });

  testWidgets('a reading that failed shows unavailable instead of crashing', (tester) async {
    final (source, _, _) = await _pump(tester);
    await _emit(tester, source, ResourceReading(memory: null, cpuPercent: null, at: DateTime(2026), error: 'boom'));
    expect(find.text('unavailable'), findsNWidgets(2));
  });

  testWidgets('a matching model hash shows a check mark', (tester) async {
    await _pump(tester);
    expect(find.textContaining('✓'), findsOneWidget);
    expect(find.textContaining('hash mismatch'), findsNothing);
  });

  testWidgets('a changed model file fails visibly and is logged for a human', (tester) async {
    final (_, audit, _) = await _pump(tester, check: ModelCheck.mismatch);
    final warning = tester.widget<Text>(find.textContaining('hash mismatch'));
    expect(warning.style?.color, testCatalog.defaultTheme.warnText);
    expect(find.bySemanticsLabel(RegExp('warning')), findsWidgets);
    expect(audit.entries, hasLength(1));
    expect(audit.entries.single.needsHuman, isTrue);
    expect(audit.entries.single.kind, 'model_hash_mismatch');
  });

  testWidgets('a missing model file is also a warning, never a pass', (tester) async {
    final (_, audit, _) = await _pump(tester, check: ModelCheck.missing);
    expect(find.textContaining('model file missing'), findsOneWidget);
    expect(audit.entries.single.needsHuman, isTrue);
  });

  testWidgets('the gear opens Settings', (tester) async {
    final (_, _, picked) = await _pump(tester);
    await tester.tap(find.bySemanticsLabel('Settings'));
    expect(picked, ['settings']);
  });

  testWidgets('theme swatches report the chosen theme and mark the active one', (tester) async {
    final (_, _, picked) = await _pump(tester);
    await tester.tap(find.bySemanticsLabel('Cyberpunk theme'));
    expect(picked, ['Cyberpunk']);
    expect(tester.getSemantics(find.bySemanticsLabel('Blues theme')),
        isSemantics(isButton: true, hasSelectedState: true, isSelected: true));
  });

  testWidgets('connections box: Local is not a button, Hybrid and Exposed are', (tester) async {
    await _pump(tester);
    expect(tester.getSemantics(find.bySemanticsLabel(RegExp('Local'))),
        isNot(isSemantics(isButton: true)));
    for (final tier in ['Hybrid', 'Exposed']) {
      expect(tester.getSemantics(find.bySemanticsLabel(RegExp(tier))),
          isSemantics(isButton: true, hasExpandedState: true));
    }
  });

  testWidgets('connections box is centered in row 2 and uses inverted colors', (tester) async {
    await _pump(tester);
    final box = find.byKey(const ValueKey('connections-box'));
    final header = tester.getRect(find.byType(HeaderBar));
    expect(tester.getCenter(box).dx, closeTo(header.center.dx, 2));
    final deco = tester.widget<DecoratedBox>(
            find.descendant(of: box, matching: find.byType(DecoratedBox)).first)
        .decoration as BoxDecoration;
    expect(deco.color, testCatalog.defaultTheme.invBg);
  });

  testWidgets('mock values are labeled MOCK', (tester) async {
    await _pump(tester);
    expect(find.textContaining('MOCK'), findsWidgets);
  });
}

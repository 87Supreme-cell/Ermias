import 'package:ermias/src/shell/shell_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// 00_shell acceptance tests at the state level.
void main() {
  test('each panel belongs to its strip', () {
    expect(PanelId.on(PanelSide.left), [PanelId.databases, PanelId.auditLog]);
    expect(PanelId.databases.side, PanelSide.left);
    expect(PanelId.auditLog.side, PanelSide.left);
    expect(PanelId.taskChain.side, PanelSide.right);
    expect(PanelId.projectGrade.side, PanelSide.right);
  });

  test('opening Audit log replaces Databases on the left', () {
    final s = const ShellState()
        .toggle(PanelId.databases)
        .toggle(PanelId.auditLog);
    expect(s.left, PanelId.auditLog);
    expect(s.isOpen(PanelId.databases), isFalse);
  });

  test('Databases and Project grade can be open together', () {
    final s = const ShellState()
        .toggle(PanelId.databases)
        .toggle(PanelId.projectGrade);
    expect([s.left, s.right], [PanelId.databases, PanelId.projectGrade]);
  });

  test('toggling an open tab closes it', () {
    final s = const ShellState()
        .toggle(PanelId.taskChain)
        .toggle(PanelId.taskChain);
    expect(s.right, isNull);
  });

  test('close(side) closes only that side', () {
    final s = const ShellState(
      left: PanelId.auditLog,
      right: PanelId.projectGrade,
    ).close(PanelSide.left);
    expect([s.left, s.right], [null, PanelId.projectGrade]);
  });

  test('toggle never mutates the original', () {
    const a = ShellState();
    final b = a.toggle(PanelId.databases);
    expect(a.left, isNull);
    expect(identical(a, b), isFalse);
  });

  test('a panel id on the wrong side is rejected', () {
    expect(() => ShellState(left: PanelId.taskChain), throwsAssertionError);
  });

  test('equal states compare equal', () {
    expect(
      const ShellState().toggle(PanelId.databases),
      const ShellState(left: PanelId.databases),
    );
  });

  test('open() opens a panel without toggling it closed', () {
    const open = ShellState(left: PanelId.auditLog);
    expect(open.open(PanelId.auditLog), open);
    expect(
      const ShellState(left: PanelId.databases).open(PanelId.auditLog).left,
      PanelId.auditLog,
    );
  });
}

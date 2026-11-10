import 'package:flutter/foundation.dart';

enum PanelSide { left, right }

/// Overlay panels opened from the edge tool strips (00_shell).
/// New panels are added here as tabs, never as new columns.
enum PanelId {
  databases(PanelSide.left, 'Databases'),
  auditLog(PanelSide.left, 'Audit log'),
  taskChain(PanelSide.right, 'Task chain'),
  projectGrade(PanelSide.right, 'Project grade');

  const PanelId(this.side, this.label);

  final PanelSide side;
  final String label;

  static List<PanelId> on(PanelSide side) =>
      List.unmodifiable(values.where((p) => p.side == side));
}

/// Which panel is open on each side. One panel per side; both sides may be
/// open at once. Every change returns a new state.
@immutable
class ShellState {
  const ShellState({this.left, this.right})
    : assert(
        left == null ||
            identical(left, PanelId.databases) ||
            identical(left, PanelId.auditLog),
        'left must be a left-strip panel',
      ),
      assert(
        right == null ||
            identical(right, PanelId.taskChain) ||
            identical(right, PanelId.projectGrade),
        'right must be a right-strip panel',
      );

  final PanelId? left;
  final PanelId? right;

  PanelId? openOn(PanelSide side) => side == PanelSide.left ? left : right;

  bool isOpen(PanelId id) => openOn(id.side) == id;

  /// Opens [id], replacing the panel on its side; closes it if already open.
  ShellState toggle(PanelId id) => _withSide(id.side, isOpen(id) ? null : id);

  ShellState close(PanelSide side) => _withSide(side, null);

  /// Opens [id] (replacing its side); unlike [toggle], never closes it.
  ShellState open(PanelId id) => _withSide(id.side, id);

  ShellState _withSide(PanelSide side, PanelId? id) => side == PanelSide.left
      ? ShellState(left: id, right: right)
      : ShellState(left: left, right: id);

  @override
  bool operator ==(Object other) =>
      other is ShellState && other.left == left && other.right == right;

  @override
  int get hashCode => Object.hash(left, right);
}

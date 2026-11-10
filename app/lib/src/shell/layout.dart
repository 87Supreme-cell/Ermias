/// Workbench geometry from 00_shell (Locked) and the reference code.
abstract final class ShellLayout {
  static const pagePadding = 20.0;
  static const gap = 16.0;
  static const stripWidth = 56.0;
  static const tabWidth = 44.0;
  static const panelWidth = 400.0;

  /// Panels sit 96 px in from their window edge (00_shell, Locked).
  static const panelInset = 96.0;

  /// Chat keeps a fixed size when the layout grows (05_chat_input).
  static const chatHeight = 172.0;
  static const minTarget = 44.0;
}

import 'shell_state.dart';

/// Figures shown on the edge strips. Real values come from sections 06–09;
/// until then [MockShellFigures] supplies them (see `lib/src/mock/`).
abstract interface class ShellFigures {
  /// Short status under a tab, e.g. `4/5` or `8.1`.
  String figureFor(PanelId id);

  /// Count of items on that side that need the person.
  int needsYou(PanelSide side);

  /// True while the figures are mock data; the strips then show `MOCK`.
  bool get isMock;
}

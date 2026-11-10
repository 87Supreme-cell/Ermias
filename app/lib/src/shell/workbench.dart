import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../mock/mock_data.dart';
import '../theme/background_painter.dart';
import '../theme/theme_scope.dart';
import 'center_placeholder.dart';
import 'edge_strip.dart';
import 'layout.dart';
import 'overlay_panel.dart';
import 'shell_figures.dart';
import 'shell_state.dart';

/// A change to the shell state, applied by the owner to its latest state so
/// that two inputs inside one frame cannot overwrite each other.
typedef ShellUpdate = ShellState Function(ShellState current);

/// The workbench frame (00_shell): header on top, an edge tool strip on each
/// side, the center between them, and overlay panels that never resize it.
class Workbench extends StatelessWidget {
  const Workbench({
    super.key,
    required this.state,
    required this.onChanged,
    required this.header,
    this.figures = const MockShellFigures(),
    this.center = const CenterPlaceholder(),
  });

  final ShellState state;
  final ValueChanged<ShellUpdate> onChanged;
  final Widget header;
  final ShellFigures figures;
  final Widget center;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return CustomPaint(
      painter: ThemeBackgroundPainter(t.bg),
      child: Padding(
        padding: const EdgeInsets.all(ShellLayout.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: ShellLayout.gap,
          children: [header, Expanded(child: _body())],
        ),
      ),
    );
  }

  Widget _body() => LayoutBuilder(builder: (context, box) {
        // Panels sit 96 px from the window edge; the body starts after the page padding.
        const offset = ShellLayout.panelInset - ShellLayout.pagePadding;
        final width = math.min(ShellLayout.panelWidth, box.maxWidth - 2 * offset);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: ShellLayout.gap,
              children: [
                _strip(PanelSide.left),
                Expanded(child: KeyedSubtree(key: const ValueKey('center'), child: center)),
                _strip(PanelSide.right),
              ],
            ),
            for (final side in PanelSide.values)
              if (state.openOn(side) case final id?)
                Positioned(
                  top: 0,
                  left: side == PanelSide.left ? offset : null,
                  right: side == PanelSide.right ? offset : null,
                  width: width,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: box.maxHeight),
                    child: OverlayPanel(
                      key: ValueKey('panel-${id.name}'),
                      id: id,
                      onClose: () => onChanged((s) => s.close(side)),
                      body: MockPanelBody(id: id),
                    ),
                  ),
                ),
          ],
        );
      });

  Widget _strip(PanelSide side) => EdgeStrip(
        key: ValueKey('strip-${side.name}'),
        side: side,
        state: state,
        figures: figures,
        onToggle: (id) => onChanged((s) => s.toggle(id)),
      );
}

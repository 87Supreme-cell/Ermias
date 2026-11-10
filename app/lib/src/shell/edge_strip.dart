import 'package:flutter/widgets.dart';

import '../theme/glass.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';
import 'layout.dart';
import 'shell_figures.dart';
import 'shell_state.dart';
import 'strip_tab.dart';

/// A glass edge tool strip with its tabs and a needs-you count (00_shell).
class EdgeStrip extends StatelessWidget {
  const EdgeStrip({
    super.key,
    required this.side,
    required this.state,
    required this.figures,
    required this.onToggle,
  });

  final PanelSide side;
  final ShellState state;
  final ShellFigures figures;
  final ValueChanged<PanelId> onToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ShellLayout.stripWidth,
      child: GlassSurface(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          spacing: 10,
          children: [
            for (final id in PanelId.on(side))
              StripTab(
                key: ValueKey('tab-${id.name}'),
                id: id,
                figure: figures.figureFor(id),
                isOpen: state.isOpen(id),
                onToggle: () => onToggle(id),
              ),
            _NeedsYouBadge(count: figures.needsYou(side)),
            const Spacer(),
            if (figures.isMock) const _MockLabel(),
          ],
        ),
      ),
    );
  }
}

class _NeedsYouBadge extends StatelessWidget {
  const _NeedsYouBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    final t = ThemeScope.of(context);
    return Semantics(
      label: '$count ${count == 1 ? 'item needs' : 'items need'} you',
      excludeSemantics: true,
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: t.warn,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: t.warnText), // D-014: visible on light glass
        ),
        child: Text('$count', style: ErmiasType.heading(t, size: 11).copyWith(color: t.onWarn)),
      ),
    );
  }
}

class _MockLabel extends StatelessWidget {
  const _MockLabel();

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return Semantics(
      label: 'Figures on this strip are mock data',
      excludeSemantics: true,
      child: RotatedBox(
        quarterTurns: 3,
        child: Text('MOCK', style: ErmiasType.data(t, size: 10, color: t.muted)),
      ),
    );
  }
}

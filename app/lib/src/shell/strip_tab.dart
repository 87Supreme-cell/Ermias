import 'package:flutter/widgets.dart';

import '../icons/ermias_icon.dart';
import '../icons/ermias_icons.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';
import 'layout.dart';
import 'shell_state.dart';

ErmiasIconData panelIcon(PanelId id) => switch (id) {
      PanelId.databases => ErmiasIconData.database,
      PanelId.auditLog => ErmiasIconData.auditLog,
      PanelId.taskChain => ErmiasIconData.taskChain,
      PanelId.projectGrade => ErmiasIconData.projectGrade,
    };

/// One edge-strip tab: icon, label reading bottom to top, status figure.
/// Accent colors while its panel is open (00_shell).
class StripTab extends StatefulWidget {
  const StripTab({
    super.key,
    required this.id,
    required this.figure,
    required this.isOpen,
    required this.onToggle,
  });

  final PanelId id;
  final String figure;
  final bool isOpen;
  final VoidCallback onToggle;

  @override
  State<StripTab> createState() => _StripTabState();
}

class _StripTabState extends State<StripTab> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final fg = widget.isOpen ? t.onAccent : t.ink;
    return Semantics(
      container: true,
      button: true,
      expanded: widget.isOpen,
      label: widget.id.label,
      value: widget.figure,
      excludeSemantics: true,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (on) => setState(() => _focused = on),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            widget.onToggle();
            return null;
          }),
        },
        child: GestureDetector(
          onTap: widget.onToggle,
          child: Container(
            width: ShellLayout.tabWidth,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: widget.isOpen ? t.accent : t.btnBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _focused ? t.ink : (widget.isOpen ? t.accent : t.btnBorder),
                width: _focused ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                ErmiasIcon(panelIcon(widget.id), color: fg),
                RotatedBox(
                  quarterTurns: 3,
                  child: Text(widget.id.label,
                      style: ErmiasType.heading(t, size: 12).copyWith(color: fg, letterSpacing: 0.48)),
                ),
                Text(widget.figure, style: ErmiasType.data(t, size: 11, color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

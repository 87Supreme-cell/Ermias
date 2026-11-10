import 'package:flutter/widgets.dart';

import '../icons/ermias_icon.dart';
import '../icons/ermias_icons.dart';
import '../mock/mock_data.dart';
import '../theme/glass.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';
import 'layout.dart';
import 'shell_state.dart';
import 'strip_tab.dart';

/// Panel heading and subtitle, from the reference panels in sections 06–09.
(String, String) panelHeading(PanelId id) => switch (id) {
  PanelId.databases => ('Active databases', 'rank · weight · grade'),
  PanelId.auditLog => ('Audit log', 'saved locally'),
  PanelId.taskChain => ('Task chain', mockTaskChainPath),
  PanelId.projectGrade => ('Project grade', 'updates each step'),
};

/// Overlay panel chrome: title, subtitle, close button and a scrolling body.
class OverlayPanel extends StatelessWidget {
  const OverlayPanel({
    super.key,
    required this.id,
    required this.onClose,
    required this.body,
  });

  final PanelId id;
  final VoidCallback onClose;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final (title, subtitle) = panelHeading(id);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: GlassSurface(
        flyout: true,
        radius: 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Row(
              spacing: 8,
              children: [
                ErmiasIcon(panelIcon(id), color: t.ink),
                Expanded(
                  child: Text(title, style: ErmiasType.heading(t, size: 16)),
                ),
                Flexible(
                  child: Text(
                    subtitle,
                    style: ErmiasType.muted(t, size: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _CloseButton(
                  label: 'Close ${title.toLowerCase()}',
                  onTap: onClose,
                ),
              ],
            ),
            Flexible(child: SingleChildScrollView(child: body)),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return Semantics(
      container: true,
      button: true,
      label: label,
      excludeSemantics: true,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => onTap(),
          ),
        },
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: ShellLayout.minTarget,
            height: ShellLayout.minTarget,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.btnBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: t.btnBorder),
            ),
            child: ErmiasIcon(ErmiasIconData.close, color: t.ink),
          ),
        ),
      ),
    );
  }
}

/// MOCK body until the panel's own section is built.
class MockPanelBody extends StatelessWidget {
  const MockPanelBody({super.key, required this.id});

  final PanelId id;

  static const _plannedIn = {
    PanelId.databases: 'section 06 · WO-2 interface, WO-5 data',
    PanelId.auditLog: 'section 07 · WO-2',
    PanelId.taskChain: 'section 08 · WO-2',
    PanelId.projectGrade: 'section 09 · WO-2 interface, WO-7 data',
  };

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return Text(
      'MOCK · contents arrive in ${_plannedIn[id]}',
      style: ErmiasType.muted(t),
    );
  }
}

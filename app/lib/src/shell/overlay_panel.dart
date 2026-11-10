import 'package:flutter/widgets.dart';

import '../icons/ermias_icon.dart';
import '../icons/ermias_icons.dart';
import '../mock/mock_data.dart';
import '../theme/glass.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';
import '../widgets/ermias_button.dart';
import 'shell_state.dart';
import 'strip_tab.dart';

/// Panel heading and subtitle, from the reference panels in sections 06–09.
(String, String) panelHeading(PanelId id) => switch (id) {
  PanelId.databases => ('Active databases', 'rank · weight · grade'),
  PanelId.auditLog => ('Audit log', 'saved locally'),
  PanelId.taskChain => ('Task chain', mockTaskChainPath),
  PanelId.projectGrade => ('Project grade', 'updates each step'),
};

/// Below this header width the subtitle is dropped and the title truncates.
/// A 400 px panel has a 368 px header, so the full layout is the default.
const _wideHeaderWidth = 340.0;

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
            _PanelHeader(id: id, onClose: onClose),
            Flexible(child: SingleChildScrollView(child: body)),
          ],
        ),
      ),
    );
  }
}

/// Icon, title, subtitle and close button. At full panel width the title
/// keeps its full length and the subtitle takes what is left.
class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.id, required this.onClose});

  final PanelId id;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final (title, subtitle) = panelHeading(id);
    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= _wideHeaderWidth;
        final heading = Text(
          title,
          style: ErmiasType.heading(t, size: 15),
          maxLines: 1,
          overflow: wide ? null : TextOverflow.ellipsis,
        );
        return Row(
          spacing: 6,
          children: [
            ErmiasIcon(panelIcon(id), color: t.ink),
            if (wide) heading else Expanded(child: heading),
            if (wide)
              Expanded(
                child: Text(
                  subtitle,
                  style: ErmiasType.muted(t, size: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ErmiasButton(
              icon: ErmiasIconData.close,
              semanticsLabel: 'Close ${title.toLowerCase()}',
              onTap: onClose,
            ),
          ],
        );
      },
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

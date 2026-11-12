import 'package:flutter/widgets.dart';

import '../audit/audit_sink.dart';
import '../icons/ermias_icons.dart';
import '../icons/risk_shape.dart';
import '../theme/background_painter.dart';
import '../theme/solid.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';
import '../widgets/ermias_button.dart';
import '../workspace/workspace_controller.dart';

/// Gate rejections and anything that left the machine are warnings (07).
bool isWarningKind(String kind) =>
    const {'gate_reject', 'left_machine', 'model_hash_mismatch'}.contains(kind);

String _two(int v) => v.toString().padLeft(2, '0');
String formatTime(DateTime t) =>
    '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';
String formatDate(DateTime t) => '${t.year}-${_two(t.month)}-${_two(t.day)}';

/// The most recent entries, newest first, each opening to its detail.
const _panelRows = 8;

/// 07: local record of everything the system did.
class AuditLogPanel extends StatefulWidget {
  const AuditLogPanel({
    super.key,
    required this.controller,
    required this.onOpenFull,
  });

  final WorkspaceController controller;
  final VoidCallback onOpenFull;

  @override
  State<AuditLogPanel> createState() => _AuditLogPanelState();
}

class _AuditLogPanelState extends State<AuditLogPanel> {
  AuditEntry? _open;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, state, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final entry in state.audit.take(_panelRows))
            AuditRow(
              entry: entry,
              isOpen: identical(entry, _open),
              onTap: () => setState(
                () => _open = identical(entry, _open) ? null : entry,
              ),
            ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              link: true,
              label: 'Open full log',
              excludeSemantics: true,
              child: GestureDetector(
                onTap: widget.onOpenFull,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Open full log',
                    style: ErmiasType.text(t, size: 13, weight: FontWeight.w500)
                        .copyWith(
                          color: t.accentText,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One log row: time, summary, and the detail when opened.
class AuditRow extends StatelessWidget {
  const AuditRow({
    super.key,
    required this.entry,
    required this.isOpen,
    required this.onTap,
    this.showDate = false,
  });

  final AuditEntry entry;
  final bool isOpen;
  final VoidCallback onTap;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final warn = isWarningKind(entry.kind);
    final color = warn ? t.warnText : t.ink;
    final time = showDate
        ? '${formatDate(entry.time)} ${formatTime(entry.time)}'
        : formatTime(entry.time);
    return Semantics(
      button: true,
      expanded: isOpen,
      label:
          '${warn ? 'Warning: ' : ''}${entry.summary}, ${formatTime(entry.time)}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: t.line)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Text(
                    time,
                    style: ErmiasType.data(t, size: 11, color: t.muted),
                  ),
                  if (warn)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: RiskMark(
                        RiskShape.triangle,
                        color: color,
                        size: 10,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      entry.summary,
                      style: ErmiasType.text(
                        t,
                        size: 13,
                      ).copyWith(color: color),
                    ),
                  ),
                ],
              ),
              if (isOpen)
                Text(
                  entry.detail ?? 'kind: ${entry.kind}',
                  style: ErmiasType.muted(t, size: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Open full log": every entry, with dates.
class FullAuditLog extends StatefulWidget {
  const FullAuditLog({super.key, required this.controller});

  final WorkspaceController controller;

  @override
  State<FullAuditLog> createState() => _FullAuditLogState();
}

class _FullAuditLogState extends State<FullAuditLog> {
  AuditEntry? _open;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return CustomPaint(
      painter: ThemeBackgroundPainter(t.bg),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SolidSurface(
          child: ValueListenableBuilder(
            valueListenable: widget.controller,
            builder: (context, state, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    ErmiasButton(
                      icon: ErmiasIconData.chevronLeft,
                      semanticsLabel: 'Back to workbench',
                      label: 'Workbench',
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    Semantics(
                      header: true,
                      child: Text(
                        'Audit log',
                        style: ErmiasType.heading(t, size: 18),
                      ),
                    ),
                    Text(
                      '${state.audit.length} entries · saved locally · MOCK',
                      style: ErmiasType.muted(t),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    children: [
                      for (final e in state.audit)
                        AuditRow(
                          entry: e,
                          showDate: true,
                          isOpen: identical(e, _open),
                          onTap: () => setState(
                            () => _open = identical(e, _open) ? null : e,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

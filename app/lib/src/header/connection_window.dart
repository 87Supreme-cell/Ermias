import 'package:flutter/widgets.dart';

import '../icons/ermias_icons.dart';
import '../icons/risk_shape.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';
import '../widgets/ermias_button.dart';
import '../workspace/models.dart';
import '../workspace/workspace_controller.dart';

const _windowWidth = 560.0;

/// 03 drill-down window, inverted colors. Revoke / End connection take
/// effect at once and are logged by the controller.
class ConnectionWindow extends StatelessWidget {
  const ConnectionWindow({
    super.key,
    required this.controller,
    required this.tier,
    required this.onClose,
    required this.onOpenAuditLog,
  });

  final WorkspaceController controller;
  final ConnectionTier tier;
  final VoidCallback onClose;
  final VoidCallback onOpenAuditLog;

  bool get _hybrid => tier == ConnectionTier.hybrid;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final title = _hybrid ? 'Hybrid connections' : 'Exposed connection';
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: title,
      child: Container(
        width: _windowWidth,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.invBg,
          border: Border.all(color: t.invBorder),
          borderRadius: BorderRadius.circular(16),
          boxShadow: t.shadow,
        ),
        child: ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, state, _) {
            final rows = state.connections
                .where((c) => c.tier == tier)
                .toList();
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    RiskMark(
                      _hybrid ? RiskShape.diamond : RiskShape.triangle,
                      color: _hybrid ? t.riskHybrid : t.riskExposed,
                      size: 11,
                    ),
                    Text(
                      title,
                      style: ErmiasType.heading(
                        t,
                        size: 16,
                      ).copyWith(color: t.invInk),
                    ),
                    Expanded(
                      child: Text(
                        _hybrid
                            ? 'internet allowed · not active'
                            : 'active · data leaving the machine',
                        textAlign: TextAlign.end,
                        style: ErmiasType.text(
                          t,
                          size: 12,
                        ).copyWith(color: t.invMuted),
                      ),
                    ),
                    ErmiasButton(
                      semanticsLabel: 'Close ${title.toLowerCase()}',
                      icon: ErmiasIconData.close,
                      tone: ErmiasButtonTone.inverted,
                      onTap: onClose,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (rows.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No ${tier.name} connections.',
                      style: ErmiasType.text(t).copyWith(color: t.invMuted),
                    ),
                  ),
                for (final c in rows)
                  _ConnectionRow(
                    connection: c,
                    controller: controller,
                    onOpenAuditLog: onOpenAuditLog,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ConnectionRow extends StatelessWidget {
  const _ConnectionRow({
    required this.connection,
    required this.controller,
    required this.onOpenAuditLog,
  });

  final Connection connection;
  final WorkspaceController controller;
  final VoidCallback onOpenAuditLog;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final c = connection;
    final hybrid = c.tier == ConnectionTier.hybrid;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: t.invLine)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  c.name,
                  style: ErmiasType.heading(
                    t,
                    size: 14,
                  ).copyWith(color: t.invInk),
                ),
              ),
              Text(
                c.destination,
                style: ErmiasType.data(t, size: 12, color: t.invMuted),
              ),
            ],
          ),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              for (final d in c.details)
                Text(
                  d,
                  style: ErmiasType.text(
                    t,
                    size: 12,
                  ).copyWith(color: t.invMuted),
                ),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              ErmiasButton(
                semanticsLabel:
                    '${hybrid ? 'Revoke' : 'End connection'} ${c.name}',
                label: hybrid ? 'Revoke' : 'End connection',
                tone: ErmiasButtonTone.inverted,
                onTap: () => hybrid
                    ? controller.revokeConnection(c.id)
                    : controller.endConnection(c.id),
              ),
              ErmiasButton(
                semanticsLabel: 'Open ${c.name} in audit log',
                label: 'Open in audit log',
                tone: ErmiasButtonTone.inverted,
                onTap: onOpenAuditLog,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

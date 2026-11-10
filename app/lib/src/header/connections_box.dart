import 'package:flutter/widgets.dart';

import '../icons/ermias_icon.dart';
import '../icons/ermias_icons.dart';
import '../icons/risk_shape.dart';
import '../mock/mock_data.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';

enum ConnectionTier { hybrid, exposed }

/// High-contrast connections box (03_connections), centered in header row 2.
/// Counts are MOCK until the monitor exists (WO-6); the drill-down windows
/// arrive with section 03 (WO-2).
class ConnectionsBox extends StatefulWidget {
  const ConnectionsBox({super.key});

  @override
  State<ConnectionsBox> createState() => _ConnectionsBoxState();
}

class _ConnectionsBoxState extends State<ConnectionsBox> {
  ConnectionTier? _open;

  void _toggle(ConnectionTier tier) => setState(() => _open = _open == tier ? null : tier);

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    const c = mockConnectionCounts;
    final label = ErmiasType.heading(t, size: 11).copyWith(color: t.invMuted, letterSpacing: 0.88);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.invBg,
        border: Border.all(color: t.invBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
        child: Row(mainAxisSize: MainAxisSize.min, spacing: 4, children: [
          Padding(padding: const EdgeInsets.only(right: 6), child: Text('CONNECTIONS', style: label)),
          Semantics(
            label: '${c.local} Local connections, local only, not openable',
            excludeSemantics: true,
            child: _TierLabel(shape: RiskShape.circle, color: t.riskLocal, text: '${c.local} Local'),
          ),
          _TierButton(tier: ConnectionTier.hybrid, count: c.hybrid, isOpen: _open == ConnectionTier.hybrid, onTap: _toggle),
          _TierButton(tier: ConnectionTier.exposed, count: c.exposed, isOpen: _open == ConnectionTier.exposed, onTap: _toggle),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('MOCK', style: label.copyWith(fontSize: 10))),
        ]),
      ),
    );
  }
}

class _TierLabel extends StatelessWidget {
  const _TierLabel({required this.shape, required this.color, required this.text, this.trailing});

  final RiskShape shape;
  final Color color;
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(mainAxisSize: MainAxisSize.min, spacing: 8, children: [
          RiskMark(shape, color: color, size: shape == RiskShape.circle ? 10 : 11),
          Text(text, style: ErmiasType.heading(t, size: 13).copyWith(color: t.invInk)),
          ?trailing,
        ]),
      ),
    );
  }
}

class _TierButton extends StatelessWidget {
  const _TierButton({required this.tier, required this.count, required this.isOpen, required this.onTap});

  final ConnectionTier tier;
  final int count;
  final bool isOpen;
  final ValueChanged<ConnectionTier> onTap;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final isHybrid = tier == ConnectionTier.hybrid;
    final name = isHybrid ? 'Hybrid' : 'Exposed';
    return Semantics(
      container: true,
      button: true,
      expanded: isOpen,
      label: '$count $name ${count == 1 ? 'connection' : 'connections'}',
      excludeSemantics: true,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            onTap(tier);
            return null;
          }),
        },
        child: GestureDetector(
          onTap: () => onTap(tier),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isOpen ? t.invBtn : null,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: isOpen ? t.invBorder : const Color(0x00000000)),
            ),
            child: _TierLabel(
              shape: isHybrid ? RiskShape.diamond : RiskShape.triangle,
              color: isHybrid ? t.riskHybrid : t.riskExposed,
              text: '$count $name',
              trailing: ErmiasIcon(ErmiasIconData.chevronDown, color: t.invInk, size: 14),
            ),
          ),
        ),
      ),
    );
  }
}

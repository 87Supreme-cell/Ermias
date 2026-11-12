import 'package:flutter/widgets.dart';

import '../icons/ermias_icon.dart';
import '../icons/ermias_icons.dart';
import '../icons/risk_shape.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';
import '../workspace/models.dart';
import '../workspace/workspace_controller.dart';
import 'connection_window.dart';

/// High-contrast connections box (03), centered in header row 2. Hybrid and
/// Exposed open a window just below it; Local is not openable. Counts and
/// connections are MOCK until the monitor exists (WO-6).
class ConnectionsBox extends StatefulWidget {
  const ConnectionsBox({
    super.key,
    required this.controller,
    required this.onOpenAuditLog,
  });

  final WorkspaceController controller;
  final VoidCallback onOpenAuditLog;

  @override
  State<ConnectionsBox> createState() => _ConnectionsBoxState();
}

class _ConnectionsBoxState extends State<ConnectionsBox> {
  final _window = OverlayPortalController();
  final _link = LayerLink();
  ConnectionTier? _open;

  void _toggle(ConnectionTier tier) {
    setState(() => _open = _open == tier ? null : tier);
    _open == null ? _window.hide() : _window.show();
  }

  void _close() {
    setState(() => _open = null);
    _window.hide();
  }

  @override
  Widget build(BuildContext context) => CompositedTransformTarget(
    link: _link,
    child: OverlayPortal(
      controller: _window,
      overlayChildBuilder: (context) => CompositedTransformFollower(
        link: _link,
        targetAnchor: Alignment.bottomCenter,
        followerAnchor: Alignment.topCenter,
        offset: const Offset(0, 8),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConnectionWindow(
            controller: widget.controller,
            tier: _open ?? ConnectionTier.hybrid,
            onClose: _close,
            onOpenAuditLog: () {
              _close();
              widget.onOpenAuditLog();
            },
          ),
        ),
      ),
      child: ValueListenableBuilder(
        valueListenable: widget.controller,
        builder: (context, state, _) => _Box(
          local: state.countOf(ConnectionTier.local),
          hybrid: state.countOf(ConnectionTier.hybrid),
          exposed: state.countOf(ConnectionTier.exposed),
          open: _open,
          onTier: _toggle,
        ),
      ),
    ),
  );
}

class _Box extends StatelessWidget {
  const _Box({
    required this.local,
    required this.hybrid,
    required this.exposed,
    required this.open,
    required this.onTier,
  });

  final int local;
  final int hybrid;
  final int exposed;
  final ConnectionTier? open;
  final ValueChanged<ConnectionTier> onTier;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final caption = ErmiasType.heading(
      t,
      size: 11,
    ).copyWith(color: t.invMuted, letterSpacing: 0.88);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.invBg,
        border: Border.all(color: t.invBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text('CONNECTIONS', style: caption),
            ),
            Semantics(
              label: '$local Local connections, local only, not openable',
              excludeSemantics: true,
              child: TierLabel(
                shape: RiskShape.circle,
                color: t.riskLocal,
                text: '$local Local',
              ),
            ),
            for (final tier in [ConnectionTier.hybrid, ConnectionTier.exposed])
              _TierButton(
                tier: tier,
                count: tier == ConnectionTier.hybrid ? hybrid : exposed,
                isOpen: open == tier,
                onTap: onTier,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('MOCK', style: caption.copyWith(fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shape + count + name, on the inverted surface.
class TierLabel extends StatelessWidget {
  const TierLabel({
    super.key,
    required this.shape,
    required this.color,
    required this.text,
    this.trailing,
  });

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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            RiskMark(
              shape,
              color: color,
              size: shape == RiskShape.circle ? 10 : 11,
            ),
            Text(
              text,
              style: ErmiasType.heading(t, size: 13).copyWith(color: t.invInk),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _TierButton extends StatelessWidget {
  const _TierButton({
    required this.tier,
    required this.count,
    required this.isOpen,
    required this.onTap,
  });

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
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              onTap(tier);
              return null;
            },
          ),
        },
        child: GestureDetector(
          onTap: () => onTap(tier),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isOpen ? t.invBtn : null,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: isOpen ? t.invBorder : const Color(0x00000000),
              ),
            ),
            child: TierLabel(
              shape: isHybrid ? RiskShape.diamond : RiskShape.triangle,
              color: isHybrid ? t.riskHybrid : t.riskExposed,
              text: '$count $name',
              trailing: ErmiasIcon(
                ErmiasIconData.chevronDown,
                color: t.invInk,
                size: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

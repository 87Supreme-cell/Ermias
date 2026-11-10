import 'package:flutter/widgets.dart';

import '../icons/ermias_icon.dart';
import '../icons/ermias_icons.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';

/// Outlined 44 px button used across the app: icon-only or icon + label.
/// Keyboard: focusable, Enter/Space activate. [onTap] null still renders the
/// button (the spec shows it) but announces it as not yet available.
class ErmiasButton extends StatelessWidget {
  const ErmiasButton({
    super.key,
    required this.icon,
    required this.semanticsLabel,
    required this.onTap,
    this.label,
    this.iconSize = 18,
  });

  final ErmiasIconData icon;
  final String semanticsLabel;
  final String? label;
  final VoidCallback? onTap;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final tap = onTap;
    return Semantics(
      container: true,
      button: true,
      enabled: tap != null,
      label: semanticsLabel,
      hint: tap == null ? 'Not yet available' : null,
      excludeSemantics: true,
      child: FocusableActionDetector(
        enabled: tap != null,
        mouseCursor: tap == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              tap?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          onTap: tap,
          child: Container(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            padding: EdgeInsets.symmetric(horizontal: label == null ? 0 : 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.btnBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: t.btnBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                ErmiasIcon(icon, color: t.ink, size: iconSize),
                if (label case final text?)
                  Text(
                    text,
                    style: ErmiasType.text(t, weight: FontWeight.w500),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

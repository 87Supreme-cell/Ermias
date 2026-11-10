import 'package:flutter/widgets.dart';

import '../icons/ermias_icon.dart';
import '../icons/ermias_icons.dart';
import '../theme/ermias_theme.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';

/// plain: outlined. accent: filled, the one primary action. warn: needs a
/// human. inverted: on the high-contrast connections surfaces.
enum ErmiasButtonTone { plain, accent, warn, inverted }

/// 44 px button used across the app: icon, label, or both.
/// Keyboard: focusable, Enter/Space activate. [onTap] null still renders the
/// button (the spec shows it) but announces it as not yet available.
class ErmiasButton extends StatelessWidget {
  const ErmiasButton({
    super.key,
    required this.semanticsLabel,
    required this.onTap,
    this.icon,
    this.label,
    this.iconSize = 18,
    this.tone = ErmiasButtonTone.plain,
    this.toggled,
  });

  final ErmiasIconData? icon;
  final String semanticsLabel;
  final String? label;
  final VoidCallback? onTap;
  final double iconSize;
  final ErmiasButtonTone tone;

  /// Set for on/off buttons: announced as a toggle with this state.
  final bool? toggled;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final tap = onTap;
    final (bg, border, fg) = _colors(t);
    return Semantics(
      container: true,
      button: true,
      enabled: tap != null,
      toggled: toggled,
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
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                if (icon case final i?)
                  ErmiasIcon(i, color: fg, size: iconSize),
                if (label case final text?)
                  Text(
                    text,
                    style: ErmiasType.text(
                      t,
                      weight: FontWeight.w600,
                    ).copyWith(color: fg),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color, Color) _colors(ErmiasTheme t) => switch (tone) {
    ErmiasButtonTone.plain => (t.btnBg, t.btnBorder, t.ink),
    ErmiasButtonTone.accent => (t.accent, t.accent, t.onAccent),
    ErmiasButtonTone.warn => (t.btnBg, t.warnText, t.warnText),
    ErmiasButtonTone.inverted => (t.invBtn, t.invBorder, t.invInk),
  };
}

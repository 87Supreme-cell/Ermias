import 'package:flutter/widgets.dart';

import '../icons/ermias_icons.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';
import 'ermias_button.dart';

/// A select: a button showing the current option that opens a menu above it.
class ErmiasSelect<T> extends StatefulWidget {
  const ErmiasSelect({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> onChanged;

  @override
  State<ErmiasSelect<T>> createState() => _ErmiasSelectState<T>();
}

class _ErmiasSelectState<T> extends State<ErmiasSelect<T>> {
  final _menu = OverlayPortalController();
  final _link = LayerLink();

  String get _current =>
      widget.options.firstWhere((o) => o.$1 == widget.value).$2;

  void _pick(T value) {
    _menu.hide();
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) => CompositedTransformTarget(
    link: _link,
    child: OverlayPortal(
      controller: _menu,
      overlayChildBuilder: _buildMenu,
      child: ErmiasButton(
        semanticsLabel: '${widget.label}: $_current',
        label: _current,
        icon: ErmiasIconData.chevronUp,
        iconSize: 14,
        onTap: _menu.toggle,
      ),
    ),
  );

  Widget _buildMenu(BuildContext context) {
    final t = ThemeScope.of(context);
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: _menu.hide,
            behavior: HitTestBehavior.opaque,
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          targetAnchor: Alignment.topLeft,
          followerAnchor: Alignment.bottomLeft,
          offset: const Offset(0, -6),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              constraints: const BoxConstraints(minWidth: 220),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: t.solid,
                border: Border.all(color: t.btnBorder),
                borderRadius: BorderRadius.circular(10),
                boxShadow: t.shadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (value, text) in widget.options)
                    Semantics(
                      button: true,
                      selected: value == widget.value,
                      label: text,
                      excludeSemantics: true,
                      child: GestureDetector(
                        onTap: () => _pick(value),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 44),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: value == widget.value ? t.accentSoft : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(text, style: ErmiasType.text(t)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

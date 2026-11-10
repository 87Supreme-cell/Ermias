import 'package:flutter/widgets.dart';

import '../theme/theme_catalog.dart';
import '../theme/theme_scope.dart';

/// Row of theme swatches (01_themes). Choosing one re-themes every screen.
class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({
    super.key,
    required this.catalog,
    required this.active,
    required this.onPick,
  });

  final ThemeCatalog catalog;
  final String active;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: 'Theme',
    explicitChildNodes: true,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 2,
      children: [
        for (final name in catalog.names)
          _Swatch(
            catalog: catalog,
            name: name,
            active: name == active,
            onPick: onPick,
          ),
      ],
    ),
  );
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.catalog,
    required this.name,
    required this.active,
    required this.onPick,
  });

  final ThemeCatalog catalog;
  final String name;
  final bool active;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final dot = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: catalog[name].swatch,
        border: active ? null : Border.all(color: t.btnBorder),
      ),
      child: const SizedBox.square(dimension: 20),
    );
    return Semantics(
      container: true,
      button: true,
      selected: active,
      label: '$name theme',
      excludeSemantics: true,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              onPick(name);
              return null;
            },
          ),
        },
        child: GestureDetector(
          onTap: () => onPick(name),
          child: SizedBox(
            width: 36,
            height: 44,
            child: Center(
              // Active: 2 px gap in the glass color, then a 2 px ink ring.
              child: active
                  ? Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: t.glass,
                        border: Border.all(color: t.ink, width: 2),
                      ),
                      child: dot,
                    )
                  : dot,
            ),
          ),
        ),
      ),
    );
  }
}

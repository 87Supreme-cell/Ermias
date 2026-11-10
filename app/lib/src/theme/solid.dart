import 'package:flutter/widgets.dart';

import 'theme_scope.dart';

/// Solid surface for PRIMARY FOCUS and chat, so text stays readable (01_themes).
class SolidSurface extends StatelessWidget {
  const SolidSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.solid,
        border: Border.all(color: t.glassBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

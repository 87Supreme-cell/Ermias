import 'package:flutter/widgets.dart';

import '../theme/solid.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';
import 'layout.dart';

/// PRIMARY FOCUS above a fixed-height chat area. Both are MOCK placeholders
/// until sections 04 and 05 are built (WO-2).
class CenterPlaceholder extends StatelessWidget {
  const CenterPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: ShellLayout.gap,
      children: [
        Expanded(
          child: SolidSurface(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 14, children: [
              Semantics(header: true, child: Text('PRIMARY FOCUS', style: ErmiasType.title(t))),
              Text('MOCK · conversation and cited answers arrive in section 04 (WO-2)',
                  style: ErmiasType.muted(t)),
            ]),
          ),
        ),
        SizedBox(
          height: ShellLayout.chatHeight,
          child: SolidSurface(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 10, children: [
              Text('Message', style: ErmiasType.heading(t, size: 13)),
              Text('MOCK · chat input arrives in section 05 (WO-2)', style: ErmiasType.muted(t)),
            ]),
          ),
        ),
      ],
    );
  }
}

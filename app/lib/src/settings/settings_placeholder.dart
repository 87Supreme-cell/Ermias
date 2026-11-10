import 'package:flutter/widgets.dart';

import '../icons/ermias_icons.dart';
import '../theme/background_painter.dart';
import '../theme/solid.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';
import '../widgets/ermias_button.dart';

/// Opened by the Settings gear. The model-providers screen is section 13 (WO-3).
class SettingsPlaceholder extends StatelessWidget {
  const SettingsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return CustomPaint(
      painter: ThemeBackgroundPainter(t.bg),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SolidSurface(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 12, children: [
                ErmiasButton(
                  icon: ErmiasIconData.chevronLeft,
                  semanticsLabel: 'Back to workbench',
                  label: 'Workbench',
                  onTap: () => Navigator.of(context).pop(),
                ),
                Semantics(header: true, child: Text('Settings', style: ErmiasType.heading(t, size: 18))),
                Text('MOCK · model providers (local runtimes and cloud API keys) arrive in section 13 (WO-3).',
                    style: ErmiasType.muted(t)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

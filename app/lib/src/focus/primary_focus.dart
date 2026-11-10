import 'package:flutter/widgets.dart';

import '../icons/ermias_icon.dart';
import '../icons/ermias_icons.dart';
import '../theme/solid.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';
import '../workspace/workspace_controller.dart';
import 'context_column.dart';
import 'conversation_view.dart';

/// Width of the side column (04, Locked).
const _sideColumnWidth = 250.0;

String formatThousands(int n) =>
    n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

/// 04: the conversation with cited answers, and exactly what the model sees.
class PrimaryFocus extends StatelessWidget {
  const PrimaryFocus({super.key, required this.controller});

  final WorkspaceController controller;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return SolidSurface(
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, state, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            Row(
              spacing: 8,
              children: [
                ErmiasIcon(ErmiasIconData.layoutFrame, color: t.ink),
                Semantics(
                  header: true,
                  child: Text('PRIMARY FOCUS', style: ErmiasType.title(t)),
                ),
                const Spacer(),
                Text(
                  '${formatThousands(state.tokensUsed)} of ${formatThousands(state.tokenWindow)} tokens',
                  style: ErmiasType.data(t, size: 12, color: t.muted),
                ),
              ],
            ),
            _ContextBar(used: state.tokensUsed / state.tokenWindow),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: ConversationView(turns: state.conversation)),
                  Container(
                    width: _sideColumnWidth + 17,
                    margin: const EdgeInsets.only(left: 16),
                    padding: const EdgeInsets.only(left: 16),
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: t.line)),
                    ),
                    child: ContextColumn(state: state),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextBar extends StatelessWidget {
  const _ContextBar({required this.used});

  final double used;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return Semantics(
      label: 'Context window ${(used * 100).round()}% used',
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: SizedBox(
          height: 6,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: t.track),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: used.clamp(0, 1),
                child: ColoredBox(color: t.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

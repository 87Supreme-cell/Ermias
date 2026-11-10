import 'package:flutter/widgets.dart';

import '../theme/glass.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';
import '../widgets/ermias_button.dart';
import '../workspace/workspace_controller.dart';

/// "Ask me before every call" (on by default): nothing leaves the machine
/// until the person approves this specific question (05, 11).
class ApprovalPrompt extends StatelessWidget {
  const ApprovalPrompt({super.key, required this.controller});

  final WorkspaceController controller;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: controller,
    builder: (context, state, _) {
      final question = state.pendingApproval;
      if (question == null) return const SizedBox.shrink();
      final t = ThemeScope.of(context);
      return Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(color: t.ink.withValues(alpha: 0.18)),
          ),
          Center(
            child: SizedBox(
              width: 520,
              child: Semantics(
                scopesRoute: true,
                namesRoute: true,
                label: 'Approve external call',
                explicitChildNodes: true,
                child: GlassSurface(
                  flyout: true,
                  radius: 16,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [
                      Text(
                        'Send this question to an external model?',
                        style: ErmiasType.heading(t, size: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: t.bubble,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(question, style: ErmiasType.text(t)),
                      ),
                      Text(
                        'Only this question leaves the machine. The answer is stored as data in external.db '
                        '(rank 5) and is never run as instructions. Both are logged.',
                        style: ErmiasType.muted(t, size: 12),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        spacing: 10,
                        children: [
                          ErmiasButton(
                            semanticsLabel: 'Decline',
                            label: 'Decline',
                            onTap: controller.declinePending,
                          ),
                          ErmiasButton(
                            semanticsLabel: 'Approve this call',
                            label: 'Approve this call',
                            tone: ErmiasButtonTone.warn,
                            onTap: controller.approvePending,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

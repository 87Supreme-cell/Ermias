import 'package:flutter/widgets.dart';

import '../theme/theme_scope.dart';
import '../theme/typography.dart';
import '../widgets/ermias_button.dart';
import '../workspace/workspace_controller.dart';

/// 09: progress against the benchmarks agreed at kickoff. Components and
/// weights are open question 2, so every number here is MOCK.
class ProjectGradePanel extends StatelessWidget {
  const ProjectGradePanel({
    super.key,
    required this.controller,
    required this.onReview,
  });

  final WorkspaceController controller;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, _) {
        final g = state.grade;
        final change =
            '${g.changeSinceMilestone >= 0 ? '+' : ''}${g.changeSinceMilestone.toStringAsFixed(1)}';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 8,
              runSpacing: 6,
              children: [
                Text(
                  g.total.toStringAsFixed(1),
                  style: ErmiasType.heading(t, size: 34).copyWith(height: 1),
                ),
                Text('/ 10', style: ErmiasType.muted(t, size: 14)),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: t.accentSoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    child: Text(
                      '$change since last milestone',
                      style: ErmiasType.text(
                        t,
                        size: 12,
                        weight: FontWeight.w500,
                      ).copyWith(color: t.accentText),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                for (final (name, value) in g.components)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: t.line)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: ErmiasType.text(t, size: 13),
                          ),
                        ),
                        Text(value, style: ErmiasType.data(t, size: 13)),
                      ],
                    ),
                  ),
              ],
            ),
            Text(
              'MOCK · grading formula is open question 2',
              style: ErmiasType.muted(t, size: 11),
            ),
            if (g.needsHuman.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: t.warnSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 6,
                  children: [
                    Text(
                      'Needs you',
                      style: ErmiasType.heading(
                        t,
                        size: 13,
                      ).copyWith(color: t.warnText),
                    ),
                    Text(
                      g.needsHuman.join(' · '),
                      style: ErmiasType.text(
                        t,
                        size: 12,
                      ).copyWith(color: t.warnText),
                    ),
                    const SizedBox(height: 4),
                    ErmiasButton(
                      semanticsLabel: 'Review now',
                      label: 'Review now',
                      tone: ErmiasButtonTone.warn,
                      onTap: onReview,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

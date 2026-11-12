import 'package:flutter/widgets.dart';

import '../theme/ermias_theme.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';
import '../workspace/models.dart';
import '../workspace/workspace_controller.dart';

/// 08: the project's stages; the current one in the accent color.
class TaskChainPanel extends StatelessWidget {
  const TaskChainPanel({super.key, required this.controller});

  final WorkspaceController controller;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: controller,
    builder: (context, state, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [for (final stage in state.tasks) _Stage(stage: stage)],
    ),
  );
}

class _Stage extends StatelessWidget {
  const _Stage({required this.stage});

  final TaskStage stage;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final current = stage.state == StepState.current;
    return Semantics(
      label: '${stage.name}, ${stage.state.name}. ${stage.note}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: current ? t.accentSoft : t.subtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: current ? t.accent : t.line),
        ),
        child: Row(
          spacing: 12,
          children: [
            StageMarker(state: stage.state),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    stage.name,
                    style: ErmiasType.text(
                      t,
                      size: 14,
                      weight: FontWeight.w500,
                    ),
                  ),
                  Text(stage.note, style: ErmiasType.muted(t, size: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filled dot = done, accent ring = current, muted ring = waiting.
class StageMarker extends StatelessWidget {
  const StageMarker({super.key, required this.state, this.size = 10});

  final StepState state;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final (fill, ring) = _colors(t);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fill,
        border: Border.all(color: ring, width: 1.6),
      ),
    );
  }

  (Color?, Color) _colors(ErmiasTheme t) => switch (state) {
    StepState.done => (t.accent, t.accent),
    StepState.current => (null, t.accent),
    StepState.waiting => (null, t.muted),
  };
}

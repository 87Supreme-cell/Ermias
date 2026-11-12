import 'package:flutter/widgets.dart';

import '../icons/ermias_icon.dart';
import '../icons/ermias_icons.dart';
import '../panels/task_chain_panel.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';
import '../workspace/models.dart';
import '../workspace/workspace_state.dart';

/// 04 side column: exactly what the model can see, drift flags, steps.
class ContextColumn extends StatelessWidget {
  const ContextColumn({super.key, required this.state});

  final WorkspaceState state;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final ranked = state.contextFiles.where((f) => !f.oneOff);
    final oneOff = state.contextFiles.where((f) => f.oneOff);
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: Semantics(
        header: true,
        child: Text(text, style: ErmiasType.heading(t, size: 13)),
      ),
    );
    return ListView(
      children: [
        heading('Files in context'),
        for (final f in ranked)
          _FileRow(
            label: f.label,
            trailing: '×${f.weight?.toStringAsFixed(1) ?? '–'}',
          ),
        if (oneOff.isNotEmpty) const SizedBox(height: 8),
        for (final f in oneOff)
          _FileRow(label: f.label, trailing: 'one-off · unranked', warn: true),
        const SizedBox(height: 8),
        heading('Drift flags'),
        for (final flag in state.driftFlags) _FlagRow(flag: flag),
        const SizedBox(height: 8),
        heading('Steps'),
        for (final step in state.steps) _StepRow(step: step),
      ],
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({
    required this.label,
    required this.trailing,
    this.warn = false,
  });

  final String label;
  final String trailing;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: ErmiasType.data(t, size: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            trailing,
            style: ErmiasType.data(
              t,
              size: 12,
              color: warn ? t.warnText : t.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlagRow extends StatelessWidget {
  const _FlagRow({required this.flag});

  final DriftFlag flag;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: flag.needsHuman ? t.warnSoft : t.subtle,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        flag.label,
        style: ErmiasType.text(
          t,
          size: 12,
        ).copyWith(color: flag.needsHuman ? t.warnText : t.muted),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step});

  final TaskStage step;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final current = step.state == StepState.current;
    return Semantics(
      label: '${step.name}, ${step.state.name}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          spacing: 7,
          children: [
            if (step.state == StepState.done)
              ErmiasIcon(ErmiasIconData.check, color: t.muted, size: 12)
            else
              StageMarker(state: step.state, size: 9),
            Text(
              step.name,
              style: ErmiasType.text(
                t,
                size: 12,
                weight: current ? FontWeight.w500 : FontWeight.w400,
              ).copyWith(color: current ? t.accentText : t.muted),
            ),
          ],
        ),
      ),
    );
  }
}

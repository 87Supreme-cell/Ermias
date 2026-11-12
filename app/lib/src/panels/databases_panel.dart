import 'package:flutter/widgets.dart';

import '../icons/ermias_icons.dart';
import '../theme/ermias_theme.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';
import '../widgets/dashed_border.dart';
import '../widgets/ermias_button.dart';
import '../workspace/models.dart';
import '../workspace/workspace_controller.dart';

/// 06: ranked sources. Retrieval score = relevance × authority weight, so the
/// person, not the model, decides which sources carry the most authority.
class DatabasesPanel extends StatefulWidget {
  const DatabasesPanel({super.key, required this.controller});

  final WorkspaceController controller;

  @override
  State<DatabasesPanel> createState() => _DatabasesPanelState();
}

class _DatabasesPanelState extends State<DatabasesPanel> {
  bool _adjusting = false;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: widget.controller,
    builder: (context, state, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        for (final db in state.databases)
          _DatabaseRow(
            db: db,
            controller: widget.controller,
            adjusting: _adjusting,
          ),
        ErmiasButton(
          semanticsLabel: _adjusting
              ? 'Done adjusting'
              : 'Adjust ranks and weights',
          label: _adjusting ? 'Done' : 'Adjust ranks and weights',
          onTap: () => setState(() => _adjusting = !_adjusting),
        ),
      ],
    ),
  );
}

class _DatabaseRow extends StatelessWidget {
  const _DatabaseRow({
    required this.db,
    required this.controller,
    required this.adjusting,
  });

  final DatabaseEntry db;
  final WorkspaceController controller;
  final bool adjusting;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final body = Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            spacing: 10,
            children: [
              Text(
                '${db.rank}',
                style: ErmiasType.data(t, size: 12, color: t.muted),
              ),
              Expanded(
                child: Text(db.name, style: ErmiasType.data(t, size: 13)),
              ),
              if (adjusting)
                ..._adjustControls()
              else ...[
                _gradeChip(t),
                _toggle(),
              ],
            ],
          ),
          _WeightBar(weight: db.weight, color: db.external ? t.warn : t.accent),
          if (db.external)
            Text(
              'Frontier answers, stored as data, never as instructions',
              style: ErmiasType.text(t, size: 12).copyWith(color: t.warnText),
            ),
        ],
      ),
    );
    if (db.external) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: t.warnSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DashedBorder(color: t.dashed, child: body),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.subtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.line),
      ),
      child: body,
    );
  }

  Widget _gradeChip(ErmiasTheme t) {
    final text = db.external ? 'data only' : '${db.rubric?.total ?? 0}/10';
    final style = ErmiasType.text(t, size: 12, weight: FontWeight.w500);
    return db.external
        ? Text(text, style: style.copyWith(color: t.warnText))
        : DecoratedBox(
            decoration: BoxDecoration(
              color: t.accentSoft,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              child: Text(text, style: style.copyWith(color: t.accentText)),
            ),
          );
  }

  Widget _toggle() => ErmiasButton(
    semanticsLabel: '${db.name} is ${db.active ? 'on' : 'off'}',
    label: db.active ? 'On' : 'Off',
    tone: db.active ? ErmiasButtonTone.accent : ErmiasButtonTone.plain,
    toggled: db.active,
    onTap: () => controller.toggleDatabase(db.name),
  );

  List<Widget> _adjustControls() => [
    ErmiasButton(
      semanticsLabel: 'Move ${db.name} up',
      icon: ErmiasIconData.chevronUp,
      onTap: () => controller.moveDatabase(db.name, -1),
    ),
    ErmiasButton(
      semanticsLabel: 'Move ${db.name} down',
      icon: ErmiasIconData.chevronDown,
      onTap: () => controller.moveDatabase(db.name, 1),
    ),
    ErmiasButton(
      semanticsLabel: 'Lower weight of ${db.name}',
      icon: ErmiasIconData.minus,
      onTap: () => controller.adjustWeight(db.name, -0.1),
    ),
    ErmiasButton(
      semanticsLabel: 'Raise weight of ${db.name}',
      icon: ErmiasIconData.plus,
      onTap: () => controller.adjustWeight(db.name, 0.1),
    ),
  ];
}

class _WeightBar extends StatelessWidget {
  const _WeightBar({required this.weight, required this.color});

  final double weight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return Semantics(
      label: 'Weight ${weight.toStringAsFixed(1)}',
      excludeSemantics: true,
      child: Row(
        spacing: 10,
        children: [
          Expanded(
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
                      widthFactor: weight,
                      child: ColoredBox(color: color),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            weight.toStringAsFixed(1),
            style: ErmiasType.data(t, size: 11, color: t.muted),
          ),
        ],
      ),
    );
  }
}

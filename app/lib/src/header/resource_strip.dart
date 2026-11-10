import 'package:flutter/widgets.dart';

import '../icons/risk_shape.dart';
import '../theme/ermias_theme.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';
import 'resource_source.dart';

const _gib = 1024 * 1024 * 1024;

String formatMemory(MemoryReading m) =>
    '${(m.usedBytes / _gib).toStringAsFixed(1)} / ${(m.totalBytes / _gib).toStringAsFixed(1)} GB';

String formatClock(DateTime t) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
}

/// Row 1 resource strip: model and hash check, memory, CPU, network, clock.
class ResourceStrip extends StatelessWidget {
  const ResourceStrip({
    super.key,
    required this.model,
    required this.check,
    required this.reading,
    required this.networkSummary,
  });

  final ModelIdentity model;
  final ModelCheck? check;
  final ResourceReading? reading;

  /// From the connections monitor (MOCK until WO-6).
  final String networkSummary;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final r = reading;
    const unavailable = 'unavailable';
    return Wrap(
      spacing: 18,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children:
          [
                _Segment(
                  label: 'Model',
                  child: _ModelValue(model: model, check: check),
                ),
                _Segment(
                  label: 'Memory',
                  value: r == null
                      ? '—'
                      : (r.memory == null
                            ? unavailable
                            : formatMemory(r.memory!)),
                  spoken: r != null && r.memory == null
                      ? 'Memory unavailable: ${r.error}'
                      : null,
                ),
                _Segment(
                  label: 'CPU',
                  value: r == null
                      ? '—'
                      : (r.cpuPercent == null
                            ? unavailable
                            : '${r.cpuPercent!.round()}%'),
                  spoken: r != null && r.cpuPercent == null
                      ? 'CPU unavailable: ${r.error}'
                      : null,
                ),
                _Segment(label: 'Network', value: '$networkSummary · MOCK'),
                _Segment(
                  label: 'Clock',
                  value: r == null ? '—' : formatClock(r.at),
                ),
              ]
              .map((w) => DefaultTextStyle(style: ErmiasType.data(t), child: w))
              .toList(),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, this.value, this.child, this.spoken});

  final String label;
  final String? value;
  final Widget? child;

  /// Screen-reader text that replaces the visible text, e.g. a failure cause.
  final String? spoken;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 7,
      children: [
        Text(label, style: ErmiasType.data(t, color: t.muted)),
        child ?? Text(value!, style: ErmiasType.data(t)),
      ],
    );
    final text = spoken;
    return text == null
        ? row
        : Semantics(label: text, excludeSemantics: true, child: row);
  }
}

class _ModelValue extends StatelessWidget {
  const _ModelValue({required this.model, required this.check});

  final ModelIdentity model;
  final ModelCheck? check;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final h = model.pinnedSha256;
    final base = '${model.name} (MOCK) · ${model.quantization}';
    return switch (check) {
      null => Text(
        '$base · checking hash…',
        style: ErmiasType.data(t, color: t.muted),
      ),
      ModelCheck.ok => Text(
        '$base · hash ${h.substring(0, 4)}…${h.substring(h.length - 2)} ✓',
        style: ErmiasType.data(t),
      ),
      ModelCheck.mismatch => _warning(
        t,
        '$base · hash mismatch',
        'warning: model hash mismatch',
      ),
      ModelCheck.missing => _warning(
        t,
        '$base · model file missing',
        'warning: model file missing',
      ),
    };
  }

  Widget _warning(ErmiasTheme t, String text, String spoken) => Semantics(
    label: spoken,
    excludeSemantics: true,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 5,
      children: [
        RiskMark(RiskShape.triangle, color: t.warnText, size: 11),
        Text(text, style: ErmiasType.data(t, color: t.warnText)),
      ],
    ),
  );
}

import 'package:flutter/foundation.dart';

import '../audit/audit_sink.dart';
import '../shell/shell_figures.dart';
import '../shell/shell_state.dart';
import 'models.dart';
import 'workspace_state.dart';

/// Holds the [WorkspaceState] and applies the person's actions to it.
/// Every change produces a new state; spec-logged actions are recorded in the
/// audit log. Also the app's [AuditSink] and the source of strip figures.
class WorkspaceController extends ValueNotifier<WorkspaceState>
    implements AuditSink, ShellFigures {
  WorkspaceController(super.value, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  // ── Audit ────────────────────────────────────────────────────────────────

  @override
  void record(AuditEntry entry) =>
      value = value.copyWith(audit: List.unmodifiable([entry, ...value.audit]));

  void _log(
    String kind,
    String summary, {
    bool needsHuman = false,
    String? detail,
  }) => record(
    AuditEntry(
      time: _now(),
      kind: kind,
      summary: summary,
      needsHuman: needsHuman,
      detail: detail,
    ),
  );

  // ── Strip figures ────────────────────────────────────────────────────────

  @override
  bool get isMock => true;

  @override
  String figureFor(PanelId id) {
    final s = value;
    return switch (id) {
      PanelId.databases =>
        '${s.databases.where((d) => d.active).length}/${s.databases.length}',
      PanelId.auditLog => '${s.audit.length}',
      PanelId.taskChain => _taskFigure(s.tasks),
      PanelId.projectGrade => s.grade.total.toStringAsFixed(1),
    };
  }

  String _taskFigure(List<TaskStage> tasks) {
    final current = tasks
        .where((t) => t.state == StepState.current)
        .firstOrNull;
    if (current?.step != null && current?.stepsTotal != null)
      return '${current!.step}/${current.stepsTotal}';
    return '${tasks.where((t) => t.state == StepState.done).length}/${tasks.length}';
  }

  @override
  int needsYou(PanelSide side) => side == PanelSide.left
      ? value.audit.where((e) => e.needsHuman).length
      : value.grade.needsHuman.length;

  // ── 06 Databases ─────────────────────────────────────────────────────────

  void toggleDatabase(String name) {
    final db = _database(name);
    _replaceDatabase(db.copyWith(active: !db.active));
    _log('setting_change', '${db.active ? 'Turned off' : 'Turned on'} $name');
  }

  void moveDatabase(String name, int delta) {
    final list = [...value.databases];
    final from = list.indexWhere((d) => d.name == name);
    final to = from + delta;
    if (from < 0 || to < 0 || to >= list.length) return;
    list.insert(to, list.removeAt(from));
    value = value.copyWith(databases: _reranked(list));
    _log('setting_change', 'Moved $name to rank ${to + 1}');
  }

  void adjustWeight(String name, double delta) {
    final db = _database(name);
    final weight = ((db.weight + delta) * 10).round().clamp(0, 10) / 10;
    if (weight == db.weight) return;
    _replaceDatabase(db.copyWith(weight: weight));
    _log(
      'setting_change',
      'Weight of $name set to ${weight.toStringAsFixed(1)}',
    );
  }

  DatabaseEntry _database(String name) =>
      value.databases.firstWhere((d) => d.name == name);

  void _replaceDatabase(DatabaseEntry next) => value = value.copyWith(
    databases: List.unmodifiable(
      value.databases.map((d) => d.name == next.name ? next : d),
    ),
  );

  List<DatabaseEntry> _reranked(List<DatabaseEntry> list) => List.unmodifiable([
    for (final (i, d) in list.indexed) d.copyWith(rank: i + 1),
  ]);

  // ── 03 Connections ───────────────────────────────────────────────────────

  void revokeConnection(String id) => _dropConnection(id, 'Revoked');

  void endConnection(String id) => _dropConnection(id, 'Ended');

  void _dropConnection(String id, String verb) {
    final connection = value.connections.firstWhere((c) => c.id == id);
    value = value.copyWith(
      connections: List.unmodifiable(
        value.connections.where((c) => c.id != id),
      ),
    );
    _log(
      'connection_change',
      '$verb ${connection.name} · ${connection.tier.name}',
      detail: '${connection.destination}\n${connection.details.join('\n')}',
    );
  }

  // ── 05 Chat input ────────────────────────────────────────────────────────

  void attachOneOff(String name) => value = value.copyWith(
    contextFiles: List.unmodifiable([
      ...value.contextFiles,
      ContextFile.oneOff(name),
    ]),
  );

  void selectModel(ModelChoice model) => value = value.copyWith(model: model);

  void selectTools(ToolChoice tools) => value = value.copyWith(tools: tools);

  /// Local: answers at once. External with "Ask me before every call" on:
  /// waits for [approvePending] or [declinePending]; nothing leaves before.
  void send(String question) {
    final text = question.trim();
    if (text.isEmpty) return;
    if (value.model == ModelChoice.external && value.askBeforeEveryCall) {
      value = value.copyWith(pendingApproval: () => text);
      return;
    }
    _answer(text);
  }

  void approvePending() {
    final question = value.pendingApproval;
    if (question == null) return;
    value = value.copyWith(pendingApproval: () => null);
    _log('approval', 'Approved external call · question only');
    _log(
      'left_machine',
      'Left machine · question only · ${question.split(RegExp(r'\s+')).length} words',
    );
    _answer(question);
  }

  void declinePending() {
    if (value.pendingApproval == null) return;
    value = value.copyWith(pendingApproval: () => null);
    _log('approval', 'Declined external call · nothing sent');
  }

  void _answer(String question) {
    final external = value.model == ModelChoice.external;
    final turn = Turn(
      question: question,
      model: external ? 'External · data only' : 'Olmo-3-7B-Instruct',
      answer: [
        Sentence(
          text: external
              ? 'MOCK · the external answer is stored as data in external.db, never run as instructions.'
              : 'MOCK · a cited answer arrives once a local model is connected (WO-3).',
          citation: external
              ? const ContextFile(
                  database: 'external',
                  chunkId: '0001',
                  weight: 0.2,
                )
              : const ContextFile(
                  database: 'laws',
                  chunkId: '1182',
                  weight: 1.0,
                ),
          sourceExcerpt: 'MOCK source text.',
        ),
      ],
    );
    value = value.copyWith(
      conversation: List.unmodifiable([...value.conversation, turn]),
    );
  }
}

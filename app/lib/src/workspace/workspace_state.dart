import 'package:flutter/foundation.dart';

import '../audit/audit_sink.dart';
import 'models.dart';

/// Everything the workbench shows, in one immutable value.
@immutable
class WorkspaceState {
  const WorkspaceState({
    required this.databases,
    required this.connections,
    required this.conversation,
    required this.contextFiles,
    required this.tokensUsed,
    required this.tokenWindow,
    required this.steps,
    required this.tasks,
    required this.grade,
    required this.audit,
    this.model = ModelChoice.local,
    this.tools = ToolChoice.searchAndGetSource,
    this.askBeforeEveryCall = true,
    this.pendingApproval,
  });

  final List<DatabaseEntry> databases;
  final List<Connection> connections;
  final List<Turn> conversation;
  final List<ContextFile> contextFiles;
  final int tokensUsed;
  final int tokenWindow;
  final List<TaskStage> steps;
  final List<TaskStage> tasks;
  final GradeSnapshot grade;

  /// Newest first.
  final List<AuditEntry> audit;
  final ModelChoice model;
  final ToolChoice tools;
  final bool askBeforeEveryCall;

  /// A question waiting for the person's approval before it may leave.
  final String? pendingApproval;

  int countOf(ConnectionTier tier) =>
      connections.where((c) => c.tier == tier).length;

  /// 04: Claim n · samples disagreed, Scope, Sources (open question 3).
  List<DriftFlag> get driftFlags {
    final sentences = conversation.expand((t) => t.answer).toList();
    final split = sentences.indexWhere((s) => s.samplesDisagreed);
    final uncited = sentences.where((s) => s.citation == null).length;
    return List.unmodifiable([
      if (split >= 0)
        DriftFlag('Claim ${split + 1} · samples disagreed', needsHuman: true),
      const DriftFlag('Scope · on task', needsHuman: false),
      uncited == 0
          ? const DriftFlag('Sources · all claims cited', needsHuman: false)
          : DriftFlag(
              'Sources · $uncited uncited ${uncited == 1 ? 'claim' : 'claims'}',
              needsHuman: true,
            ),
    ]);
  }

  WorkspaceState copyWith({
    List<DatabaseEntry>? databases,
    List<Connection>? connections,
    List<Turn>? conversation,
    List<ContextFile>? contextFiles,
    List<AuditEntry>? audit,
    ModelChoice? model,
    ToolChoice? tools,
    String? Function()? pendingApproval,
  }) => WorkspaceState(
    databases: databases ?? this.databases,
    connections: connections ?? this.connections,
    conversation: conversation ?? this.conversation,
    contextFiles: contextFiles ?? this.contextFiles,
    tokensUsed: tokensUsed,
    tokenWindow: tokenWindow,
    steps: steps,
    tasks: tasks,
    grade: grade,
    audit: audit ?? this.audit,
    model: model ?? this.model,
    tools: tools ?? this.tools,
    askBeforeEveryCall: askBeforeEveryCall,
    pendingApproval: pendingApproval == null
        ? this.pendingApproval
        : pendingApproval(),
  );

  WorkspaceState withConversation(List<Turn> turns) =>
      copyWith(conversation: List.unmodifiable(turns));
}

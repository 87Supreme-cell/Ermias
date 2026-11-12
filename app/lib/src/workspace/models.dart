import 'package:flutter/foundation.dart';

// Value types shaped like Code/shared/contracts/*.schema.json.

/// 06: five-part rubric, 0–2 each.
@immutable
class Rubric {
  const Rubric(
    this.provenance,
    this.license,
    this.pii,
    this.reproducible,
    this.audit,
  );

  final int provenance;
  final int license;
  final int pii;
  final int reproducible;
  final int audit;

  int get total => provenance + license + pii + reproducible + audit;
}

/// 06: one ranked source (database_entry.schema.json).
@immutable
class DatabaseEntry {
  const DatabaseEntry({
    required this.name,
    required this.path,
    required this.rank,
    required this.weight,
    required this.active,
    required this.external,
    required this.sha256,
    this.rubric,
  });

  final String name;
  final String path;
  final int rank;
  final double weight;
  final bool active;
  final bool external;
  final String sha256;
  final Rubric? rubric;

  DatabaseEntry copyWith({int? rank, double? weight, bool? active}) =>
      DatabaseEntry(
        name: name,
        path: path,
        rank: rank ?? this.rank,
        weight: weight ?? this.weight,
        active: active ?? this.active,
        external: external,
        sha256: sha256,
        rubric: rubric,
      );
}

enum ConnectionTier { local, hybrid, exposed }

/// 03: one external connection (connection.schema.json).
@immutable
class Connection {
  const Connection({
    required this.id,
    required this.name,
    required this.destination,
    required this.tier,
    this.details = const [],
  });

  final String id;
  final String name;
  final String destination;
  final ConnectionTier tier;

  /// Process, what was sent and received, approval, encryption: one line each.
  final List<String> details;
}

/// 04: a chunk the model can see (citation.schema.json), or a one-off document.
@immutable
class ContextFile {
  const ContextFile({
    required this.database,
    required this.chunkId,
    this.weight,
    this.oneOff = false,
  });

  const ContextFile.oneOff(String name)
    : this(database: name, chunkId: '', oneOff: true);

  final String database;
  final String chunkId;
  final double? weight;
  final bool oneOff;

  String get label => oneOff ? database : '$database · $chunkId';
}

/// Repeated samples of the same question compared by meaning (open question 3).
@immutable
class SampleCheck {
  const SampleCheck({required this.disagreed, required this.of});

  final int disagreed;
  final int of;
}

/// 04: one answer sentence and the source it came from.
@immutable
class Sentence {
  const Sentence({
    required this.text,
    this.citation,
    this.samples,
    this.sourceExcerpt,
  });

  final String text;
  final ContextFile? citation;
  final SampleCheck? samples;

  /// Text of the cited chunk, shown when its chip is opened.
  final String? sourceExcerpt;

  bool get samplesDisagreed => samples != null && samples!.disagreed > 0;
}

@immutable
class Turn {
  const Turn({
    required this.question,
    required this.model,
    required this.answer,
  });

  final String question;
  final String model;
  final List<Sentence> answer;
}

enum StepState { done, current, waiting }

/// 04 Steps and 08 stages (task.schema.json).
@immutable
class TaskStage {
  const TaskStage({
    required this.name,
    required this.state,
    this.note = '',
    this.step,
    this.stepsTotal,
  });

  final String name;
  final StepState state;
  final String note;
  final int? step;
  final int? stepsTotal;
}

/// 09: grade snapshot (grade.schema.json). Formula is open question 2.
@immutable
class GradeSnapshot {
  const GradeSnapshot({
    required this.total,
    required this.changeSinceMilestone,
    required this.components,
    required this.needsHuman,
  });

  final double total;
  final double changeSinceMilestone;
  final List<(String, String)> components;
  final List<String> needsHuman;
}

@immutable
class DriftFlag {
  const DriftFlag(this.label, {required this.needsHuman});

  final String label;
  final bool needsHuman;
}

enum ModelChoice { local, external }

enum ToolChoice { searchAndGetSource, searchOnly }

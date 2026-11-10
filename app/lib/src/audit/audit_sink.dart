import 'package:flutter/foundation.dart';

/// One audit event. Mirrors the required fields of
/// `Code/shared/contracts/audit_event.schema.json`.
@immutable
class AuditEntry {
  const AuditEntry({
    required this.time,
    required this.kind,
    required this.summary,
    required this.needsHuman,
  });

  final DateTime time;
  final String kind;
  final String summary;
  final bool needsHuman;
}

/// Where audit events go. The real, persisted log is section 07 (WO-2).
abstract interface class AuditSink {
  void record(AuditEntry entry);
}

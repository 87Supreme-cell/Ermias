import 'dart:async';

import 'package:flutter/foundation.dart';

import '../rust/api/hash.dart' as rust_hash;
import '../rust/api/system.dart' as rust_system;

@immutable
class MemoryReading {
  const MemoryReading({required this.usedBytes, required this.totalBytes});

  final int usedBytes;
  final int totalBytes;
}

/// One sample for the header resource strip. A field is null when that
/// reading failed; [error] then says why.
@immutable
class ResourceReading {
  const ResourceReading({
    required this.memory,
    required this.cpuPercent,
    required this.at,
    this.error,
  });

  final MemoryReading? memory;
  final double? cpuPercent;
  final DateTime at;
  final String? error;
}

/// The model the header reports on, and the SHA-256 it is pinned to.
@immutable
class ModelIdentity {
  const ModelIdentity({
    required this.name,
    required this.quantization,
    required this.path,
    required this.pinnedSha256,
  });

  final String name;
  final String quantization;
  final String path;
  final String pinnedSha256;
}

enum ModelCheck { ok, mismatch, missing }

/// Live system figures and the model integrity check (02_header_status).
abstract interface class ResourceSource {
  Stream<ResourceReading> readings(Duration every);

  Future<ModelCheck> checkModel(ModelIdentity model);
}

/// Wait after the CPU baseline sample; above sysinfo's minimum (200 ms).
const cpuBaselineInterval = Duration(milliseconds: 250);

/// Reads memory, CPU and file hashes from the Rust core.
class RustResourceSource implements ResourceSource {
  const RustResourceSource();

  @override
  Stream<ResourceReading> readings(Duration every) async* {
    // CPU usage is a delta between two samples. Take a baseline first so
    // the first reading shown is a real measurement, not ~0%.
    try {
      await rust_system.cpuPercent();
    } catch (_) {
      // The next sample reports the same failure in ResourceReading.error.
    }
    await Future<void>.delayed(cpuBaselineInterval);
    while (true) {
      yield await _sample();
      await Future<void>.delayed(every);
    }
  }

  Future<ResourceReading> _sample() async {
    final errors = <String>[];
    MemoryReading? memory;
    double? cpu;
    try {
      final m = await rust_system.memorySnapshot();
      memory = MemoryReading(
        usedBytes: m.usedBytes.toInt(),
        totalBytes: m.totalBytes.toInt(),
      );
    } catch (e) {
      errors.add('memory: $e');
    }
    try {
      cpu = await rust_system.cpuPercent();
    } catch (e) {
      errors.add('cpu: $e');
    }
    return ResourceReading(
      memory: memory,
      cpuPercent: cpu,
      at: DateTime.now(),
      error: errors.isEmpty ? null : errors.join('; '),
    );
  }

  @override
  Future<ModelCheck> checkModel(ModelIdentity model) async {
    try {
      final matches = await rust_hash.verifyPinned(
        path: model.path,
        expectedHex: model.pinnedSha256,
      );
      return matches ? ModelCheck.ok : ModelCheck.mismatch;
    } catch (_) {
      // Unreadable or missing file: never treated as a pass.
      return ModelCheck.missing;
    }
  }
}

import 'dart:async';

import 'package:ermias/src/header/resource_source.dart';

/// Test double: emits readings pushed by the test, and a fixed model check.
class FakeResourceSource implements ResourceSource {
  FakeResourceSource({this.check = ModelCheck.ok});

  final _controller = StreamController<ResourceReading>.broadcast();
  ModelCheck check;

  void emit(ResourceReading reading) => _controller.add(reading);

  @override
  Stream<ResourceReading> readings(Duration every) => _controller.stream;

  @override
  Future<ModelCheck> checkModel(ModelIdentity model) async => check;
}

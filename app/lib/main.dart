import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'src/app.dart';
import 'src/header/resource_source.dart';
import 'src/mock/mock_data.dart';
import 'src/rust/frb_generated.dart';
import 'src/theme/theme_catalog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  final catalog = ThemeCatalog.fromJsonString(await rootBundle.loadString('assets/themes.json'));
  runApp(ErmiasApp(
    catalog: catalog,
    resources: const RustResourceSource(),
    audit: MockAuditSink(),
    model: mockModelAt(await _writeMockModel()),
  ));
}

/// MOCK: writes the mock model file once, so the header's SHA-256 check runs
/// for real. An existing file is left as is, so editing it shows a mismatch.
Future<String> _writeMockModel() async {
  final file = File('${Directory.systemTemp.path}/ermias-mock-model.bin');
  if (!file.existsSync()) await file.writeAsString(mockModelContents, flush: true);
  return file.path;
}

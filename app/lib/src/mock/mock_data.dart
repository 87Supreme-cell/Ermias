import '../header/resource_source.dart';
import '../shell/shell_figures.dart';
import '../shell/shell_state.dart';

// MOCK: every value in this file is mock data from the approved reference
// design. Each is replaced by a real source in a later work order without
// changing the interface it implements.

/// MOCK strip figures (reference: Code/reference/Main.dc.html).
class MockShellFigures implements ShellFigures {
  const MockShellFigures();

  static const _figures = {
    PanelId.databases: '4/5', // MOCK → 06_databases (WO-5)
    PanelId.auditLog: '5', // MOCK → 07_audit_log (WO-2)
    PanelId.taskChain: '4/5', // MOCK → 08_task_chain (WO-2)
    PanelId.projectGrade: '8.1', // MOCK → 09_project_grade (WO-7)
  };

  @override
  String figureFor(PanelId id) => _figures[id]!;

  @override
  int needsYou(PanelSide side) => 2; // MOCK

  @override
  bool get isMock => true;
}

/// MOCK panel subtitle that depends on project data.
const mockTaskChainPath = 'Engineering → Code → Tech data'; // MOCK → 08 (WO-2)

/// MOCK session state. Real state arrives with sign-in (12, WO-3).
const mockSessionPill = 'Sterile session · state verified · key present';

/// MOCK connection counts per tier (03, WO-6).
const mockConnectionCounts = (local: 4, hybrid: 2, exposed: 1);

/// MOCK model file. The app writes these bytes on start-up and pins their
/// SHA-256, so the header's hash check runs for real against a mock file.
/// Real models come from Settings → model providers (13, WO-3).
const mockModelContents = 'Ermias MOCK model file v1\n';
const mockModelSha256 =
    'af8890cd28043edb95b8ddaa702c68424531628b7d8e106fc548ee3434391fe7';

ModelIdentity mockModelAt(String path) => ModelIdentity(
  name: 'Olmo-3-7B-Instruct',
  quantization: 'Q4',
  path: path,
  pinnedSha256: mockModelSha256,
);

/// Mock model identity for tests and previews.
final mockModel = mockModelAt('mock-model.bin');

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

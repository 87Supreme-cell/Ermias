import 'package:flutter/widgets.dart';

import 'focus/approval_prompt.dart';
import 'focus/chat_input.dart';
import 'focus/primary_focus.dart';
import 'header/header_bar.dart';
import 'header/resource_source.dart';
import 'panels/audit_log_panel.dart';
import 'panels/databases_panel.dart';
import 'panels/project_grade_panel.dart';
import 'panels/task_chain_panel.dart';
import 'settings/settings_placeholder.dart';
import 'shell/layout.dart';
import 'shell/shell_state.dart';
import 'shell/workbench.dart';
import 'theme/theme_catalog.dart';
import 'theme/theme_scope.dart';
import 'workspace/workspace_controller.dart';

/// Root widget: holds the active theme and the shell state, and routes
/// between the workbench, the full audit log and Settings.
class ErmiasApp extends StatefulWidget {
  const ErmiasApp({
    super.key,
    required this.catalog,
    required this.resources,
    required this.workspace,
    required this.model,
  });

  final ThemeCatalog catalog;
  final ResourceSource resources;
  final WorkspaceController workspace;
  final ModelIdentity model;

  @override
  State<ErmiasApp> createState() => _ErmiasAppState();
}

class _ErmiasAppState extends State<ErmiasApp> {
  // Where the chosen theme is saved is open question 8; until then it
  // resets to the default on each launch.
  String _theme = ThemeCatalog.defaultName;
  ShellState _shell = const ShellState();

  void _openPanel(PanelId id) => setState(() => _shell = _shell.open(id));

  Widget _panelBody(BuildContext context, PanelId id) {
    final w = widget.workspace;
    return switch (id) {
      PanelId.databases => DatabasesPanel(controller: w),
      PanelId.auditLog => AuditLogPanel(
        controller: w,
        onOpenFull: () => Navigator.of(context).pushNamed('/audit'),
      ),
      PanelId.taskChain => TaskChainPanel(controller: w),
      PanelId.projectGrade => ProjectGradePanel(
        controller: w,
        onReview: () => _openPanel(PanelId.auditLog),
      ),
    };
  }

  Widget _workbench(BuildContext context) => Workbench(
    state: _shell,
    onChanged: (update) => setState(() => _shell = update(_shell)),
    figures: widget.workspace,
    panelBody: (id) => _panelBody(context, id),
    header: HeaderBar(
      resources: widget.resources,
      workspace: widget.workspace,
      model: widget.model,
      catalog: widget.catalog,
      activeTheme: _theme,
      onTheme: (name) => setState(() => _theme = name),
      onSettings: () => Navigator.of(context).pushNamed('/settings'),
      onOpenAuditLog: () => _openPanel(PanelId.auditLog),
    ),
    center: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: ShellLayout.gap,
      children: [
        Expanded(child: PrimaryFocus(controller: widget.workspace)),
        SizedBox(
          height: ShellLayout.chatHeight,
          child: ChatInput(controller: widget.workspace),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = widget.catalog[_theme];
    return WidgetsApp(
      title: 'Ermias',
      debugShowCheckedModeBanner: false,
      color: theme.accent,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) =>
          PageRouteBuilder<T>(
            settings: settings,
            pageBuilder: (context, _, _) => builder(context),
          ),
      builder: (context, navigator) => ThemeScope(
        theme: theme,
        child: Stack(
          children: [
            navigator!,
            ApprovalPrompt(controller: widget.workspace),
          ],
        ),
      ),
      routes: {
        '/': _workbench,
        '/audit': (context) => FullAuditLog(controller: widget.workspace),
        '/settings': (context) => const SettingsPlaceholder(),
      },
    );
  }
}

import 'package:flutter/widgets.dart';

import 'audit/audit_sink.dart';
import 'header/header_bar.dart';
import 'header/resource_source.dart';
import 'settings/settings_placeholder.dart';
import 'shell/shell_state.dart';
import 'shell/workbench.dart';
import 'theme/theme_catalog.dart';
import 'theme/theme_scope.dart';

/// Root widget: holds the active theme and the shell state, and routes
/// between the workbench and Settings.
class ErmiasApp extends StatefulWidget {
  const ErmiasApp({
    super.key,
    required this.catalog,
    required this.resources,
    required this.audit,
    required this.model,
  });

  final ThemeCatalog catalog;
  final ResourceSource resources;
  final AuditSink audit;
  final ModelIdentity model;

  @override
  State<ErmiasApp> createState() => _ErmiasAppState();
}

class _ErmiasAppState extends State<ErmiasApp> {
  // Where the chosen theme is saved is open question 8; until then it
  // resets to the default on each launch.
  String _theme = ThemeCatalog.defaultName;
  ShellState _shell = const ShellState();

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
      builder: (context, navigator) =>
          ThemeScope(theme: theme, child: navigator!),
      routes: {
        '/': (context) => Workbench(
          state: _shell,
          onChanged: (update) => setState(() => _shell = update(_shell)),
          header: HeaderBar(
            resources: widget.resources,
            audit: widget.audit,
            model: widget.model,
            catalog: widget.catalog,
            activeTheme: _theme,
            onTheme: (name) => setState(() => _theme = name),
            onSettings: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ),
        '/settings': (context) => const SettingsPlaceholder(),
      },
    );
  }
}

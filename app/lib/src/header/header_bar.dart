import 'dart:async';

import 'package:flutter/widgets.dart';

import '../audit/audit_sink.dart';
import '../workspace/workspace_controller.dart';
import '../icons/ermias_icon.dart';
import '../icons/ermias_icons.dart';
import '../mock/mock_data.dart';
import '../theme/glass.dart';
import '../theme/theme_catalog.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';
import '../widgets/ermias_button.dart';
import 'connections_box.dart';
import 'resource_source.dart';
import 'resource_strip.dart';
import 'theme_switch.dart';

/// How often the resource strip refreshes.
const resourceInterval = Duration(seconds: 2);

/// The two-row header (02_header_status). Row 1: name, session, resources.
/// Row 2: theme switch, Briefing room, Settings, and the connections box,
/// centered.
class HeaderBar extends StatefulWidget {
  const HeaderBar({
    super.key,
    required this.resources,
    required this.workspace,
    required this.model,
    required this.catalog,
    required this.activeTheme,
    required this.onTheme,
    required this.onSettings,
    required this.onOpenAuditLog,
  });

  final ResourceSource resources;

  /// Workspace: audit sink for the hash check, source of connections.
  final WorkspaceController workspace;
  final ModelIdentity model;
  final ThemeCatalog catalog;
  final String activeTheme;
  final ValueChanged<String> onTheme;
  final VoidCallback onSettings;
  final VoidCallback onOpenAuditLog;

  @override
  State<HeaderBar> createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar> {
  ResourceReading? _reading;
  ModelCheck? _check;
  StreamSubscription<ResourceReading>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.resources.readings(resourceInterval).listen((r) {
      if (mounted) setState(() => _reading = r);
    });
    unawaited(_checkModel());
  }

  Future<void> _checkModel() async {
    final check = await widget.resources.checkModel(widget.model);
    if (!mounted) return;
    setState(() => _check = check);
    if (check != ModelCheck.ok) {
      widget.workspace.record(
        AuditEntry(
          time: DateTime.now(),
          kind: check == ModelCheck.mismatch
              ? 'model_hash_mismatch'
              : 'model_file_missing',
          summary:
              '${widget.model.name}: ${check.name} (pinned ${widget.model.pinnedSha256})',
          needsHuman: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return GlassSurface(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Wrap(
            spacing: 20,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: [
                  Text('Ermias', style: ErmiasType.heading(t, size: 18)),
                  const _SessionPill(),
                ],
              ),
              ValueListenableBuilder(
                valueListenable: widget.workspace,
                builder: (context, state, _) => ResourceStrip(
                  model: widget.model,
                  check: _check,
                  reading: _reading,
                  networkSummary: state.networkSummary,
                ),
              ),
            ],
          ),
          _secondRow(),
        ],
      ),
    );
  }

  /// Equal flexible space on both sides keeps the connections box centered.
  Widget _secondRow() => Row(
    children: [
      Expanded(
        child: LayoutBuilder(
          builder: (context, box) {
            final compact = box.maxWidth < 380;
            return Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  ThemeSwitch(
                    catalog: widget.catalog,
                    active: widget.activeTheme,
                    onPick: widget.onTheme,
                  ),
                  ErmiasButton(
                    icon: ErmiasIconData.users,
                    semanticsLabel: 'Briefing room',
                    label: compact ? null : 'Briefing room',
                    onTap: null, // Behavior is open question 6.
                  ),
                  ErmiasButton(
                    icon: ErmiasIconData.settings,
                    semanticsLabel: 'Settings',
                    iconSize: 20,
                    onTap: widget.onSettings,
                  ),
                ],
              ),
            );
          },
        ),
      ),
      ConnectionsBox(
        key: const ValueKey('connections-box'),
        controller: widget.workspace,
        onOpenAuditLog: widget.onOpenAuditLog,
      ),
      const Expanded(child: SizedBox.shrink()),
    ],
  );
}

class _SessionPill extends StatelessWidget {
  const _SessionPill();

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.accentSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            ErmiasIcon(
              ErmiasIconData.shieldCheck,
              color: t.accentText,
              size: 14,
            ),
            Text(
              '$mockSessionPill · MOCK',
              style: ErmiasType.text(
                t,
                size: 13,
                weight: FontWeight.w500,
              ).copyWith(color: t.accentText),
            ),
          ],
        ),
      ),
    );
  }
}

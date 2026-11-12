import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../icons/ermias_icons.dart';
import '../theme/solid.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';
import '../widgets/ermias_button.dart';
import '../widgets/ermias_select.dart';
import '../workspace/models.dart';
import '../workspace/workspace_controller.dart';

/// 05: message area under PRIMARY FOCUS. Fixed height; tools offered are
/// only those on the gate's allowlist.
class ChatInput extends StatefulWidget {
  const ChatInput({super.key, required this.controller});

  final WorkspaceController controller;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  int _attached = 0;

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send() {
    widget.controller.send(_text.text);
    _text.clear();
  }

  /// MOCK: a real document needs a native file dialog (drift F2-2).
  void _attach() =>
      widget.controller.attachOneOff('MOCK-attachment-${++_attached}.txt');

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final c = widget.controller;
    return SolidSurface(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ValueListenableBuilder(
        valueListenable: c,
        builder: (context, state, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Text('Message', style: ErmiasType.heading(t, size: 13)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                ErmiasButton(
                  semanticsLabel: 'Attach a one-off document (MOCK)',
                  icon: ErmiasIconData.plus,
                  onTap: _attach,
                ),
                Expanded(
                  child: _MessageBox(text: _text, focus: _focus, onSend: _send),
                ),
              ],
            ),
            Row(
              spacing: 10,
              children: [
                ExcludeSemantics(
                  child: Text('Model', style: ErmiasType.muted(t, size: 12)),
                ),
                ErmiasSelect<ModelChoice>(
                  label: 'Model',
                  value: state.model,
                  options: const [
                    (ModelChoice.local, 'Local · Olmo-3-7B-Instruct'),
                    (ModelChoice.external, 'External · data only'),
                  ],
                  onChanged: c.selectModel,
                ),
                ExcludeSemantics(
                  child: Text('Tools', style: ErmiasType.muted(t, size: 12)),
                ),
                ErmiasSelect<ToolChoice>(
                  label: 'Tools',
                  value: state.tools,
                  options: const [
                    (ToolChoice.searchAndGetSource, 'search, get_source'),
                    (ToolChoice.searchOnly, 'search only'),
                  ],
                  onChanged: c.selectTools,
                ),
                const Spacer(),
                ErmiasButton(
                  semanticsLabel: 'Send',
                  label: 'Send',
                  tone: ErmiasButtonTone.accent,
                  onTap: _send,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({
    required this.text,
    required this.focus,
    required this.onSend,
  });

  final TextEditingController text;
  final FocusNode focus;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final style = ErmiasType.text(t);
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: t.btnBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.btnBorder),
      ),
      // Enter sends; Shift+Enter is left to the text field for a new line.
      child: CallbackShortcuts(
        bindings: {const SingleActivator(LogicalKeyboardKey.enter): onSend},
        child: Stack(
          children: [
            ValueListenableBuilder(
              valueListenable: text,
              builder: (context, value, _) => value.text.isEmpty
                  ? IgnorePointer(
                      child: Text(
                        'Ask a question of the selected databases',
                        style: style.copyWith(color: t.muted),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Semantics(
              label: 'Message',
              textField: true,
              child: EditableText(
                controller: text,
                focusNode: focus,
                style: style,
                cursorColor: t.accent,
                backgroundCursorColor: t.muted,
                selectionColor: t.accentSoft,
                maxLines: 2,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

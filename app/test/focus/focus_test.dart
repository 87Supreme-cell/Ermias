import 'package:ermias/src/focus/approval_prompt.dart';
import 'package:ermias/src/focus/chat_input.dart';
import 'package:ermias/src/focus/primary_focus.dart';
import 'package:ermias/src/mock/mock_workspace.dart';
import 'package:ermias/src/workspace/models.dart';
import 'package:ermias/src/workspace/workspace_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/harness.dart';

WorkspaceController _controller() =>
    WorkspaceController(mockWorkspace(), now: () => DateTime(2026, 11, 10, 11));

Future<void> _pumpFocus(WidgetTester tester, WorkspaceController c) =>
    pumpThemed(
      tester,
      SizedBox(width: 1200, height: 620, child: PrimaryFocus(controller: c)),
    );

Future<void> _pumpChat(WidgetTester tester, WorkspaceController c) =>
    pumpThemed(
      tester,
      Align(
        alignment: Alignment.topCenter,
        child: SizedBox(width: 1200, child: ChatInput(controller: c)),
      ),
    );

void main() {
  group('04 PRIMARY FOCUS', () {
    testWidgets('title, context usage and the question', (tester) async {
      await _pumpFocus(tester, _controller());
      expect(find.text('PRIMARY FOCUS'), findsOneWidget);
      expect(find.text('3,840 of 32,768 tokens'), findsOneWidget);
      expect(
        find.textContaining('before personal data is stored'),
        findsOneWidget,
      );
    });

    testWidgets('every sentence carries a chip that opens its source', (
      tester,
    ) async {
      final c = _controller();
      await _pumpFocus(tester, c);
      final sentences = c.value.conversation.expand((t) => t.answer).length;
      expect(
        find.bySemanticsLabel(RegExp(r'^Source ')),
        findsNWidgets(sentences),
      );
      expect(find.textContaining('chunk 1182'), findsNothing);
      await tester.tap(find.bySemanticsLabel('Source laws · 1182'));
      await tester.pump();
      expect(find.textContaining('chunk 1182'), findsOneWidget);
    });

    testWidgets(
      'a sentence whose samples disagreed is marked with the result',
      (tester) async {
        await _pumpFocus(tester, _controller());
        expect(find.textContaining('samples disagreed 2 of 5'), findsOneWidget);
      },
    );

    testWidgets('Files in context lists weights and labels one-off documents', (
      tester,
    ) async {
      await _pumpFocus(tester, _controller());
      expect(find.text('×1.0'), findsOneWidget);
      expect(find.text('scope-memo.pdf'), findsOneWidget);
      expect(find.text('one-off · unranked'), findsOneWidget);
    });

    testWidgets('drift flags and steps', (tester) async {
      await _pumpFocus(tester, _controller());
      expect(find.text('Claim 3 · samples disagreed'), findsOneWidget);
      expect(find.text('Sources · all claims cited'), findsOneWidget);
      expect(find.bySemanticsLabel('Draft answer, current'), findsOneWidget);
    });

    testWidgets('an uncited sentence raises a Sources drift flag', (
      tester,
    ) async {
      final c = WorkspaceController(
        mockWorkspace().withConversation(const [
          Turn(
            question: 'q',
            model: 'm',
            answer: [Sentence(text: 'Unsupported.')],
          ),
        ]),
      );
      await _pumpFocus(tester, c);
      expect(find.text('Sources · 1 uncited claim'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'^Source ')), findsNothing);
      expect(
        find.bySemanticsLabel('No source for this sentence'),
        findsOneWidget,
      );
    });
  });

  group('05 Chat input', () {
    testWidgets('tools offered are exactly the gate allowlist options', (
      tester,
    ) async {
      await _pumpChat(tester, _controller());
      await tester.tap(find.bySemanticsLabel(RegExp(r'^Tools: ')));
      await tester.pump();
      expect(find.text('search only'), findsOneWidget);
      expect(
        find.text('search, get_source'),
        findsNWidgets(2),
      ); // selected value + menu item
    });

    testWidgets(
      'the + button attaches a one-off document to Files in context',
      (tester) async {
        final c = _controller();
        await _pumpChat(tester, c);
        final before = c.value.contextFiles.length;
        await tester.tap(
          find.bySemanticsLabel(RegExp(r'^Attach a one-off document')),
        );
        await tester.pump();
        expect(c.value.contextFiles.length, before + 1);
        expect(c.value.contextFiles.last.oneOff, isTrue);
        expect(
          c.value.databases.length,
          5,
          reason: 'never added to a ranked database',
        );
      },
    );

    testWidgets(
      'Send with the local model adds the question and clears the box',
      (tester) async {
        final c = _controller();
        await _pumpChat(tester, c);
        await tester.enterText(find.byType(EditableText), 'Which laws apply?');
        await tester.tap(find.bySemanticsLabel('Send'));
        await tester.pump();
        expect(c.value.conversation.last.question, 'Which laws apply?');
        expect(
          tester
              .widget<EditableText>(find.byType(EditableText))
              .controller
              .text,
          isEmpty,
        );
      },
    );

    testWidgets(
      'choosing the external model asks for approval before sending',
      (tester) async {
        final c = _controller();
        await _pumpChat(tester, c);
        await tester.tap(find.bySemanticsLabel(RegExp(r'^Model: ')));
        await tester.pump();
        await tester.tap(find.text('External · data only'));
        await tester.pump();
        expect(c.value.model, ModelChoice.external);
        await tester.enterText(
          find.byType(EditableText),
          'Ask the frontier model',
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(c.value.pendingApproval, 'Ask the frontier model');
      },
    );

    testWidgets('the approval prompt approves or declines', (tester) async {
      final c = _controller()
        ..selectModel(ModelChoice.external)
        ..send('Ask the frontier model');
      await pumpThemed(tester, ApprovalPrompt(controller: c));
      expect(find.textContaining('Ask the frontier model'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Approve this call'));
      await tester.pump();
      expect(c.value.pendingApproval, isNull);
      expect(c.value.audit.first.kind, 'left_machine');
      expect(find.textContaining('Ask the frontier model'), findsNothing);
    });
  });
}

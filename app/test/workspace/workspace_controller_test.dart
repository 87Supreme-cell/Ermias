import 'package:ermias/src/audit/audit_sink.dart';
import 'package:ermias/src/mock/mock_workspace.dart';
import 'package:ermias/src/shell/shell_state.dart';
import 'package:ermias/src/workspace/models.dart';
import 'package:ermias/src/workspace/workspace_controller.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 11, 10, 11, 0, 0);

WorkspaceController _controller() =>
    WorkspaceController(mockWorkspace(), now: () => _now);

DatabaseEntry _db(WorkspaceController c, String name) =>
    c.value.databases.firstWhere((d) => d.name == name);

void main() {
  test(
    'seed matches the reference: 4 of 5 databases on, external.db last and off',
    () {
      final c = _controller();
      expect(c.figureFor(PanelId.databases), '4/5');
      expect(c.value.databases.last.name, 'external.db');
      expect(c.value.databases.last.active, isFalse);
      expect(c.value.databases.last.external, isTrue);
      expect(c.figureFor(PanelId.auditLog), '5');
      expect(c.figureFor(PanelId.taskChain), '4/5');
      expect(c.figureFor(PanelId.projectGrade), '8.1');
      expect(c.needsYou(PanelSide.left), 2);
      expect(c.needsYou(PanelSide.right), 2);
    },
  );

  test(
    'toggling a database flips it, updates the figure and logs the change',
    () {
      final c = _controller();
      final before = c.value;
      c.toggleDatabase('tools.db');
      expect(_db(c, 'tools.db').active, isFalse);
      expect(c.figureFor(PanelId.databases), '3/5');
      expect(c.value.audit.first.kind, 'setting_change');
      expect(c.value.audit.first.summary, contains('tools.db'));
      expect(
        before.databases.firstWhere((d) => d.name == 'tools.db').active,
        isTrue,
        reason: 'previous state is never mutated',
      );
    },
  );

  test('moving a database swaps ranks and keeps them 1..n', () {
    final c = _controller();
    c.moveDatabase('practices.db', -1);
    expect(c.value.databases.map((d) => d.name).take(3), [
      'laws.db',
      'practices.db',
      'principles.db',
    ]);
    expect(c.value.databases.map((d) => d.rank), [1, 2, 3, 4, 5]);
    c.moveDatabase('laws.db', -1); // already first: no change, nothing logged
    expect(c.value.databases.first.name, 'laws.db');
  });

  test('weights move in 0.1 steps and stay within 0..1', () {
    final c = _controller();
    c.adjustWeight('laws.db', 0.1);
    expect(_db(c, 'laws.db').weight, 1.0);
    c.adjustWeight('tools.db', -0.1);
    expect(_db(c, 'tools.db').weight, closeTo(0.3, 1e-9));
    for (var i = 0; i < 10; i++) {
      c.adjustWeight('tools.db', -0.1);
    }
    expect(_db(c, 'tools.db').weight, 0.0);
    expect(c.value.audit.first.kind, 'setting_change');
  });

  test('revoking a hybrid connection removes it at once and logs it', () {
    final c = _controller();
    final hybrid = c.value.connections.firstWhere(
      (x) => x.tier == ConnectionTier.hybrid,
    );
    c.revokeConnection(hybrid.id);
    expect(c.value.connections.where((x) => x.id == hybrid.id), isEmpty);
    expect(c.value.countOf(ConnectionTier.hybrid), 1);
    expect(c.value.audit.first.kind, 'connection_change');
    expect(c.value.audit.first.summary, contains('Revoked'));
  });

  test('ending the exposed connection removes it at once and logs it', () {
    final c = _controller();
    final exposed = c.value.connections.firstWhere(
      (x) => x.tier == ConnectionTier.exposed,
    );
    c.endConnection(exposed.id);
    expect(c.value.countOf(ConnectionTier.exposed), 0);
    expect(c.value.audit.first.summary, contains('Ended'));
  });

  test(
    'a one-off document joins Files in context, unranked, and no database',
    () {
      final c = _controller();
      final databasesBefore = c.value.databases;
      c.attachOneOff('notes.txt');
      final file = c.value.contextFiles.last;
      expect(file.oneOff, isTrue);
      expect(file.label, 'notes.txt');
      expect(c.value.databases, databasesBefore);
    },
  );

  test(
    'sending with the local model adds the question and a MOCK, cited answer',
    () {
      final c = _controller();
      c.send('What changed in the laws database?');
      final turn = c.value.conversation.last;
      expect(turn.question, 'What changed in the laws database?');
      expect(turn.answer.single.text, startsWith('MOCK'));
      expect(turn.answer.single.citation, isNotNull);
      expect(c.value.pendingApproval, isNull);
    },
  );

  test('blank messages are not sent', () {
    final c = _controller();
    final turns = c.value.conversation.length;
    c.send('   ');
    expect(c.value.conversation.length, turns);
  });

  test(
    'an external model asks first; approving logs the approval and what left',
    () {
      final c = _controller();
      c.selectModel(ModelChoice.external);
      final turns = c.value.conversation.length;
      c.send('Summarise the external answer');
      expect(c.value.pendingApproval, 'Summarise the external answer');
      expect(
        c.value.conversation.length,
        turns,
        reason: 'nothing sent before approval',
      );

      c.approvePending();
      expect(c.value.pendingApproval, isNull);
      final kinds = c.value.audit.take(2).map((e) => e.kind).toList();
      expect(kinds, ['left_machine', 'approval']);
      expect(c.value.conversation.length, turns + 1);
    },
  );

  test('declining an external call sends nothing and logs the decision', () {
    final c = _controller();
    c.selectModel(ModelChoice.external);
    c.send('Anything');
    final turns = c.value.conversation.length;
    c.declinePending();
    expect(c.value.pendingApproval, isNull);
    expect(c.value.conversation.length, turns);
    expect(c.value.audit.first.kind, 'approval');
    expect(c.value.audit.first.summary, contains('Declined'));
    expect(
      c.value.audit.where((e) => e.kind == 'left_machine').length,
      1,
      reason: 'only the seed entry; nothing new left the machine',
    );
  });

  test('audit entries from other parts of the app land at the top', () {
    final c = _controller();
    c.record(
      AuditEntry(
        time: _now,
        kind: 'model_hash_mismatch',
        summary: 'x',
        needsHuman: true,
      ),
    );
    expect(c.value.audit.first.kind, 'model_hash_mismatch');
    expect(c.needsYou(PanelSide.left), 3);
  });

  test('drift flags: every claim cited, one sentence with split samples', () {
    final flags = _controller().value.driftFlags;
    expect(flags.map((f) => f.label), [
      'Claim 3 · samples disagreed',
      'Scope · on task',
      'Sources · all claims cited',
    ]);
    expect(flags.first.needsHuman, isTrue);
  });

  test('an uncited sentence raises a Sources drift flag', () {
    final c = WorkspaceController(
      mockWorkspace().withConversation([
        const Turn(
          question: 'q',
          model: 'm',
          answer: [Sentence(text: 'An unsupported claim.')],
        ),
      ]),
      now: () => _now,
    );
    final sources = c.value.driftFlags.last;
    expect(sources.label, 'Sources · 1 uncited claim');
    expect(sources.needsHuman, isTrue);
  });
}

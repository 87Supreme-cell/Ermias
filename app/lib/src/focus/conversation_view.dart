import 'package:flutter/widgets.dart';

import '../icons/risk_shape.dart';
import '../theme/theme_scope.dart';
import '../theme/typography.dart';
import '../workspace/models.dart';

/// Questions and cited answers. Every sentence carries its source chip; an
/// uncited sentence is marked, and raises a Sources drift flag (04).
class ConversationView extends StatefulWidget {
  const ConversationView({super.key, required this.turns});

  final List<Turn> turns;

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  Sentence? _openSource;

  @override
  Widget build(BuildContext context) => ListView(
    children: [
      for (final turn in widget.turns) ...[
        _QuestionBubble(text: turn.question),
        const SizedBox(height: 14),
        _AnswerCard(
          turn: turn,
          openSource: _openSource,
          onChip: (s) => setState(
            () => _openSource = identical(s, _openSource) ? null : s,
          ),
        ),
        const SizedBox(height: 18),
      ],
    ],
  );
}

class _QuestionBubble extends StatelessWidget {
  const _QuestionBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 640),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: t.bubble,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: ErmiasType.text(t)),
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.turn,
    required this.openSource,
    required this.onChip,
  });

  final Turn turn;
  final Sentence? openSource;
  final ValueChanged<Sentence> onChip;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Text(
            '${turn.model} · every sentence carries its source',
            style: ErmiasType.muted(t, size: 12),
          ),
          for (final s in turn.answer) ...[
            _SentenceLine(sentence: s, onChip: () => onChip(s)),
            if (identical(s, openSource) && s.sourceExcerpt != null)
              _SourcePreview(sentence: s),
          ],
        ],
      ),
    );
  }
}

class _SentenceLine extends StatelessWidget {
  const _SentenceLine({required this.sentence, required this.onChip});

  final Sentence sentence;
  final VoidCallback onChip;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final s = sentence;
    final line = Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(s.text, style: ErmiasType.text(t)),
        if (s.citation case final c?)
          CitationChip(citation: c, onTap: onChip)
        else
          const _NoSource(),
        if (s.samples case final k? when s.samplesDisagreed)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 5,
            children: [
              RiskMark(RiskShape.triangle, color: t.warnText, size: 10),
              Text(
                'samples disagreed ${k.disagreed} of ${k.of}',
                style: ErmiasType.text(
                  t,
                  size: 12,
                  weight: FontWeight.w500,
                ).copyWith(color: t.warnText),
              ),
            ],
          ),
      ],
    );
    if (!s.samplesDisagreed) return line;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: t.warnSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: line,
    );
  }
}

/// `database · chunk` chip; opens the source (04).
class CitationChip extends StatelessWidget {
  const CitationChip({super.key, required this.citation, required this.onTap});

  final ContextFile citation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return Semantics(
      container: true,
      button: true,
      label: 'Source ${citation.label}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: t.accentSoft,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                citation.label,
                style: ErmiasType.data(t, size: 11, color: t.accentText),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoSource extends StatelessWidget {
  const _NoSource();

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return Semantics(
      container: true,
      label: 'No source for this sentence',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          RiskMark(RiskShape.triangle, color: t.warnText, size: 10),
          Text(
            'no source',
            style: ErmiasType.data(t, size: 11, color: t.warnText),
          ),
        ],
      ),
    );
  }
}

class _SourcePreview extends StatelessWidget {
  const _SourcePreview({required this.sentence});

  final Sentence sentence;

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: t.subtle,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: t.accent, width: 3)),
      ),
      child: Text(
        sentence.sourceExcerpt!,
        style: ErmiasType.data(t, size: 12, color: t.muted),
      ),
    );
  }
}

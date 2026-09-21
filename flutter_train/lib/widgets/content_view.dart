import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../core/theme.dart';
import '../models/models.dart';
import 'code_block.dart';

const _calloutStyles = {
  'note': (Icons.info_outline, Color(0xFF5B8DEF)),
  'tip': (Icons.lightbulb_outline, Color(0xFF7BC47F)),
  'warning': (Icons.warning_amber_rounded, Color(0xFFE3A857)),
  'trap': (Icons.report_gmailerrorred, Color(0xFFE2705B)),
  'key': (Icons.vpn_key_outlined, Color(0xFFB792EA)),
};

/// Renders the ordered [blocks] of a module body.
class ContentView extends StatelessWidget {
  final List<ContentBlock> blocks;
  final CodeRunnerBridge bridge;
  final Widget Function(ContentBlock block) onQuizBlock;
  const ContentView({
    super.key,
    required this.blocks,
    required this.bridge,
    required this.onQuizBlock,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final b in blocks) {
      switch (b.kind) {
        case BlockKind.prose:
          children.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: MarkdownBody(
                data: b.text,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  p: const TextStyle(fontSize: 15, height: 1.65, color: Colors.white),
                  h2: const TextStyle(
                      fontSize: 21, fontWeight: FontWeight.w700, color: Colors.white),
                  h3: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
                  code: PTheme.mono.copyWith(fontSize: 12.5, color: const Color(0xFF9FD6FF)),
                  codeblockDecoration: BoxDecoration(
                    color: const Color(0xFF181B2C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  blockquoteDecoration: const BoxDecoration(
                    color: Color(0xFF232840),
                    border: Border(left: BorderSide(color: kAccent, width: 3)),
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                ),
              ),
            ),
          );
        case BlockKind.code:
          children.add(CodeBlock(
            bridge: bridge,
            code: b.text,
            language: b.language ?? '',
            runnable: b.runnable,
          ));
        case BlockKind.callout:
          children.add(CalloutCard(kind: b.language ?? 'note', text: b.text));
        case BlockKind.quizYaml:
        case BlockKind.examYaml:
          children.add(onQuizBlock(b));
        case BlockKind.heading:
        case BlockKind.other:
          children.add(Text(b.text));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class CalloutCard extends StatelessWidget {
  final String kind;
  final String text;
  const CalloutCard({super.key, required this.kind, required this.text});
  @override
  Widget build(BuildContext context) {
    final (icon, color) = _calloutStyles[kind] ?? _calloutStyles['note']!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(icon, color: color, size: 20),
          ),
          Expanded(
            child: MarkdownBody(
              data: text,
              softLineBreak: true,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                  .copyWith(
                p: TextStyle(
                    fontSize: 14, height: 1.55, color: color.withValues(alpha:1.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
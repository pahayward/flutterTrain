import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';

import '../core/theme.dart';
import '../models/models.dart';

/// A fenced code block with copy + run buttons backed by the native engines.
class CodeBlock extends StatefulWidget {
  final CodeRunnerBridge bridge;
  final String code;
  final String language;
  final bool runnable;
  const CodeBlock({
    super.key,
    required this.bridge,
    required this.code,
    required this.language,
    required this.runnable,
  });

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

/// Tiny gateway so widget code stays decoupled from AppState.
abstract class CodeRunnerBridge {
  bool get enginesAvailable;
  Future<RunResult> run(String language, String code);
}

class _CodeBlockState extends State<CodeBlock> {
  bool _running = false;
  RunResult? _result;
  bool _showOutput = false;

  Future<void> _run() async {
    setState(() {
      _running = true;
      _showOutput = true;
    });
    final r = await widget.bridge.run(widget.language, widget.code);
    if (!mounted) return;
    setState(() {
      _running = false;
      _result = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canRun = widget.runnable && widget.bridge.enginesAvailable;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF181B2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kSurfaceAlt),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: const Color(0xFF1E2133),
            child: Row(
              children: [
                Text(
                  widget.language,
                  style: const TextStyle(
                      color: kMuted, fontSize: 11, letterSpacing: 0.8),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16, color: kMuted),
                  tooltip: 'Copy',
                  visualDensity: VisualDensity.compact,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: widget.code));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Copied'), duration: Duration(seconds: 1)),
                      );
                    }
                  },
                ),
                if (canRun)
                  _running
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: kAccent),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.play_arrow,
                              size: 20, color: kAccent),
                          tooltip: 'Run',
                          visualDensity: VisualDensity.compact,
                          onPressed: _run,
                        ),
                if (!canRun && widget.runnable)
                  const Tooltip(
                    message: 'Engines unavailable',
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.play_disabled, size: 18, color: kMuted),
                    ),
                  ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(10),
            child: HighlightView(
              widget.code,
              language: widget.language == 'go' ? 'go' : 'python',
              theme: monokaiSublimeTheme,
              padding: EdgeInsets.zero,
              textStyle: PTheme.mono.copyWith(fontSize: 12.5),
            ),
          ),
          if (_showOutput && (_result != null || _running)) _output(context),
        ],
      ),
    );
  }

  Widget _output(BuildContext context) {
    if (_running) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('Running…', style: TextStyle(color: kMuted, fontSize: 12)),
      );
    }
    final r = _result!;
    final out = StringBuffer();
    if (r.stdout.isNotEmpty) out.write(r.stdout);
    if (r.error.isNotEmpty) {
      out.write(r.error.endsWith('\n') ? '' : '\n');
      out.write(r.error);
    }
    if (r.stderr.isNotEmpty) {
      out.write('\n[stderr]\n');
      out.write(r.stderr);
    }
    var text = out.toString().trimRight();
    if (text.isEmpty && r.ok) text = 'OK (no output)';
    final color = r.ok ? const Color(0xFFB2F2BB) : const Color(0xFFF3B0A9);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF14172A),
      child: Text(
        text,
        style: PTheme.mono.copyWith(
            fontSize: 12, color: color, height: 1.4),
      ),
    );
  }
}
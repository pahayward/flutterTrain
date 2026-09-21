import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_state.dart';
import '../core/code_runner.dart';
import '../core/theme.dart';
import '../models/models.dart';

/// Free-form lab: run your own Python or Go snippets on the embedded engines.
class PracticeScreen extends StatefulWidget {
  final AppState state;
  final String language; // python | go
  final String? initialCode;
  const PracticeScreen({
    super.key,
    required this.state,
    this.language = 'python',
    this.initialCode,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late final TextEditingController _code;
  late String _lang;
  bool _running = false;
  RunResult? _result;
  static const _pyDefault =
      '# Python lab — try it live\n'
      'def greet(name):\n'
      '    return f"Hello, {name}!"\n\n'
      'print(greet("PCPP1"))\n';
  static const _goDefault =
      'package main\n\n'
      'import "fmt"\n\n'
      'func main() {\n'
      '    fmt.Println("Hello from Go!")\n'
      '}\n';

  @override
  void initState() {
    super.initState();
    _lang = widget.language;
    _code = TextEditingController(
        text: widget.initialCode ??
            (_lang == 'go' ? _goDefault : _pyDefault));
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _run() async {
    setState(() => _running = true);
    final r = await CodeRunner.run(_lang, _code.text);
    if (!mounted) return;
    setState(() {
      _running = false;
      _result = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_lang == 'go' ? 'Go lab' : 'Python lab'),
        actions: [
          IconButton(
            tooltip: 'Copy code',
            icon: const Icon(Icons.copy_outlined),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: _code.text));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Copied'), duration: Duration(seconds: 1)),
                );
              }
            },
          ),
          IconButton(
            tooltip: 'Run',
            icon: _running
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: kAccent))
                : const Icon(Icons.play_arrow, color: kAccent),
            onPressed: _running ? null : _run,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: kSurface,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                for (final lang in const ['python', 'go'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(lang == 'go' ? 'Go' : 'Python'),
                      selected: _lang == lang,
                      selectedColor: kAccent,
                      onSelected: (_) => setState(() {
                        _lang = lang;
                        _code.text = lang == 'go' ? _goDefault : _pyDefault;
                        _result = null;
                      }),
                    ),
                  ),
                const Spacer(),
                Text(_running ? 'Running…' : '',
                    style: const TextStyle(color: kMuted, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF181B2C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kSurfaceAlt),
                ),
                child: TextField(
                  controller: _code,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: PTheme.mono,
                  decoration: const InputDecoration(
                    hintText: 'Type code here…',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                    hintStyle: TextStyle(color: kMuted),
                  ),
                ),
              ),
            ),
          ),
          if (_result != null)
            _output(context),
        ],
      ),
    );
  }

  Widget _output(BuildContext context) {
    final r = _result!;
    final buf = StringBuffer();
    if (r.stdout.isNotEmpty) buf.writeln(r.stdout);
    if (r.stderr.isNotEmpty) buf.writeln('[stderr]\n${r.stderr}');
    if (r.error.isNotEmpty) buf.writeln(r.error);
    final text = buf.toString().trimRight();
    final ok = r.ok && r.error.isEmpty;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 220),
      color: const Color(0xFF14172A),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Text(
        text.isEmpty ? (ok ? 'OK (no output)' : 'no output') : text,
        style: PTheme.mono.copyWith(
          fontSize: 12.5,
          color: (ok || text.isEmpty)
              ? const Color(0xFFB2F2BB)
              : const Color(0xFFF3B0A9),
        ),
      ),
    );
  }
}
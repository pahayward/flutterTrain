import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/code_runner.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../widgets/code_block.dart';
import '../widgets/content_view.dart';
import 'quiz_screen.dart';

class LessonScreen extends StatefulWidget {
  final AppState state;
  final Module module;
  const LessonScreen({super.key, required this.state, required this.module});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final ScrollController _scroll;
  AppState get s => widget.state;
  ModuleProgress? _prog;
  bool _quizDone = false;

  @override
  void initState() {
    super.initState();
    _prog = s.progressOf(widget.module.courseId, widget.module.id);
    _scroll = ScrollController(initialScrollOffset: _prog!.lastPosition.toDouble());
    _scroll.addListener(_savePos);
    _loadQuizStatus();
  }

  Future<void> _loadQuizStatus() async {
    final p = await s.repo.progressFor(widget.module.courseId, widget.module.id);
    if (mounted) {
      setState(() => _quizDone = (p?.bestQuizScore ?? -1) >= 0);
    }
  }

  void _savePos() {
    s.savePosition(widget.module, _scroll.offset.round());
  }

  @override
  void dispose() {
    _scroll.removeListener(_savePos);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.module;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          m.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 17),
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle bookmark',
            icon: Icon(
              _prog!.bookmarked
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: _prog!.bookmarked ? kAccent : null,
            ),
            onPressed: () {
              s.toggleBookmark(m);
              setState(() => _prog = s.progressOf(m.courseId, m.id));
            },
          ),
          IconButton(
            tooltip: 'Notes',
            icon: Icon(Icons.notes, color: _hasNotes ? kAccent : null),
            onPressed: _editNotes,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scroll,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Chip(
                      label: Text(m.sectionTitle,
                          style: const TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: kSurfaceAlt,
                    ),
                    if (m.tags.isNotEmpty)
                      ...m.tags.take(4).map((t) => Chip(
                            label: Text('#$t',
                                style: const TextStyle(fontSize: 11)),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: kSurface,
                          )),
                  ],
                ),
              ),
              ContentView(
                blocks: m.blocks,
                bridge: _Bridge(s),
                onQuizBlock: _quizCard,
              ),
              const SizedBox(height: 12),
              _completeToggle(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _nav(m),
    );
  }

  bool get _hasNotes => (_prog?.personalNotes ?? '').isNotEmpty;

  Widget _quizCard(ContentBlock block) {
    final m = widget.module;
    final caseBlock = block.kind == BlockKind.examYaml;
    if (caseBlock) {
      if (m.examBank.isEmpty) return const SizedBox.shrink();
      return Card(
        child: ListTile(
          leading: const Icon(Icons.school_outlined, color: kAccent),
          title: const Text('Exam-style questions'),
          subtitle:
              Text('${m.examBank.length} questions · weighted mix across the course'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => QuizScreen.lessonExam(
                    module: m, state: s)),
          ),
        ),
      );
    }
    if (m.quiz.isEmpty) return const SizedBox.shrink();
    return Card(
      child: ListTile(
        leading: Icon(
          _quizDone ? Icons.check_circle_outline : Icons.quiz_outlined,
          color: _quizDone ? const Color(0xFF7BC47F) : kAccent,
        ),
        title: const Text('Lesson quiz'),
        subtitle: Text('${m.quiz.length} questions'
            '${_quizDone && _prog?.bestQuizScore != null ? ' · best ${(_prog!.bestQuizScore! * 100).round()}%' : ''}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => QuizScreen.lessonQuiz(module: m, state: s)),
          );
          _loadQuizStatus();
        },
      ),
    );
  }

  Widget _completeToggle() {
    final m = widget.module;
    final done = _prog!.completed;
    return Card(
      child: CheckboxListTile(
        value: done,
        activeColor: kAccent,
        title: Text(done ? 'Marked as complete' : 'Mark as complete'),
        secondary: Icon(
          done ? Icons.task_alt : Icons.radio_button_unchecked,
          color: done ? const Color(0xFF7BC47F) : kMuted,
        ),
        onChanged: (v) async {
          await s.setCompleted(m, v ?? false);
          if (mounted) {
            setState(() => _prog = s.progressOf(m.courseId, m.id));
          }
        },
      ),
    );
  }

  Widget _nav(Module m) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            if (m.order > 1)
              TextButton.icon(
                icon: const Icon(Icons.chevron_left),
                label: const Text('Prev'),
                onPressed: () => _jump(m.order - 1),
              ),
            const Spacer(),
            TextButton.icon(
              icon: Icon(isLast ? Icons.done : Icons.chevron_right),
              label: Text(isLast ? 'Done' : 'Next'),
              onPressed: () => _jump(m.order + 1),
            ),
          ],
        ),
      ),
    );
  }

  bool get isLast {
    final course = s.courseOf(widget.module.courseId);
    final sec = course.sections.firstWhere(
        (sec) => sec.id == widget.module.sectionId);
    return widget.module.order >= sec.modules.length;
  }

  void _jump(int order) {
    final course = s.courseOf(widget.module.courseId);
    final sec = course.sections.firstWhere(
        (sec) => sec.id == widget.module.sectionId);
    if (order < 1 || order > sec.modules.length) {
      Navigator.of(context).pop();
      return;
    }
    final next = sec.modules.firstWhere((m) => m.order == order);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => LessonScreen(state: s, module: next)));
  }

  Future<void> _editNotes() async {
    final controller =
        TextEditingController(text: _prog?.personalNotes ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Personal notes'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration:
              const InputDecoration(hintText: 'Type notes for this module…'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Save')),
        ],
      ),
    );
    if (result != null && mounted) {
      await s.saveNotes(widget.module, result);
      setState(() => _prog = s.progressOf(widget.module.courseId, widget.module.id));
    }
  }
}

class _Bridge implements CodeRunnerBridge {
  final AppState state;
  _Bridge(this.state);
  @override
  bool get enginesAvailable => state.enginesAvailable;
  @override
  Future<RunResult> run(String language, String code) =>
      CodeRunner.run(language, code);
}
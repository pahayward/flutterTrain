import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../models/models.dart';
import 'lesson_screen.dart';
import 'quiz_screen.dart';

class CourseScreen extends StatefulWidget {
  final AppState state;
  final Course course;
  const CourseScreen({super.key, required this.state, required this.course});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  late AppState s;

  @override
  void initState() {
    super.initState();
    s = widget.state;
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
        actions: [
          IconButton(
            tooltip: 'Exam',
            icon: const Icon(Icons.school_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => QuizScreen.exam(course: course, state: s)),
            ),
          ),
          IconButton(
            tooltip: 'Rapid practice',
            icon: const Icon(Icons.fastfood_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => QuizScreen.practice(
                      course: course, state: s)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          for (var i = 0; i < course.sections.length; i++)
            _SectionTile(
              section: course.sections[i],
              index: i,
              progress: sectionProgressOf(course.sections[i]),
              onTapModule: (m) => _openModule(m),
            ),
        ],
      ),
    );
  }

  double sectionProgressOf(Section section) {
    if (section.modules.isEmpty) return 0;
    var done = 0;
    for (final m in section.modules) {
      if (s.progressOf(widget.course.courseId, m.id).completed) done++;
    }
    return done / section.modules.length;
  }

  void _openModule(Module module) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => LessonScreen(state: s, module: module)),
    );
    if (mounted) setState(() {});
  }
}

class _SectionTile extends StatefulWidget {
  final Section section;
  final int index;
  final double progress;
  final void Function(Module) onTapModule;
  const _SectionTile({
    required this.section,
    required this.index,
    required this.progress,
    required this.onTapModule,
  });

  @override
  State<_SectionTile> createState() => _SectionTileState();
}

class _SectionTileState extends State<_SectionTile> {
  late bool _expanded = widget.index == 0;
  @override
  Widget build(BuildContext context) {
    final sec = widget.section;
    return Card(
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _expanded = !_expanded),
            leading: CircleAvatar(
              backgroundColor: kAccent.withValues(alpha:0.15),
              foregroundColor: kAccent,
              child: Text('${widget.index + 1}'),
            ),
            title: Text(sec.title,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: widget.progress,
                  minHeight: 4,
                  backgroundColor: kSurfaceAlt,
                ),
              ),
            ),
            trailing: Icon(_expanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down),
          ),
          if (_expanded)
            ...sec.modules.map((m) => _moduleTile(m)),
        ],
      ),
    );
  }

  Widget _moduleTile(Module m) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(left: 24, right: 16),
      leading: const Icon(Icons.menu_book_outlined, size: 18),
      title: Text('${m.order}. ${m.title}', style: const TextStyle(fontSize: 14)),
      trailing: m.quiz.isNotEmpty
          ? const Icon(Icons.quiz_outlined, size: 16, color: kMuted)
          : null,
      onTap: () => widget.onTapModule(m),
    );
  }
}
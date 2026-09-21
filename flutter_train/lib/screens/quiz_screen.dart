import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../models/models.dart';

/// Multi-mode quiz engine: practice, lesson quiz, module exam, full exam.
class QuizScreen extends StatefulWidget {
  final AppState state;
  final Course? course;
  final Module? module;
  final List<QuizQuestion> questions;
  final String title;
  final bool timed; // cert exam only
  final bool immediate; // show per-question feedback
  final Duration? duration;
  final double passPct;

  const QuizScreen._({
    required this.state,
    this.course,
    this.module,
    required this.questions,
    required this.title,
    this.timed = false,
    this.immediate = true,
    this.duration,
    this.passPct = 0.7,
  });

  factory QuizScreen.practice(
      {required Course course, required AppState state}) {
    final qs = course.allExamQuestions.toList()..shuffle();
    return QuizScreen._(
      state: state,
      course: course,
      questions: qs.take(min(qs.length, 20)).toList(),
      title: 'Rapid practice',
      immediate: true,
      passPct: course.examConfig.passPct / 100,
    );
  }

  factory QuizScreen.lessonQuiz({required Module module, required AppState state}) {
    return QuizScreen._(
      state: state,
      module: module,
      questions: List.of(module.quiz),
      title: '${module.title} — quiz',
      immediate: true,
    );
  }

  factory QuizScreen.lessonExam({required Module module, required AppState state}) {
    final qs = List.of(module.examBank)..shuffle();
    return QuizScreen._(
      state: state,
      module: module,
      questions: qs,
      title: '${module.title} — exam questions',
      immediate: false,
    );
  }

  factory QuizScreen.exam(
      {required Course course, required AppState state}) {
    final cfg = course.examConfig;
    final pool = course.allExamQuestions.toList();
    // sample per section to mirror exam weight distribution as closely as possible
    final selected = <QuizQuestion>[];
    final rng = Random();
    var remaining = cfg.questionCount;
    for (final section in course.sections) {
      final avail =
          pool.where((q) => q.section == section.id).toList();
      if (avail.isEmpty) continue;
      final target = (cfg.questionCount * section.weight / 100).round();
      avail.shuffle(rng);
      selected.addAll(avail.take(min(target, avail.length)));
      remaining -= min(target, avail.length);
    }
    if (remaining > 0) {
      final rest = pool.where((q) => !selected.contains(q)).toList()
        ..shuffle(rng);
      selected.addAll(rest.take(min(remaining, rest.length)));
    }
    selected.shuffle(rng);
    return QuizScreen._(
      state: state,
      course: course,
      questions: selected,
      title: '${course.title} — exam',
      timed: true,
      immediate: false,
      duration: Duration(minutes: cfg.durationMinutes),
      passPct: cfg.passPct / 100,
    );
  }

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;
  final Set<int> _chosen = {};
  late final Map<int, bool> _checked; // question idx -> answered correctly? (immediate mode)
  bool _graded = false;
  int _score = 0;
  late int _max;
  bool _running = false;
  String _time = '';
  Timer? _timer;
  DateTime? _deadline;
  final List<List<int>> _history = []; // previous answers per question

  @override
  void initState() {
    super.initState();
    _max = widget.questions.length;
    _checked = {for (var i = 0; i < _max; i++) i: false};
    if (widget.timed) {
      _running = true;
      _deadline = DateTime.now().add(widget.duration!);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      _tick();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    final left = _deadline!.difference(DateTime.now());
    if (left.isNegative) {
      _timer?.cancel();
      setState(() {
        _time = 'Time is up';
        _grade();
      });
      return;
    }
    final m = left.inMinutes.remainder(60).toString().padLeft(2, '0');
    final h = left.inHours;
    setState(() =>
        _time = h > 0 ? '${left.inHours}:$m:${left.inSeconds.remainder(60).toString().padLeft(2, '0')}' : '${left.inMinutes}:$m');
  }

  QuizQuestion get _q => widget.questions[_index];

  void _toggle(int choice) {
    setState(() {
      if (_q.multi) {
        if (!_chosen.remove(choice)) _chosen.add(choice);
      } else {
        _chosen
          ..clear()
          ..add(choice);
      }
      while (_history.length <= _index) {
        _history.add(const []);
      }
      _history[_index] = _chosen.toList();
    });
  }

  void _check() {
    if (_chosen.isEmpty) return;
    final correct = _q.isCorrect(_chosen.toList());
    setState(() {
      _checked[_index] = correct;
      if (correct) _score++;
    });
  }

  void _grade() {
    _timer?.cancel();
    var score = 0;
    for (var i = 0; i < _max; i++) {
      if (i >= _history.length) continue; // unanswered counts as wrong
      if (widget.questions[i].isCorrect(_history[i])) score++;
    }
    setState(() {
      _score = score;
      _graded = true;
      _running = false;
    });
    final config = widget.course?.examConfig;
    if (widget.module != null) {
      final state = widget.state;
      final p = state.progressOf(widget.module!.courseId, widget.module!.id);
      state.recordQuizResult(
          widget.module!, _pct, p.quizAttempts + 1);
    } else if (widget.course != null && config != null) {
      widget.state.repo.recordExam(widget.course!.courseId, _score, _max,
          passed: _pct >= widget.passPct);
    }
  }

  double get _pct => _max == 0 ? 0 : _score / _max;

  void _next() {
    if (_index < _max - 1) {
      setState(() {
        _index++;
        _chosen.clear();
      });
    } else {
      _grade();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_running,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title, style: const TextStyle(fontSize: 16)),
          actions: [
            if (_running && !_graded)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(_time,
                      style: TextStyle(
                          color: _time.startsWith('Time')
                              ? const Color(0xFFE2705B)
                              : kAccent,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
        body: _graded
            ? _result()
            : _question(),
      ),
    );
  }

  Widget _question() {
    final q = _q;
    final answered =
        widget.immediate && _checked[_index]!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Text('Question ${_index + 1} of $_max',
                  style: const TextStyle(color: kMuted, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('Score: $_score',
                  style: const TextStyle(color: kMuted)),
            ],
          ),
        ),
        LinearProgressIndicator(
          value: (_index + 1) / _max,
          minHeight: 4,
          backgroundColor: kSurfaceAlt,
          color: kAccent,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                q.prompt,
                style: const TextStyle(fontSize: 17, height: 1.5, fontWeight: FontWeight.w600),
              ),
              if (q.multi)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Select all that apply',
                      style: TextStyle(color: kMuted, fontSize: 12)),
                ),
              const SizedBox(height: 14),
              for (var i = 0; i < q.choices.length; i++)
                _choice(i),
              if (answered) ...[
                const SizedBox(height: 12),
                _solution(),
              ],
            ],
          ),
        ),
        _controls(answered),
      ],
    );
  }

  Widget _choice(int i) {
    final q = _q;
    final isChosen = _chosen.contains(i);
    final answered = _checked[_index]!;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: answered ? null : () => _toggle(i),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isChosen ? kAccent : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _q.multi
                    ? (isChosen ? Icons.check_box : Icons.check_box_outline_blank)
                    : (isChosen ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                color: isChosen ? kAccent : kMuted,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(q.choices[i], style: const TextStyle(fontSize: 15, height: 1.4)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _solution() {
    final q = _q;
    final ok = _checked[_index]!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (ok ? const Color(0xFF7BC47F) : const Color(0xFFE2705B))
            .withValues(alpha:0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: (ok ? const Color(0xFF7BC47F) : const Color(0xFFE2705B))
                .withValues(alpha:0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ok ? Icons.check_circle : Icons.cancel,
                  color: ok ? const Color(0xFF7BC47F) : const Color(0xFFE2705B),
                  size: 20),
              const SizedBox(width: 8),
              Text(ok ? 'Correct' : 'Not quite',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          if (q.explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(q.explanation, style: const TextStyle(fontSize: 14, height: 1.5)),
          ],
        ],
      ),
    );
  }

  Widget _controls(bool answered) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (!widget.immediate || answered)
              OutlinedButton(
                onPressed: _index == 0
                    ? null
                    : () => setState(() {
                          _index--;
                          _chosen.clear();
                          if (_index < _history.length) {
                            _chosen.addAll(_history[_index]);
                          }
                        }),
                child: const Text('Previous'),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: widget.immediate && !answered
                    ? (_chosen.isEmpty ? null : _check)
                    : _next,
                child: Text(widget.immediate && !answered
                    ? 'Check'
                    : _index == _max - 1
                        ? 'Finish'
                        : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _result() {
    final ok = _pct >= widget.passPct;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ok ? Icons.celebration_outlined : Icons.trending_down,
                size: 64, color: ok ? const Color(0xFF7BC47F) : const Color(0xFFE2705B)),
            const SizedBox(height: 16),
            Text(
              ok ? 'Passed' : 'Keep practicing',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '$_score / $_max  (${(_pct * 100).round()}%)',
              style: const TextStyle(fontSize: 18, color: kMuted),
            ),
            if (widget.timed && _time != 'Time is up')
              Text('Time elapsed: ${widget.duration!.inMinutes} min',
                  style: const TextStyle(color: kMuted, fontSize: 13)),
            const SizedBox(height: 8),
            Text(
              widget.course != null && widget.timed
                  ? ok
                      ? 'You beat the exam threshold of ${(widget.passPct * 100).round()}%.'
                      : 'Aim for ${(widget.passPct * 100).round()}% — review the missed sections.'
                  : 'Review missed questions for a deeper grip.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: kMuted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
            if (!ok && !widget.immediate)
              TextButton(
                onPressed: () {
                  setState(() {
                    _graded = false;
                    _score = 0;
                    _index = 0;
                    _checked = {for (var i = 0; i < _max; i++) i: false};
                    _history.clear();
                  });
                },
                child: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
}
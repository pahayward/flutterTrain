/// Domain models for course content and user progress.
library;

/// A parsed content block inside a module body.
enum BlockKind { prose, code, callout, quizYaml, examYaml, heading, other }

class ContentBlock {
  final BlockKind kind;
  final String text;
  final String? language; // for code blocks: python | go
  final String info; // fence info string ("title=.. eval=no")
  final String? title; // extracted from info string
  final bool runnable;
  ContentBlock(this.kind, this.text,
      {this.language, this.info = '', this.title, this.runnable = false});
}

class QuizQuestion {
  final String id;
  final String prompt;
  final bool multi;
  final List<String> choices;
  final List<int> answer; // zero-indexed
  final String explanation;
  final int difficulty;
  final String? section;
  final int weight;
  QuizQuestion({
    required this.id,
    required this.prompt,
    required this.multi,
    required this.choices,
    required this.answer,
    required this.explanation,
    required this.difficulty,
    this.section,
    this.weight = 4,
  });
  bool isCorrect(List<int> picked) =>
      picked.length == answer.length &&
      answer.every(picked.contains) &&
      picked.every(answer.contains);
}

class Module {
  final String courseId;
  final String id;
  final String title;
  final int order;
  final String sectionId;
  final String sectionTitle;
  final String language; // python | golang
  final String summary;
  final List<String> tags;
  final String rawBody;
  final List<ContentBlock> blocks;
  final List<QuizQuestion> quiz;
  final List<QuizQuestion> examBank;
  Module({
    this.courseId = 'python',
    required this.id,
    required this.title,
    required this.order,
    required this.sectionId,
    required this.sectionTitle,
    this.language = 'python',
    this.summary = '',
    this.tags = const [],
    this.rawBody = '',
    this.blocks = const [],
    this.quiz = const [],
    this.examBank = const [],
  });
}

class Section {
  final String id;
  final String title;
  final int weight;
  final List<Module> modules;
  Section({required this.id, required this.title, this.weight = 0, this.modules = const []});
}

class ExamConfig {
  final int questionCount;
  final int durationMinutes;
  final int passPct;
  const ExamConfig({this.questionCount = 45, this.durationMinutes = 65, this.passPct = 70});
}

class Course {
  final String courseId;
  final String title;
  final String subtitle;
  final String language; // python | golang
  final ExamConfig examConfig;
  final List<Section> sections;
  final String sourceDir; // where blocks were loaded from (assets or user content)
  Course({
    required this.courseId,
    required this.title,
    this.subtitle = '',
    this.language = 'python',
    this.examConfig = const ExamConfig(),
    this.sections = const [],
    required this.sourceDir,
  });

  Iterable<QuizQuestion> get allExamQuestions =>
      sections.expand((s) => s.modules.expand((m) => m.examBank));

  Iterable<Module> get allModules => sections.expand((s) => s.modules);
}

/// User progress row stored in SQLite.
class ModuleProgress {
  final String courseId;
  final String moduleId;
  bool completed;
  int lastPosition; // scroll offset
  double? bestQuizScore; // 0..1
  int quizAttempts;
  bool bookmarked;
  String personalNotes;
  ModuleProgress({
    required this.courseId,
    required this.moduleId,
    this.completed = false,
    this.lastPosition = 0,
    this.bestQuizScore,
    this.quizAttempts = 0,
    this.bookmarked = false,
    this.personalNotes = '',
  });
}

/// Runtime result from the embedded code engines.
class RunResult {
  final bool ok;
  final String stdout;
  final String stderr;
  final String error;
  final String engine; // 'python' | 'go'
  RunResult(this.ok, this.stdout, this.stderr, this.error, this.engine);
}
/// App-wide state: loaded courses + progress, exposed via ChangeNotifier.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../models/models.dart';
import 'content_engine.dart';
import 'progress_repository.dart';

class AppState extends ChangeNotifier {
  final ContentLibrary library = ContentLibrary();
  final ProgressRepository repo = ProgressRepository();
  final Map<String, ModuleProgress> _progress = {};

  bool loaded = false;
  bool enginesAvailable = false;
  String? loadError;

  Future<void> init() async {
    Directory? userBase;
    try {
      final docs = await getApplicationDocumentsDirectory();
      userBase = Directory('${docs.path}/courseware');
    } catch (_) {
      userBase = null;
    }
    await library.load(userBase: userBase);
    // seed progress cache
    for (final c in library.courses) {
      for (final p in await repo.allProgress(c.courseId)) {
        _progress['${c.courseId}:${p.moduleId}'] = p;
      }
    }
    loaded = true;
    loadError = library.lastError;
    notifyListeners();
  }

  ModuleProgress progressOf(String courseId, String moduleId) =>
      _progress['$courseId:$moduleId'] ??
      ModuleProgress(courseId: courseId, moduleId: moduleId);

  Future<void> setCompleted(Module module, bool value) async {
    final p = progressOf(module.courseId, module.id);
    p.completed = value;
    await repo.saveProgress(p);
    _progress['${module.courseId}:${module.id}'] = p;
    notifyListeners();
  }

  Future<void> savePosition(Module module, int position) async {
    final p = progressOf(module.courseId, module.id);
    p.lastPosition = position;
    await repo.saveProgress(p);
  }

  Future<void> recordQuizResult(
      Module module, double best, int attempts) async {
    final p = progressOf(module.courseId, module.id);
    p.bestQuizScore = best;
    p.quizAttempts = attempts;
    await repo.saveProgress(p);
    _progress['${module.courseId}:${module.id}'] = p;
    notifyListeners();
  }

  Future<void> toggleBookmark(Module module) async {
    final p = progressOf(module.courseId, module.id);
    p.bookmarked = !p.bookmarked;
    await repo.saveProgress(p);
    _progress['${module.courseId}:${module.id}'] = p;
    notifyListeners();
  }

  Future<void> saveNotes(Module module, String notes) async {
    final p = progressOf(module.courseId, module.id);
    p.personalNotes = notes;
    await repo.saveProgress(p);
    _progress['${module.courseId}:${module.id}'] = p;
  }

  List<Module> bookmarks(String courseId) =>
      library.courses
          .firstWhere((c) => c.courseId == courseId)
          .allModules
          .where((m) => progressOf(courseId, m.id).bookmarked)
          .toList();

  int completedCount(String courseId) {
    var n = 0;
    for (final m in courseOf(courseId).allModules) {
      if (progressOf(courseId, m.id).completed) n++;
    }
    return n;
  }

  Course courseOf(String courseId) =>
      library.courses.firstWhere((c) => c.courseId == courseId);

  /// Percentage of modules completed in [sectionId], 0..1.
  double sectionProgress(String courseId, String sectionId) {
    final course = courseOf(courseId);
    final section = course.sections.firstWhere((s) => s.id == sectionId);
    if (section.modules.isEmpty) return 0;
    var done = 0;
    for (final m in section.modules) {
      if (progressOf(courseId, m.id).completed) done++;
    }
    return done / section.modules.length;
  }

  String formatDate(int ms) =>
      DateFormat('MMM d, HH:mm').format(DateTime.fromMillisecondsSinceEpoch(ms));

  @override
  void dispose() {
    repo.close();
    super.dispose();
  }
}
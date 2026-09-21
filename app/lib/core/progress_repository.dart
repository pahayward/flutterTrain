/// SQLite persistence for user progress, quiz/exam attempts, notes, bookmarks.
library;

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

class ProgressRepository {
  Database? _db;

  Future<Database> _database() async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    _db = await openDatabase(
      '${dir.path}/pp1study.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE progress (
            course_id TEXT NOT NULL,
            module_id TEXT NOT NULL,
            completed INTEGER NOT NULL DEFAULT 0,
            last_position INTEGER NOT NULL DEFAULT 0,
            best_quiz_score REAL,
            quiz_attempts INTEGER NOT NULL DEFAULT 0,
            bookmarked INTEGER NOT NULL DEFAULT 0,
            personal_notes TEXT NOT NULL DEFAULT '',
            PRIMARY KEY (course_id, module_id)
          )
        ''');
        await db.execute('''
          CREATE TABLE exam_attempts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            course_id TEXT NOT NULL,
            started_at INTEGER NOT NULL,
            finished_at INTEGER,
            passed INTEGER,
            score INTEGER,
            total INTEGER
          )
        ''');
      },
    );
    return _db!;
  }

  Future<void> saveProgress(ModuleProgress p) async {
    final db = await _database();
    await db.insert(
      'progress',
      {
        'course_id': p.courseId,
        'module_id': p.moduleId,
        'completed': p.completed ? 1 : 0,
        'last_position': p.lastPosition,
        'best_quiz_score': p.bestQuizScore,
        'quiz_attempts': p.quizAttempts,
        'bookmarked': p.bookmarked ? 1 : 0,
        'personal_notes': p.personalNotes,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ModuleProgress?> progressFor(String courseId, String moduleId) async {
    final db = await _database();
    final rows = await db.query('progress',
        where: 'course_id = ? AND module_id = ?',
        whereArgs: [courseId, moduleId],
        limit: 1);
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  Future<List<ModuleProgress>> allProgress(String courseId) async {
    final db = await _database();
    final rows = await db.query('progress',
        where: 'course_id = ?', whereArgs: [courseId]);
    return rows.map(_fromRow).toList(growable: false);
  }

  Future<Map<String, int>> sectionCompletions(String courseId) async {
    final db = await _database();
    final rows = await db.query('progress',
        columns: ['module_id', 'completed'],
        where: 'course_id = ?',
        whereArgs: [courseId]);
    return {
      for (final r in rows)
        r['module_id'] as String:
            (r['completed'] as int?) ?? 0,
    };
  }

  ModuleProgress _fromRow(Map<String, Object?> r) => ModuleProgress(
        courseId: r['course_id'] as String,
        moduleId: r['module_id'] as String,
        completed: (r['completed'] as int) == 1,
        lastPosition: (r['last_position'] as int?) ?? 0,
        bestQuizScore: (r['best_quiz_score'] as num?)?.toDouble(),
        quizAttempts: (r['quiz_attempts'] as int?) ?? 0,
        bookmarked: (r['bookmarked'] as int) == 1,
        personalNotes: r['personal_notes']?.toString() ?? '',
      );

  Future<void> recordExam(String courseId, int score, int total,
      {required bool passed}) async {
    final db = await _database();
    await db.insert('exam_attempts', {
      'course_id': courseId,
      'started_at': DateTime.now().millisecondsSinceEpoch,
      'finished_at': DateTime.now().millisecondsSinceEpoch,
      'passed': passed ? 1 : 0,
      'score': score,
      'total': total,
    });
  }

  Future<List<Map<String, Object?>>> examHistory(String courseId) async {
    final db = await _database();
    return db.query('exam_attempts',
        where: 'course_id = ?',
        whereArgs: [courseId],
        orderBy: 'started_at DESC',
        limit: 20);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
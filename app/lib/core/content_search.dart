/// Lightweight offline full-text search over loaded courses.
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class SearchHit {
  final Module module;
  final int score;
  final String snippet;
  SearchHit(this.module, this.score, this.snippet);
}

class ContentSearch {
  static const List<String> _stop = [
    'the', 'a', 'an', 'and', 'or', 'of', 'to', 'in', 'on', 'is', 'are',
    'for', 'with', 'this', 'that', 'it', 'as', 'at', 'by', 'from',
    'и', 'с', 'для', 'это', 'в', 'на', 'ко', 'к', 'по', 'не', 'из',
  ];

  static List<String> tokens(String text) {
    final cleaned = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9а-я \u00e0-\u00ff]'), ' ');
    return cleaned
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 1 && !_stop.contains(t))
        .toList(growable: false);
  }

  /// Naive term-overlap scoring over title, summary, tags, and body.
  static List<SearchHit> search(List<Course> courses, String query,
      {int limit = 30}) {
    final q = tokens(query);
    if (q.isEmpty) return const [];
    final hits = <SearchHit>[];
    for (final course in courses) {
      for (final m in course.allModules) {
        final titleText = tokens('${m.title} ${m.summary} ${m.tags.join(' ')}');
        final bodyText = tokens(m.rawBody);
        var score = 0;
        final tb = Set<String>.from(titleText);
        final bb = Set<String>.from(bodyText);
        for (final t in q) {
          if (tb.contains(t)) score += 10;
          if (bb.contains(t)) score += 1;
        }
        if (score > 0) {
          hits.add(SearchHit(
              m, score, _snippet(m, q[0], bodyText)));
        }
      }
    }
    hits.sort((a, b) => b.score.compareTo(a.score));
    return hits.take(limit).toList(growable: false);
  }

  static String _snippet(Module m, String term, List<String> bodyTokens) {
    final idx = bodyTokens.indexOf(term);
    final start = (idx - 4).clamp(0, bodyTokens.length - 1);
    final end = (idx + 8).clamp(0, bodyTokens.length);
    final window = bodyTokens.sublist(start, end).join(' ');
    return idx == -1 ? (m.summary.isNotEmpty ? m.summary : m.title) : '… $window …';
  }

  /// Remembers recent searches for convenience.
  static Future<List<String>> recentSearches({int limit = 5}) async {
    final sp = await SharedPreferences.getInstance();
    return (sp.getStringList('recent_searches') ?? const []).take(limit).toList();
  }

  static Future<void> addRecentSearch(String q) async {
    final sp = await SharedPreferences.getInstance();
    var list = sp.getStringList('recent_searches') ?? <String>[];
    list.remove(q);
    list = [q, ...list].take(20).toList();
    await sp.setStringList('recent_searches', list);
  }
}

/// Cache of generated cheat-sheet markdown (exam prep summaries).
class CheatSheetCache {
  static const _key = 'cheat_sheet_v1';
  static Future<String?> get(String courseId) async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('$_key:$courseId');
    if (raw == null) return null;
    return utf8.decode(base64.decode(raw));
  }

  static Future<void> set(String courseId, String markdown) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('$_key:$courseId',
        base64.encode(utf8.encode(markdown)));
  }
}
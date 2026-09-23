import 'package:flutter/services.dart';

import '../models/models.dart';

/// Shares the current page as a Markdown file through the Android share
/// sheet, so it can be handed to any app (e.g. an AI assistant) for help.
class PageShare {
  static const _channel = MethodChannel('com.fluttertrain/share');

  /// Returns false when sharing is unavailable (e.g. not running on Android).
  static Future<bool> shareMarkdown(String title, String markdown) async {
    try {
      await _channel.invokeMethod('shareMarkdown', {
        'fileName': '${_slug(title)}.md',
        'title': title,
        'content': markdown,
      });
      return true;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  static String lessonMarkdown(Module m, Course course) {
    final b = StringBuffer()
      ..writeln('# ${m.title}')
      ..writeln()
      ..writeln('- Course: ${course.title}')
      ..writeln('- Section: ${m.sectionTitle}')
      ..writeln('- Language: ${m.language}');
    if (m.tags.isNotEmpty) b.writeln('- Tags: ${m.tags.join(', ')}');
    if (m.summary.isNotEmpty) {
      b
        ..writeln()
        ..writeln('> ${m.summary}');
    }
    b
      ..writeln()
      ..writeln(m.rawBody.trim());
    return b.toString();
  }

  /// [revealAnswer] adds the correct answer and explanation; leave it off
  /// while the question is still unanswered so the share doesn't spoil it.
  static String questionMarkdown(String quizTitle, int number, int total,
      QuizQuestion q, List<int> chosen,
      {required bool revealAnswer}) {
    final b = StringBuffer()
      ..writeln('# $quizTitle — question $number of $total')
      ..writeln()
      ..writeln(q.prompt)
      ..writeln();
    if (q.multi) {
      b
        ..writeln('_Select all that apply._')
        ..writeln();
    }
    for (var i = 0; i < q.choices.length; i++) {
      final letter = String.fromCharCode(65 + i);
      b.writeln('- [${chosen.contains(i) ? 'x' : ' '}] $letter. ${q.choices[i]}');
    }
    if (revealAnswer) {
      final answer =
          q.answer.map((i) => String.fromCharCode(65 + i)).join(', ');
      b
        ..writeln()
        ..writeln('**Correct answer:** $answer');
      if (q.explanation.isNotEmpty) {
        b
          ..writeln()
          ..writeln('**Explanation:** ${q.explanation}');
      }
    }
    return b.toString();
  }

  static String _slug(String s) {
    final slug = s
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (slug.isEmpty) return 'flutter-train-page';
    return slug.length > 60 ? slug.substring(0, 60) : slug;
  }
}

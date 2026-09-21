/// Content engine: loads courses from the bundled `assets/courseware/pack.json`
/// plus an optional user-editable overlay directory, and parses modules into
/// the model classes. The user overlay uses the same on-disk format
/// (COURSEWARE_FORMAT.md) so AI-generated or hand-added modules slot in.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;

import '../models/models.dart';

/// ---------------------------------------------------------------------------
/// YAML-lite: parses the limited YAML subset used by quiz/exam blocks.
/// ---------------------------------------------------------------------------
class YamlLite {
  static dynamic parse(String src) {
    var p = _YLines(src.split('\n'));
    return p.block();
  }
}

class _YLines {
  final List<String> lines;
  int pos = 0;
  _YLines(this.lines);

  List<dynamic> block({int indent = -1}) {
    final out = <dynamic>[];
    while (pos < lines.length) {
      final line = lines[pos];
      final stripped = line.replaceFirst(RegExp(r'^\s+'), '');
      if (stripped.isEmpty || stripped.startsWith('#')) {
        pos++;
        continue;
      }
      final cur = _indent(line);
      if (indent != -1 && cur < indent) break;
      if (stripped.startsWith('- ')) {
        out.add(_dash(stripped.substring(2).trim(), cur));
        continue;
      }
      final idx = stripped.indexOf(':');
      if (idx > 0) {
        final key = stripped.substring(0, idx).trim();
        final val = stripped.substring(idx + 1).trim();
        final map = <String, dynamic>{};
        if (val.isEmpty) {
          pos++;
          map[key] = block(indent: cur + 1);
          out.add(map);
          continue;
        }
        map[key] = _scalar(val);
        out.add(map);
        pos++;
        continue;
      }
      pos++;
    }
    return out;
  }

  /// Parses a `- item` which may open a map that continues on following
  /// deeper-indented key lines (the courseware quiz format).
  dynamic _dash(String text, int cur) {
    final idx = text.indexOf(':');
    if (idx < 0) {
      pos++;
      return _scalar(text);
    }
    final map = <String, dynamic>{};
    final val = text.substring(idx + 1).trim();
    if (val.isEmpty) {
      pos++;
      map[text.substring(0, idx).trim()] = block(indent: cur + 1);
    } else {
      map[text.substring(0, idx).trim()] = _scalar(val);
      pos++;
    }
    // absorb following key lines indented deeper than the dash item
    while (pos < lines.length) {
      final line = lines[pos];
      final stripped = line.replaceFirst(RegExp(r'^\s+'), '');
      if (stripped.isEmpty || stripped.startsWith('#')) {
        pos++;
        continue;
      }
      if (_indent(line) <= cur) break;
      if (stripped.startsWith('- ')) break;
      final k = stripped.indexOf(':');
      if (k > 0) {
        final subKey = stripped.substring(0, k).trim();
        final subVal = stripped.substring(k + 1).trim();
        if (subVal.isEmpty) {
          pos++;
          map[subKey] = block(indent: _indent(line) + 1);
        } else {
          map[subKey] = _scalar(subVal);
          pos++;
        }
        continue;
      }
      pos++;
    }
    return map;
  }

  static int _indent(String line) {
    var n = 0;
    for (var i = 0; i < line.length; i++) {
      final c = line.codeUnitAt(i);
      if (c == 32) {
        n++;
      } else if (c == 9) {
        n += 2;
      } else {
        break;
      }
    }
    return n;
  }

  static dynamic _scalar(String v) {
    v = v.trim();
    if (v.length >= 2 &&
        ((v.startsWith('"') && v.endsWith('"')) ||
            (v.startsWith("'") && v.endsWith("'")))) {
      var s = v.substring(1, v.length - 1);
      if (v.startsWith('"')) {
        s = s.replaceAll(r'\n', '\n').replaceAll(r'\t', '\t').replaceAll(r'\"', '"');
      }
      return s;
    }
    if (v.startsWith('[') && v.endsWith(']')) {
      return _splitList(v.substring(1, v.length - 1));
    }
    if (v == 'true') return true;
    if (v == 'false') return false;
    final i = int.tryParse(v);
    if (i != null) return i;
    final d = double.tryParse(v);
    if (d != null) return d;
    return v;
  }

  /// Splits "a, \"b, c\", d" on commas that are not inside quotes.
  static List<dynamic> _splitList(String inner) {
    final parts = <String>[];
    var buf = StringBuffer();
    var quote = '';
    for (final ch in inner.split('')) {
      if (quote.isNotEmpty) {
        buf.write(ch);
        if (ch == quote) quote = '';
      } else if (ch == '"' || ch == "'") {
        quote = ch;
        buf.write(ch);
      } else if (ch == ',') {
        parts.add(buf.toString().trim());
        buf = StringBuffer();
      } else {
        buf.write(ch);
      }
    }
    parts.add(buf.toString().trim());
    return parts.where((p) => p.isNotEmpty).map(_scalar).toList();
  }
}

/// ---------------------------------------------------------------------------
/// Front matter parsing
/// ---------------------------------------------------------------------------
Map<String, dynamic> _parseFrontMatter(String text) {
  final out = <String, dynamic>{};
  for (final line in text.split('\n')) {
    final idx = line.indexOf(':');
    if (idx <= 0) continue;
    final key = line.substring(0, idx).trim();
    var value = line.substring(idx + 1).trim();
    if (value.length >= 2 &&
        ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'")))) {
      value = value.substring(1, value.length - 1);
    } else if (value.startsWith('[') && value.endsWith(']')) {
      final inner = value.substring(1, value.length - 1).trim();
      if (inner.isEmpty) {
        out[key] = <String>[];
      } else {
        out[key] = inner
            .split(',')
            .map((s) => s.trim().replaceAll('"', '').replaceAll("'", ''))
            .where((s) => s.isNotEmpty)
            .toList();
      }
      continue;
    }
    out[key] = int.tryParse(value) ??
        (value == 'true'
            ? true
            : value == 'false'
                ? false
                : value);
  }
  return out;
}

/// ---------------------------------------------------------------------------
/// Markdown block scanner
/// ---------------------------------------------------------------------------
const alertKindRe = '(note|tip|warning|trap|key)';
final _fenceStart = RegExp(r'^```([\w+-]*)\s*(.*)$');
final _alertLine =
    RegExp('^\\s*>\\s*\\[!($alertKindRe)\\]\\s*\$');
final _heading = RegExp(r'^#{1,3}\s');

List<ContentBlock> parseBlocks(
    String body, List<QuizQuestion> quizOut, List<QuizQuestion> examOut) {
  final blocks = <ContentBlock>[];
  final prose = StringBuffer();
  List<String> calloutLines = [];
  var calloutKind = '';
  var inFence = false;
  var fencedYaml = false;
  var pendingYaml = '';
  final fenceLines = <String>[];
  var fenceLang = '';
  var fenceInfo = '';

  void flushProse() {
    if (prose.isEmpty) return;
    blocks.add(ContentBlock(BlockKind.prose, prose.toString()));
    prose.clear();
  }

  void flushCallout() {
    if (calloutKind.isEmpty) return;
    flushProse();
    blocks.add(ContentBlock(BlockKind.callout,
        calloutLines.join('\n').trim(),
        language: calloutKind));
    calloutKind = '';
    calloutLines = [];
  }

  for (final line in linesOf(body)) {
    if (!inFence) {
      final m = _fenceStart.firstMatch(line);
      if (m != null) {
        flushCallout();
        flushProse();
        inFence = true;
        fencedYaml = (m.group(1) ?? '') == 'yaml';
        fenceLang = m.group(1) ?? '';
        fenceInfo = m.group(2) ?? '';
        fenceLines.clear();
        continue;
      }
      final alert = _alertLine.firstMatch(line);
      if (alert != null) {
        flushCallout();
        flushProse();
        calloutKind = alert.group(1)!;
        continue;
      }
      if (calloutKind.isNotEmpty) {
        calloutLines.add(line.startsWith('> ') ? line.substring(2) : line);
        continue;
      }
      if (line.startsWith('## Quiz')) {
        pendingYaml = 'quiz';
      } else if (line.startsWith('## ExamQuestions')) {
        pendingYaml = 'exam';
      } else if (_heading.hasMatch(line)) {
        pendingYaml = '';
      }
      prose.writeln(line);
      continue;
    }
    // in fence
    if (line.trim() == '```') {
        inFence = false;
        final code = fenceLines.join('\n');
        if (fencedYaml) {
          final data = _parseItems(code);
          if (data != null) {
            if (pendingYaml == 'exam') {
              examOut.addAll(data);
              blocks.add(ContentBlock(BlockKind.examYaml, code));
            } else {
              quizOut.addAll(data);
              blocks.add(ContentBlock(BlockKind.quizYaml, code));
            }
          }
          pendingYaml = '';
        } else {
          final info = fenceInfo;
          blocks.add(ContentBlock(BlockKind.code, code,
              language: fenceLang,
              info: info,
              runnable: (fenceLang == 'python' || fenceLang == 'go') &&
                  !info.contains('eval=no')));
        }
        fenceLines.clear();
        continue;
      }
      fenceLines.add(line);
      continue;
    }
    flushCallout();
    flushProse();
    return blocks;
}

List<String> linesOf(String s) => s.split('\n');

List<QuizQuestion>? _parseItems(String yamlText) {
  final raw = YamlLite.parse(yamlText);
  dynamic items = raw;
  if (raw is Map<String, dynamic>) {
    items = raw['questions'] ?? raw['bank'] ?? raw;
  } else if (raw is List) {
    // May be wrapped: [{ "questions": [...] }]
    if (raw.length == 1 && raw.first is Map<String, dynamic>) {
      final m = raw.first as Map<String, dynamic>;
      if (m.containsKey('questions') || m.containsKey('bank')) {
        items = m['questions'] ?? m['bank'];
      }
    }
  }
  if (items is! List) return null;
  final out = <QuizQuestion>[];
  for (var i = 0; i < items.length; i++) {
    final q = items[i];
    if (q is! Map<String, dynamic>) continue;
    final choices = (q['choices'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];
    final answers = (q['answer'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        <int>[];
    out.add(QuizQuestion(
      id: q['id']?.toString() ?? 'q$i',
      prompt: q['prompt']?.toString() ?? q['question']?.toString() ?? '',
      multi: (q['type']?.toString() ?? 'single') == 'multi',
      choices: choices,
      answer: answers,
      explanation: q['explanation']?.toString() ?? '',
      difficulty: (q['difficulty'] as num?)?.toInt() ?? 1,
      section: q['section']?.toString(),
      weight: (q['weight'] as num?)?.toInt() ?? 4,
    ));
  }
  return out;
}

/// ---------------------------------------------------------------------------
  /// ContentLibrary
  /// ---------------------------------------------------------------------------
class ContentLibrary {
  final List<Course> courses = [];

  /// Bubbles up load failures for the UI to present.
  String? lastError;

  Future<void> load({Directory? userBase}) async {
    courses.clear();
    lastError = null;
    try {
      final packText =
          await rootBundle.loadString('assets/courseware/pack.json');
      final packs = (jsonDecode(packText) as List).cast<Map<String, dynamic>>();
      for (final pack in packs) {
        courses.add(_fromPack(pack));
      }
    } catch (e) {
      lastError = 'Bundled content unavailable: $e';
    }
    if (userBase != null && userBase.existsSync()) {
      try {
        for (final courseDir
            in userBase.listSync().whereType<Directory>()) {
          final id = courseDir.uri.pathSegments.last;
          final mfFile = File(
              '${courseDir.path}${Platform.pathSeparator}manifest.json');
          if (!mfFile.existsSync()) continue;
          final mf = jsonDecode(mfFile.readAsStringSync())
              as Map<String, dynamic>;
          final course = _fromDir(id, mf, courseDir.path);
          _merge(course);
        }
      } catch (e) {
        lastError = 'User content problem: $e';
      }
    }
    courses.sort((a, b) => a.courseId.compareTo(b.courseId));
  }

  void _merge(Course course) {
    final existing = courses.indexWhere((c) => c.courseId == course.courseId);
    if (existing == -1) {
      courses.add(course);
      return;
    }
    final base = courses[existing];
    courses[existing] = Course(
      courseId: base.courseId,
      title: base.title,
      subtitle: base.subtitle,
      language: base.language,
      examConfig: course.examConfig,
      sections: [
        ...base.sections,
        ...course.sections,
      ],
      sourceDir: base.sourceDir,
    );
  }

  Course _fromPack(Map<String, dynamic> mf) {
    final id = mf['courseId']?.toString() ?? '';
    final sections = <Section>[];
    for (final s in (mf['sections'] as List? ?? [])) {
      final sm = s as Map<String, dynamic>;
      final secId = sm['id'].toString();
      final secTitle = sm['title']?.toString() ?? secId;
      final mods =
          _loadModulesFromPack(secId, secTitle, id, sm['modules'] as List? ?? []);
      sections.add(Section(
        id: secId,
        title: secTitle,
        weight: (sm['weight'] as num?)?.toInt() ?? 0,
        modules: _sortModules(mods),
      ));
    }
    return Course(
      courseId: id,
      title: mf['title']?.toString() ?? id,
      subtitle: mf['subtitle']?.toString() ?? '',
      language: mf['language']?.toString() ?? 'python',
      examConfig: _exam(mf),
      sections: sections.where((s) => s.modules.isNotEmpty).toList(),
      sourceDir: 'assets',
    );
  }

  ExamConfig _exam(Map<String, dynamic> mf) {
    final e = mf['examMode'] as Map<String, dynamic>? ?? {};
    return ExamConfig(
      questionCount: (e['questionCount'] as num?)?.toInt() ?? 45,
      durationMinutes: (e['durationMinutes'] as num?)?.toInt() ?? 65,
      passPct: (e['passPct'] as num?)?.toInt() ?? 70,
    );
  }

  List<Module> _loadModulesFromPack(
      String secId, String secTitle, String courseId, List modules) {
    final out = <Module>[];
    for (final m in modules) {
      final mm = m as Map<String, dynamic>;
      final md = mm['markdown']?.toString() ?? '';
      out.add(_parseModule(
          md, mm['file']?.toString() ?? '', secId, secTitle, courseId));
    }
    return out;
  }

  Course _fromDir(String id, Map<String, dynamic> mf, String dir) {
    final sections = <Section>[];
    final sectionMeta = <String, Map<String, dynamic>>{
      for (final s in (mf['sections'] as List? ?? []))
        (s as Map)['id'].toString(): s as Map<String, dynamic>,
    };
    if (Directory(dir).existsSync()) {
      for (final secDir in Directory(dir).listSync().whereType<Directory>()) {
        final secId = secDir.uri.pathSegments.last;
        final meta = sectionMeta[secId] ??
            {
              'id': secId,
              'title': secId,
              'weight': 0,
            };
        final secTitle = meta['title']?.toString() ?? secId;
        final mods =
            _sortModules(_loadMdFiles(secDir.path, secId, secTitle, id));
        if (mods.isNotEmpty) {
          sections.add(Section(
            id: secId,
            title: secTitle,
            weight: (meta['weight'] as num?)?.toInt() ?? 0,
            modules: mods,
          ));
        }
      }
    }
    return Course(
      courseId: id,
      title: mf['title']?.toString() ?? id,
      subtitle: mf['subtitle']?.toString() ?? '',
      language: mf['language']?.toString() ?? 'python',
      examConfig: _exam(mf),
      sections: sections,
      sourceDir: dir,
    );
  }

  List<Module> _loadMdFiles(String dir, String secId, String secTitle, String courseId) {
    final files = Directory(dir)
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.md'))
        .toList()
      ..sort((a, b) => a.uri.pathSegments.last
          .compareTo(b.uri.pathSegments.last));
    return files
        .map((f) => _parseModule(f.readAsStringSync(),
            f.uri.pathSegments.last, secId, secTitle, courseId))
        .toList();
  }

  List<Module> _sortModules(List<Module> mods) {
    final copy = [...mods]
      ..sort((a, b) {
        // sort by numeric prefix of filename-ish order, fallback to order
        final ka = a.order != 0 ? a.order : int.tryParse(a.id.split('-').first) ?? 0;
        final kb = b.order != 0 ? b.order : int.tryParse(b.id.split('-').first) ?? 0;
        if (ka != kb) return ka.compareTo(kb);
        return a.id.compareTo(b.id);
      });
    return copy;
  }

  Module _parseModule(String md, String fileName, String sectionId,
      String sectionTitle, String courseId) {
    var fm = <String, dynamic>{};
    var body = md;
    if (md.trimLeft().startsWith('---')) {
      final end = md.indexOf('\n---', 3);
      if (end != -1) {
        fm = _parseFrontMatter(md.substring(4, end));
        body = md.substring(end + 5);
      }
    }
    final quiz = <QuizQuestion>[];
    final exam = <QuizQuestion>[];
    final blocks = parseBlocks(body, quiz, exam);
    return Module(
      courseId: courseId,
      id: fm['id']?.toString() ?? fileName.replaceAll('.md', ''),
      title: fm['title']?.toString() ??
          fileName.replaceAll('.md', '').replaceAll('-', ' '),
      order: (fm['order'] as num?)?.toInt() ?? 0,
      sectionId: sectionId,
      sectionTitle: sectionTitle,
      language: fm['language']?.toString() ?? 'python',
      summary: fm['summary']?.toString() ?? '',
      tags: (fm['tags'] is List)
          ? (fm['tags'] as List).map((e) => e.toString()).toList()
          : const [],
      rawBody: body,
      blocks: blocks,
      quiz: quiz,
      examBank: exam,
    );
  }
}
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../models/models.dart';
import 'lesson_screen.dart';

class SettingsScreen extends StatefulWidget {
  final AppState state;
  const SettingsScreen({super.key, required this.state});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _exporting = false;
  String? _exportMsg;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Overview & Settings'),
          bottom: const TabBar(
            indicatorColor: kAccent,
            labelColor: Colors.white,
            unselectedLabelColor: kMuted,
            tabs: [
              Tab(icon: Icon(Icons.dashboard_outlined), text: 'Overview'),
              Tab(icon: Icon(Icons.bookmarks_outlined), text: 'Bookmarks'),
              Tab(icon: Icon(Icons.settings_outlined), text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _overview(widget.state),
            _bookmarks(widget.state),
            _settings(widget.state),
          ],
        ),
      ),
    );
  }

  Widget _overview(AppState s) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final c in s.library.courses) _courseProgressCard(s, c),
        const SizedBox(height: 16),
        _examHistoryCard(s),
      ],
    );
  }

  Widget _courseProgressCard(AppState s, Course c) {
    final total = c.allModules.length;
    final done = s.completedCount(c.courseId);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 10),
            for (final sec in c.sections) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text('${sec.title} (${sec.modules.length})',
                          style: const TextStyle(fontSize: 13, color: kMuted)),
                    ),
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: s.sectionProgress(c.courseId, sec.id),
                          minHeight: 6,
                          backgroundColor: kSurfaceAlt,
                          valueColor:
                              const AlwaysStoppedAnimation(kAccent),
                        ),
                      ),
                    ),
                    SizedBox(
                        width: 40,
                        child: Text(
                          ' ${(s.sectionProgress(c.courseId, sec.id) * 100).round()}%',
                          style: const TextStyle(fontSize: 12, color: kMuted),
                        )),
                  ],
                ),
              ),
            ],
            const Divider(height: 20),
            Text('$done / $total modules complete',
                style: const TextStyle(color: kMuted, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _examHistoryCard(AppState s) {
    return FutureBuilder<List<Map<String, Object?>>>(
      future: s.repo.examHistory(firstCourse(s)),
      builder: (ctx, snap) {
        final rows = snap.data ?? [];
        if (rows.isEmpty) {
          return const Card(
            child: ListTile(
              leading: Icon(Icons.school_outlined, color: kMuted),
              title: Text('No exam attempts yet'),
              subtitle:
                  Text('Run the exam simulator from a course page.'),
            ),
          );
        }
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Text('Recent exams',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              for (final r in rows.take(5))
                ListTile(
                  dense: true,
                  leading: Icon(
                    (r['passed'] as int? ?? 0) == 1
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: (r['passed'] as int? ?? 0) == 1
                        ? const Color(0xFF7BC47F)
                        : const Color(0xFFE2705B),
                  ),
                  title: Text(
                      'Score ${r['score']} / ${r['total']}  (${r['passed'] == 1 ? 'passed' : 'failed'})',
                      style: const TextStyle(fontSize: 14)),
                  subtitle: Text(
                      s.formatDate(r['started_at'] as int),
                      style: const TextStyle(fontSize: 12)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _bookmarks(AppState s) {
    if (s.library.courses.isEmpty) return const SizedBox.shrink();
    final course = s.library.courses.first;
    final bm = s.bookmarks(course.courseId);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        if (bm.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text('No bookmarks yet. Tap the bookmark icon in a lesson.',
                  style: TextStyle(color: kMuted)),
            ),
          ),
        for (final m in bm)
          ListTile(
            leading: const Icon(Icons.bookmark, color: kAccent, size: 20),
            title: Text('${m.order}. ${m.title}'),
            subtitle: Text(m.sectionTitle,
                style: const TextStyle(fontSize: 12, color: kMuted)),
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => LessonScreen(state: s, module: m)),
            ),
          ),
      ],
    );
  }

  Widget _settings(AppState s) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Data',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.upload_file_outlined),
                title: const Text('Export my progress'),
                subtitle: Text(_exportMsg ?? 'JSON in app documents dir',
                    style: const TextStyle(fontSize: 12)),
                trailing: _exporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.chevron_right),
                onTap: _exporting ? null : () => _export(s),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Color(0xFFE2705B)),
                title: const Text('Reset all progress'),
                onTap: () => _confirmWipe(s),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.info_outline, color: kMuted),
          title: Text('flutterTrain',
              style: TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(
              'Offline Python + Go zero-to-hero training harness.\n'
              'Code runs natively on-device via Chaquopy CPython and the yaegi Go interpreter.',
              style: TextStyle(color: kMuted, fontSize: 12, height: 1.5)),
        ),
      ],
    );
  }

  Future<String> _export(AppState s) async {
    setState(() {
      _exporting = true;
      _exportMsg = null;
    });
    final dir = await getApplicationDocumentsDirectory();
    final data = <String, dynamic>{};
    for (final c in s.library.courses) {
      data[c.courseId] = {
        'completed': s.completedCount(c.courseId),
        'total': c.allModules.length,
      };
    }
    final file = File('${dir.path}/flutter_train_progress_export.json');
    await file.writeAsString(jsonEncode(data));
    if (mounted) {
      setState(() {
        _exporting = false;
        _exportMsg = file.path;
      });
    }
    return file.path;
  }

  Future<void> _confirmWipe(AppState s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset all progress?'),
        content: const Text(
            'This clears module completion, quiz scores, attempts, notes, and bookmarks. Cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reset')),
        ],
      ),
    );
    if (ok == true && mounted) {
      final dir = await getApplicationDocumentsDirectory();
      final db = File('${dir.path}/flutter_train.db');
      if (db.existsSync()) db.deleteSync();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress reset. Restart the app.')),
        );
      }
    }
  }

  String firstCourse(AppState s) =>
      s.library.courses.isNotEmpty ? s.library.courses.first.courseId : '';
}
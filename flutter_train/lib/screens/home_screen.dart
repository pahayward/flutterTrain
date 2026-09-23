import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/code_runner.dart';
import '../core/theme.dart';
import '../models/models.dart';
import 'course_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppState state;
  const HomeScreen({super.key, required this.state});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    CodeRunner.ping().then((ok) {
      widget.state.enginesAvailable = ok;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('flutterTrain', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => SearchScreen(state: widget.state)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => SettingsScreen(state: widget.state)),
            ),
          ),
        ],
      ),
      body: state.loadError != null
          ? _ErrorRetry(state: state)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!state.enginesAvailable)
                  const _EnginesNotice(),
                ...state.library.courses.map(
                  (c) => _CourseCard(state: state, course: c),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

class _EnginesNotice extends StatelessWidget {
  const _EnginesNotice();
  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.offline_bolt_outlined, color: kMuted),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Code engines unavailable — run/download on Android to enable live examples.',
                style: TextStyle(color: kMuted, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final AppState state;
  final Course course;
  const _CourseCard({required this.state, required this.course});

  @override
  Widget build(BuildContext context) {
    final total = course.allModules.length;
    final done = state.completedCount(course.courseId);
    final pct = total == 0 ? 0.0 : done / total;
    final sections = course.sections.length;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => CourseScreen(state: state, course: course)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kAccent.withValues(alpha:0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      course.language.toUpperCase(),
                      style: const TextStyle(color: kAccent, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Spacer(),
                  Text('$sections sections · $total modules',
                      style: const TextStyle(color: kMuted, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 10),
              Text(course.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              if (course.subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(course.subtitle,
                    style: const TextStyle(color: kMuted, fontSize: 13)),
              ],
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                  backgroundColor: kSurfaceAlt,
                  valueColor: const AlwaysStoppedAnimation(kAccent),
                ),
              ),
              const SizedBox(height: 6),
              Text('$done / $total completed',
                  style: const TextStyle(color: kMuted, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final AppState state;
  const _ErrorRetry({required this.state});
  @override
  Widget build(BuildContext context) {
    final error = state.loadError!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFE2705B), size: 48),
            const SizedBox(height: 12),
            const Text('Content load failed',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: kMuted, fontSize: 13)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (_) => HomeScreen(state: state)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
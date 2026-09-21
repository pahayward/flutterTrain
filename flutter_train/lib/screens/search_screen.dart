import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/content_search.dart';
import '../core/theme.dart';
import 'lesson_screen.dart';

class SearchScreen extends StatefulWidget {
  final AppState state;
  const SearchScreen({super.key, required this.state});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _query = TextEditingController();
  List<SearchHit> _hits = [];
  String _queryText = '';
  bool _searched = false;

  void _search(String q) {
    _queryText = q.trim();
    setState(() {
      _hits = _queryText.isEmpty
          ? []
          : ContentSearch.search(widget.state.library.courses, _queryText);
      _searched = true;
    });
    if (_queryText.isNotEmpty) ContentSearch.addRecentSearch(_queryText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _query,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search lessons, topics, snippets…',
            border: InputBorder.none,
            hintStyle: TextStyle(color: kMuted),
          ),
          onSubmitted: _search,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _search(_query.text),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 4),
        children: [
          if (!_searched)
            _recentSearches(),
          if (_searched && _hits.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No matches. Try another keyword.',
                    style: TextStyle(color: kMuted)),
              ),
            ),
          for (final hit in _hits)
            ListTile(
              leading: Icon(
                hit.module.language == 'go'
                    ? Icons.terminal
                    : Icons.code,
                color: kAccent,
              ),
              title: Text(hit.module.title,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${hit.module.sectionTitle} · ${hit.module.courseId.toUpperCase()}',
                    style: const TextStyle(fontSize: 11, color: kMuted),
                  ),
                  Text(hit.snippet,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: kMuted)),
                ],
              ),
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => LessonScreen(
                          state: widget.state, module: hit.module)),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _recentSearches() {
    Future<List<String>> recent = ContentSearch.recentSearches();
    return FutureBuilder<List<String>>(
      future: recent,
      builder: (ctx, snap) {
        final items = snap.data ?? [];
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text('Recent',
                  style: TextStyle(color: kMuted, fontWeight: FontWeight.w600)),
            ),
            for (final q in items)
              ListTile(
                dense: true,
                leading: const Icon(Icons.history, size: 16),
                title: Text(q, style: const TextStyle(fontSize: 14)),
                onTap: () {
                  _query.text = q;
                  _search(q);
                },
              ),
          ],
        );
      },
    );
  }
}
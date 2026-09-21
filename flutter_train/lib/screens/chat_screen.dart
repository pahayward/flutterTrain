import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';

/// Optional OpenRouter chat: expand/explain courseware topics. App works fully
/// offline without an API key.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _busy = false;
  String? _key;
  bool _keyLoaded = false;

  static const int _maxMessages = 30;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _key = sp.getString('openrouter_key');
      _keyLoaded = true;
    });
  }

  void _add(String role, String text) {
    setState(() {
      _messages.add({'role': role, 'text': text});
      if (_messages.length > _maxMessages) {
        _messages.removeAt(0);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _busy) return;
    final key = _key;
    if (key == null || key.isEmpty) {
      _add('system', 'Set an OpenRouter API key in Settings (internet required). The app works fully offline otherwise.');
      return;
    }
    _input.clear();
    _add('user', text);
    setState(() => _busy = true);
    try {
      final res = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $key',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'openchat/openchat-3.5-1210',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a study assistant for the PCPP1 (PCPP-32-101) Python exam '
                      'and a Go zero-to-hero course. Be concise, give runnable code '
                      'snippets, and explain trade-offs. If asked to expand the offline '
                      'courseware, provide COURSEWARE_FORMAT-style markdown sections '
                      'with front matter, code blocks, and a ## Quiz yaml block.'
            },
            ..._messages
                .where((m) => m['role'] != 'system')
                .map((m) => {'role': m['role'], 'content': m['text']}),
          ],
          'max_tokens': 900,
          'temperature': 0.5,
        }),
      );
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final content = (body['choices'] as List?)?[0]?['message']?['content'];
      _add('assistant', content?.toString() ?? 'No response.');
    } catch (e) {
      _add('system', 'Request failed: $e. Check your key and internet connection.');
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Study Assistant')),
      body: Column(
        children: [
          if (!_keyLoaded)
            const LinearProgressIndicator(minHeight: 2, color: kAccent)
          else if ((_key ?? '').isEmpty)
            Container(
              width: double.infinity,
              color: kSurface,
              padding: const EdgeInsets.all(10),
              child: const Text(
                'Offline mode — no API key set. Enable in Settings for AI help.',
                style: TextStyle(color: kMuted, fontSize: 12),
              ),
            ),
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Ask about a PCPP1 topic or any Go concept. Snippets are '
                        'plain text; try them in the Lab.\n\n'
                        'Offline by design — nothing is sent anywhere until you set a key.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: kMuted, height: 1.5),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (ctx, i) => _bubble(_messages[i]),
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      onSubmitted: (_) => _send(),
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Ask about PCPP1 or Go…',
                        filled: true,
                        fillColor: kSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.arrow_upward),
                    onPressed: _busy ? null : _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(Map<String, String> m) {
    final role = m['role']!;
    final text = m['text']!;
    final me = role == 'user';
    if (role == 'system') {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFE3A857).withValues(alpha:0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text,
            style: const TextStyle(color: Color(0xFFE3A857), fontSize: 12.5)),
      );
    }
    return Align(
      alignment: me ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: me ? kAccent : kSurface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(me ? 14 : 2),
            bottomRight: Radius.circular(me ? 2 : 14),
          ),
        ),
        child: SelectableText(text, style: const TextStyle(fontSize: 14, height: 1.5)),
      ),
    );
  }
}
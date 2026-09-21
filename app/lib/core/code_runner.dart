/// Bridge to the embedded code engines via MethodChannel.
///
/// Android side (android-overlay/src/main/kotlin/.../MainActivity.kt):
///   runPython(code, timeout<Double secs>) -> JSON string {ok,stdout,stderr,err}
///   runGo(code, timeout<Double ms>)        -> JSON string {ok,stdout,stderr,error}
library;

import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/models.dart';

const MethodChannel _channel = MethodChannel('pp1.study/code');

class CodeRunner {
  static const int defaultTimeoutS = 8;

  /// True if the native engines responded (guards the "run" buttons on
  /// platforms without Chaquopy/gomobile, e.g. flutter test / desktop).
  static Future<bool> ping() async {
    try {
      final res = await _channel.invokeMethod<String>('ping');
      return res == 'pong';
    } catch (_) {
      return false;
    }
  }

  static Future<RunResult> runPython(
    String code, {
    int timeoutS = defaultTimeoutS,
  }) async {
    return _run(
        _channel.invokeMethod<String>('runPython', {
          'code': code,
          'timeout': timeoutS.toDouble(),
        }),
        engine: 'python');
  }

  static Future<RunResult> runGo(
    String code, {
    int timeoutS = defaultTimeoutS,
  }) async {
    return _run(
        _channel.invokeMethod<String>('runGo', {
          'code': code,
          'timeout': (timeoutS * 1000).toDouble(),
        }),
        engine: 'go');
  }

  /// Engine-agnostic: picks python or go runner.
  static Future<RunResult> run(String language, String code,
      {int timeoutS = defaultTimeoutS}) {
    return language == 'go' ? runGo(code, timeoutS: timeoutS) : runPython(code, timeoutS: timeoutS);
  }

  static Future<RunResult> _run(Future<String?> future,
      {required String engine}) async {
    try {
      final raw = await future;
      if (raw == null || raw.isEmpty) {
        return RunResult(false, '', '', 'No engine response', engine);
      }
      if (engine == 'go') {
        // Go engine returns plain text: stdout, or "Error: <msg>".
        final text = raw.trimRight();
        if (text.startsWith('Error: ')) {
          return RunResult(false, '', '', text.substring('Error: '.length), engine);
        }
        return RunResult(true, text, '', '', engine);
      }
      final r = (jsonDecode(raw) as Map<String, dynamic>);
      final err = r['error']?.toString() ?? r['err']?.toString() ?? '';
      return RunResult(
        r['ok'] is bool ? r['ok'] as bool : err.isEmpty,
        r['stdout']?.toString() ?? '',
        r['stderr']?.toString() ?? '',
        err,
        engine,
      );
    } on MissingPluginException {
      return RunResult(false, '', '', 'Code engines unavailable (desktop/test)', engine);
    } on FormatException {
      return RunResult(false, '', '', 'Engine returned malformed output', engine);
    } on PlatformException catch (e) {
      return RunResult(false, '', '', e.message ?? 'Engine error', engine);
    } catch (e) {
      return RunResult(false, '', '', e.toString(), engine);
    }
  }
}
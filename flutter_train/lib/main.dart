import 'package:flutter/material.dart';

import 'core/app_state.dart';
import 'core/theme.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (details) => Container(
        padding: const EdgeInsets.all(12),
        color: const Color(0xFF3A1F24),
        child: Text(
          'Render error: ${details.exceptionAsString()}',
          style: const TextStyle(color: Color(0xFFF3B0A9), fontSize: 12),
        ),
      );
  final state = AppState();
  try {
    await state.init();
  } catch (e) {
    state.loadError = 'Init failed: $e';
  }
  runApp(FlutterTrainApp(state: state));
}

class FlutterTrainApp extends StatelessWidget {
  final AppState state;
  const FlutterTrainApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutterTrain',
      debugShowCheckedModeBanner: false,
      theme: PTheme.dark(),
      home: HomeScreen(state: state),
    );
  }
}
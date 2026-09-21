import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pp1study/core/app_state.dart';
import 'package:pp1study/core/theme.dart';
import 'package:pp1study/screens/home_screen.dart';
import 'package:pp1study/screens/lesson_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final state = AppState();

  setUpAll(() async {
    // Real I/O must complete outside the fake-async test zone.
    await state.library.load();
  });

  String renderedText(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .join(' ')
      .trim();

  testWidgets('home lists bundled courses', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: PTheme.dark(),
      home: HomeScreen(state: state),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(renderedText(tester).length, greaterThan(20));
  });

  testWidgets('lesson body renders visible prose', (tester) async {
    final module = state.library.courses.first.allModules.first;
    await tester.pumpWidget(MaterialApp(
      theme: PTheme.dark(),
      home: LessonScreen(state: state, module: module),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(renderedText(tester).length, greaterThan(100));
  });
}

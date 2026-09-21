import 'package:flutter/material.dart';

const kAccent = Color(0xFF2F6BFF);
const kBg = Color(0xFF0F1220);
const kSurface = Color(0xFF1A1E30);
const kSurfaceAlt = Color(0xFF232840);
const kMuted = Color(0xFF9AA3C0);

abstract class PTheme {
  static ThemeData dark() => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(
          primary: kAccent,
          secondary: kAccent,
          surface: kSurface,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kBg,
          elevation: 0,
          centerTitle: false,
        ),
        listTileTheme: const ListTileThemeData(
          textColor: Colors.white,
          iconColor: kMuted,
        ),
        dividerTheme: const DividerThemeData(color: kSurfaceAlt),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: kSurfaceAlt,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      );

  static const mono = TextStyle(
    fontFamily: 'monospace',
    fontSize: 13,
    height: 1.45,
    color: Color(0xFFD7E0FF),
  );
}
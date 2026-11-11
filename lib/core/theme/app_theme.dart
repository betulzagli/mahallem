import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

/// Material 3 açık ve koyu tema yapılandırmalarını sunan tema yöneticisi.
class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = buildLightTheme();
  static final ThemeData darkTheme = buildDarkTheme();
}


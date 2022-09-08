import 'dart:ui';

import 'package:flutter/material.dart';

class Theme {
  const Theme(
      {required this.background,
      required this.foreground,
      required this.card,
      required this.navIcon});

  final Color background;
  final Color foreground;
  final Color card;
  final Color navIcon;

  static const Theme white = Theme(
      background: Color.fromRGBO(247, 247, 248, 1),
      foreground: Colors.black,
      card: Colors.white,
      navIcon: Color.fromRGBO(220, 220, 200, 1));
  static const Theme dark = Theme(
      background: Color.fromRGBO(18, 18, 17, 1),
      foreground: Colors.white,
      card: Colors.black,
      navIcon: Color.fromRGBO(35, 35, 35, 1));
}

class ThemesHandler {
  ThemesHandler({this.white = Theme.white, this.dark = Theme.dark});

  Theme white;
  Theme dark;

  bool isDark = true;

  toggleTheme() => isDark = !isDark;

  Theme get theme => isDark ? dark : white;

  static ThemesHandler instance = ThemesHandler();
}

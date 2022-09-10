import 'dart:ui';

import 'package:flutter/material.dart';

class Theme {
  const Theme(
      {required this.id,
      required this.background,
      required this.foreground,
      required this.card,
      required this.navIcon});

  Theme.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        background = json["background"],
        foreground = json["foreground"],
        card = json["card"],
        navIcon = json["navIcon"];

  final int id;
  final Color background;
  final Color foreground;
  final Color card;
  final Color navIcon;

  static const Theme white = Theme(
      id: 0,
      background: Color.fromRGBO(247, 247, 248, 1),
      foreground: Colors.black,
      card: Colors.white,
      navIcon: Color.fromRGBO(220, 220, 200, 1));
  static const Theme dark = Theme(
      id: 1,
      background: Color.fromRGBO(18, 18, 17, 1),
      foreground: Colors.white,
      card: Colors.black,
      navIcon: Color.fromRGBO(35, 35, 35, 1));
}

class ThemesHandler {
  ThemesHandler({this.white = Theme.white, this.dark = Theme.dark});

  Theme white;
  Theme dark;

  bool isDark = false;

  toggleTheme() => isDark = !isDark;

  Theme get theme => isDark ? dark : white;

  static ThemesHandler instance = ThemesHandler();
}

class Styles {  
  static const TextStyle f_13nt = TextStyle(
      fontFamily: "Montserrat",
      fontSize: 13,
      color: Colors.white);
  static const TextStyle f_15nt = TextStyle(
      fontFamily: "Montserrat",
      fontSize: 15,
      color: Colors.white);
  static const TextStyle f_18nt = TextStyle(
      fontFamily: "Montserrat",
      fontSize: 18,
      color: Colors.white);
  static const TextStyle f_24nt = TextStyle(
      fontFamily: "Montserrat",
      fontSize: 24,
      color: Colors.white);
  static const TextStyle f_30nt = TextStyle(fontFamily: "Montserrat", fontSize: 30, color: Colors.white);

  static TextStyle f_13 =
      f_13nt.apply(color: ThemesHandler.instance.theme.foreground);
  static TextStyle f_15 =
      f_15nt.apply(color: ThemesHandler.instance.theme.foreground);
  static TextStyle f_18 =
      f_18nt.apply(color: ThemesHandler.instance.theme.foreground);
  static TextStyle f_24 =
      f_24nt.apply(color: ThemesHandler.instance.theme.foreground);
  static TextStyle f_30 =
      f_24nt.apply(color: ThemesHandler.instance.theme.foreground);
}

enum CyrelOrientation {
  portrait,
  landscape;

  static CyrelOrientation current = CyrelOrientation.portrait;
}

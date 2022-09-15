import 'dart:ui';

import 'package:cyrel/api/base_entity.dart';
import 'package:flutter/material.dart';

class Theme extends BaseEntity {
  const Theme(
      {required this.id,
      required this.background,
      required this.foreground,
      required this.card,
      required this.navIcon});

  Theme.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        background = Color(int.parse(json["background"] as String)),
        foreground = Color(int.parse(json["foreground"] as String)),
        card = Color(int.parse(json["card"] as String)),
        navIcon = Color(int.parse(json["navIcon"] as String));

  @override
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "background": background.value.toString(),
      "foreground": foreground.value.toString(),
      "card": card.value.toString(),
      "navIcon": navIcon.value.toString(),
    };
  }

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
      navIcon: Color.fromRGBO(225, 225, 225, 1));
  static const Theme dark = Theme(
      id: 1,
      background: Color.fromRGBO(18, 18, 17, 1),
      foreground: Colors.white,
      card: Colors.black,
      navIcon: Color.fromRGBO(35, 35, 35, 1));
}

class ThemesHandler {
  ThemesHandler({List<Theme>? themeList}) {
    if (themeList != null) {
      _themeList = themeList; 
    }
  }
  
  List<Theme> _themeList =  [Theme.white, Theme.dark];
  List<Theme>? get themeList => _themeList;
  set themeList(List<Theme>? l) {
    if (l != null) {
      _themeList = l;
    }
  }

  int _cursor = 0;
  int get cursor => _cursor;
  set cursor(int c) {
    _cursor = c % _themeList.length; 
  }

  toggleTheme() => cursor++;

  Theme get theme => _themeList[cursor];

  static ThemesHandler instance = ThemesHandler();
}

class Styles {  
  static const TextStyle f_10nt = TextStyle(
      fontFamily: "Montserrat",
      fontSize: 10,
      color: Colors.white);
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

  TextStyle f_10 =
      f_10nt.apply(color: ThemesHandler.instance.theme.foreground);
  TextStyle f_13 =
      f_13nt.apply(color: ThemesHandler.instance.theme.foreground);
  TextStyle f_15 =
      f_15nt.apply(color: ThemesHandler.instance.theme.foreground);
  TextStyle f_18 =
      f_18nt.apply(color: ThemesHandler.instance.theme.foreground);
  TextStyle f_24 =
      f_24nt.apply(color: ThemesHandler.instance.theme.foreground);
  TextStyle f_30 =
      f_24nt.apply(color: ThemesHandler.instance.theme.foreground);
}

enum CyrelOrientation {
  portrait,
  landscape;

  static CyrelOrientation current = CyrelOrientation.portrait;
}

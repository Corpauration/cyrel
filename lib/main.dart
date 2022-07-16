import 'package:cyrel/ui/home.dart';
import 'package:cyrel/ui/homework.dart';
import 'package:cyrel/ui/navigation.dart';
import 'package:cyrel/ui/timetable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cyrel',
      home: NavHandler(pages: [
        UiPage(
            icon: SvgPicture.asset("assets/svg/home.svg"), page: const Home()),
        UiPage(
            icon: SvgPicture.asset("assets/svg/timetable.svg"),
            page: const TimeTable()),
        UiPage(
            icon: SvgPicture.asset("assets/svg/homework.svg"),
            page: const HomeWork())
      ]),
    );
  }
}

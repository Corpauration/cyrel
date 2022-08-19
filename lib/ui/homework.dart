import 'dart:math';

import 'package:cyrel/utils/week.dart';
import 'package:flutter/material.dart';


class HomeWorkDay extends StatelessWidget {
  const HomeWorkDay({Key? key, required this.dayName}) : super(key: key);

  final String dayName;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Text(dayName, style: TextStyle(fontFamily: "Montserrat", fontSize: 18),)
      ]),
    );
  }
}

class HomeWork extends StatefulWidget {
  const HomeWork({Key? key}) : super(key: key);

  @override
  State<HomeWork> createState() => _HomeWorkState();
}

class _HomeWorkState extends State<HomeWork> {
  Week week = Week().next();


  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color.fromRGBO(247, 247, 248, 1),
        child: LayoutBuilder(builder: (context, constraints) {
          const double minWidth = 350;
          double horizontalMargin = constraints.maxWidth / 3 < minWidth
              ? max(0, constraints.maxWidth / 2 - minWidth / 2)
              : max(0, constraints.maxWidth / 3);

          return Container(
              margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
              child: Column(children: [
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(week.toString(), style: const TextStyle(fontFamily: "Montserrat", fontSize: 24),),
                )
              ]));
        }));
  }
}

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

class HomeWork extends StatefulWidget {
  const HomeWork({Key? key}) : super(key: key);

  @override
  State<HomeWork> createState() => _HomeWorkState();
}

class _HomeWorkState extends State<HomeWork> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color.fromRGBO(247, 247, 248, 1),
        child: LayoutBuilder(builder: (context, constraints) {
          const double minWidth = 350;
          double horizontalMargin = constraints.maxWidth / 3 < minWidth
              ? max(0, constraints.maxWidth / 2 - minWidth / 2)
              : max(0, constraints.maxWidth / 3);
          double androidMargin = Platform.isAndroid
              ? max(0, MediaQuery.of(context).viewPadding.top)
              : 0;

          return Container(
              margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
              child: Column(children: [
                ConstrainedBox(
                    constraints: BoxConstraints(minHeight: androidMargin)),
              ]));
        }));
  }
}

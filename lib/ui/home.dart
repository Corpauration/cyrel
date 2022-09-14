import 'dart:math';

import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    const screenRatio = 7 / 5;

    return LayoutBuilder(builder: (context, constraints) {
      double horizontalMargin =
          constraints.maxHeight > (screenRatio * constraints.maxWidth)
              ? max(5, constraints.maxWidth / 48)
              : max(20, constraints.maxWidth / 12);

      return Container(
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
        child: UiScrollBar(
          scrollController: null,
          child: Column(children: [
            SizedBox(height: (1 / 24) * constraints.maxHeight),
            SizedBox(
              height: 40,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  children: [
                    Expanded(child: Container()),
                    Container(
                      decoration: BoxDecoration(
                          color: ThemesHandler.instance.theme.card,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(width: 5),
                            BoxButton(
                              child: Container(
                                  height: 35,
                                  width: 35,
                                  padding: const EdgeInsets.all(7),
                                  child: SizedBox(
                                      height: 21,
                                      child: SvgPicture.asset(
                                        "assets/svg/theme.svg",
                                        height: 21,
                                      ))),
                              onTap: () {},
                            ),
                            const SizedBox(width: 5),
                            BoxButton(
                              child: Container(
                                  height: 35,
                                  width: 35,
                                  padding: const EdgeInsets.all(7),
                                  child: SizedBox(
                                      height: 21,
                                      child: SvgPicture.asset(
                                        "assets/svg/logout.svg",
                                        height: 21,
                                      ))),
                              onTap: () {},
                            ),
                            const SizedBox(width: 5),
                          ]),
                    ),
                  ],
                ),
              ),
            )
          ]),
        ),
      );
    });
  }
}

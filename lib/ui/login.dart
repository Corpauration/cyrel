import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: null,
        body: Container(
          color: Color.fromRGBO(245, 245, 245, 1),
          child: LayoutBuilder(
            builder: (context, constraints) {
              late double horizontalPadding;

              if (constraints.maxWidth / 3 < 350) {
                horizontalPadding = max(0, constraints.maxWidth / 2 - 175);
              } else {
                horizontalPadding = max(0, constraints.maxWidth / 3);
              }

              return Stack(children: [
                Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white),
                    margin: EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      top: constraints.maxHeight / 8,
                      bottom: constraints.maxHeight / 8,
                    ),
                    child: Container(
                      padding: EdgeInsets.only(
                          top: max(
                              1,
                              max(constraints.maxHeight / 6, 80) -
                                  constraints.maxHeight / 18 +
                                  40)),
                      child: Column(children: [
                        Text("Bienvenue sur Cyrel",
                            style: TextStyle(
                                fontFamily: "Montserrat", fontSize: 24)),
                      ]),
                    )),
                Container(
                  margin: EdgeInsets.only(
                      top: (constraints.maxHeight / 8) -
                          constraints.maxHeight / 18,
                      left: (constraints.maxWidth / 2) -
                          max(constraints.maxHeight / 12, 40)),
                  child: SvgPicture.asset(
                    "assets/svg/cyrel.svg",
                    height: max(constraints.maxHeight / 6, 80),
                  ),
                ),
              ]);
            },
          ),
        ));
  }
}

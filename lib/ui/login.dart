import 'dart:math';
import 'dart:io' show Platform;
import 'package:cyrel/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginInput extends StatefulWidget {
  const LoginInput({Key? key}) : super(key: key);

  @override
  State<LoginInput> createState() => _LoginInputState();
}

class _LoginInputState<T extends LoginInput> extends State<T> {
  InputDecoration decoration =
      const InputDecoration(border: InputBorder.none, hintText: "Login");
  TextStyle style = const TextStyle(fontFamily: "Montserrat", fontSize: 16);
  Color cursorColor = const Color.fromRGBO(210, 210, 211, 1);

  Widget _buildDecoration(Widget icon, Widget child) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(247, 247, 248, 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          icon,
          const Spacer(
            flex: 1,
          ),
          Expanded(flex: 20, child: child)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildDecoration(
        SvgPicture.asset(
          "assets/svg/user.svg",
          height: 25,
        ),
        TextFormField(
          autocorrect: false,
          cursorColor: cursorColor,
          decoration: decoration,
          style: style,
        ));
  }
}

class PasswordInput extends LoginInput {
  const PasswordInput({Key? key}) : super(key: key);

  @override
  State<PasswordInput> createState() => PasswordInputState();
}

class PasswordInputState extends _LoginInputState<PasswordInput> {
  @override
  InputDecoration decoration =
      const InputDecoration(border: InputBorder.none, hintText: "Mot de passe");

  @override
  Widget build(BuildContext context) {
    return _buildDecoration(
        SvgPicture.asset(
          "assets/svg/lock.svg",
          height: 25,
        ),
        TextFormField(
          obscureText: true,
          autocorrect: false,
          cursorColor: cursorColor,
          decoration: decoration,
          style: style,
        ));
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({Key? key, required this.onTap}) : super(key: key);

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return BoxButton(
        onTap: onTap,
        child: Container(
            width: 250,
            height: 50,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 38, 96, 170),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
                child: Text(
              "Connection",
              style: TextStyle(
                  fontFamily: "Montserrat", color: Colors.white, fontSize: 18),
            ))));
  }
}

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
          color: const Color.fromRGBO(247, 247, 248, 1),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double minWidth = 350;
              const double minHeight = 410;
              late double horizontalMargin;
              late double topMargin;
              late double bottomMargin;
              late double verticalMargin;

              if (constraints.maxWidth / 3 < minWidth) {
                horizontalMargin =
                    max(0, constraints.maxWidth / 2 - minWidth / 2);
              } else {
                horizontalMargin = max(0, constraints.maxWidth / 3);
              }

              if (6 / 8 * constraints.maxHeight > minHeight) {
                verticalMargin =
                    max(0, constraints.maxHeight / 2 - minHeight / 2);
              } else {
                verticalMargin = max(0, constraints.maxHeight / 8);
              }

              if (Platform.isAndroid) {
                double topBarSize = MediaQuery.of(context).viewPadding.top;

                topMargin = max(0, verticalMargin + topBarSize);
                bottomMargin = max(0, verticalMargin - topBarSize);
              } else {
                topMargin = verticalMargin;
                bottomMargin = topMargin;
              }

              return Stack(children: [
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white),
                  margin: EdgeInsets.only(
                      left: horizontalMargin,
                      right: horizontalMargin,
                      top: topMargin,
                      bottom: bottomMargin),
                  child: Column(children: [
                    Container(
                        padding: EdgeInsets.only(
                            top: max(
                                1,
                                max(constraints.maxHeight / 6, 80) -
                                    constraints.maxHeight / 18 +
                                    20)),
                        child: Column(children: [
                          const Text("Bienvenue sur Cyrel",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: "Montserrat", fontSize: 24)),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 15),
                            child: Text(
                              "Connectez-vous à l'aide de votre compte Corpauration :",
                              style: TextStyle(
                                  fontFamily: "Montserrat", fontSize: 13),
                              softWrap: true,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          LoginInput(),
                          PasswordInput(),
                          LoginButton(onTap: () {})
                        ])),
                  ]),
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: max(0, topMargin - constraints.maxHeight / 18),
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

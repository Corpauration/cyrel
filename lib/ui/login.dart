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
  InputDecoration decoration = const InputDecoration(
    border: InputBorder.none,
    hintText: "Login",
  );
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
          textInputAction: TextInputAction.next,
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
  late double iconOpacity = 1;
  final ScrollController _scrollController = ScrollController();

  void _scrollListener() {
    setState(() {
      double scrollPosition = _scrollController.position.pixels;
      if (scrollPosition < 60) {
        iconOpacity = 1 / (scrollPosition + 1);
      } else {
        iconOpacity = 0;
      }
    });
  }

  @override
  void initState() {
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: LayoutBuilder(builder: (context, constraints) {
        const double minWidth = 350;
        double horizontalMargin = constraints.maxWidth / 3 < minWidth
            ? max(0, constraints.maxWidth / 2 - minWidth / 2)
            : max(0, constraints.maxWidth / 3);
        double androidMargin = Platform.isAndroid
            ? max(0, MediaQuery.of(context).viewPadding.top)
            : 0;
        double iconSize = max(constraints.maxHeight / 6, 80);
        double iconOffset = constraints.maxHeight / 18;
        double cardWidth = constraints.maxWidth - (horizontalMargin * 2);

        return Container(
          margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
          child: Column(children: [
            ConstrainedBox(
                constraints: BoxConstraints(minHeight: androidMargin)),
            Expanded(
              child: Center(
                child: Stack(children: [
                  Container(
                      margin: EdgeInsets.symmetric(vertical: iconOffset),
                      padding: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white),
                      child: Scrollbar(
                          controller: _scrollController,
                          thickness: 4,
                          thumbVisibility: true,
                          radius: const Radius.circular(10),
                          child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(scrollbars: false),
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: Column(
                                  children: [
                                    ConstrainedBox(
                                        constraints: BoxConstraints(
                                            minHeight: max(0,
                                                iconSize - iconOffset + 20))),
                                    const Text("Bienvenue sur Cyrel",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontFamily: "Montserrat",
                                            fontSize: 24)),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 15),
                                      child: Text(
                                        "Connectez-vous à l'aide de votre compte Corpauration :",
                                        style: TextStyle(
                                            fontFamily: "Montserrat",
                                            fontSize: 13),
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    LoginInput(),
                                    PasswordInput(),
                                    LoginButton(onTap: () {})
                                  ],
                                ),
                              )))),
                  Opacity(
                    opacity: iconOpacity,
                    child: Container(
                      margin: EdgeInsets.only(
                          left: max(0, (cardWidth - iconSize) / 2)),
                      child: SvgPicture.asset(
                        "assets/svg/cyrel.svg",
                        height: iconSize,
                      ),
                    ),
                  ),
                ]),
              ),
            )
          ]),
        );
      }),
    );
  }
}

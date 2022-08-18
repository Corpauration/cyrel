import 'dart:math';
import 'dart:io' show Platform;
import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/auth.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginInput extends StatefulWidget {
  const LoginInput({Key? key, required this.onChanged}) : super(key: key);

  final Function(String) onChanged;

  @override
  State<LoginInput> createState() => _LoginInputState();
}

class _LoginInputState<T extends LoginInput> extends State<T> {
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
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "Login",
          ),
          style: style,
          onChanged: (value) => widget.onChanged(value.trim()),
        ));
  }
}

class PasswordInput extends LoginInput {
  const PasswordInput(this.onSubmit,
      {Key? key, required Function(String) onChanged})
      : super(key: key, onChanged: onChanged);

  final Function onSubmit;

  @override
  State<PasswordInput> createState() => PasswordInputState();
}

class PasswordInputState extends _LoginInputState<PasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return _buildDecoration(
        SvgPicture.asset(
          "assets/svg/lock.svg",
          height: 25,
        ),
        TextFormField(
          obscureText: _obscureText,
          autocorrect: false,
          cursorColor: cursorColor,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Mot de passe",
              suffixIcon: Container(
                decoration: BoxDecoration(
                    color: _obscureText
                        ? Colors.transparent
                        : const Color.fromRGBO(210, 210, 211, 1),
                    borderRadius: BorderRadius.circular(10)),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: SvgPicture.asset(
                    "assets/svg/obscure.svg",
                    height: 20,
                  ),
                ),
              )),
          style: style,
          onChanged: (value) => widget.onChanged(value),
          onFieldSubmitted: (_) => widget.onSubmit(),
        ));
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.onLoginSuccess}) : super(key: key);

  final Function() onLoginSuccess;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late double iconOpacity = 1;
  final ScrollController _scrollController = ScrollController();
  String _login = "";
  String _password = "";

  Future<void> _checkPassword() async {

    try {
      await Api.instance.login(_login, _password);
      widget.onLoginSuccess();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Informations de connexion incorrectes", style: TextStyle(fontFamily: "Montserrat"),)));
    }
  }

  void _scrollListener() {
    setState(() {
      double scrollPosition = _scrollController.position.pixels;
      if (scrollPosition < 40) {
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
    return UiContainer(
      backgroundColor: const Color.fromRGBO(247, 247, 248, 1),
        child: LayoutBuilder(builder: (context, constraints) {
          const double minWidth = 350;
          double horizontalMargin = constraints.maxWidth / 3 < minWidth
              ? max(0, constraints.maxWidth / 2 - minWidth / 2)
              : max(0, constraints.maxWidth / 3);
          double iconSize = max(constraints.maxHeight / 6, 80);
          double iconOffset = constraints.maxHeight / 18;
          double cardWidth = constraints.maxWidth - (horizontalMargin * 2);

          return Container(
            margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
            child: Column(children: [
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
                                      LoginInput(
                                        onChanged: (String s) => _login = s,
                                      ),
                                      PasswordInput(
                                          onChanged: (String s) =>
                                              _password = s,
                                          _checkPassword),
                                      UiButton(
                                          onTap: _checkPassword,
                                          width: 250,
                                          height: 50,
                                          color: const Color.fromARGB(
                                              255, 38, 96, 170),
                                          child: const Text("Connexion",
                                              style: TextStyle(
                                                  fontFamily: "Montserrat",
                                                  color: Colors.white,
                                                  fontSize: 18)))
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

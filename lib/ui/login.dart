import 'dart:math';

import 'package:cyrel/api/api.dart';
import 'package:cyrel/constants.dart';
import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.onLoginSuccess}) : super(key: key);

  final Function() onLoginSuccess;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late double iconOpacity = 1;
  final ScrollController _scrollController = ScrollController();
  bool loading = false;

  Future<void> _checkPassword() async {
    setState(() {
      loading = true;
    });
    try {
      await Api.instance.login(context);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
        "Informations de connexion incorrectes",
        style: Styles.f_13nt,
      )));
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
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          _scrollController.animateTo(
              _scrollController.position.pixels + event.scrollDelta.dy,
              duration: const Duration(microseconds: 100),
              curve: Curves.ease);
        }
      },
      child: UiContainer(
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
                        padding: const EdgeInsets.symmetric(vertical: 10),
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
                                                  iconSize - iconOffset + 10))),
                                      Text("Bienvenue sur Cyrel",
                                          overflow: TextOverflow.ellipsis,
                                          style: Styles().f_24),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 15),
                                        child: RichText(
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          text: TextSpan(children: [
                                            TextSpan(
                                                text:
                                                    "Connectez-vous à l'aide de votre compte ",
                                                style: Styles().f_13),
                                            TextSpan(
                                                text: "Corpauration",
                                                mouseCursor:
                                                    SystemMouseCursors.click,
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () async {
                                                        Uri url = accountUrl;
                                                        if (await canLaunchUrl(
                                                            url)) {
                                                          await launchUrl(
                                                            url,
                                                          );
                                                        }
                                                      },
                                                style: Styles()
                                                    .f_13
                                                    .apply(color: Colors.blue)
                                                    .apply(
                                                        decoration:
                                                            TextDecoration
                                                                .underline)),
                                            TextSpan(
                                                text: " :",
                                                style: Styles().f_13),
                                          ]),
                                        ),
                                      ),
                                      UiButton(
                                          onTap: _checkPassword,
                                          width: cardWidth,
                                          height: 50,
                                          color: const Color.fromARGB(
                                              255, 38, 96, 170),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Visibility(
                                                visible: loading,
                                                child: const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            255, 38, 96, 170),
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: loading ? 10 : 0,
                                              ),
                                              const Text("Connexion",
                                                  style: Styles.f_18nt)
                                            ],
                                          ))
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
      ),
    );
  }
}

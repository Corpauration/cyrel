import 'dart:math';
import 'dart:io' show Platform;
import 'package:cyrel/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterBox extends StatelessWidget {
  const RegisterBox({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double horizontalMargin = max(constraints.maxWidth / 8, 10);
          double androidMargin = Platform.isAndroid
              ? max(0, MediaQuery.of(context).viewPadding.top)
              : 0;

          return Container(
            margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                      constraints: BoxConstraints(minHeight: androidMargin)),
                  child
                ]),
          );
        },
      ),
    );
  }
}

class RegisterWelcome extends StatefulWidget {
  const RegisterWelcome({Key? key, required this.onSubmit}) : super(key: key);

  final Function() onSubmit;

  @override
  State<RegisterWelcome> createState() => _RegisterWelcomeState();
}

class _RegisterWelcomeState extends State<RegisterWelcome> {
  bool showLogo = true;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        late double opacity = 0;

        if (constraints.maxWidth >
            (constraints.maxWidth / 6 +
                500 +
                820 * (constraints.maxHeight / 1200))) {
          opacity = 1;
        } else if (constraints.maxWidth >
            (constraints.maxWidth / 6 +
                460 +
                820 * (constraints.maxHeight / 1200))) {
          opacity = max(
              0,
              1 -
                  1 /
                      (constraints.maxWidth -
                          (constraints.maxWidth / 6 +
                              460 +
                              820 * (constraints.maxHeight / 1200))));
        } else {
          opacity = 0;
        }

        return Stack(children: [
          RegisterBox(
              child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Bienvenue !",
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: 30,
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Vous êtes sur le point de vous inscrire sur Cyrel.",
                  style: TextStyle(fontFamily: "Montserrat", fontSize: 18),
                ),
              ),
              ConstrainedBox(constraints: const BoxConstraints(minHeight: 50)),
              Align(
                alignment: Alignment.centerRight,
                child: UiButton(
                    onTap: () {
                      setState(() {
                        showLogo = false;
                      });
                      widget.onSubmit();
                    },
                    width: 200,
                    height: 50,
                    color: const Color.fromARGB(255, 38, 96, 170),
                    child: const Text("Suivant",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            color: Colors.white,
                            fontSize: 18))),
              )
            ],
          )),
          IgnorePointer(
            child: Opacity(
                opacity: showLogo ? opacity : 0,
                child: Align(
                    alignment: Alignment.centerRight,
                    child: SvgPicture.asset("assets/svg/registerbubbles.svg",
                        height: constraints.maxHeight))),
          )
        ]);
      },
    );
  }
}

class RegisterMainGroup extends StatefulWidget {
  const RegisterMainGroup({Key? key, required this.onSubmit}) : super(key: key);

  final Function(String) onSubmit;

  @override
  State<RegisterMainGroup> createState() => _RegisterMainGroupState();
}

class _RegisterMainGroupState extends State<RegisterMainGroup> {
  int _index = -1;
  String value = " ";
  List<String> list = ["michel", "patrick"];
  Color _buttonColor = const Color.fromRGBO(86, 134, 218, 1);

  @override
  Widget build(BuildContext context) {
    return RegisterBox(
      child: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text("Selectionnez votre groupe :",
              style: TextStyle(fontFamily: "Montserrat", fontSize: 18)),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (context, index) {
              return BoxButton(
                  onTap: (() {
                    setState(() {
                      _index = index;
                      _buttonColor = const Color.fromARGB(255, 38, 96, 170);
                    });
                  }),
                  child: Container(
                    decoration: BoxDecoration(
                        color: index == _index
                            ? const Color.fromARGB(255, 38, 96, 170)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    child: Text(
                      list[index],
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: 18,
                        color: index == _index ? Colors.white : Colors.black,
                      ),
                    ),
                  ));
            },
          ),
        ),
        ConstrainedBox(constraints: const BoxConstraints(minHeight: 50)),
        Align(
          alignment: Alignment.centerRight,
          child: UiButton(
              onTap: () {
                widget.onSubmit(value);
              },
              width: 200,
              height: 50,
              color: _buttonColor,
              child: const Text("Suivant",
                  style: TextStyle(
                      fontFamily: "Montserrat",
                      color: Colors.white,
                      fontSize: 18))),
        ),
      ]),
    );
  }
}

class UserRegister extends StatefulWidget {
  const UserRegister({Key? key}) : super(key: key);

  @override
  State<UserRegister> createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    PageController pageControler = PageController(initialPage: _index);

    void _next() {
      _index++;
      pageControler.animateToPage(_index,
          duration: const Duration(milliseconds: 400), curve: Curves.ease);
    }

    return Scaffold(
        appBar: null,
        extendBodyBehindAppBar: true,
        body: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: pageControler,
            children: [
              RegisterWelcome(
                onSubmit: _next,
              ),
              RegisterMainGroup(
                onSubmit: (_) {
                  _next();
                },
              ),
              RegisterWelcome(
                onSubmit: _next,
              ),
              RegisterWelcome(
                onSubmit: _next,
              ),
            ]));
  }
}

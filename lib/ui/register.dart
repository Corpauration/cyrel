import 'dart:async';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/group.dart';
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

class RegisterButton extends StatelessWidget {
  const RegisterButton(
      {Key? key,
      required this.onTap,
      this.active = true,
      this.content = "Suivant"})
      : super(key: key);

  final Function() onTap;
  final bool active;
  final String content;

  @override
  Widget build(BuildContext context) {
    return UiButton(
        onTap: active ? onTap : () {},
        width: 200,
        height: 50,
        color: active
            ? const Color.fromARGB(255, 38, 96, 170)
            : const Color.fromRGBO(86, 134, 218, 1),
        child: Text(content,
            style: const TextStyle(
                fontFamily: "Montserrat", color: Colors.white, fontSize: 18)));
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
                child: RegisterButton(
                  onTap: () {
                    setState(() {
                      showLogo = false;
                    });
                    widget.onSubmit();
                  },
                ),
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

class RegisterGroup extends StatefulWidget {
  const RegisterGroup(
      {Key? key,
      required this.onSubmit,
      required this.future,
      required this.header})
      : super(key: key);

  final Function(int) onSubmit;
  final Future<List<Group>> future;
  final String header;

  @override
  State<RegisterGroup> createState() => _RegisterGroupState();
}

class _RegisterGroupState extends State<RegisterGroup> {
  int _index = -1;
  int _value = -1;
  bool _buttonActive = false;

  @override
  Widget build(BuildContext context) {
    return RegisterBox(
      child: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(widget.header,
              style: const TextStyle(fontFamily: "Montserrat", fontSize: 18)),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FutureBuilder<List<Group>>(
            future: widget.future,
            builder : (BuildContext context, AsyncSnapshot<List<Group>> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  return BoxButton(
                      onTap: (() {
                        setState(() {
                          _index = index;
                          _value = snapshot.data![index].id;
                          _buttonActive = true;
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
                          snapshot.data![index].name,
                          style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 18,
                            color: index == _index ? Colors.white : Colors.black,
                          ),
                        ),
                      ));
                },
              );
              } else {
                return const CircularProgressIndicator();
              }
            }
          ),
        ),
        ConstrainedBox(constraints: const BoxConstraints(minHeight: 50)),
        Align(
          alignment: Alignment.centerRight,
          child: RegisterButton(
            onTap: () {
              widget.onSubmit(_value);
            },
            active: _buttonActive,
          ),
        ),
      ]),
    );
  }
}

class RegisterThanks extends StatelessWidget {
  const RegisterThanks({Key? key, required this.onSubmit}) : super(key: key);

  final Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return RegisterBox(
        child: Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Felicitation !",
            style: TextStyle(
              fontFamily: "Montserrat",
              fontSize: 30,
            ),
          ),
        ),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Vous êtes maintenant inscrit sur Cyrel.",
            style: TextStyle(fontFamily: "Montserrat", fontSize: 18),
          ),
        ),
        ConstrainedBox(constraints: const BoxConstraints(minHeight: 50)),
        Align(
          alignment: Alignment.centerRight,
          child: RegisterButton(
            content: "Commencer",
            onTap: onSubmit,
          ),
        )
      ],
    ));
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

    Completer<List<Group>> subgroups = Completer();

    late int _groupId;

    return Scaffold(
        appBar: null,
        extendBodyBehindAppBar: true,
        body: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: pageControler,
            children: [
              RegisterWelcome(
                onSubmit: () async {
                  _next();
                },
              ),
              RegisterGroup(
                header: "Selectionner votre groupe :",
                future: () async {
                  return await Api.instance.groups.getParents();
                } (),
                onSubmit: (id) async {
                  _next();
                  _groupId = id;
                  subgroups.complete(await Api.instance.group.getChildren(id));
                },
              ),
              RegisterGroup(
                header: "Selectionner votre sous groupe :",
                future: subgroups.future,
                onSubmit: (id) async {
                  // register here
                  print(await Api.instance.group.join(_groupId));
                  print(await Api.instance.group.join(id));
                  _next();
                },
              ),
              RegisterThanks(
                onSubmit: () {},
              ),
            ]));
  }
}
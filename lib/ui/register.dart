import 'dart:async';
import 'dart:math';

import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/errors.dart';
import 'package:cyrel/api/group_entity.dart';
import 'package:cyrel/api/preference_entity.dart';
import 'package:cyrel/api/user_entity.dart';
import 'package:cyrel/main.dart';
import 'package:cyrel/ui/theme.dart';
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

          return Container(
            margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center, children: [child]),
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
      this.content = "Suivant",
      this.loading = false})
      : super(key: key);

  final Function() onTap;
  final bool active;
  final String content;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return UiButton(
        onTap: active ? onTap : () {},
        width: 200,
        height: 50,
        color: active
            ? const Color.fromARGB(255, 38, 96, 170)
            : const Color.fromRGBO(86, 134, 218, 1),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Visibility(
            visible: loading,
            child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                backgroundColor: Color.fromARGB(255, 38, 96, 170),
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
          SizedBox(
            width: loading ? 10 : 0,
          ),
          Text(content, style: Styles.f_13nt)
        ]));
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
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Bienvenue !",
                  style: Styles().f_30,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Vous êtes sur le point de vous inscrire sur Cyrel.",
                  style: Styles().f_18,
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

class RegisterUserType extends StatefulWidget {
  const RegisterUserType(
      {Key? key, required this.onSubmit, required this.header})
      : super(key: key);

  final Function(UserType) onSubmit;
  final String header;

  @override
  State<RegisterUserType> createState() => _RegisterUserTypeState();
}

class _RegisterUserTypeState extends State<RegisterUserType> {
  int _index = -1;
  UserType _value = UserType.student;
  bool _buttonActive = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return RegisterBox(
      child: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(widget.header, style: Styles().f_18),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: UserType.values.length,
            itemBuilder: (context, index) {
              return BoxButton(
                  onTap: (() {
                    if (UserType.values[index] == UserType.professor) {
                      return;
                    }
                    setState(() {
                      _index = index;
                      _value = UserType.values[index];
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
                      (UserType.values[index] == UserType.professor)
                          ? "${UserType.values[index].value} - Indisponible"
                          : UserType.values[index].value,
                      style: Styles().f_18.apply(
                            color:
                                index == _index ? Colors.white : Colors.black,
                          ),
                    ),
                  ));
            },
          ),
        ),
        ConstrainedBox(constraints: const BoxConstraints(minHeight: 50)),
        Align(
          alignment: Alignment.centerRight,
          child: RegisterButton(
            onTap: () {
              setState(() {
                _loading = true;
              });
              widget.onSubmit(_value);
            },
            active: _buttonActive,
            loading: _loading,
          ),
        ),
      ]),
    );
  }
}

class RegisterStudentInformation extends StatefulWidget {
  const RegisterStudentInformation(
      {Key? key, required this.onSubmit, required this.header})
      : super(key: key);

  final Function(int) onSubmit;
  final String header;

  @override
  State<RegisterStudentInformation> createState() =>
      _RegisterStudentInformationState();
}

class _RegisterStudentInformationState
    extends State<RegisterStudentInformation> {
  int? _value;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return RegisterBox(
      child: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(widget.header, style: Styles().f_18),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: NumberInput(
            onChanged: (n) {
              if (n != null && n >= 10000000 && n <= 999999999) {
                setState(() {
                  _value = n;
                });
              } else {
                setState(() {
                  _value = null;
                });
              }
            },
            icon: SvgPicture.asset(
              "assets/svg/user.svg",
              height: 25,
            ),
          ),
        ),
        ConstrainedBox(constraints: const BoxConstraints(minHeight: 50)),
        Align(
          alignment: Alignment.centerRight,
          child: RegisterButton(
            onTap: () {
              setState(() {
                _loading = true;
              });
              widget.onSubmit(_value!);
            },
            active: _value != null,
            loading: _loading,
          ),
        ),
      ]),
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
  final Future<List<GroupEntity>> future;
  final String header;

  @override
  State<RegisterGroup> createState() => _RegisterGroupState();
}

class _RegisterGroupState extends State<RegisterGroup> {
  int _index = -1;
  int _value = -1;
  bool _buttonActive = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return RegisterBox(
      child: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(widget.header, style: Styles().f_18),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FutureBuilder<List<GroupEntity>>(
              future: widget.future,
              builder: (BuildContext context,
                  AsyncSnapshot<List<GroupEntity>> snapshot) {
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
                              style: Styles().f_18.apply(
                                color: index == _index
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ));
                    },
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              }),
        ),
        ConstrainedBox(constraints: const BoxConstraints(minHeight: 50)),
        Align(
          alignment: Alignment.centerRight,
          child: RegisterButton(
            onTap: () {
              setState(() {
                _loading = true;
              });
              widget.onSubmit(_value);
            },
            active: _buttonActive,
            loading: _loading,
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
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Félicitations !",
            style: Styles().f_30,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Vous êtes maintenant inscrit sur Cyrel.",
            style: Styles().f_18,
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

class RegisterError extends StatelessWidget {
  const RegisterError({Key? key, required this.onSubmit, required this.reasons})
      : super(key: key);

  final Function() onSubmit;
  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    return RegisterBox(
        child: Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Aïe...",
            style: Styles().f_30,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Votre inscription sur Cyrel a échoué pour ${reasons.length == 1 ? "la raison suivante" : "les raisons suivantes"} :",
            style: Styles().f_18,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: reasons.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Text(
                  reasons[index],
                  style: Styles().f_18.apply(
                        color: Colors.black,
                      ),
                ),
              );
            },
          ),
        ),
        ConstrainedBox(constraints: const BoxConstraints(minHeight: 50)),
        Align(
          alignment: Alignment.centerRight,
          child: RegisterButton(
            content: "Recommencer",
            onTap: onSubmit,
          ),
        )
      ],
    ));
  }
}

class UserRegister extends StatefulWidget {
  const UserRegister({Key? key, required this.onFinish}) : super(key: key);

  final Function() onFinish;

  @override
  State<UserRegister> createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister> {
  int _index = 0;
  UserType _userType = UserType.student;
  int? _studentId;
  late int _groupId;
  Completer<List<GroupEntity>> subgroups = Completer();
  bool _success = false;
  List<String> _reasons = [];

  @override
  Widget build(BuildContext context) {
    PageController pageControler = PageController(initialPage: _index);

    void _next() {
      _index++;
      pageControler.animateToPage(_index,
          duration: const Duration(milliseconds: 400), curve: Curves.ease);
    }

    return UiContainer(
      backgroundColor: Colors.white,
      child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageControler,
          children: [
            RegisterWelcome(
              onSubmit: () {
                _next();
              },
            ),
            RegisterUserType(
                onSubmit: (type) {
                  setState(() {
                    _userType = type;
                  });
                  _next();
                },
                header: "Sélectionnez votre régime :"),
            _userType == UserType.student
                ? RegisterStudentInformation(
                    onSubmit: (sid) {
                      _studentId = sid;
                      _next();
                    },
                    header: "Entrez votre numéro étudiant :")
                : RegisterThanks(onSubmit: () {}),
            RegisterGroup(
              header: "Sélectionnez votre groupe :",
              future: () async {
                return await Api.instance.groups.getParents();
              }(),
              onSubmit: (id) async {
                _groupId = id;
                subgroups.complete(await Api.instance.group.getChildren(id));
                _next();
              },
            ),
            RegisterGroup(
              header: "Sélectionnez votre sous groupe :",
              future: subgroups.future,
              onSubmit: (id) async {
                try {
                  await Api.instance.user.register(_userType, _studentId, null);
                  await Api.instance.group.join(_groupId);
                  await Api.instance.group.join(id);
                  setState(() {
                    _success = true;
                  });
                } on UnknownStudentId {
                  setState(() {
                    _success = false;
                    _reasons.add("Le numéro étudiant entré n'est pas valide");
                  });
                } catch (e) {
                  _success = false;
                  _reasons.add("Erreur inconnue :/");
                }
                _next();
              },
            ),
            _success
                ? RegisterThanks(
                    onSubmit: () async {
                      // widget.onFinish();
                      await Api.instance.clearApiCache();
                      HotRestartController.performHotRestart(context);
                    },
                  )
                : RegisterError(
                    onSubmit: () {
                      HotRestartController.performHotRestart(context);
                    },
                    reasons: _reasons),
          ]),
    );
  }
}

class IsRegistered extends StatefulWidget {
  const IsRegistered({Key? key, required this.onResult}) : super(key: key);

  final Function(bool) onResult;

  @override
  State<IsRegistered> createState() => _IsRegisteredState();
}

class _IsRegisteredState extends State<IsRegistered> {
  _isRegistered() async {
    bool value = await Api.instance.user.isRegistered();
    if (value) {
      Api.instance.addData("myGroups", await Api.instance.groups.getMyGroups());
      Api.instance.addData("homework", false);
      for (var group in Api.instance.getData<List<GroupEntity>>("myGroups")) {
        if (group.id == Groups.homeworkResp.value)
          Api.instance.addData("homework", true);
      }
      Api.instance.addData("preferences", await Api.instance.preference.get());
      ThemesHandler.instance.cursor =
          Api.instance.getData<PreferenceEntity>("preferences").theme.id;
    }
    widget.onResult(value);
  }

  @override
  Widget build(BuildContext context) {
    _isRegistered();
    return const SplashScreen();
  }
}

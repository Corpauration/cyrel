import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/base_entity.dart';
import 'package:cyrel/api/errors.dart';
import 'package:cyrel/api/group_entity.dart';
import 'package:cyrel/api/preference_entity.dart';
import 'package:cyrel/api/preregistration_biscuit_entity.dart';
import 'package:cyrel/api/service.dart';
import 'package:cyrel/api/user_entity.dart';
import 'package:cyrel/cache/cache.dart';
import 'package:cyrel/cache/fs/fs.dart';
import 'package:cyrel/cache/fs/fs_io.dart';
import 'package:cyrel/main.dart';
import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import "package:universal_html/html.dart" show window;

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
          ),
          Positioned(
            top: 20,
            left: 20,
            child: SizedBox(
                height: 25,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: BoxButton(
                      onTap: () async {
                        await Api.instance.logout();
                        ThemesHandler.instance.cursor = 0;
                        HotRestartController.performHotRestart(context);
                      },
                      child: SizedBox(
                          width: 30,
                          child: Center(
                            child: SvgPicture.asset("assets/svg/logout.svg",
                                height: 15),
                          ))),
                )),
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
                          ? UserType.values[index].value
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
  const RegisterThanks(
      {Key? key, required this.onSubmit, required this.userType})
      : super(key: key);

  final Function() onSubmit;
  final UserType userType;

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
        const SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            userType == UserType.student
                ? "Vous êtes maintenant inscrit sur Cyrel."
                : userType == UserType.professor
                    ? "Vous êtes maintenant inscrit sur Cyrel. Par mesure de sécurité, une vérification manuelle va être faite pour nous assurer que vous êtes bien un enseignant. Nous vous remercions de patientez."
                    : "",
            style: Styles().f_18,
          ),
        ),
        ConstrainedBox(constraints: const BoxConstraints(minHeight: 50)),
        Align(
          alignment: Alignment.centerRight,
          child: RegisterButton(
            content: userType == UserType.student
                ? "Commencer"
                : userType == UserType.professor
                    ? "D'accord"
                    : "",
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
  late int _promoId;
  late int _groupId;
  Completer<List<GroupEntity>> subgroups = Completer();
  Completer<List<GroupEntity>> engroups = Completer();
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

    register(List<int> ids) async {
      try {
        await Api.instance.user.register(_userType, _studentId, null);
        for (var id in ids) {
          await Api.instance.group.join(id);
        }
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
                onSubmit: (type) async {
                  if (type == UserType.professor) {
                    await Api.instance.user.register(type, null, null);
                  }
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
                : RegisterThanks(
                    onSubmit: () async {
                      await Api.instance.clearApiCache();
                      HotRestartController.performHotRestart(context);
                    },
                    userType: _userType,
                  ),
            RegisterGroup(
              header: "Sélectionnez votre groupe :",
              future: () async {
                return (await Api.instance.groups.getParents())
                    .where((element) => element.tags["type"] == "promo")
                    .toList();
              }(),
              onSubmit: (id) async {
                _promoId = id;
                subgroups.complete((await Api.instance.group.getChildren(id))
                    .where((element) => element.tags["type"] == "group")
                    .toList());
                _next();
              },
            ),
            RegisterGroup(
              header: "Sélectionnez votre groupe :",
              future: subgroups.future,
              onSubmit: (id) async {
                _groupId = id;
                engroups.complete(
                    (await Api.instance.group.getChildren(_promoId))
                        .where((element) => element.tags["type"] == "english")
                        .toList());
                _next();
                engroups.future.then((value) async {
                  if (value.isEmpty) {
                    await register([_promoId, _groupId]);
                  }
                });
              },
            ),
            RegisterGroup(
              header: "Sélectionnez votre sous groupe d'anglais :",
              future: engroups.future,
              onSubmit: (id) async {
                await register([_promoId, _groupId, id]);
              },
            ),
            _success
                ? RegisterThanks(
                    onSubmit: () async {
                      // widget.onFinish();
                      await Api.instance.clearApiCache();
                      HotRestartController.performHotRestart(context);
                    },
                    userType: _userType,
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

class UserPreregister extends StatefulWidget {
  const UserPreregister(
      {Key? key, required this.biscuit, required this.onFinish})
      : super(key: key);

  final String biscuit;
  final Function() onFinish;

  @override
  State<UserPreregister> createState() => _UserPreregisterState();
}

class _UserPreregisterState extends State<UserPreregister> {
  int _index = 0;
  PreregistrationBiscuit? _preregistrationBiscuit;
  int? _studentId;
  Completer<List<GroupEntity>> engroups = Completer();
  bool _success = false;
  bool _continue = false;
  List<String> _reasons = [];

  @override
  Widget build(BuildContext context) {
    PageController pageControler = PageController(initialPage: _index);

    void _next() {
      _index++;
      pageControler.animateToPage(_index,
          duration: const Duration(milliseconds: 400), curve: Curves.ease);
    }

    preregister(List<int> ids) async {
      try {
        await Api.instance.user.preregister(widget.biscuit, _studentId!, null);
        for (var id in ids) {
          await Api.instance.group.join(id);
        }
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
    }

    return UiContainer(
      backgroundColor: Colors.white,
      child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageControler,
          children: [
            RegisterWelcome(
              onSubmit: () async {
                try {
                  _preregistrationBiscuit =
                      await Api.instance.user.checkPreregister(widget.biscuit);
                  setState(() {
                    _continue = true;
                  });
                } catch (e) {
                  _reasons.add("Lien de pré-inscription invalide");
                }
                _next();
              },
            ),
            _continue
                ? RegisterStudentInformation(
                    onSubmit: (sid) async {
                      _studentId = sid;
                      engroups.complete((await Api.instance.group
                              .getChildren(_preregistrationBiscuit!.promo))
                          .where((element) => element.tags["type"] == "english")
                          .toList());
                      _next();
                      engroups.future.then((value) async {
                        if (value.isEmpty) {
                          await preregister([]);
                        }
                      });
                    },
                    header: "Entrez votre numéro étudiant :")
                : RegisterError(
                    onSubmit: () async {
                      await Api.instance.clearApiCache();
                      HotRestartController.performHotRestart(context);
                    },
                    reasons: _reasons,
                  ),
            RegisterGroup(
              header: "Sélectionnez votre groupe d'anglais :",
              future: engroups.future,
              onSubmit: (id) async {
                await preregister([id]);
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
                    userType: UserType.student,
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

  final Function(bool, bool, String?) onResult;

  @override
  State<IsRegistered> createState() => _IsRegisteredState();
}

class _IsRegisteredState extends State<IsRegistered> {
  final CacheManager _serviceCache = CacheManager("service");
  bool _init = false;
  static const _channel = MethodChannel('fr.corpauration.cyrel/main_activity');

  _isRegistered() async {
    bool value = await Api.instance.user.isRegistered();
    if (value) {
      try {
        Api.instance.addData("me", await Api.instance.user.getMe());
      } catch (e) {
        if (e.toString() == "Professor is not authorized") {
          widget.onResult(value, true, null);
          return;
        }
      }
      if (Api.instance.getData<UserEntity>("me").type == UserType.student &&
          !kIsWeb &&
          Platform.isAndroid) {
        if (!_init) {
          await _serviceCache.mount(IOFileSystem(), FileSystemPriority.both);
          _init = true;
        }
        bool se;
        try {
          var b = await _serviceCache.get<BoolEntity>("enabled");
          se = !(b != null && !b.toBool());
        } catch (e) {
          se = true;
        }
        if (se) {
          try {
            await _channel.invokeMethod('disableBatteryOptimizations');
          } catch (e) {}
          await Service.launchCourseAlertTask();
        }
      }
      Api.instance.addData("myGroups", await Api.instance.groups.getMyGroups());
      Api.instance.addData("homework", false);
      for (var group in Api.instance.getData<List<GroupEntity>>("myGroups")) {
        if (group.id == Groups.homeworkResp.value)
          Api.instance.addData("homework", true);
      }
      Api.instance.addData("preferences", await Api.instance.preference.get());
      ThemesHandler.instance.cursor =
          Api.instance.getData<PreferenceEntity>("preferences").theme.id;
    } else {
      if (kIsWeb && window.localStorage.containsKey("preregistration")) {
        var preregistration = window.localStorage.remove("preregistration");
        widget.onResult(value, false, preregistration);
        return;
      }
    }
    widget.onResult(value, false, null);
  }

  @override
  Widget build(BuildContext context) {
    _isRegistered();
    return const SplashScreen();
  }
}

class ProfessorNotAuthorizedPage extends StatelessWidget {
  const ProfessorNotAuthorizedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UiContainer(
        backgroundColor: ThemesHandler.instance.theme.background,
        child: Center(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: UiScrollBar(
            scrollController: null,
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Vous n'êtes pas encore autorisé.",
                  style: Styles().f_18,
                  softWrap: true,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  "Merci de patientez le temps que la vérification manuelle soit faite.",
                  style: Styles().f_15,
                  softWrap: true,
                )
              ],
            ),
          ),
        )));
  }
}

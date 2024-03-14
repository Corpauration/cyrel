import 'dart:math';

import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/base_entity.dart';
import 'package:cyrel/api/service.dart';
import 'package:cyrel/api/user_entity.dart';
import 'package:cyrel/cache/cache.dart';
import 'package:cyrel/cache/fs/fs.dart';
import 'package:cyrel/cache/fs/fs_io.dart';
import 'package:cyrel/cache/fs/fs_web.dart';
import 'package:cyrel/ui/home.dart';
import 'package:cyrel/ui/homework.dart';
import 'package:cyrel/ui/login.dart';
import 'package:cyrel/ui/navigation.dart';
import 'package:cyrel/ui/offline.dart';
import 'package:cyrel/ui/register.dart';
import 'package:cyrel/ui/rooms.dart';
import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/ui/timetable.dart';
import 'package:cyrel/ui/update.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:cyrel/utils/version.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:home_widget/home_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeService();

  Api.instance.startLoop();
  await Version.instance.init;
  runApp(HotRestartController(child: const MyApp()));
}

class HotRestartController extends StatefulWidget {
  final Widget child;

  HotRestartController({required this.child});

  static performHotRestart(BuildContext context) {
    final _HotRestartControllerState state =
        context.findAncestorStateOfType<_HotRestartControllerState>()!;
    state.performHotRestart();
  }

  @override
  _HotRestartControllerState createState() => _HotRestartControllerState();
}

class _HotRestartControllerState extends State<HotRestartController> {
  Key key = UniqueKey();

  void performHotRestart() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      child: widget.child,
    );
  }
}

class EolWidget extends StatefulWidget {
  EolWidget({super.key, required this.onSubmit, required this.screenOfDeath});

  final Function() onSubmit;
  final Function() screenOfDeath;

  @override
  State<EolWidget> createState() => _EolWidgetState();
}

class _EolWidgetState extends State<EolWidget> {
  int count = 0;
  double show = 0;

  @override
  Widget build(BuildContext context) {
    return UiContainer(
      backgroundColor: Colors.white,
      child: LayoutBuilder(
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

          return Stack(
            children: [
              RegisterBox(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onDoubleTap: () {
                          setState(() {
                            show = 1;
                          });
                        },
                        child: Text(
                          "Message à caractère informatif",
                          style: Styles().f_30,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 2 / 3 * constraints.maxHeight,
                          child: SingleChildScrollView(
                            child: BoxButton(
                              onTap: () {
                                count++;
                                if (count >= 69) {
                                  widget.screenOfDeath();
                                }
                              },
                              child: Text(
                                """Chers utilisateurs / utilisatrices,

Nous sommes au regret de vous informer qu'à ce jour la fiabilité des données fournies par Cyrel est compromise.
En effet, il n'est à présent plus possible de consulter l'emploi du temps d'autres élèves dans les outils mis à disposition par l'école.
Les emplois du temps de Cyrel se basant principalement sur cette fonctionnalité, nous ne sommes plus en capacité de vous fournir des emplois du temps à jour.
Cette fonctionnalité a été arrêté du jour au lendemain sans qu'on n'en soit prévenu.
Nous avons essayé de contacter le service informatique à ce sujet, les informant des problèmes d'accessibilités et d'ergonomies sur Celcat.
Nos mails sont restés sans réponse.

Nous sommes désolés du désagrément causé, et sommes attristés par la fin brutale de quatre ans d'efforts sur le sujet.
Le service sera néanmoins maintenu jusqu'à la fin de l'année.

Cordialement, la Corpauration.""",
                                style: Styles().f_18,
                              ),
                            ),
                          ),
                        )),
                    ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 50)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: RegisterButton(
                        content: "F",
                        onTap: widget.onSubmit,
                      ),
                    )
                  ],
                ),
              ),
              IgnorePointer(
                child: Opacity(
                    opacity: opacity * (1 - show),
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: SvgPicture.asset(
                            "assets/svg/registerbubbles.svg",
                            height: constraints.maxHeight))),
              ),
              IgnorePointer(
                child: Opacity(
                    opacity: opacity * show,
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: Image.asset("assets/svg/NotLikeThis.png",
                            height: constraints.maxHeight))),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late List<Widget> page;
  bool? online;
  bool? connected;
  bool? registered;
  bool professorNotAuthorized = false;
  String? registrationKey;
  late TimetableState timetableState;
  bool needUpdate = false;
  final Container background = Container(
    color: Colors.red,
  );
  final CacheManager _cache = CacheManager("eol_cache");
  bool _cacheInit = false;
  bool needToShowEOL = false;

  Widget getPage() {
    if (needUpdate) {
      return const Updater();
    }
    if (professorNotAuthorized) {
      return const ProfessorNotAuthorizedPage();
    } else if (connected == null && online == null) {
      return CheckBackendStatus(
        onResult: (c, logged, needUpdate) {
          setState(() {
            online = c;
            connected = logged;
            this.needUpdate = needUpdate;
          });
          setPage();
        },
      );
    } else if (online == false) {
      return OfflinePage(
          onQuit: () {
            setState(() {
              online = true;
            });
            setPage();
          },
          offlineMode: connected!);
    } else if (!connected!) {
      return LoginPage(
        onLoginSuccess: () {
          setState(() {
            connected = true;
          });
          setPage();
        },
      );
    } else if (connected! && registered == null) {
      return IsRegistered(
        onResult: (reg, pa, regkey) {
          setState(() {
            registered = reg;
            professorNotAuthorized = pa;
            registrationKey = regkey;
          });
          setPage();
        },
      );
    } else if (connected! && !registered!) {
      if (registrationKey == null) {
        return UserRegister(
          onFinish: () {
            setState(() {
              registered = true;
            });
            setPage();
          },
        );
      } else {
        return UserPreregister(
          biscuit: registrationKey!,
          onFinish: () {
            setState(() {
              registered = true;
            });
            setPage();
          },
        );
      }
    } else /* if (connected && registered) */ {
      timetableState = TimetableState();

      if (Api.instance.getData<UserEntity>("me").type == UserType.student) {
        return NavHandler(pages: [
          UiPage(
              icon: SvgPicture.asset("assets/svg/home.svg"),
              page: const Home()),
          UiPage(
              icon: SvgPicture.asset("assets/svg/timetable.svg"),
              page: StudentTimeTable(
                timetableState: timetableState,
              )),
          UiPage(
              icon: SvgPicture.asset("assets/svg/homework.svg"),
              page: const HomeWork()),
          UiPage(
              icon: SvgPicture.asset("assets/svg/position.svg"),
              page: const Room())
        ]);
      } else /* if (Api.instance.getData<UserEntity>("me").type == UserType.professor) */ {
        return NavHandler(pages: [
          UiPage(
              icon: SvgPicture.asset("assets/svg/home.svg"),
              page: const TeacherHome()),
          UiPage(
              icon: SvgPicture.asset("assets/svg/timetable.svg"),
              page: TeacherTimeTable(timetableState: timetableState)),
          UiPage(
              icon: SvgPicture.asset("assets/svg/homework.svg"),
              page: const HomeworkTeacher()),
          UiPage(
              icon: SvgPicture.asset("assets/svg/position.svg"),
              page: const Room())
        ]);
      }
    }
  }

  initCache() async {
    if (!_cacheInit) {
      if (kIsWeb) {
        await _cache.mount(WebFileSystem(), FileSystemPriority.both);
      } else {
        await _cache.mount(IOFileSystem(), FileSystemPriority.both);
      }

      _cacheInit = true;
    }

    try {
      var message = await _cache.get<BoolEntity>("message");
      if (message == null || !message.toBool()) {
        needToShowEOL = true;
      }
    } catch (e) {
      needToShowEOL = true;
    }

    if (needToShowEOL) {
      setPage();
    }
  }

  void setPage() {
    setState(() {
      page = [background, getPage()];
      if (needToShowEOL) {
        page.add(EolWidget(
          onSubmit: () async {
            setState(() {
              page.removeLast();
            });
            await _cache.save<BoolEntity>("message", BoolEntity.fromBool(true),
                expireAt:
                    DateTime.now().add(const Duration(days: 420, hours: 69)));
          },
          screenOfDeath: () {
            setState(() {
              page.removeLast();
              page.removeLast();
            });
          },
        ));
      }
    });
  }

  @override
  void initState() {
    HomeWidget.updateWidget(
        name: "ScheduleWidgetProvider",
        androidName: "ScheduleWidgetProvider",
        qualifiedAndroidName: "fr.corpauration.cyrel.ScheduleWidgetProvider");
    setPage();
    initCache();
    Api.instance.onConnectionChanged = (ol) {
      if (online == false && ol) {
        // not totologie
        setState(() {
          online = true;
        });
        setPage();
      } else if (online == true && !ol) {
        // not totologie
        setState(() {
          online = false;
        });
        setPage();
      }
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Api.instance.onAuthExpired = () {
      HotRestartController.performHotRestart(context);
    };
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cyrel',
      home: Stack(
        children: page,
      ),
    );
  }
}

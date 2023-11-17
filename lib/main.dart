import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/service.dart';
import 'package:cyrel/api/user_entity.dart';
import 'package:cyrel/ui/home.dart';
import 'package:cyrel/ui/homework.dart';
import 'package:cyrel/ui/login.dart';
import 'package:cyrel/ui/navigation.dart';
import 'package:cyrel/ui/offline.dart';
import 'package:cyrel/ui/register.dart';
import 'package:cyrel/ui/rooms.dart';
import 'package:cyrel/ui/timetable.dart';
import 'package:cyrel/ui/update.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeService();

  Api.instance.startLoop();
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

  void setPage() {
    setState(() {
      page = [background, getPage()];
    });
  }

  @override
  void initState() {
    setPage();
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cyrel',
      home: Stack(
        children: page,
      ),
    );
  }
}

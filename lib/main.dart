import 'package:cyrel/api/api.dart';
import 'package:cyrel/ui/home.dart';
import 'package:cyrel/ui/homework.dart';
import 'package:cyrel/ui/login.dart';
import 'package:cyrel/ui/navigation.dart';
import 'package:cyrel/ui/offline.dart';
import 'package:cyrel/ui/register.dart';
import 'package:cyrel/ui/timetable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  Api.instance.startLoop();
  runApp(HotRestartController(child: const MyApp()));
}

class HotRestartController extends StatefulWidget {
  final Widget child;

  HotRestartController({required this.child});

  static performHotRestart(BuildContext context) {
    final _HotRestartControllerState state = context.findAncestorStateOfType<_HotRestartControllerState>()!;
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
  final Container background = Container(
    color: Colors.red,
  );

  Widget getPage() {
    if (connected == null && online == null) {
      return CheckBackendStatus(
        onResult: (c, logged) {
          setState(() {
            online = c;
            connected = logged;
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
        onResult: (reg) {
          setState(() {
            registered = reg;
          });
          setPage();
        },
      );
    } else if (connected! && !registered!) {
      return UserRegister(
        onFinish: () {
          setState(() {
            registered = true;
          });
          setPage();
        },
      );
    } else /* if (connected && registered) */ {
      return NavHandler(pages: [
        UiPage(
            icon: SvgPicture.asset("assets/svg/home.svg"), page: const Home()),
        UiPage(
            icon: SvgPicture.asset("assets/svg/timetable.svg"),
            page: const TimeTable()),
        UiPage(
            icon: SvgPicture.asset("assets/svg/homework.svg"),
            page: const HomeWork())
      ]);
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
          online = true;
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

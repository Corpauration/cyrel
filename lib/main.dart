import 'package:cyrel/ui/home.dart';
import 'package:cyrel/ui/homework.dart';
import 'package:cyrel/ui/login.dart';
import 'package:cyrel/ui/navigation.dart';
import 'package:cyrel/ui/register.dart';
import 'package:cyrel/ui/timetable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late List<Page<dynamic>> page;
  bool connected = false;
  bool? registered;

  static MaterialPage background = MaterialPage(
      child: Container(
    color: Colors.white,
  ));

  Page<dynamic> getPage() {
    if (!connected) {
      return MaterialPage(child: LoginPage(
        onLoginSuccess: () {
          setState(() {
            connected = true;
          });
        },
      ));
    } else if (connected && registered == null) {
      return MaterialPage(child: IsRegistered(onResult: (reg) {
        setState(() {
          registered = reg;
        });
      },));
    } else if (connected && !registered!) {
      return MaterialPage(child: UserRegister(onFinish: () {
        setState(() {
          registered = true;
        });
      },));
    } else /* if (connected && registered) */ {
      return MaterialPage(
          child: NavHandler(pages: [
        UiPage(
            icon: SvgPicture.asset("assets/svg/home.svg"), page: const Home()),
        UiPage(
            icon: SvgPicture.asset("assets/svg/timetable.svg"),
            page: const TimeTable()),
        UiPage(
            icon: SvgPicture.asset("assets/svg/homework.svg"),
            page: const HomeWork())
      ]));
    }
  }

  @override
  void initState() {
    page = [getPage()];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cyrel',
      home: Navigator(
        pages: page,
        onPopPage: (route, result) {
          if (route.didPop(result)) {
            setState(() {
              page = [getPage()];
            });
            return true;
          } else {
            return false;
          }
        },
      ),
    );
  }
}

import 'package:cyrel/ui/home.dart';
import 'package:cyrel/ui/homework.dart';
import 'package:cyrel/ui/login.dart';
import 'package:cyrel/ui/navigation.dart';
import 'package:cyrel/ui/register.dart';
import 'package:cyrel/ui/timetable.dart';
import 'package:flutter/material.dart';
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
  late List<Widget> page;
  bool connected = false;
  bool? registered;
  final Container background = Container(
    color: Colors.red,
  );

  Widget getPage() {
    if (!connected) {
      return LoginPage(
        onLoginSuccess: () {
          setState(() {
            connected = true;
          });
          setPage();
        },
      );
    } else if (connected && registered == null) {
      return IsRegistered(
        onResult: (reg) {
          setState(() {
            registered = reg;
          });
          setPage();
        },
      );
    } else if (connected && !registered!) {
      return UserRegister(
        onFinish: () {
          setState(() {
            registered = true;
          });
          setPage();
        },
      );
    } else /* if (connected && registered) */ {
      return
          NavHandler(pages: [
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

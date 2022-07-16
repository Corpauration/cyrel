import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/flutter_svg.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Column(children: [
        const Spacer(
          flex: 1,
        ),
        Flexible(
          flex: 5,
          child: SvgPicture.asset("assets/svg/cyrel.svg")),
        const Spacer(
          flex: 1,
        )
      ]),
    );
  }
}
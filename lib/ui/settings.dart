import 'dart:io';
import 'dart:math';

import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final sc = ScrollController();
  bool _serviceEnabled = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      final service = FlutterBackgroundService();
      service.isRunning().then((value) => setState(() {
        _serviceEnabled = value;
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    const screenRatio = 7 / 5;
    return UiContainer(
        backgroundColor: ThemesHandler.instance.theme.background,
        child: LayoutBuilder(
          builder: (context, constraints) {
            double horizontalMargin =
                constraints.maxHeight > (screenRatio * constraints.maxWidth)
                    ? max(5, constraints.maxWidth / 48)
                    : max(20, constraints.maxWidth / 12);
            double titleWidth = max(constraints.maxWidth - 4 * 28, 1);

            return Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  BoxButton(
                      onTap: () => Navigator.of(context).pop(),
                      child: SizedBox(
                          width: 28,
                          child: SvgPicture.asset("assets/svg/cross.svg",
                              height: 20))),
                  Container(
                    width: titleWidth,
                    alignment: Alignment.center,
                    child: Text(
                      "Paramètres",
                      textAlign: TextAlign.center,
                      style: Styles().f_24,
                    ),
                  ),
                ]),
              ),
              Flexible(
                child: Container(
                    margin: EdgeInsets.fromLTRB(
                        horizontalMargin, 10, horizontalMargin, 20),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: ThemesHandler.instance.theme.card),
                    child: UiScrollBar(
                      scrollController: sc,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CheckboxListTile(
                              value: _serviceEnabled,
                              onChanged: (value) async {
                                setState(() {
                                  _serviceEnabled = value!;
                                });
                                if (Platform.isAndroid) {
                                  final service = FlutterBackgroundService();
                                  var isRunning = await service.isRunning();
                                  if (!isRunning && value!) {
                                    await service.startService();
                                  } else if(isRunning && !value!) {
                                    service.invoke("stopService");
                                  }
                                }
                              },
                              activeColor:
                                  const Color.fromARGB(255, 38, 96, 170),
                              checkColor: Colors.white,
                              tileColor:
                                  ThemesHandler.instance.theme.background,
                              checkboxShape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3))),
                              title: Text(
                                  "Notifiez quand l'emploi du temps de la semaine change",
                                  style: Styles().f_15),
                            ),
                            Visibility(
                              visible: _serviceEnabled,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "A partir d'android 12 (même avant en fonction de votre marque) il est nécessaire de désactiver l'optimisation de la batterie pour Cyrel afin que le service tourne en arrière-plan sans être tué.\n"
                                            "Pour cela, allez dans Paramètres du téléphone > Applications > Cyrel > Batterie > Non restreinte (les menus peuvent varier selon le constructeur)",
                                        textAlign: TextAlign.start,
                                        style: Styles().f_15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )),
              ),
            ]);
          },
        ));
  }
}

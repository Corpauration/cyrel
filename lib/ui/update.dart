import 'dart:math';

import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/version_entity.dart';
import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:cyrel_updater/cyrel_updater.dart';
import 'package:cyrel_updater/platform_type.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Updater extends StatefulWidget {
  const Updater({Key? key}) : super(key: key);

  @override
  State<Updater> createState() => _CheckBackendStatusState();
}

class _CheckBackendStatusState extends State<Updater> {
  late Future<VersionEntity> version;
  bool updating = false;
  double? progress;

  _check() async {
    version = Api.instance.version.getClientLastVersion();
  }

  update() async {
    VersionEntity v = await version;
    CyrelUpdater updater = CyrelUpdater();
    switch (v.platform) {
      case "android":
        setState(() {
          updating = true;
        });
        updater.update(v.url, PlatformType.android, (prog) {
          setState(() {
            progress = prog;
          });
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    _check();
    return UiContainer(
        backgroundColor: ThemesHandler.instance.theme.background,
        child: Center(
            child: FutureBuilder(
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData ||
                updating) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: UiScrollBar(
                  scrollController: null,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        updating
                            ? "Mise à jour en cours..."
                            : "Mise à jour disponible !",
                        style: Styles().f_18,
                        softWrap: true,
                      ),
                      Visibility(
                        visible: !updating,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Merci de mettre Cyrel à jour vers la version ${(snapshot.data as VersionEntity).version}",
                              style: Styles().f_15,
                              textAlign: TextAlign.center,
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: updating ? 25 : 10,
                      ),
                      Visibility(
                        visible: !updating,
                        child: UiButton(
                            onTap: update,
                            height: 50,
                            width: 200,
                            color: const Color.fromARGB(255, 38, 96, 170),
                            child: const Text(
                              "Mettre à jour",
                              style: Styles.f_18nt,
                            )),
                      ),
                      Visibility(
                        visible: updating,
                        child: LayoutBuilder(builder: (ctx, constraints) {
                          double barWidth =
                              max(constraints.maxHeight / 6, 80) * 2;
                          return SizedBox(
                              width: barWidth,
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor:
                                    const Color.fromRGBO(213, 213, 213, 1.0),
                                color: const Color.fromRGBO(55, 110, 187, 1),
                              ));
                        }),
                      )
                    ],
                  ),
                ),
              );
            } else {
              return CircularProgressIndicator(
                color: const Color.fromARGB(255, 38, 96, 170),
                backgroundColor: ThemesHandler.instance.theme.card,
                strokeWidth: 2,
              );
            }
          },
          future: version,
        )));
  }
}

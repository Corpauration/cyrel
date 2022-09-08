import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:flutter/material.dart';

class OfflinePage extends StatelessWidget {
  const OfflinePage({Key? key}) : super(key: key);

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
                  "Impossible de se connecter au serveur.",
                  style: Styles.f_18,
                  softWrap: true,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  "Il est fortement probable que votre appareil ne soit pas connecté à internet.",
                  style: Styles.f_15,
                  softWrap: true,
                ),
                const SizedBox(
                  height: 30,
                ),
                UiButton(
                    onTap: () {},
                    height: 50,
                    width: 200,
                    color: const Color.fromARGB(255, 38, 96, 170),
                    child: Text("Mode hors ligne", style: TextStyle(fontFamily: "Montserrat", fontSize: 18),))
              ],
            ),
          ),
        )));
  }
}

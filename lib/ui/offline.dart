import 'package:cyrel/api/api.dart';
import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:flutter/material.dart';

class OfflinePage extends StatelessWidget {
  const OfflinePage({Key? key, required this.onQuit, required this.offlineMode})
      : super(key: key);

  final Function() onQuit;
  final bool offlineMode;

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
                      style: Styles().f_18,
                      softWrap: true,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Il est fortement probable que votre appareil ne soit pas connecté à internet.",
                      style: Styles().f_15,
                      softWrap: true,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Visibility(
                      visible: offlineMode,
                      child: UiButton(
                          onTap: onQuit,
                      height: 50,
                      width: 200,
                      color: const Color.fromARGB(255, 38, 96, 170),
                      child: const Text(
                        "Mode hors ligne",
                        style: Styles.f_18nt,
                      )),
                )
              ],
            ),
          ),
        )));
  }
}

class CheckBackendStatus extends StatefulWidget {
  const CheckBackendStatus({Key? key, required this.onResult})
      : super(key: key);

  final Function(bool, bool) onResult;

  @override
  State<CheckBackendStatus> createState() => _CheckBackendStatusState();
}

class _CheckBackendStatusState extends State<CheckBackendStatus> {
  _check() async {
    await Api.instance.awaitInitFutures();
    bool token = await Api.instance.isTokenCached();
    try {
      await Api.instance.user.ping();
      Api.instance.isOffline = false;
      widget.onResult(true, token);
    } catch (e) {
      Api.instance.isOffline = true;
      widget.onResult(false, token);
    }
  }

  @override
  Widget build(BuildContext context) {
    _check();
    return const SplashScreen();
  }
}

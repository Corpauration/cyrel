import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/version_entity.dart';
import 'package:cyrel/constants.dart';
import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:cyrel/utils/version.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  height: 10,
                ),
                RichText(
                  textAlign: TextAlign.center,
                  softWrap: true,
                  text: TextSpan(children: [
                    TextSpan(text: "Consultez le ", style: Styles().f_13),
                    TextSpan(
                        text: "status",
                        mouseCursor: SystemMouseCursors.click,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            Uri url = statusUrl;
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                        style: Styles()
                            .f_13
                            .apply(color: Colors.blue)
                            .apply(decoration: TextDecoration.underline)),
                    TextSpan(text: " des serveurs.", style: Styles().f_13),
                  ]),
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

  final Function(bool, bool, bool) onResult;

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

      try {
        await Version.instance.init;
        if (kDebugMode) {
          print(Version.instance.toString());
          print(await Api.instance.version.getVersion());
        }
        VersionEntity version = await Api.instance.version.getClientLastVersion();
        if (version.version != "" &&
            Version.compare(version.version, Version.instance.toString()) > 0) {
          widget.onResult(true, token, true);
        } else {
          widget.onResult(true, token, false);
        }
      } catch (e) {
        widget.onResult(true, token, false);
      }
    } catch (e) {
      Api.instance.isOffline = true;
      widget.onResult(false, token, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _check();
    return const SplashScreen();
  }
}

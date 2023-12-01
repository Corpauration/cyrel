import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:cyrel/api/service.dart';
import 'package:cyrel/api/token.dart';
import 'package:cyrel/constants.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher_string.dart';

class IoAuth {
  late HttpServer server;
  String? state;
  String? codeVerifier;
  String? code;
  late Client httpClient;
  Completer<Token?> completer = Completer();
  static const serviceNotificationChannelId = 'cyrel_auth_service';
  static const serviceNotificationId = 889;

  late FlutterBackgroundService service;

  void setClient(Client client) => httpClient = client;

  startServer() async {
    if (Platform.isAndroid) {
      service = FlutterBackgroundService();

      const AndroidNotificationChannel serviceChannel = AndroidNotificationChannel(
        serviceNotificationChannelId,
        'Cyrel auth service',
        description: 'This channel is used for Cyrel auth service notification.',
        importance: Importance.low,
        showBadge: false,
      );

      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(serviceChannel);

      await service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: onStart,

          autoStart: false,
          isForegroundMode: true,
          autoStartOnBoot: false,

          notificationChannelId: serviceNotificationChannelId,
          // this must match with notification channel you created above.
          initialNotificationTitle: 'Cyrel auth service',
          initialNotificationContent: 'Waiting for login',
          foregroundServiceNotificationId: serviceNotificationId,
        ),
        iosConfiguration: IosConfiguration(),
      );

      await service.startService();

     await service.on("started").first;
      service.invoke("watch", {
        "state": state
      });

      completer.complete(service.on("result").first.then((value) async {
        code = value?["code"];
        return await resumeLogin(httpClient);
      }));
    } else {
      server = await HttpServer.bind(
          InternetAddress.loopbackIPv4, 6431); // 6: Cy, 4: r, 3: e, 1: l
      }
  }

  @pragma('vm:entry-point')
  static Future<void> onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    HttpServer server = await HttpServer.bind(
        InternetAddress.loopbackIPv4, 6431); // 6: Cy, 4: r, 3: e, 1: l

    service.on('stopService').listen((event) async {
      await server.close(force: true);
      for (ActiveNotification n
      in (await flutterLocalNotificationsPlugin.getActiveNotifications())) {
        if (n.id == serviceNotificationId &&
            n.channelId == serviceNotificationChannelId) {
          await flutterLocalNotificationsPlugin.cancel(n.id);
        }
      }
      await service.stopSelf();
    });


    service.on('watch').listen((event) async {
      String state = event?["state"];
      await for (var request in server) {
        Map<String, String> params = request.uri.queryParameters;
        if (params.containsKey("state") &&
            params.containsKey("session_state") &&
            params.containsKey("code") &&
            params["state"] == state) {
          String? code = params["code"];
          request.response
            ..headers.contentType = ContentType("text", "html", charset: "utf-8")
            ..write(
                '<div style="width: 98vw; height: 98vh; display: flex; justify-content: center; align-items: center;"><div style="font-size: 6vw; font-family: Roboto,serif;">Vous pouvez fermer cette page</div></div>')
            ..close();
          service.invoke("result", {
            "code": code
          });
        } else {
          request.response
            ..headers.contentType = ContentType("text", "plain", charset: "utf-8")
            ..write('Requête invalide')
            ..close();
        }
      }
    });

    print("Service started");
    service.invoke("started");
  }

  watchRequest() async {
    await for (var request in server) {
      Map<String, String> params = request.uri.queryParameters;
      if (params.containsKey("state") &&
          params.containsKey("session_state") &&
          params.containsKey("code") &&
          params["state"] == state) {
        code = params["code"];
        request.response
          ..headers.contentType = ContentType("text", "html", charset: "utf-8")
          ..write(
              '<div style="width: 98vw; height: 98vh; display: flex; justify-content: center; align-items: center;"><div style="font-size: 6vw; font-family: Roboto,serif;">Vous pouvez fermer cette page</div></div>')
          ..close();
        completer.complete(await resumeLogin(httpClient));
      } else {
        request.response
          ..headers.contentType = ContentType("text", "plain", charset: "utf-8")
          ..write('Requête invalide')
          ..close();
      }
    }
  }

  close() async {
    if (Platform.isAndroid) {
      service.invoke("stopService");
      while (await service.isRunning()) {}
      initializeService();
    } else {
      await server.close(force: true);
    }
  }

  void reset() {
    state = null;
    codeVerifier = null;
    code = null;
  }

  static Future<Token?> login(Client httpClient) async {
    if (instance.state != null) return null;
    instance.setClient(httpClient);
    final random = Random.secure();
    instance.state = base64UrlEncode(
        utf8.encode((random.nextDouble() * random.nextDouble()).toString()));
    await instance.startServer();
    if (!Platform.isAndroid) {
      instance.watchRequest();
    }
    instance.codeVerifier =
        base64UrlEncode(List.generate(96, (_) => random.nextInt(256)))
            .split('=')[0];
    String codeChallenge = base64UrlEncode(
            sha256.convert(ascii.encode(instance.codeVerifier!)).bytes)
        .split('=')[0];
    launchUrlString(
        "$baseRealm/auth?response_type=code&client_id=$clientId&state=${instance.state}&redirect_uri=${Uri.encodeQueryComponent("http://localhost:6431/")}&scope=openid%20profile%20email%20offline_access&code_challenge=$codeChallenge&code_challenge_method=S256&nonce=${instance.state}");
    return instance.completer.future;
  }

  static Future<Token?> resumeLogin(Client httpClient) async {
    if (instance.code != null) {
      instance.completer = Completer();
      Response response = await httpClient.post(Uri.parse("$baseRealm/token"),
          body: _buildQuery({
            "client_id": clientId,
            "grant_type": "authorization_code",
            "state": instance.state!,
            "code": instance.code!,
            "code_verifier": instance.codeVerifier!,
            "redirect_uri": "http://localhost:6431/"
          }),
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            "Accept": "application/json"
          });
      await instance.close();
      instance.reset();
      if (response.statusCode != 200) {
        return null;
      }
      Map<String, dynamic> json = jsonDecode(response.body);
      return Token.fromJsonLegacy(json);
    }
    return null;
  }

  static String _buildQuery(Map<String, String> params) {
    List<String> list = List.empty(growable: true);
    params.forEach((key, value) {
      list.add(
          "${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(value)}");
    });
    return list.join("&");
  }

  static IoAuth instance = IoAuth();
}

// this will be used as notification channel id

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/base_entity.dart';
import 'package:cyrel/api/course_alert_entity.dart';
import 'package:cyrel/api/course_entity.dart';
import 'package:cyrel/api/group_entity.dart';
import 'package:cyrel/api/user_entity.dart';
import 'package:cyrel/cache/cache.dart';
import 'package:cyrel/cache/fs/fs.dart';
import 'package:cyrel/cache/fs/fs_io.dart';
import 'package:cyrel/cache/fs/fs_ram.dart';
import 'package:cyrel/utils/date.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const serviceNotificationChannelId = 'cyrel_service';
const serviceNotificationId = 888;
const alertScheduleNotificationChannelId = 'cyrel_alert_schedule';

int inc = 0;

Future<void> initializeService() async {
  if (!Platform.isAndroid) return;

  final service = FlutterBackgroundService();

  const AndroidNotificationChannel serviceChannel = AndroidNotificationChannel(
    serviceNotificationChannelId, // id
    'Cyrel service', // title
    description: 'This channel is used for Cyrel service notification.',
    // description
    importance: Importance.low,
    // importance must be at low or higher level
    showBadge: false,
  );

  const AndroidNotificationChannel alertScheduleChannel =
      AndroidNotificationChannel(
    alertScheduleNotificationChannelId, // id
    'Alertes changement edt', // title
    description:
        "Canal de notifications pour les alertes liées au changement d'emploi du temps", // description
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(serviceChannel);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(alertScheduleChannel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
      autoStartOnBoot: true,

      notificationChannelId: serviceNotificationChannelId,
      // this must match with notification channel you created above.
      initialNotificationTitle: 'Cyrel service',
      initialNotificationContent: 'Starting...',
      foregroundServiceNotificationId: serviceNotificationId,
    ),
    iosConfiguration: IosConfiguration(),
  );
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  service.on('stopService').listen((event) async {
    service.stopSelf();
    for(ActiveNotification n in (await flutterLocalNotificationsPlugin.getActiveNotifications())) {
      if (n.id == serviceNotificationId && n.channelId == serviceNotificationChannelId) {
        await flutterLocalNotificationsPlugin.cancel(n.id);
      }
    }
  });

  CacheManager cache = CacheManager("service");
  await cache.mount(RamFileSystem(), FileSystemPriority.both);
  await cache.syncThenMount(IOFileSystem(), FileSystemPriority.write);

  await _mainLogic(flutterLocalNotificationsPlugin, service, cache);
  Timer.periodic(const Duration(hours: 2), (timer) async {
    await _mainLogic(flutterLocalNotificationsPlugin, service, cache);
  });
}

Future<void> _mainLogic(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    ServiceInstance service,
    CacheManager cache) async {
  if (service is AndroidServiceInstance) {
    if (await service.isForegroundService()) {
      try {
        await _updateAlertSchedule(service, flutterLocalNotificationsPlugin, cache);
      } catch(e) {
        // Ignored
      }
      flutterLocalNotificationsPlugin.show(
        serviceNotificationId,
        'Cyrel service',
        'Dernière actualisation à ${DateTime.now().toHourString()}',
        NotificationDetails(
          android: AndroidNotificationDetails(
              serviceNotificationChannelId, 'Cyrel service',
              icon: "ic_bg_service_small",
              ongoing: true,
              color: const Color.fromARGB(255, 38, 96, 170),
              priority: Priority.min,
              channelShowBadge: false,
              enableVibration: false,
              playSound: false,
              showWhen: false,
              additionalFlags: Int32List.fromList([64]),
              category: AndroidNotificationCategory.service),
        ),
      );
    }
  }
}

Future<void> _updateAlertSchedule(
    ServiceInstance service,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    CacheManager cache) async {
  Api.instance = Api();
  await Api.instance.awaitInitFutures();
  if (Api.instance.isOffline) {
    return;
  }
  bool logged = await Api.instance.isTokenCached();
  if (!logged) {
    final s = FlutterBackgroundService();
    var isRunning = await s.isRunning();
    if (isRunning) {
      service.stopSelf();
      for(ActiveNotification n in (await flutterLocalNotificationsPlugin.getActiveNotifications())) {
        if (n.id == serviceNotificationId && n.channelId == serviceNotificationChannelId) {
          await flutterLocalNotificationsPlugin.cancel(n.id);
        }
      }
    }
    return;
  }

  UserEntity me = await Api.instance.user.getMe();

  if (me.type != UserType.student) {
    return;
  }

  StringEntity? last =
      await cache.get<StringEntity>("alert_schedule", evenIfExpired: true);
  Week weekNow = Week();

  DateTime date;
  if (last == null || !weekNow.belong(DateTime.parse(last.toString()))) {
    date = weekNow.begin;
  } else {
    date = DateTime.parse(last.toString());
  }

  GroupEntity group;
  try {
    group = (await Api.instance.groups.getMyGroups())
        .where((element) => element.referent != null)
        .first;
  } catch (e) {
    group = (await Api.instance.groups.getMyGroups()).first;
  }

  List<CourseAlertEntity> alerts =
      await Api.instance.courseAlert.get(group, time: date);
  alerts.sort((a, b) => a.time.compareTo(b.time));

  if (alerts.isEmpty) return;

  for (CourseAlertEntity ca in alerts) {
    CourseEntity course = await Api.instance.schedule.get(ca.id);

    String title;
    String description;

    switch (ca.event) {
      case CourseAlertEvent.ADDED:
        title = "ajouté";
        description =
            "${course.subject != null ? course.subject! : course.category.name} ajouté le ${course.start.toDayString()} à ${course.start.toHourString()}";
        break;
      case CourseAlertEvent.DELETED:
        title = "supprimé";
        description =
            "${course.subject != null ? course.subject! : course.category.name} du ${course.start.toDayString()} à ${course.start.toHourString()} supprimé";
        break;
      case CourseAlertEvent.MODIFIED:
        title = "modifié";
        description =
            "${course.subject != null ? course.subject! : course.category.name} déplacé le ${course.start.toDayString()} à ${course.start.toHourString()}";
        break;
    }

    flutterLocalNotificationsPlugin.show(
      inc++,
      'Cours $title',
      description,
      const NotificationDetails(
        android: AndroidNotificationDetails(
            alertScheduleNotificationChannelId, 'Alertes changement edt',
            icon: "ic_bg_service_small",
            color: Color.fromARGB(255, 38, 96, 170),
            category: AndroidNotificationCategory.event),
      ),
    );
  }

  await cache.save(
      "alert_schedule",
      StringEntity.fromString(
          alerts.last.time.add(const Duration(minutes: 10)).toString()));
}

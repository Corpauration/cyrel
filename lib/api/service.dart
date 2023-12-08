import 'dart:async';
import 'dart:io';
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
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

const alertScheduleNotificationChannelId = 'cyrel_alert_schedule';

int inc = (((DateTime.now().millisecondsSinceEpoch / 60000)) % 1080).toInt();

Future<void> initializeService() async {
  if (kIsWeb || !Platform.isAndroid) return;

  await Workmanager().initialize(onStart, isInDebugMode: kDebugMode);

  CacheManager cache = CacheManager("service");
  await cache.mount(IOFileSystem(), FileSystemPriority.both);

  try {
    if (!((await cache.get<BoolEntity>("enabled", evenIfExpired: true))
            ?.toBool() ??
        true)) return;
  } catch (e) {}

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
      ?.createNotificationChannel(alertScheduleChannel);
}

@pragma('vm:entry-point')
Future<void> onStart() async {
  Workmanager().executeTask((task, inputData) async {
    print(
        "Native called background task: $task"); //simpleTask will be emitted here.
    CacheManager cache = CacheManager("service");
    await cache.mount(RamFileSystem(), FileSystemPriority.both);
    await cache.syncThenMount(IOFileSystem(), FileSystemPriority.write);

    await Api.instance.awaitInitFutures();

    Future<bool> res;

    if (task == "courseAlertTask") {
      res = _Tasks.courseAlertTask(cache);
    } else {
      res = Future.value(true);
    }

    try {
      Api.instance.killLoop();
    } catch (e) {}

    return res;
  });
}

class Service {
  static launchCourseAlertTask() async {
    await Workmanager().registerPeriodicTask(
        "courseAlertTask", "courseAlertTask",
        frequency: const Duration(hours: 2),
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingWorkPolicy.keep);
  }

  static stopCourseAlertTask() async {
    await Workmanager().cancelByUniqueName("courseAlertTask");
  }

  static cancelAllTasks() async {
    if (kIsWeb || !Platform.isAndroid) return;
    await Workmanager().cancelAll();
  }
}

class _Tasks {
  static Future<bool> courseAlertTask(CacheManager serviceCache) async {
    if (!((await serviceCache.get<BoolEntity>("enabled", evenIfExpired: true))
            ?.toBool() ??
        true)) {
      await Workmanager().cancelByUniqueName("courseAlertTask");
      return true;
    }

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    try {
      if (!await _updateAlertSchedule(
          flutterLocalNotificationsPlugin, serviceCache)) {
        await Workmanager().cancelByUniqueName("courseAlertTask");
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return true;
  }
}

Future<bool> _updateAlertSchedule(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    CacheManager cache) async {
  if (Api.instance.isOffline) {
    return true;
  }
  bool logged = await Api.instance.isTokenCached();
  if (!logged) {
    return false;
  }

  UserEntity me = await Api.instance.user.getMe();

  if (me.type != UserType.student) {
    return false;
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

  if (alerts.isEmpty) return true;

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

  return true;
}

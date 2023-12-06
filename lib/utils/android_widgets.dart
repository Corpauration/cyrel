import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/course_entity.dart';
import 'package:cyrel/api/group_entity.dart';
import 'package:cyrel/api/user_entity.dart';
import 'package:cyrel/utils/date.dart';
import 'package:cyrel/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@pragma('vm:entry-point')
Future<void> widgetEntrypoint(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  const MethodChannel channel = MethodChannel(
    'id.flutter/cyrel_widgets',
    JSONMethodCodec(),
  );

  Api.instance = Api();

  await Api.instance.awaitInitFutures();

  bool logged = await Api.instance.isTokenCached();
  if (!logged) {
    Api.instance.killLoop();
    return await channel.invokeMethod('notConnected');
  }

  UserEntity me;
  try {
    me = await Api.instance.user.getMe();
  } catch (e) {
    Api.instance.killLoop();
    return await channel.invokeMethod('offline');
  }

  Week week = Week();
  DateTime now = DateTime.now();
  List<CourseEntity> courses = List.empty();

  if (me.type == UserType.student) {
    courses = await Api.instance.schedule.getFromTo(
        GroupEntity(int.parse(me.tags["group"]!), "", null, null, false, {}),
        week.begin,
        week.end);
  } else {
    List<String> professors =
        await Api.instance.schedule.getScheduleProfessors();
    Iterable<String> match = professors.where((element) {
      String r =
          "${me.lastname.replaceAll(" ", " *").toUpperCase()} ${me.firstname.replaceAll(" ", " *").toUpperCase()}";
      return RegExp(r.replaceAllCapitalizedAccent()).hasMatch(element);
    });
    if (match.isNotEmpty) {
      courses = await Api.instance.schedule
          .getProfessorScheduleFromTo(match.first, week.begin, week.end);
    }
  }

  if (courses.isEmpty && Api.instance.isOffline) {
    Api.instance.killLoop();
    return await channel.invokeMethod('offline');
  }

  courses =
      courses.where((element) => element.start.isTheSameDate(now)).toList();

  courses.sort((a, b) => a.start.compareTo(b.start));
  await channel.invokeMethod(
      'setCourses',
      courses.map((e) {
        if (e.teachers.isEmpty) {
          e.teachers.add("Pas de professeur indiqué");
        }
        if (e.rooms.isEmpty) {
          e.rooms.add("Pas de salle indiquée");
        }
        e.subject ??= e.category.name;
        var map = e.toMap();
        map["start_t"] = DateTime.parse(map["start"]).millisecondsSinceEpoch;
        map["end_t"] = DateTime.tryParse(map["end"])?.millisecondsSinceEpoch;
        return map;
      }).toList());

  Api.instance.killLoop();
}

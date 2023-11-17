import 'package:cyrel/api/base_entity.dart';

import 'group_entity.dart';

enum CourseAlertEvent { ADDED, DELETED, MODIFIED }

class CourseAlertEntity extends BaseEntity {
  String id = "";
  GroupEntity group = GroupEntity(-100, "", null, null, false, {});
  DateTime time = DateTime.now();
  CourseAlertEvent event = CourseAlertEvent.MODIFIED;

  CourseAlertEntity(
      {required this.id,
      required this.group,
      required this.time,
      required this.event});

  CourseAlertEntity.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        group = GroupEntity(json["group"], "", null, null, false, {}),
        time = DateTime.parse((json["time"] as String).replaceAll("T", " ")),
        event = CourseAlertEvent.values[json["event"]];

  @override
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "group": group.id,
      "time": time.toString(),
      "event": event.index
    };
  }
}

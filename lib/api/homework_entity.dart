import 'dart:core';

import 'package:cyrel/api/base_entity.dart';
import 'package:cyrel/api/group_entity.dart';

enum HomeworkType { dm, exo, ds }

class HomeworkEntity extends BaseEntity {
  String id = "";
  String title = "";
  String content = "";
  DateTime date = DateTime.now();
  HomeworkType type = HomeworkType.exo;
  GroupEntity group;

  HomeworkEntity(
      {required this.title,
      required this.content,
      required this.date,
      required this.type,
      required this.group});

  HomeworkEntity.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        title = json["title"],
        content = json["content"],
        date = DateTime.parse(json["date"]).add(const Duration(hours: 1)),
        type = HomeworkType.values[json["type"]],
        group = GroupEntity.fromJson(json["group"]);

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toString().split(" ")[0],
      'type': type.index,
      'group': group.id,
    };
  }
}

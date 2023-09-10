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
  DateTime last_modified_at = DateTime.now();
  DateTime created_at = DateTime.now();

  HomeworkEntity(
      {this.id = "",
      required this.title,
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
        group = GroupEntity.fromJson(json["group"]),
        last_modified_at = DateTime.parse(json["last_modified_at"]),
        created_at = DateTime.parse(json["created_at"]);

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toString().split(" ")[0],
      'type': type.index,
      'group': group.toMap(),
      'last_modified_at': last_modified_at.toString(),
      'created_at': created_at.toString(),
    };
  }
}

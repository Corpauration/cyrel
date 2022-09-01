import 'dart:core';

enum HomeworkType { dm, exo, ds }

class HomeworkEntity {
  String id = "";
  String title = "";
  String content = "";
  DateTime date = DateTime.now();
  HomeworkType type = HomeworkType.exo;

  HomeworkEntity(this.title, this.content, this.date, this.type);

  HomeworkEntity.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        title = json["title"],
        content = json["content"],
        date = DateTime.parse(json["date"]).add(const Duration(hours: 1)),
        type = HomeworkType.values[json["type"]];
}

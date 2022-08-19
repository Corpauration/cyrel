import 'dart:core';

enum HomeworkLevel { normal, info, warning, important }

enum HomeworkType { dm, exo, ds }

class HomeworkEntity {
  String title = "";
  String content = "";
  DateTime date = DateTime.now();
  HomeworkLevel level = HomeworkLevel.normal;
  HomeworkType type = HomeworkType.exo;

  HomeworkEntity(this.title, this.content, this.date, this.level, this.type);
}

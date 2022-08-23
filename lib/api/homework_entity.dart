import 'dart:core';

enum HomeworkType { dm, exo, ds }

class HomeworkEntity {
  String title = "";
  String content = "";
  DateTime date = DateTime.now();
  HomeworkType type = HomeworkType.exo;

  HomeworkEntity(this.title, this.content, this.date, this.type);
}

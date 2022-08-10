import 'dart:core';

enum HomeworkLevel { normal, info, warning, important }

enum HomeworkType { dm, exo, ds }

class HomeWork {
  String title = "";
  String content = "";
  DateTime date = DateTime.now();
  HomeworkLevel level = HomeworkLevel.normal;
  HomeworkType type = HomeworkType.exo;

  HomeWork(this.title, this.content, this.date, this.level, this.type);
}

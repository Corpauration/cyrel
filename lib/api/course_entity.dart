enum CourseCategory { DEFAULT, cm }

class CourseEntity {
  String id = "";
  DateTime start = DateTime.now();
  DateTime? end;
  CourseCategory category = CourseCategory.DEFAULT;
  String? subject;
  List<String> teachers = List.empty();
  List<String> rooms = List.empty();

  CourseEntity(
      {required this.id,
      required this.start,
      required this.end,
      required this.category,
      required this.subject,
      required this.teachers,
      required this.rooms});

  CourseEntity.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        start = DateTime.parse(json["start"]),
        end = DateTime.tryParse(json["end"]),
        category = CourseCategory.values[json["content"]],
        subject = json["subject"],
        teachers = json["teachers"],
        rooms = json["rooms"];
}

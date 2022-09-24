import 'package:cyrel/api/base_entity.dart';

enum CourseCategory {
  DEFAULT,
  cm,
  td,
  accueil,
  examens,
  indisponibilite,
  reunions,
  manifestation,
  projetEncadreTutore
}

class CourseEntity extends BaseEntity {
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
        start = DateTime.parse((json["start"] as String).replaceAll("T", " ")),
        end = DateTime.tryParse((json["end"] as String).replaceAll("T", " ")),
        category = CourseCategory.values[json["category"]],
        subject = json["subject"],
        teachers = (json["teachers"] as String).split(","),
        rooms = (json["rooms"] as String).split(",");

  @override
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "start": start.toString(),
      "end": end.toString(),
      "category": category.index,
      "subject": subject,
      "teachers": teachers.join(","),
      "rooms": rooms.join(",")
    };
  }
}
